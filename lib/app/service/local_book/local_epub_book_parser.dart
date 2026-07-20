import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html_parser;
import 'package:path/path.dart' as p;
import 'package:xml/xml.dart';
import '../../l10n/generated/l10n.dart';

import 'local_book_constants.dart';
import 'local_text_book_parser.dart';
import 'models/parsed_local_book.dart';
import 'models/parsed_local_chapter.dart';

class LocalEpubBookParser {
  static const int _maxArchiveEntries = 10000;
  static const int _maxExpandedBytes = 512 * 1024 * 1024;

  Future<ParsedLocalBook> parseFile({
    required String filePath,
    required String fallbackTitle,
  }) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw LocalBookParseException(S.current.epubFileNotFound);
    }
    final archive = ZipDecoder().decodeBytes(await file.readAsBytes());
    if (archive.files.length > _maxArchiveEntries ||
        archive.files.fold<int>(0, (sum, entry) => sum + entry.size) >
            _maxExpandedBytes) {
      throw LocalBookParseException(S.current.epubExpandedTooLarge);
    }
    final entries = <String, ArchiveFile>{};
    for (final entry in archive.files) {
      if (entry.isFile) entries[_normalizeArchivePath(entry.name)] = entry;
    }
    final container = _readText(entries, 'META-INF/container.xml');
    final containerXml = XmlDocument.parse(container);
    final rootFile = containerXml
        .findAllElements('rootfile')
        .map((node) => node.getAttribute('full-path'))
        .whereType<String>()
        .firstOrNull;
    if (rootFile == null) {
      throw LocalBookParseException(S.current.epubManifestMissing);
    }

    final opfPath = _normalizeArchivePath(rootFile);
    final opfDir = p.posix.dirname(opfPath);
    final package = XmlDocument.parse(_readText(entries, opfPath));
    final manifest = <String, _ManifestItem>{};
    for (final item in package.findAllElements('item')) {
      final id = item.getAttribute('id');
      final href = item.getAttribute('href');
      if (id == null || href == null) continue;
      manifest[id] = _ManifestItem(
        path: _resolveArchivePath(opfDir, href),
        mediaType: item.getAttribute('media-type') ?? '',
        properties: item.getAttribute('properties') ?? '',
      );
    }
    final title = _metadataText(package, 'title')?.trim();
    final author = _metadataText(package, 'creator')?.trim();
    final intro = _metadataText(package, 'description')?.trim();
    final resourceDir = Directory(p.join(file.parent.path, 'resources'));
    await resourceDir.create(recursive: true);

    final extracted = <String, String>{};
    for (final item in manifest.values.where((item) =>
        item.mediaType.startsWith('image/') &&
        entries.containsKey(item.path))) {
      final safeName = '${extracted.length}_${p.posix.basename(item.path)}';
      final output = File(p.join(resourceDir.path, safeName));
      await output.writeAsBytes(entries[item.path]!.content as List<int>);
      extracted[item.path] = output.uri.toString();
    }

    final navigationTitles = _navigationTitles(entries, manifest);
    final chapters = <ParsedLocalChapter>[];
    for (final itemRef in package.findAllElements('itemref')) {
      final idRef = itemRef.getAttribute('idref');
      final item = idRef == null ? null : manifest[idRef];
      if (item == null || !entries.containsKey(item.path)) continue;
      final document = html_parser.parse(_readText(entries, item.path));
      final content = _sanitizeDocument(
        document,
        chapterPath: item.path,
        extractedResources: extracted,
      );
      if (content.trim().isEmpty) continue;
      final chapterTitle = navigationTitles[item.path] ??
          document.querySelector('h1, h2, title')?.text.trim();
      chapters.add(ParsedLocalChapter(
        index: chapters.length,
        name: chapterTitle?.isNotEmpty == true
            ? chapterTitle!
            : S.current.chapterNumber(chapters.length + 1),
        startOffset: 0,
        endOffset: 0,
        contentCharLength: content.length,
        content: content,
      ));
    }
    if (chapters.isEmpty) {
      throw LocalBookParseException(S.current.epubNoReadableChapters);
    }

    String? coverPath;
    final coverItem = manifest.values.cast<_ManifestItem?>().firstWhere(
          (item) => item?.properties.split(' ').contains('cover-image') == true,
          orElse: () => null,
        );
    if (coverItem != null) coverPath = extracted[coverItem.path];
    return ParsedLocalBook(
      title: title?.isNotEmpty == true ? title! : fallbackTitle,
      author: author?.isNotEmpty == true ? author : null,
      charset: 'utf-8',
      chapters: chapters,
      intro: intro?.isNotEmpty == true ? intro : null,
      coverPath: coverPath,
      format: LocalBookConstants.epubFormat,
    );
  }

  Map<String, String> _navigationTitles(
    Map<String, ArchiveFile> entries,
    Map<String, _ManifestItem> manifest,
  ) {
    final result = <String, String>{};
    for (final nav in manifest.values.where(
      (item) => item.properties.split(' ').contains('nav'),
    )) {
      final entry = entries[nav.path];
      if (entry == null) continue;
      final document =
          html_parser.parse(utf8.decode(entry.content as List<int>));
      for (final anchor in document.querySelectorAll('nav a[href]')) {
        final href = anchor.attributes['href'];
        if (href == null) continue;
        final path = _resolveArchivePath(p.posix.dirname(nav.path), href);
        final label = anchor.text.trim();
        if (label.isNotEmpty) result.putIfAbsent(path, () => label);
      }
    }
    return result;
  }

  String _sanitizeDocument(
    dom.Document document, {
    required String chapterPath,
    required Map<String, String> extractedResources,
  }) {
    document
        .querySelectorAll('script, style, noscript, iframe')
        .forEach((e) => e.remove());
    final buffer = StringBuffer();
    void visit(dom.Node node) {
      if (node is dom.Text) {
        buffer.write(node.data.replaceAll(RegExp(r'\s+'), ' '));
      } else if (node is dom.Element) {
        if (node.localName == 'img') {
          final src = node.attributes['src'];
          if (src != null) {
            final resolved =
                _resolveArchivePath(p.posix.dirname(chapterPath), src);
            final localUri = extractedResources[resolved];
            if (localUri != null) {
              buffer.write('\n<img src="$localUri">\n');
            }
          }
          return;
        }
        final block = const {
          'p',
          'div',
          'section',
          'article',
          'li',
          'br',
          'h1',
          'h2',
          'h3',
          'blockquote'
        }.contains(node.localName);
        if (block) buffer.write('\n');
        for (final child in node.nodes) {
          visit(child);
        }
        if (block) buffer.write('\n');
      }
    }

    visit(document.body ?? document.documentElement!);
    return buffer
        .toString()
        .replaceAll(RegExp(r' *\n *'), '\n')
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')
        .trim();
  }

  String? _metadataText(XmlDocument document, String localName) =>
      document.descendants
          .whereType<XmlElement>()
          .where((element) => element.name.local == localName)
          .map((element) => element.innerText)
          .firstOrNull;

  String _readText(Map<String, ArchiveFile> entries, String path) {
    final entry = entries[_normalizeArchivePath(path)];
    if (entry == null) {
      throw LocalBookParseException(S.current.epubResourceMissing(path));
    }
    return utf8.decode(entry.content as List<int>, allowMalformed: true);
  }

  String _resolveArchivePath(String base, String href) {
    final cleanHref =
        Uri.decodeComponent(href.split('#').first.split('?').first);
    return _normalizeArchivePath(p.posix.join(base, cleanHref));
  }

  String _normalizeArchivePath(String path) {
    final normalized = p.posix.normalize(path.replaceAll('\\', '/'));
    if (normalized == '..' ||
        normalized.startsWith('../') ||
        p.posix.isAbsolute(normalized)) {
      throw LocalBookParseException(S.current.epubUnsafeResourcePath);
    }
    return normalized;
  }
}

class _ManifestItem {
  const _ManifestItem(
      {required this.path, required this.mediaType, required this.properties});
  final String path;
  final String mediaType;
  final String properties;
}
