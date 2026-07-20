import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' as drift;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../database/dao/book_content_info_dao.dart';
import '../../database/dao/book_read_history_dao.dart';
import '../../database/dao/book_read_progress_dao.dart';
import '../../database/dao/bookmark_dao.dart';
import '../../database/dao/bookshelf_dao.dart';
import '../../database/dao/local_book_file_dao.dart';
import '../../database/drift/app_database.dart' as db;
import '../../database/models/models.dart';
import '../../../rust/api/rule_engine.dart' hide BookInfo;
import '../local_book/local_book_constants.dart';
import 'reader_locator.dart';

class AddToBookshelfResult {
  final bool isInBookshelf;
  final int? currentReadChapterIndex;
  final int currentReadPageIndex;

  const AddToBookshelfResult({
    required this.isInBookshelf,
    required this.currentReadChapterIndex,
    required this.currentReadPageIndex,
  });
}

/// 书架写入服务。
///
/// 普通加入书架遵循两级判定：
/// 1. 同源 + 书名命中：视为同一本书，直接更新；
/// 2. 跨源时仅在 name + author 归一化精确命中时自动并书迁移；
///    否则按独立书籍插入书架。
class BookshelfService {
  final db.AppDatabase _db;
  late final BookshelfDao _bookshelfDao = BookshelfDao(database: _db);
  late final BookContentInfoDao _contentInfoDao =
      BookContentInfoDao(database: _db);
  late final BookReadProgressDao _readProgressDao =
      BookReadProgressDao(database: _db);
  late final BookReadHistoryDao _readHistoryDao =
      BookReadHistoryDao(database: _db);
  late final BookmarkDao _bookmarkDao = BookmarkDao(database: _db);
  late final LocalBookFileDao _localBookFileDao =
      LocalBookFileDao(database: _db);

  BookshelfService({db.AppDatabase? database})
      : _db = database ?? db.AppDatabase.instance;

  Future<AddToBookshelfResult> addToBookshelf({
    required db.BookSource source,
    required BookInfo bookInfo,
    required BookDetail bookDetail,
    required List<BookChapterInfo> chapterInfo,
    required int? currentReadChapterIndex,
    required int currentReadPageIndex,
  }) async {
    int? resolvedChapterIndex = currentReadChapterIndex;
    int resolvedPageIndex = currentReadPageIndex;
    final now = DateTime.now();

    await _db.transaction(() async {
      final existingBook = await _bookshelfDao.findBook(
        bookSourceId: source.id,
        bookName: bookInfo.name,
      );

      if (existingBook != null) {
        // 同源：更新元数据与章节
        final chaptersToSave = chapterInfo.isNotEmpty
            ? chapterInfo
            : (bookDetail.chapters ?? const <BookChapterInfo>[]);
        final resolvedAuthor = _resolvePreferredAuthor(
          detailAuthor: bookDetail.author,
          fallbackAuthor: bookInfo.author,
        );

        await _bookshelfDao.updateBook(
          bookId: existingBook.id,
          book: db.BooksCompanion(
            author: drift.Value(resolvedAuthor),
            cover: drift.Value(_preferredText(
              primary: bookDetail.cover,
              fallback: bookInfo.cover,
            )),
            intro: drift.Value(_preferredText(
              primary: bookDetail.intro,
              fallback: bookInfo.intro,
            )),
            kind: drift.Value(_encodeKind(
              _preferredKind(
                primary: bookDetail.kind,
                fallback: bookInfo.kind,
              ),
            )),
            wordCount: drift.Value(_preferredText(
              primary: bookDetail.wordCount,
              fallback: bookInfo.wordCount,
            )),
            lastChapter: drift.Value(_preferredText(
              primary: bookDetail.lastChapter,
              fallback: bookInfo.lastChapter,
            )),
            totalChapterNum: drift.Value(chaptersToSave.length),
            durChapterIndex: drift.Value(resolvedChapterIndex ?? 0),
            durChapterPos: drift.Value(resolvedPageIndex),
            lastReadTime: drift.Value(
              resolvedChapterIndex != null ? now : existingBook.lastReadTime,
            ),
          ),
        );

        await _replaceBookChapters(
          bookId: existingBook.id,
          bookSourceId: source.id,
          chapters: chaptersToSave,
        );
        return;
      }

      final mergeCandidate = await _findAutoMergeCandidate(
        source: source,
        bookInfo: bookInfo,
        bookDetail: bookDetail,
      );

      if (mergeCandidate != null) {
        final oldBookSourceId = mergeCandidate.bookSourceId;
        final chaptersToSave = chapterInfo.isNotEmpty
            ? chapterInfo
            : (bookDetail.chapters ?? const <BookChapterInfo>[]);
        final resolvedAuthor = _resolvePreferredAuthor(
          detailAuthor: bookDetail.author,
          fallbackAuthor: bookInfo.author,
        );
        final oldProgress = await _readProgressDao.findByBook(
          bookSourceId: oldBookSourceId,
          bookName: bookInfo.name,
        );

        if (oldProgress?.chapterName != null && chaptersToSave.isNotEmpty) {
          try {
            final matchedChapter =
                _findSimilarChapter(oldProgress!.chapterName!, chaptersToSave);
            resolvedChapterIndex = matchedChapter.chapterIndex;
            resolvedPageIndex = 0;
          } catch (_) {}
        }

        await _bookshelfDao.updateBook(
          bookId: mergeCandidate.id,
          book: db.BooksCompanion(
            bookSourceId: drift.Value(source.id),
            bookUrl: drift.Value(bookDetail.bookUrl),
            author: drift.Value(resolvedAuthor),
            cover: drift.Value(_preferredText(
              primary: bookDetail.cover,
              fallback: bookInfo.cover,
            )),
            intro: drift.Value(_preferredText(
              primary: bookDetail.intro,
              fallback: bookInfo.intro,
            )),
            kind: drift.Value(_encodeKind(
              _preferredKind(
                primary: bookDetail.kind,
                fallback: bookInfo.kind,
              ),
            )),
            wordCount: drift.Value(_preferredText(
              primary: bookDetail.wordCount,
              fallback: bookInfo.wordCount,
            )),
            lastChapter: drift.Value(_preferredText(
              primary: bookDetail.lastChapter,
              fallback: bookInfo.lastChapter,
            )),
            totalChapterNum: drift.Value(chaptersToSave.length),
            durChapterIndex: drift.Value(resolvedChapterIndex ?? 0),
            durChapterPos: drift.Value(resolvedPageIndex),
            lastReadTime: drift.Value(
              resolvedChapterIndex != null ? now : mergeCandidate.lastReadTime,
            ),
          ),
        );

        await _replaceBookChapters(
          bookId: mergeCandidate.id,
          bookSourceId: source.id,
          chapters: chaptersToSave,
        );

        await _readProgressDao.deleteByBook(
          bookSourceId: oldBookSourceId,
          bookName: bookInfo.name,
        );

        if (resolvedChapterIndex != null && chaptersToSave.isNotEmpty) {
          final int resolvedChapterIndexValue = resolvedChapterIndex!;
          final currentChapter = chaptersToSave.firstWhere(
            (c) => c.chapterIndex == resolvedChapterIndexValue,
            orElse: () => chaptersToSave[0],
          );

          await _readProgressDao.save(
            bookSourceId: source.id,
            bookName: bookInfo.name,
            chapterName: currentChapter.chapterName,
            chapterIndex: resolvedChapterIndexValue,
            locatorJson: ReaderLocator(
              chapterIndex: resolvedChapterIndexValue,
              chapterName: currentChapter.chapterName,
              chapterProgression: 0,
            ).encode(),
          );
        }

        await _migrateReadHistories(
          oldBookSourceId: oldBookSourceId,
          newBookSourceId: source.id,
          bookName: bookInfo.name,
          chapters: chaptersToSave,
        );
        await _migrateCachedContents(
          oldBookSourceId: oldBookSourceId,
          newBookSourceId: source.id,
          bookName: bookInfo.name,
          chapters: chaptersToSave,
        );
        await _migrateBookmarks(
          oldBookSourceId: oldBookSourceId,
          newBookSourceId: source.id,
          bookName: bookInfo.name,
          chapters: chaptersToSave,
        );
        return;
      }

      final detailToSave = bookDetail.copyWith(
        chapters: chapterInfo.isNotEmpty ? chapterInfo : bookDetail.chapters,
        author: _resolvePreferredAuthor(
          detailAuthor: bookDetail.author,
          fallbackAuthor: bookInfo.author,
        ),
        cover: _preferredText(
          primary: bookDetail.cover,
          fallback: bookInfo.cover,
        ),
        intro: _preferredText(
          primary: bookDetail.intro,
          fallback: bookInfo.intro,
        ),
        kind: _preferredKind(
          primary: bookDetail.kind,
          fallback: bookInfo.kind,
        ),
        lastChapter: _preferredText(
          primary: bookDetail.lastChapter,
          fallback: bookInfo.lastChapter,
        ),
      );
      final chaptersToSave = chapterInfo.isNotEmpty
          ? chapterInfo
          : (bookDetail.chapters ?? const <BookChapterInfo>[]);

      final bookId = await _bookshelfDao.insertBook(
        db.BooksCompanion.insert(
          bookSourceId: source.id,
          bookUrl: drift.Value(detailToSave.bookUrl),
          name: bookInfo.name,
          author: drift.Value(detailToSave.author),
          cover: drift.Value(detailToSave.cover),
          intro: drift.Value(detailToSave.intro),
          kind: drift.Value(_encodeKind(detailToSave.kind)),
          wordCount: drift.Value(_preferredText(
            primary: detailToSave.wordCount,
            fallback: bookInfo.wordCount,
          )),
          lastChapter: drift.Value(detailToSave.lastChapter),
          totalChapterNum: drift.Value(chaptersToSave.length),
          durChapterIndex: drift.Value(resolvedChapterIndex ?? 0),
          durChapterPos: drift.Value(resolvedPageIndex),
          lastReadTime: drift.Value(resolvedChapterIndex != null ? now : null),
          isAscending: drift.Value(detailToSave.isAscending),
          bookGroup: const drift.Value(''),
        ),
      );

      if (chaptersToSave.isNotEmpty) {
        await _bookshelfDao.insertChapters(
          chaptersToSave
              .map((ch) => db.BookChaptersCompanion.insert(
                    bookId: bookId,
                    bookSourceId: source.id,
                    chapterIndex: ch.chapterIndex ?? 0,
                    chapterName: ch.chapterName ?? '',
                    chapterUrl: ch.chapterUrl ?? '',
                  ))
              .toList(),
        );
      }

      if (resolvedChapterIndex != null && chapterInfo.isNotEmpty) {
        final int resolvedChapterIndexValue = resolvedChapterIndex!;
        final currentChapter = chapterInfo.firstWhere(
          (c) => c.chapterIndex == resolvedChapterIndexValue,
          orElse: () => chapterInfo[0],
        );

        await _readProgressDao.save(
          bookSourceId: source.id,
          bookName: bookInfo.name,
          chapterName: currentChapter.chapterName,
          chapterIndex: resolvedChapterIndexValue,
          locatorJson: ReaderLocator(
            chapterIndex: resolvedChapterIndexValue,
            chapterName: currentChapter.chapterName,
            chapterProgression: 0,
          ).encode(),
        );
      }
    });

    return AddToBookshelfResult(
      isInBookshelf: true,
      currentReadChapterIndex: resolvedChapterIndex,
      currentReadPageIndex: resolvedPageIndex,
    );
  }

  /// 从书架移除书籍，并清理关联章节/缓存/阅读数据。
  Future<void> removeFromBookshelf({
    required int bookSourceId,
    required String bookName,
  }) async {
    final matchedBooks = await _bookshelfDao.listBooksBySourceAndName(
      bookSourceId: bookSourceId,
      bookName: bookName,
    );
    final localFiles = LocalBookConstants.isLocalBookSource(bookSourceId)
        ? await _localBookFileDao.listByBookIds(
            matchedBooks.map((book) => book.id),
          )
        : const <db.LocalBookFile>[];

    await _db.transaction(() async {
      for (final book in matchedBooks) {
        await _bookshelfDao.deleteChaptersByBookId(book.id);
        if (LocalBookConstants.isLocalBookSource(bookSourceId)) {
          await _localBookFileDao.deleteByBookId(book.id);
        }
      }

      await _bookshelfDao.deleteBooksBySourceAndName(
        bookSourceId: bookSourceId,
        bookName: bookName,
      );

      await _contentInfoDao.deleteByBook(
        bookSourceId: bookSourceId,
        bookName: bookName,
      );

      await _readProgressDao.deleteByBook(
        bookSourceId: bookSourceId,
        bookName: bookName,
      );

      await _readHistoryDao.deleteByBook(
        bookSourceId: bookSourceId,
        bookName: bookName,
      );

      await _bookmarkDao.deleteByBook(
        bookSourceId: bookSourceId,
        bookName: bookName,
      );
    });

    for (final localFile in localFiles) {
      await _deleteStoredLocalBookFile(localFile.storedFilePath);
    }
  }

  /// 批量移出书架，共用一个事务，避免每本书重复开启事务。
  Future<void> removeManyFromBookshelf(Iterable<db.Book> books) async {
    final selected = books.toList(growable: false);
    if (selected.isEmpty) return;

    final keys = selected
        .map((book) => (book.bookSourceId, book.name))
        .toSet()
        .toList(growable: false);
    final matchedBooks = <db.Book>[];
    for (final key in keys) {
      matchedBooks.addAll(
        await _bookshelfDao.listBooksBySourceAndName(
          bookSourceId: key.$1,
          bookName: key.$2,
        ),
      );
    }
    final localBookIds = matchedBooks
        .where(
          (book) => LocalBookConstants.isLocalBookSource(book.bookSourceId),
        )
        .map((book) => book.id)
        .toList(growable: false);
    final localFiles = localBookIds.isEmpty
        ? const <db.LocalBookFile>[]
        : await _localBookFileDao.listByBookIds(localBookIds);

    await _db.transaction(() async {
      for (final book in matchedBooks) {
        await _bookshelfDao.deleteChaptersByBookId(book.id);
        if (LocalBookConstants.isLocalBookSource(book.bookSourceId)) {
          await _localBookFileDao.deleteByBookId(book.id);
        }
      }
      for (final key in keys) {
        await _bookshelfDao.deleteBooksBySourceAndName(
          bookSourceId: key.$1,
          bookName: key.$2,
        );
        await _contentInfoDao.deleteByBook(
          bookSourceId: key.$1,
          bookName: key.$2,
        );
        await _readProgressDao.deleteByBook(
          bookSourceId: key.$1,
          bookName: key.$2,
        );
        await _readHistoryDao.deleteByBook(
          bookSourceId: key.$1,
          bookName: key.$2,
        );
        await _bookmarkDao.deleteByBook(
          bookSourceId: key.$1,
          bookName: key.$2,
        );
      }
    });

    for (final localFile in localFiles) {
      await _deleteStoredLocalBookFile(localFile.storedFilePath);
    }
  }

  Future<void> _deleteStoredLocalBookFile(String path) async {
    try {
      final supportDirectory = await getApplicationSupportDirectory();
      final managedRoot =
          p.normalize(p.absolute(p.join(supportDirectory.path, 'local_books')));
      final normalizedPath = p.normalize(p.absolute(path));
      if (!p.isWithin(managedRoot, normalizedPath)) return;
      final parent = File(path).parent;
      final normalizedParent = p.normalize(p.absolute(parent.path));
      if (normalizedParent == managedRoot ||
          !p.isWithin(managedRoot, normalizedParent)) {
        return;
      }
      if (await parent.exists()) {
        await parent.delete(recursive: true);
      }
    } catch (_) {
      // 文件清理失败不应阻断书架数据删除。
    }
  }

  Future<void> _replaceBookChapters({
    required int bookId,
    required int bookSourceId,
    required List<BookChapterInfo> chapters,
  }) async {
    await _bookshelfDao.replaceChapters(
      bookId: bookId,
      chapters: chapters
          .map((ch) => db.BookChaptersCompanion.insert(
                bookId: bookId,
                bookSourceId: bookSourceId,
                chapterIndex: ch.chapterIndex ?? 0,
                chapterName: ch.chapterName ?? '',
                chapterUrl: ch.chapterUrl ?? '',
              ))
          .toList(),
    );
  }

  Future<db.Book?> _findAutoMergeCandidate({
    required db.BookSource source,
    required BookInfo bookInfo,
    required BookDetail bookDetail,
  }) async {
    final targetNameKey = _normalizeMergeField(bookInfo.name);
    final targetAuthorKey = _normalizeMergeField(
      _resolvePreferredAuthor(
            detailAuthor: bookDetail.author,
            fallbackAuthor: bookInfo.author,
          ) ??
          '',
    );
    if (targetNameKey.isEmpty || targetAuthorKey.isEmpty) {
      return null;
    }

    final books = await _bookshelfDao.listBooks();
    for (final book in books) {
      if (book.bookSourceId == source.id) continue;
      if (_normalizeMergeField(book.name) != targetNameKey) continue;
      if (_normalizeMergeField(book.author ?? '') != targetAuthorKey) continue;
      return book;
    }
    return null;
  }

  Future<void> _migrateReadHistories({
    required int oldBookSourceId,
    required int newBookSourceId,
    required String bookName,
    required List<BookChapterInfo> chapters,
  }) async {
    final oldHistories = await _readHistoryDao.listByBook(
      bookSourceId: oldBookSourceId,
      bookName: bookName,
    );

    for (final history in oldHistories) {
      if (history.chapterName == null || chapters.isEmpty) {
        await _readHistoryDao.updateById(
          id: history.id,
          history: db.BookReadHistoriesCompanion(
            bookSourceId: drift.Value(newBookSourceId),
          ),
        );
        continue;
      }
      try {
        final newChapter = _findSimilarChapter(history.chapterName!, chapters);
        await _readHistoryDao.updateById(
          id: history.id,
          history: db.BookReadHistoriesCompanion(
            bookSourceId: drift.Value(newBookSourceId),
            chapterName: drift.Value(newChapter.chapterName),
            chapterIndex: drift.Value(newChapter.chapterIndex!),
          ),
        );
      } catch (_) {
        await _readHistoryDao.updateById(
          id: history.id,
          history: db.BookReadHistoriesCompanion(
            bookSourceId: drift.Value(newBookSourceId),
          ),
        );
      }
    }
  }

  Future<void> _migrateCachedContents({
    required int oldBookSourceId,
    required int newBookSourceId,
    required String bookName,
    required List<BookChapterInfo> chapters,
  }) async {
    final oldContents = await _contentInfoDao.listByBook(
      bookSourceId: oldBookSourceId,
      bookName: bookName,
    );

    for (final content in oldContents) {
      if (content.chapterName == null || chapters.isEmpty) {
        await _contentInfoDao.updateById(
          id: content.id,
          content: db.BookContentInfosCompanion(
            bookSourceId: drift.Value(newBookSourceId),
          ),
        );
        continue;
      }
      try {
        final newChapter = _findSimilarChapter(content.chapterName!, chapters);
        final existingTarget = await _contentInfoDao.findByChapter(
          bookSourceId: newBookSourceId,
          bookName: bookName,
          chapterName: newChapter.chapterName ?? '',
        );

        if (existingTarget != null && existingTarget.id != content.id) {
          await _contentInfoDao.deleteById(content.id);
          continue;
        }

        await _contentInfoDao.updateById(
          id: content.id,
          content: db.BookContentInfosCompanion(
            bookSourceId: drift.Value(newBookSourceId),
            chapterIndex: drift.Value(newChapter.chapterIndex),
            chapterName: drift.Value(newChapter.chapterName),
          ),
        );
      } catch (_) {
        await _contentInfoDao.deleteById(content.id);
      }
    }
  }

  Future<void> _migrateBookmarks({
    required int oldBookSourceId,
    required int newBookSourceId,
    required String bookName,
    required List<BookChapterInfo> chapters,
  }) async {
    final oldBookmarks = await _bookmarkDao.listByBook(
      bookSourceId: oldBookSourceId,
      bookName: bookName,
    );

    for (final bookmark in oldBookmarks) {
      if (chapters.isEmpty || bookmark.chapterName.isEmpty) {
        await _bookmarkDao.updateById(
          bookmarkId: bookmark.id,
          bookmark: db.BookmarksCompanion(
            bookSourceId: drift.Value(newBookSourceId),
          ),
        );
        continue;
      }

      try {
        final newChapter = _findSimilarChapter(bookmark.chapterName, chapters);
        final oldLocator = ReaderLocator.decode(bookmark.locatorJson);
        final newLocator = ReaderLocator(
          chapterIndex: newChapter.chapterIndex!,
          chapterId: oldLocator.chapterId,
          chapterName: newChapter.chapterName,
          resourceHref: oldLocator.resourceHref,
          offsetUtf16: oldLocator.offsetUtf16,
          quote: oldLocator.quote,
          prefix: oldLocator.prefix,
          suffix: oldLocator.suffix,
          chapterProgression: oldLocator.chapterProgression,
        );
        await _bookmarkDao.updateById(
          bookmarkId: bookmark.id,
          bookmark: db.BookmarksCompanion(
            bookSourceId: drift.Value(newBookSourceId),
            locatorJson: drift.Value(newLocator.encode()),
            chapterName: drift.Value(newChapter.chapterName ?? ''),
          ),
        );
      } catch (_) {
        await _bookmarkDao.updateById(
          bookmarkId: bookmark.id,
          bookmark: db.BookmarksCompanion(
            bookSourceId: drift.Value(newBookSourceId),
          ),
        );
      }
    }
  }

  BookChapterInfo _findSimilarChapter(
    String targetName,
    List<BookChapterInfo> chapters,
  ) {
    if (chapters.isEmpty) throw StateError('章节列表为空');
    final chapterNames = chapters.map((c) => c.chapterName ?? '').toList();
    final matchedIndex = findMatchingChapter(
      target: targetName,
      chapterNames: chapterNames,
    );
    return chapters[matchedIndex];
  }

  String _normalizeMergeField(String value) {
    return value.trim().replaceAll(RegExp(r'\s+'), '').toLowerCase();
  }

  String? _resolvePreferredAuthor({
    required String? detailAuthor,
    required String? fallbackAuthor,
  }) {
    final primary = detailAuthor?.trim();
    if (primary != null && primary.isNotEmpty) return primary;
    final fallback = fallbackAuthor?.trim();
    if (fallback != null && fallback.isNotEmpty) return fallback;
    return null;
  }

  String? _preferredText({
    required String? primary,
    required String? fallback,
  }) {
    final primaryValue = primary?.trim();
    if (primaryValue != null && primaryValue.isNotEmpty) return primary;
    final fallbackValue = fallback?.trim();
    if (fallbackValue != null && fallbackValue.isNotEmpty) return fallback;
    return primary ?? fallback;
  }

  List<String>? _preferredKind({
    required List<String>? primary,
    required String? fallback,
  }) {
    final primaryValues = _normalizeKindList(primary);
    if (primaryValues.isNotEmpty) {
      return primaryValues;
    }

    final fallbackValues = _splitKind(fallback);
    if (fallbackValues.isNotEmpty) return fallbackValues;
    return primaryValues;
  }

  String? _encodeKind(List<String>? kind) {
    final values = _normalizeKindList(kind);
    return values.isEmpty ? null : jsonEncode(values);
  }

  List<String> _normalizeKindList(List<String>? raw) {
    if (raw == null || raw.isEmpty) return const <String>[];
    return raw.expand(_splitKind).where((item) => item.isNotEmpty).toList();
  }

  List<String> _splitKind(String? raw) {
    final value = raw?.trim();
    if (value == null || value.isEmpty) return const <String>[];
    return value
        .split(RegExp(r'[,，、/|;\n\r\t]+'))
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }
}
