import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:math' as math;

import 'models/parsed_local_book.dart';
import 'models/parsed_local_chapter.dart';

class LocalBookParseException implements Exception {
  const LocalBookParseException(this.message);

  final String message;

  @override
  String toString() => message;
}

class LocalTextBookParser {
  static const int _minChapterTitleHits = 2;
  static const int _virtualChapterTargetBytes = 10 * 1024;
  static const int _scanBufferBytes = 512 * 1024;
  static const int _maxChapterTitleBytes = 512;
  static const int _maxChapterTitleLength = 80;
  static const int _lineFeedByte = 0x0A;
  static const int _carriageReturnByte = 0x0D;
  static const int _utf8BomLength = 3;

  static final RegExp _chapterTitlePattern = RegExp(
    r'^\s*(第[一二三四五六七八九十百千万零〇两\d]+[章节回卷集部].*|Chapter\s+\d+.*|正文|楔子|序章|尾声|番外.*)\s*$',
    caseSensitive: false,
  );

  Future<ParsedLocalBook> parseFile({
    required String filePath,
    required String fallbackTitle,
  }) {
    return Isolate.run(
      () => _parseFileSync(
        filePath: filePath,
        fallbackTitle: fallbackTitle,
      ),
    );
  }

  static ParsedLocalBook _parseFileSync({
    required String filePath,
    required String fallbackTitle,
  }) {
    final file = File(filePath);
    if (!file.existsSync()) {
      throw const LocalBookParseException('文件不存在，请重新选择');
    }

    final stat = file.statSync();
    if (stat.size <= 0) {
      throw const LocalBookParseException('文件内容为空，无法导入');
    }

    final scan = _scanUtf8Lines(file);
    if (!scan.hasReadableText) {
      throw const LocalBookParseException('未解析到可阅读内容');
    }

    final title = _normalizeTitle(fallbackTitle);
    final chapters = scan.titleLines.length >= _minChapterTitleHits
        ? _parseTitledChapters(scan)
        : _parseVirtualChapters(file);
    if (chapters.isEmpty) {
      throw const LocalBookParseException('未解析到可阅读内容');
    }

    return ParsedLocalBook(
      title: title,
      author: null,
      charset: 'utf-8',
      chapters: chapters,
    );
  }

  static _LineScanResult _scanUtf8Lines(File file) {
    final titleLines = <_ChapterTitleLine>[];
    var hasReadableText = false;

    final raf = file.openSync(mode: FileMode.read);
    try {
      final fileLength = raf.lengthSync();
      final startsWithBom = _consumeUtf8BomIfPresent(raf, fileLength);
      var lineStart = startsWithBom ? _utf8BomLength : 0;
      var lineBytes = <int>[];
      var lineTooLongForTitle = false;
      var lineHasNonWhitespace = false;
      var prefaceHasNonWhitespace = false;
      var bodyHasNonWhitespace = false;
      var activeTitleIndex = -1;
      final utf8Validator = _Utf8Validator();

      void handleLine({
        required int lineEnd,
        required int bodyStart,
      }) {
        final titleLine = _inspectLine(
          lineBytes: lineBytes,
          lineTooLongForTitle: lineTooLongForTitle,
          lineStart: lineStart,
          lineEnd: lineEnd,
          bodyStart: bodyStart,
        );
        if (titleLine == null) {
          if (lineHasNonWhitespace) {
            bodyHasNonWhitespace = true;
          }
          return;
        }

        if (activeTitleIndex >= 0) {
          titleLines[activeTitleIndex].bodyHasNonWhitespace =
              bodyHasNonWhitespace;
        } else {
          prefaceHasNonWhitespace = bodyHasNonWhitespace;
        }
        titleLines.add(titleLine);
        activeTitleIndex = titleLines.length - 1;
        bodyHasNonWhitespace = false;
      }

      while (true) {
        final chunkStart = raf.positionSync();
        final chunk = raf.readSync(_scanBufferBytes);
        if (chunk.isEmpty) break;

        for (var i = 0; i < chunk.length; i++) {
          final byte = chunk[i];
          final position = chunkStart + i;
          utf8Validator.accept(byte);

          if (byte == _lineFeedByte) {
            handleLine(lineEnd: position, bodyStart: position + 1);
            lineBytes = <int>[];
            lineTooLongForTitle = false;
            lineHasNonWhitespace = false;
            lineStart = position + 1;
            continue;
          }

          if (byte > 0x20) {
            hasReadableText = true;
            lineHasNonWhitespace = true;
          }
          if (!lineTooLongForTitle) {
            if (lineBytes.length < _maxChapterTitleBytes) {
              lineBytes.add(byte);
            } else {
              lineTooLongForTitle = true;
              lineBytes = <int>[];
            }
          }
        }
      }

      utf8Validator.finish();
      if (lineBytes.isNotEmpty || lineStart < fileLength) {
        handleLine(lineEnd: fileLength, bodyStart: fileLength);
      }
      if (activeTitleIndex >= 0) {
        titleLines[activeTitleIndex].bodyHasNonWhitespace =
            bodyHasNonWhitespace;
      } else {
        prefaceHasNonWhitespace = bodyHasNonWhitespace;
      }

      return _LineScanResult(
        fileLength: fileLength,
        contentStart: startsWithBom ? _utf8BomLength : 0,
        prefaceHasNonWhitespace: prefaceHasNonWhitespace,
        titleLines: titleLines,
        hasReadableText: hasReadableText,
      );
    } finally {
      raf.closeSync();
    }
  }

  static bool _consumeUtf8BomIfPresent(RandomAccessFile raf, int fileLength) {
    if (fileLength < _utf8BomLength) {
      raf.setPositionSync(0);
      return false;
    }

    final firstBytes = raf.readSync(_utf8BomLength);
    final hasBom = firstBytes.length == _utf8BomLength &&
        firstBytes[0] == 0xEF &&
        firstBytes[1] == 0xBB &&
        firstBytes[2] == 0xBF;
    raf.setPositionSync(hasBom ? _utf8BomLength : 0);
    return hasBom;
  }

  static _ChapterTitleLine? _inspectLine({
    required List<int> lineBytes,
    required bool lineTooLongForTitle,
    required int lineStart,
    required int lineEnd,
    required int bodyStart,
  }) {
    if (lineTooLongForTitle) return null;
    final trimmedLine = _decodeUtf8Line(lineBytes).trim();
    if (_isChapterTitle(trimmedLine)) {
      return _ChapterTitleLine(
        title: trimmedLine,
        lineStart: lineStart,
        lineEnd: _trimTrailingCr(lineBytes, lineEnd),
        bodyStart: bodyStart,
      );
    }
    return null;
  }

  static String _decodeUtf8Line(List<int> bytes) {
    if (bytes.isEmpty) return '';
    try {
      return const Utf8Decoder(allowMalformed: false).convert(bytes);
    } on FormatException {
      throw const LocalBookParseException(
        '文件编码暂不支持，请转换为 UTF-8 后重试',
      );
    }
  }

  static int _trimTrailingCr(List<int> lineBytes, int lineEnd) {
    if (lineBytes.isNotEmpty && lineBytes.last == _carriageReturnByte) {
      return math.max(0, lineEnd - 1);
    }
    return lineEnd;
  }

  static String _normalizeTitle(String fallbackTitle) {
    final trimmed = fallbackTitle.trim();
    if (trimmed.isEmpty) return '未命名本地书籍';
    return trimmed;
  }

  static bool _isChapterTitle(String line) {
    if (line.isEmpty || line.length > _maxChapterTitleLength) return false;
    return _chapterTitlePattern.hasMatch(line);
  }

  static List<ParsedLocalChapter> _parseTitledChapters(_LineScanResult scan) {
    final chapters = <ParsedLocalChapter>[];
    final usedChapterNames = <String>{};
    if (scan.prefaceHasNonWhitespace) {
      _addChapter(
        chapters,
        usedChapterNames: usedChapterNames,
        name: '序章',
        startOffset: scan.contentStart,
        endOffset: scan.titleLines.first.lineStart,
      );
    }

    for (var i = 0; i < scan.titleLines.length; i++) {
      final current = scan.titleLines[i];
      final nextStart = i + 1 < scan.titleLines.length
          ? scan.titleLines[i + 1].lineStart
          : scan.fileLength;
      final bodyStart = current.bodyStart.clamp(0, scan.fileLength).toInt();
      final bodyEnd = nextStart.clamp(bodyStart, scan.fileLength).toInt();
      final hasBody = current.bodyHasNonWhitespace && bodyStart < bodyEnd;
      _addChapter(
        chapters,
        usedChapterNames: usedChapterNames,
        name: current.title,
        startOffset: bodyStart,
        endOffset: hasBody ? bodyEnd : bodyStart,
        allowEmpty: true,
      );
    }

    return chapters;
  }

  static List<ParsedLocalChapter> _parseVirtualChapters(File file) {
    final chapters = <ParsedLocalChapter>[];
    final usedChapterNames = <String>{};

    final raf = file.openSync(mode: FileMode.read);
    try {
      final fileLength = raf.lengthSync();
      final startsWithBom = _consumeUtf8BomIfPresent(raf, fileLength);
      final contentStart = startsWithBom ? _utf8BomLength : 0;
      var offset = contentStart;
      while (offset < fileLength) {
        final end = _findVirtualChapterEnd(raf, offset, fileLength);
        if (offset < end) {
          _addChapter(
            chapters,
            usedChapterNames: usedChapterNames,
            name: '第${chapters.length + 1}章',
            startOffset: offset,
            endOffset: end,
          );
        }
        offset = math.max(end, offset + 1);
      }
    } finally {
      raf.closeSync();
    }

    return chapters;
  }

  static int _findVirtualChapterEnd(
    RandomAccessFile raf,
    int start,
    int fileLength,
  ) {
    final target = math.min(start + _virtualChapterTargetBytes, fileLength);
    if (target >= fileLength) return fileLength;

    final searchEnd = math.min(target + 1200, fileLength);
    raf.setPositionSync(target);
    for (var position = target; position < searchEnd; position++) {
      final byte = raf.readByteSync();
      if (byte < 0) return fileLength;
      if (byte == _lineFeedByte) return position + 1;
    }

    final searchStart = math.max(start + 1, target - 1200);
    raf.setPositionSync(searchStart);
    var lastBreak = -1;
    for (var position = searchStart; position < target; position++) {
      final byte = raf.readByteSync();
      if (byte < 0) break;
      if (byte == _lineFeedByte) lastBreak = position + 1;
    }

    return lastBreak >= searchStart ? lastBreak : target;
  }

  static void _addChapter(
    List<ParsedLocalChapter> chapters, {
    required Set<String> usedChapterNames,
    required String name,
    required int startOffset,
    required int endOffset,
    bool allowEmpty = false,
  }) {
    if (startOffset > endOffset || (!allowEmpty && startOffset == endOffset)) {
      return;
    }
    final chapterName = _resolveUniqueChapterName(
      usedChapterNames,
      chapters.length,
      name.trim(),
    );
    usedChapterNames.add(chapterName);
    chapters.add(
      ParsedLocalChapter(
        index: chapters.length,
        name: chapterName,
        startOffset: startOffset,
        endOffset: endOffset,
        contentCharLength: null,
      ),
    );
  }

  static String _resolveUniqueChapterName(
    Set<String> usedChapterNames,
    int chapterCount,
    String rawName,
  ) {
    final baseName = rawName.isEmpty ? '第${chapterCount + 1}章' : rawName;
    if (!usedChapterNames.contains(baseName)) {
      return baseName;
    }

    var suffix = 2;
    while (usedChapterNames.contains('$baseName ($suffix)')) {
      suffix++;
    }
    return '$baseName ($suffix)';
  }
}

class _LineScanResult {
  const _LineScanResult({
    required this.fileLength,
    required this.contentStart,
    required this.prefaceHasNonWhitespace,
    required this.titleLines,
    required this.hasReadableText,
  });

  final int fileLength;
  final int contentStart;
  final bool prefaceHasNonWhitespace;
  final List<_ChapterTitleLine> titleLines;
  final bool hasReadableText;
}

class _ChapterTitleLine {
  _ChapterTitleLine({
    required this.title,
    required this.lineStart,
    required this.lineEnd,
    required this.bodyStart,
  });

  final String title;
  final int lineStart;
  final int lineEnd;
  final int bodyStart;
  bool bodyHasNonWhitespace = false;
}

class _Utf8Validator {
  int _expectedContinuationBytes = 0;

  void accept(int byte) {
    if (_expectedContinuationBytes > 0) {
      if ((byte & 0xC0) != 0x80) {
        _throwUnsupportedCharset();
      }
      _expectedContinuationBytes--;
      return;
    }

    if (byte <= 0x7F) return;
    if (byte >= 0xC2 && byte <= 0xDF) {
      _expectedContinuationBytes = 1;
      return;
    }
    if (byte >= 0xE0 && byte <= 0xEF) {
      _expectedContinuationBytes = 2;
      return;
    }
    if (byte >= 0xF0 && byte <= 0xF4) {
      _expectedContinuationBytes = 3;
      return;
    }
    _throwUnsupportedCharset();
  }

  void finish() {
    if (_expectedContinuationBytes != 0) {
      _throwUnsupportedCharset();
    }
  }

  Never _throwUnsupportedCharset() {
    throw const LocalBookParseException(
      '文件编码暂不支持，请转换为 UTF-8 后重试',
    );
  }
}
