import 'dart:convert';

import 'package:drift/drift.dart' as drift;

import '../../database/dao/bookshelf_dao.dart';
import '../../database/dao/book_content_info_dao.dart';
import '../../database/dao/local_book_file_dao.dart';
import '../../database/drift/app_database.dart' as db;
import '../../database/models/models.dart';
import 'local_book_constants.dart';
import 'local_book_source.dart';
import 'models/parsed_local_book.dart';

class LocalBookImportResult {
  const LocalBookImportResult({
    required this.bookId,
    required this.bookInfo,
    required this.bookDetail,
  });

  final int bookId;
  final BookInfo bookInfo;
  final BookDetail bookDetail;
}

class LocalBookRepository {
  LocalBookRepository({
    db.AppDatabase? database,
  }) : _database = database ?? db.AppDatabase.instance;

  final db.AppDatabase _database;
  late final BookshelfDao _bookshelfDao = BookshelfDao(database: _database);
  late final BookContentInfoDao _contentInfoDao =
      BookContentInfoDao(database: _database);
  late final LocalBookFileDao _localBookFileDao =
      LocalBookFileDao(database: _database);
  late final LocalBookSource _localBookSource =
      LocalBookSource(database: _database);

  Future<LocalBookImportResult> saveImportedFile({
    required String title,
    required String originalFileName,
    required String storedFilePath,
    required int fileSize,
    required DateTime? sourceModifiedTime,
  }) async {
    final source = await _localBookSource.ensureExists();
    final importTime = DateTime.now();

    return _database.transaction(() async {
      final bookName = await _resolveUniqueBookName(title);
      final bookId = await _bookshelfDao.insertBook(
        db.BooksCompanion.insert(
          bookSourceId: source.id,
          name: bookName,
          bookUrl: const drift.Value(null),
          author: const drift.Value(null),
          cover: const drift.Value(null),
          intro: drift.Value('本地导入：$originalFileName'),
          kind: drift.Value(jsonEncode(const [LocalBookConstants.kind])),
          wordCount: const drift.Value(null),
          lastChapter: const drift.Value(null),
          totalChapterNum: const drift.Value(0),
          durChapterIndex: const drift.Value(0),
          durChapterPos: const drift.Value(0),
          lastReadTime: const drift.Value(null),
          isAscending: const drift.Value(true),
          bookGroup: const drift.Value(LocalBookConstants.bookGroup),
        ),
      );

      await _localBookFileDao.save(
        bookId: bookId,
        originalFileName: originalFileName,
        storedFilePath: storedFilePath,
        format: LocalBookConstants.txtFormat,
        charset: null,
        fileSize: fileSize,
        fileHash: null,
        importTime: importTime,
        sourceModifiedTime: sourceModifiedTime,
      );

      final bookInfo = BookInfo(
        bookSourceId: source.id,
        name: bookName,
        intro: '本地导入：$originalFileName',
        kind: LocalBookConstants.kind,
      );
      final bookDetail = BookDetail(
        bookSourceId: source.id,
        name: bookName,
        intro: '本地导入：$originalFileName',
        kind: const [LocalBookConstants.kind],
        isAscending: true,
      );

      return LocalBookImportResult(
        bookId: bookId,
        bookInfo: bookInfo,
        bookDetail: bookDetail,
      );
    });
  }

  Future<LocalBookImportResult> saveParsedBook({
    required ParsedLocalBook parsedBook,
    required String originalFileName,
    required String storedFilePath,
    required int fileSize,
    required DateTime? sourceModifiedTime,
  }) async {
    final source = await _localBookSource.ensureExists();
    final importTime = DateTime.now();

    return _database.transaction(() async {
      final bookName = await _resolveUniqueBookName(parsedBook.title);
      final totalChars = parsedBook.chapters.fold<int>(
        0,
        (sum, chapter) => sum + chapter.contentLength,
      );

      final bookId = await _bookshelfDao.insertBook(
        db.BooksCompanion.insert(
          bookSourceId: source.id,
          name: bookName,
          bookUrl: const drift.Value(null),
          author: drift.Value(parsedBook.author),
          cover: drift.Value(parsedBook.coverPath),
          intro: drift.Value(parsedBook.intro ?? '本地导入：$originalFileName'),
          kind: drift.Value(jsonEncode(const [LocalBookConstants.kind])),
          wordCount: drift.Value(totalChars > 0 ? '$totalChars字' : null),
          lastChapter: drift.Value(parsedBook.chapters.last.name),
          totalChapterNum: drift.Value(parsedBook.chapters.length),
          durChapterIndex: const drift.Value(0),
          durChapterPos: const drift.Value(0),
          lastReadTime: const drift.Value(null),
          isAscending: const drift.Value(true),
          bookGroup: const drift.Value(LocalBookConstants.bookGroup),
        ),
      );

      final chapters = parsedBook.chapters
          .map(
            (chapter) => BookChapterInfo(
              bookSourceId: source.id,
              chapterIndex: chapter.index,
              chapterName: chapter.name,
              chapterUrl: LocalBookConstants.chapterUrl(
                bookId: bookId,
                chapterIndex: chapter.index,
                startOffset: chapter.startOffset,
                endOffset: chapter.endOffset,
              ),
            ),
          )
          .toList(growable: false);

      await _bookshelfDao.insertChapters(
        chapters
            .map(
              (chapter) => db.BookChaptersCompanion.insert(
                bookId: bookId,
                bookSourceId: source.id,
                chapterIndex: chapter.chapterIndex ?? 0,
                chapterName: chapter.chapterName ?? '',
                chapterUrl: chapter.chapterUrl ?? '',
              ),
            )
            .toList(growable: false),
      );

      await _localBookFileDao.save(
        bookId: bookId,
        originalFileName: originalFileName,
        storedFilePath: storedFilePath,
        format: parsedBook.format,
        charset: parsedBook.charset,
        fileSize: fileSize,
        fileHash: null,
        importTime: importTime,
        sourceModifiedTime: sourceModifiedTime,
      );

      await _contentInfoDao.bulkUpsert(
        parsedBook.chapters
            .where((chapter) => chapter.content != null)
            .map(
              (chapter) => db.BookContentInfosCompanion.insert(
                bookSourceId: source.id,
                name: drift.Value(bookName),
                chapterName: drift.Value(chapter.name),
                chapterIndex: drift.Value(chapter.index),
                bookContent: drift.Value(chapter.content),
              ),
            )
            .toList(growable: false),
      );

      final bookInfo = BookInfo(
        bookSourceId: source.id,
        name: bookName,
        author: parsedBook.author,
        cover: parsedBook.coverPath,
        intro: parsedBook.intro ?? '本地导入：$originalFileName',
        kind: LocalBookConstants.kind,
        lastChapter: parsedBook.chapters.last.name,
        wordCount: totalChars > 0 ? '$totalChars字' : null,
      );
      final bookDetail = BookDetail(
        bookSourceId: source.id,
        name: bookName,
        author: parsedBook.author,
        cover: parsedBook.coverPath,
        intro: parsedBook.intro ?? '本地导入：$originalFileName',
        kind: const [LocalBookConstants.kind],
        lastChapter: parsedBook.chapters.last.name,
        wordCount: totalChars > 0 ? '$totalChars字' : null,
        isAscending: true,
        chapters: chapters,
      );

      return LocalBookImportResult(
        bookId: bookId,
        bookInfo: bookInfo,
        bookDetail: bookDetail,
      );
    });
  }

  Future<BookDetail> saveParsedChaptersForBook({
    required db.Book book,
    required ParsedLocalBook parsedBook,
  }) async {
    return _database.transaction(() async {
      final totalChars = parsedBook.chapters.fold<int>(
        0,
        (sum, chapter) => sum + chapter.contentLength,
      );

      final chapters = parsedBook.chapters
          .map(
            (chapter) => BookChapterInfo(
              bookSourceId: book.bookSourceId,
              chapterIndex: chapter.index,
              chapterName: chapter.name,
              chapterUrl: LocalBookConstants.chapterUrl(
                bookId: book.id,
                chapterIndex: chapter.index,
                startOffset: chapter.startOffset,
                endOffset: chapter.endOffset,
              ),
            ),
          )
          .toList(growable: false);

      await _bookshelfDao.updateBook(
        bookId: book.id,
        book: db.BooksCompanion(
          lastChapter: drift.Value(parsedBook.chapters.last.name),
          totalChapterNum: drift.Value(parsedBook.chapters.length),
          wordCount: drift.Value(totalChars > 0 ? '$totalChars字' : null),
        ),
      );

      await _bookshelfDao.replaceChapters(
        bookId: book.id,
        chapters: chapters
            .map(
              (chapter) => db.BookChaptersCompanion.insert(
                bookId: book.id,
                bookSourceId: book.bookSourceId,
                chapterIndex: chapter.chapterIndex ?? 0,
                chapterName: chapter.chapterName ?? '',
                chapterUrl: chapter.chapterUrl ?? '',
              ),
            )
            .toList(growable: false),
      );

      await _localBookFileDao.updateByBookId(
        bookId: book.id,
        file: db.LocalBookFilesCompanion(
          charset: drift.Value(parsedBook.charset),
        ),
      );

      return BookDetail(
        bookSourceId: book.bookSourceId,
        name: book.name,
        author: book.author,
        cover: book.cover,
        intro: book.intro,
        kind: book.kind != null
            ? List<String>.from(jsonDecode(book.kind!))
            : null,
        lastChapter: parsedBook.chapters.last.name,
        wordCount: totalChars > 0 ? '$totalChars字' : null,
        bookUrl: book.bookUrl,
        isAscending: book.isAscending,
        chapters: chapters,
      );
    });
  }

  Future<String> _resolveUniqueBookName(String preferredName) async {
    final baseName =
        preferredName.trim().isEmpty ? '未命名本地书籍' : preferredName.trim();
    var candidate = baseName;
    var suffix = 2;
    while (await _bookshelfDao.findBook(
          bookSourceId: LocalBookConstants.sourceId,
          bookName: candidate,
        ) !=
        null) {
      candidate = '$baseName ($suffix)';
      suffix++;
    }
    return candidate;
  }
}
