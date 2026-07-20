import 'dart:async';

import 'package:dio/dio.dart';
import 'package:drift/drift.dart' as drift;

import '../../database/dao/book_content_info_dao.dart';
import '../../database/dao/book_read_history_dao.dart';
import '../../database/dao/book_read_progress_dao.dart';
import '../../database/dao/bookshelf_dao.dart';
import '../../database/drift/app_database.dart' as db;
import '../../database/models/models.dart';
import 'models/source_book_info.dart';
import 'reader_locator.dart';
import 'service_result.dart';
import '../source/web_book_detail_service.dart';
import '../source/source_http.dart';
import '../source/source_login_service.dart';
import '../../../rust/api/rule_engine.dart' hide BookInfo;
import '../../../util/log_utils.dart';

/// 换源结果
class ChangeSourceResult {
  final BookInfo bookInfo;
  final BookDetail bookDetail;
  final int newChapterIndex;
  final String newChapterName;
  final String newChapterUrl;

  ChangeSourceResult({
    required this.bookInfo,
    required this.bookDetail,
    required this.newChapterIndex,
    required this.newChapterName,
    required this.newChapterUrl,
  });
}

/// 换源服务 - 提取公共换源逻辑
class BookChangeService {
  BookChangeService({db.AppDatabase? database})
      : _db = database ?? db.AppDatabase.instance;

  final db.AppDatabase _db;
  late final BookshelfDao _bookshelfDao = BookshelfDao(database: _db);
  late final BookContentInfoDao _contentInfoDao =
      BookContentInfoDao(database: _db);
  late final BookReadProgressDao _readProgressDao =
      BookReadProgressDao(database: _db);
  late final BookReadHistoryDao _readHistoryDao =
      BookReadHistoryDao(database: _db);

  /// 执行换源操作
  ///
  /// [sourceInfo] 新书源信息
  /// [bookInfo] 当前书籍信息
  /// [bookDetail] 当前书籍详情
  /// [currentChapterName] 当前章节名称（用于匹配）
  /// [isInBookshelf] 是否在书架中
  /// [cancelToken] 取消令牌
  ///
  /// 返回换源结果，包含新的书籍信息、详情和章节索引
  Future<ServiceResult<ChangeSourceResult>> changeSource({
    required SourceBookInfo sourceInfo,
    required BookInfo bookInfo,
    required BookDetail bookDetail,
    required String currentChapterName,
    required bool isInBookshelf,
    CancelToken? cancelToken,
  }) async {
    final oldBookSourceId = bookInfo.bookSourceId;

    try {
      final preparedTarget = await _loadPreparedTarget(
        sourceInfo: sourceInfo,
        bookDetail: bookDetail,
        currentChapterName: currentChapterName,
        cancelToken: cancelToken,
      );

      LogUtils.d(
        '章节匹配: "$currentChapterName" -> "${preparedTarget.newChapterName}" '
        '(index: ${preparedTarget.newChapterIndex})',
      );

      await _db.transaction(() async {
        await _replaceReadProgress(
          oldBookSourceId: oldBookSourceId,
          sourceInfo: sourceInfo,
          bookName: bookInfo.name,
          newChapterName: preparedTarget.newChapterName,
          newChapterIndex: preparedTarget.newChapterIndex,
        );
        await _migrateReadHistories(
          oldBookSourceId: oldBookSourceId,
          sourceInfo: sourceInfo,
          bookName: bookInfo.name,
          chapterNames: preparedTarget.chapterNames,
        );
        await _syncBookshelfIfNeeded(
          isInBookshelf: isInBookshelf,
          oldBookSourceId: oldBookSourceId,
          sourceInfo: sourceInfo,
          bookName: bookInfo.name,
          newBookDetail: preparedTarget.newBookDetail,
          chapters: preparedTarget.chapters,
        );
        await _migrateCachedContents(
          oldBookSourceId: oldBookSourceId,
          sourceInfo: sourceInfo,
          bookName: bookInfo.name,
          chapterNames: preparedTarget.chapterNames,
        );
      });

      final newBookInfo = BookInfo(
        bookSourceId: sourceInfo.bookSource.id,
        name: bookInfo.name,
        author: bookInfo.author,
        bookUrl: sourceInfo.bookUrl,
        intro: bookInfo.intro,
      );
      final finalBookDetail = preparedTarget.newBookDetail
          .copyWith(chapters: preparedTarget.chapters);

      LogUtils.d('换源成功: ${sourceInfo.bookSource.bookSourceName}');

      return ServiceResult<ChangeSourceResult>.success(
        ChangeSourceResult(
          bookInfo: newBookInfo,
          bookDetail: finalBookDetail,
          newChapterIndex: preparedTarget.newChapterIndex,
          newChapterName: preparedTarget.newChapterName,
          newChapterUrl: preparedTarget.newChapterUrl,
        ),
      );
    } catch (error, stackTrace) {
      final serviceError = _buildChangeSourceError(
        sourceInfo: sourceInfo,
        bookInfo: bookInfo,
        currentChapterName: currentChapterName,
        error: error,
        stackTrace: stackTrace,
      );
      return ServiceResult<ChangeSourceResult>.failure(serviceError);
    }
  }

  Future<_PreparedChangeTarget> _loadPreparedTarget({
    required SourceBookInfo sourceInfo,
    required BookDetail bookDetail,
    required String currentChapterName,
    CancelToken? cancelToken,
  }) async {
    final loadedDetail = await WebBookDetailService.loadBookDetailAndChapters(
      sourceInfo.bookSource,
      sourceInfo.bookUrl,
      cancelToken: cancelToken,
    );
    final chapters = loadedDetail.chapters ?? const <BookChapterInfo>[];
    final chapterNames = chapters
        .map((chapter) => chapter.chapterName ?? '')
        .toList(growable: false);
    final chapterUrls = chapters
        .map((chapter) => chapter.chapterUrl ?? '')
        .toList(growable: false);

    if (chapterNames.isEmpty) {
      throw StateError('未找到章节列表');
    }

    final newBookDetail = BookDetail(
      bookSourceId: sourceInfo.bookSource.id,
      name: bookDetail.name,
      author: (loadedDetail.author?.trim().isNotEmpty ?? false)
          ? loadedDetail.author
          : bookDetail.author,
      cover: (loadedDetail.cover?.trim().isNotEmpty ?? false)
          ? loadedDetail.cover
          : bookDetail.cover,
      intro: (loadedDetail.intro?.trim().isNotEmpty ?? false)
          ? loadedDetail.intro
          : bookDetail.intro,
      kind: (loadedDetail.kind?.isNotEmpty ?? false)
          ? loadedDetail.kind
          : bookDetail.kind,
      lastChapter: (loadedDetail.lastChapter?.trim().isNotEmpty ?? false)
          ? loadedDetail.lastChapter
          : bookDetail.lastChapter,
      wordCount: (loadedDetail.wordCount?.trim().isNotEmpty ?? false)
          ? loadedDetail.wordCount
          : bookDetail.wordCount,
      bookUrl: sourceInfo.bookUrl,
      tocUrl: loadedDetail.tocUrl,
    );

    final newChapterIndex = findMatchingChapter(
      target: currentChapterName,
      chapterNames: chapterNames,
    );
    final newChapterName = chapterNames[newChapterIndex];
    final rawUrl = newChapterIndex < chapterUrls.length
        ? chapterUrls[newChapterIndex]
        : '';
    final newChapterUrl = rawUrl.startsWith('http')
        ? rawUrl
        : resolveUrl(base: sourceInfo.bookSource.bookSourceUrl, href: rawUrl);

    return _PreparedChangeTarget(
      newBookDetail: newBookDetail,
      chapters: chapters,
      chapterNames: chapterNames,
      newChapterIndex: newChapterIndex,
      newChapterName: newChapterName,
      newChapterUrl: newChapterUrl,
    );
  }

  Future<void> _replaceReadProgress({
    required int oldBookSourceId,
    required SourceBookInfo sourceInfo,
    required String bookName,
    required String newChapterName,
    required int newChapterIndex,
  }) async {
    await _readProgressDao.deleteByBook(
      bookSourceId: oldBookSourceId,
      bookName: bookName,
    );

    await _readProgressDao.save(
      bookSourceId: sourceInfo.bookSource.id,
      bookName: bookName,
      chapterName: newChapterName,
      chapterIndex: newChapterIndex,
      locatorJson: ReaderLocator(
        chapterIndex: newChapterIndex,
        chapterName: newChapterName,
        chapterProgression: 0,
      ).encode(),
    );
  }

  Future<void> _migrateReadHistories({
    required int oldBookSourceId,
    required SourceBookInfo sourceInfo,
    required String bookName,
    required List<String> chapterNames,
  }) async {
    final oldHistories = await _readHistoryDao.listByBook(
      bookSourceId: oldBookSourceId,
      bookName: bookName,
    );

    for (final history in oldHistories) {
      if (history.chapterName == null) continue;
      final matchedIndex = findMatchingChapter(
        target: history.chapterName!,
        chapterNames: chapterNames,
      );
      await _readHistoryDao.updateById(
        id: history.id,
        history: db.BookReadHistoriesCompanion(
          bookSourceId: drift.Value(sourceInfo.bookSource.id),
          chapterName: drift.Value(chapterNames[matchedIndex]),
          chapterIndex: drift.Value(matchedIndex),
        ),
      );
    }
  }

  Future<void> _syncBookshelfIfNeeded({
    required bool isInBookshelf,
    required int oldBookSourceId,
    required SourceBookInfo sourceInfo,
    required String bookName,
    required BookDetail newBookDetail,
    required List<BookChapterInfo> chapters,
  }) async {
    if (!isInBookshelf) return;

    final existingBook = await _bookshelfDao.findBook(
      bookSourceId: oldBookSourceId,
      bookName: bookName,
    );

    if (existingBook == null) return;

    await _bookshelfDao.updateBook(
      bookId: existingBook.id,
      book: db.BooksCompanion(
        bookSourceId: drift.Value(sourceInfo.bookSource.id),
        bookUrl: drift.Value(newBookDetail.bookUrl),
        author: drift.Value(newBookDetail.author),
        cover: drift.Value(newBookDetail.cover),
        intro: drift.Value(newBookDetail.intro),
        wordCount: drift.Value(newBookDetail.wordCount),
        lastChapter: drift.Value(newBookDetail.lastChapter),
        totalChapterNum: drift.Value(chapters.length),
      ),
    );

    await _bookshelfDao.replaceChapters(
      bookId: existingBook.id,
      chapters: chapters
          .map(
            (chapter) => db.BookChaptersCompanion.insert(
              bookId: existingBook.id,
              bookSourceId: sourceInfo.bookSource.id,
              chapterIndex: chapter.chapterIndex ?? 0,
              chapterName: chapter.chapterName ?? '',
              chapterUrl: chapter.chapterUrl ?? '',
            ),
          )
          .toList(),
    );
  }

  Future<void> _migrateCachedContents({
    required int oldBookSourceId,
    required SourceBookInfo sourceInfo,
    required String bookName,
    required List<String> chapterNames,
  }) async {
    final oldContents = await _contentInfoDao.listByBook(
      bookSourceId: oldBookSourceId,
      bookName: bookName,
    );

    for (final content in oldContents) {
      if (content.chapterName == null) continue;
      final matchedIndex = findMatchingChapter(
        target: content.chapterName!,
        chapterNames: chapterNames,
      );
      final targetChapterName = chapterNames[matchedIndex];
      final existingTarget = await _contentInfoDao.findByChapter(
        bookSourceId: sourceInfo.bookSource.id,
        bookName: bookName,
        chapterName: targetChapterName,
      );

      if (existingTarget != null && existingTarget.id != content.id) {
        await _contentInfoDao.deleteById(content.id);
        continue;
      }

      await _contentInfoDao.updateById(
        id: content.id,
        content: db.BookContentInfosCompanion(
          bookSourceId: drift.Value(sourceInfo.bookSource.id),
          chapterName: drift.Value(targetChapterName),
          chapterIndex: drift.Value(matchedIndex),
        ),
      );
    }
  }

  ServiceError _buildChangeSourceError({
    required SourceBookInfo sourceInfo,
    required BookInfo bookInfo,
    required String currentChapterName,
    required Object error,
    required StackTrace stackTrace,
  }) {
    final context = <String, Object?>{
      'fromBookSourceId': bookInfo.bookSourceId,
      'toBookSourceId': sourceInfo.bookSource.id,
      'bookName': bookInfo.name,
      'bookUrl': sourceInfo.bookUrl,
      'currentChapterName': currentChapterName,
      'targetSourceName': sourceInfo.bookSource.bookSourceName,
    };

    if (error is TimeoutException) {
      return ServiceError(
        code: '${ServiceErrorCodes.changeSourceFailed}.timeout',
        userMessage: '换源超时，请稍后重试',
        debugMessage: '换源请求超时',
        context: context,
        cause: error,
        stackTrace: stackTrace,
      );
    }

    if (error is SourceLoginRequiredException) {
      return ServiceError(
        code: '${ServiceErrorCodes.changeSourceFailed}.login_required',
        userMessage: error.message,
        debugMessage: 'tag: 登录校验',
        context: <String, Object?>{
          ...context,
          ...error.loginRequired.toJson(),
        },
        cause: error,
        stackTrace: stackTrace,
      );
    }

    if (error is CheckException) {
      return ServiceError(
        code: '${ServiceErrorCodes.changeSourceFailed}.rule_failed',
        userMessage: error.message,
        debugMessage: 'tag: ${error.tag}',
        context: context,
        cause: error,
        stackTrace: stackTrace,
      );
    }

    if (error is StateError && error.toString().contains('未找到章节列表')) {
      return ServiceError(
        code: ServiceErrorCodes.changeSourceChaptersEmpty,
        userMessage: '换源失败，未获取到有效目录',
        debugMessage: error.toString(),
        context: context,
        cause: error,
        stackTrace: stackTrace,
      );
    }

    return ServiceError(
      code: ServiceErrorCodes.changeSourceFailed,
      userMessage: '换源失败，请稍后重试',
      debugMessage: error.toString(),
      context: context,
      cause: error,
      stackTrace: stackTrace,
    );
  }
}

class _PreparedChangeTarget {
  const _PreparedChangeTarget({
    required this.newBookDetail,
    required this.chapters,
    required this.chapterNames,
    required this.newChapterIndex,
    required this.newChapterName,
    required this.newChapterUrl,
  });

  final BookDetail newBookDetail;
  final List<BookChapterInfo> chapters;
  final List<String> chapterNames;
  final int newChapterIndex;
  final String newChapterName;
  final String newChapterUrl;
}
