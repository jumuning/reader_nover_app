import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../database/drift/app_database.dart' as db;
import '../../l10n/generated/l10n.dart';
import 'local_book_constants.dart';
import 'local_book_cover_service.dart';
import 'local_epub_book_parser.dart';
import 'local_book_repository.dart';
import 'local_text_book_parser.dart';
import 'models/parsed_local_book.dart';

class LocalBookImportService {
  LocalBookImportService({
    db.AppDatabase? database,
    LocalTextBookParser? parser,
    LocalEpubBookParser? epubParser,
    LocalBookCoverService? coverService,
  })  : _database = database ?? db.AppDatabase.instance,
        _parser = parser ?? LocalTextBookParser(),
        _epubParser = epubParser ?? LocalEpubBookParser(),
        _coverService = coverService ?? const LocalBookCoverService();

  static const int _maxTxtFileBytes = 80 * 1024 * 1024;
  static const int _maxEpubFileBytes = 200 * 1024 * 1024;

  final db.AppDatabase _database;
  final LocalTextBookParser _parser;
  final LocalEpubBookParser _epubParser;
  final LocalBookCoverService _coverService;
  late final LocalBookRepository _repository =
      LocalBookRepository(database: _database);

  Future<LocalBookImportResult> importFile(String sourcePath) async {
    final sourceFile = File(sourcePath);
    if (!await sourceFile.exists()) {
      throw LocalBookParseException(S.current.fileNotFoundReselect);
    }

    final extension = p.extension(sourcePath).toLowerCase();
    if (extension != '.txt' && extension != '.epub') {
      throw LocalBookParseException(S.current.supportedLocalFormats);
    }

    final stat = await sourceFile.stat();
    if (stat.size <= 0) {
      throw LocalBookParseException(S.current.emptyFileCannotImport);
    }
    if (extension == '.txt' && stat.size > _maxTxtFileBytes) {
      throw LocalBookParseException(S.current.txtFileTooLarge);
    }
    if (extension == '.epub' && stat.size > _maxEpubFileBytes) {
      throw LocalBookParseException(S.current.epubFileTooLarge);
    }

    final originalFileName = p.basename(sourcePath);
    final storedFile = await _copyToLocalBookDirectory(
      sourceFile: sourceFile,
      originalFileName: originalFileName,
    );

    try {
      final parsedBook = extension == '.epub'
          ? await _epubParser.parseFile(
              filePath: storedFile.path,
              fallbackTitle: _bookTitleFromFileName(originalFileName),
            )
          : await _parser.parseFile(
              filePath: storedFile.path,
              fallbackTitle: _bookTitleFromFileName(originalFileName),
            );
      final coverPath = (parsedBook.coverPath?.trim().isNotEmpty ?? false)
          ? parsedBook.coverPath
          : await _coverService.ensureGeneratedCover(
              bookDirectory: storedFile.parent,
              title: parsedBook.title,
              author: parsedBook.author,
            );
      final bookWithCover = ParsedLocalBook(
        title: parsedBook.title,
        author: parsedBook.author,
        charset: parsedBook.charset,
        chapters: parsedBook.chapters,
        intro: parsedBook.intro,
        coverPath: coverPath,
        format: parsedBook.format,
      );
      return await _repository.saveParsedBook(
        parsedBook: bookWithCover,
        originalFileName: originalFileName,
        storedFilePath: storedFile.path,
        fileSize: stat.size,
        sourceModifiedTime: stat.modified,
      );
    } catch (_) {
      await _deleteStoredFileQuietly(storedFile);
      rethrow;
    }
  }

  Future<File> _copyToLocalBookDirectory({
    required File sourceFile,
    required String originalFileName,
  }) async {
    final supportDir = await getApplicationSupportDirectory();
    final importKey = DateTime.now().microsecondsSinceEpoch.toString();
    final targetDir = Directory(
      p.join(supportDir.path, 'local_books', importKey),
    );
    await targetDir.create(recursive: true);

    final safeName = _safeFileName(originalFileName);
    final targetPath = p.join(targetDir.path, safeName);
    return sourceFile.copy(targetPath);
  }

  String _bookTitleFromFileName(String fileName) {
    final name = p.basenameWithoutExtension(fileName).trim();
    return name.isEmpty ? S.current.unnamedLocalBook : name;
  }

  String _safeFileName(String fileName) {
    final base = p.basename(fileName).replaceAll(RegExp(r'[\\/:*?"<>|]+'), '_');
    if (base.trim().isEmpty) {
      return 'original.${LocalBookConstants.txtFormat}';
    }
    return base;
  }

  Future<void> _deleteStoredFileQuietly(File file) async {
    try {
      final parent = file.parent;
      if (await parent.exists()) {
        await parent.delete(recursive: true);
      }
    } catch (_) {}
  }
}
