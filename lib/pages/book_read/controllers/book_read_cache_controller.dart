import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:reader_nover/app/database/dao/book_content_info_dao.dart';
import 'package:reader_nover/app/database/dao/book_source_dao.dart';
import 'package:reader_nover/app/database/drift/app_database.dart' as db;
import 'package:reader_nover/app/database/models/models.dart';
import 'package:reader_nover/app/service/book/chapter_content_loader.dart';
import 'package:reader_nover/app/service/book/service_result.dart';
import 'package:reader_nover/app/service/local_book/local_book_constants.dart';
import 'package:reader_nover/util/log_utils.dart';

import '../state.dart';

typedef LoadBookChapterCallback = Future<void> Function({
  required int chapter,
  required bool preChapter,
  int initialPage,
  bool forceRefresh,
});

class BookReadCacheController {
  BookReadCacheController({
    required this.state,
    required db.AppDatabase database,
    required ChapterContentLoader chapterContentLoader,
    required this.onUpdate,
    required this.onToggleAppBarVisibility,
    required this.onLoadChapter,
    required this.onLoadCachedChapters,
  })  : _database = database,
        _chapterContentLoader = chapterContentLoader;

  final BookReadState state;
  final db.AppDatabase _database;
  late final BookContentInfoDao _contentInfoDao =
      BookContentInfoDao(database: _database);
  late final BookSourceDao _bookSourceDao = BookSourceDao(database: _database);
  final ChapterContentLoader _chapterContentLoader;
  final VoidCallback onUpdate;
  final VoidCallback onToggleAppBarVisibility;
  final LoadBookChapterCallback onLoadChapter;
  final Future<void> Function() onLoadCachedChapters;

  final List<CancelToken> _cacheCancelTokens = [];

  Future<void> reloadCurrentChapter() async {
    try {
      if (LocalBookConstants.isLocalBookSource(state.bookInfo.bookSourceId)) {
        Get.snackbar(
          '提示',
          '本地书籍无需刷新正文',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      if (state.isAppBarVisible) {
        onToggleAppBarVisibility();
      }

      final chapters = state.bookDetail.chapters;
      if (chapters == null || chapters.isEmpty) {
        LogUtils.e('章节列表为空，无法重新加载');
        return;
      }

      final currentChapterInfo = chapters.firstWhere(
        (chapter) => chapter.chapterIndex == state.currentChapterIndex,
        orElse: () => chapters.first,
      );
      final chapterNameToDelete = currentChapterInfo.chapterName ?? '';

      await _contentInfoDao.deleteByChapter(
        bookSourceId: state.bookInfo.bookSourceId,
        bookName: state.bookInfo.name,
        chapterName: chapterNameToDelete,
        chapterIndex: state.currentChapterIndex,
      );

      LogUtils.d(
          '已删除章节缓存: $chapterNameToDelete (index: ${state.currentChapterIndex})');

      await onLoadChapter(
        chapter: state.currentChapterIndex,
        preChapter: false,
        initialPage: state.currentPage,
        forceRefresh: true,
      );
      LogUtils.d('章节已重新加载,对应章节${state.currentChapterIndex}');
    } catch (e) {
      LogUtils.e('重新加载失败: $e');
    }
  }

  Future<void> cacheAllChapters() async {
    if (state.isCaching) return;

    if (LocalBookConstants.isLocalBookSource(state.bookInfo.bookSourceId)) {
      final chapters = state.bookDetail.chapters ?? const <BookChapterInfo>[];
      state.cachedChapterIndices = chapters
          .map((chapter) => chapter.chapterIndex)
          .whereType<int>()
          .toSet();
      state.cachedChapterCount = state.cachedChapterIndices.length;
      state.totalCacheChapterCount = chapters.length;
      state.cacheProgress = chapters.isEmpty ? 0 : 1;
      onUpdate();
      Get.snackbar(
        '提示',
        '本地书籍无需缓存正文',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final chapters = state.bookDetail.chapters;
    if (chapters == null || chapters.isEmpty) return;

    final cachedChapters =
        await _contentInfoDao.listCachedChapterIdentitiesByBook(
      bookSourceId: state.bookInfo.bookSourceId,
      bookName: state.bookInfo.name,
    );

    final cachedChapterIndices =
        cachedChapters.map((chapter) => chapter.chapterIndex).whereType<int>();
    final cachedChapterNames = cachedChapters
        .map((chapter) => chapter.chapterName)
        .whereType<String>();
    final cachedChapterIndexSet = cachedChapterIndices.toSet();
    final cachedChapterNameSet = cachedChapterNames.toSet();

    final needCacheChapters = chapters
        .where(
          (chapter) => !_isChapterCached(
              chapter, cachedChapterIndexSet, cachedChapterNameSet),
        )
        .toList();

    if (needCacheChapters.isEmpty) {
      Get.snackbar('提示', '所有章节已缓存');
      return;
    }

    state.isCaching = true;
    state.isCacheCancelled = false;
    final alreadyCachedCount = chapters.length - needCacheChapters.length;
    state.cachedChapterCount = alreadyCachedCount;
    state.totalCacheChapterCount = chapters.length;
    state.cacheProgress = alreadyCachedCount / chapters.length;

    _cancelAllCacheDownloads();
    onUpdate();

    try {
      final concurrencyLimit = await _resolveCacheConcurrencyLimit();
      LogUtils.d(
        '开始批量缓存，共 ${needCacheChapters.length} 章，并发数 $concurrencyLimit',
      );
      await _runCacheWorkerPool(
        needCacheChapters,
        concurrencyLimit: concurrencyLimit,
      );

      if (!state.isCacheCancelled &&
          state.cachedChapterCount == state.totalCacheChapterCount) {
        Get.snackbar('提示', '缓存完成，共缓存 ${state.cachedChapterCount} 章');
      }

      await onLoadCachedChapters();
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) {
        LogUtils.d('缓存下载已取消');
      } else {
        LogUtils.e('缓存章节异常: $e');
        Get.snackbar('错误', '缓存失败: $e');
      }
    } catch (e) {
      LogUtils.e('缓存章节异常: $e');
      Get.snackbar('错误', '缓存失败: $e');
    } finally {
      state.isCaching = false;
      _cancelAllCacheDownloads();
      onUpdate();
    }
  }

  void cancelCache() {
    if (!state.isCaching) return;

    state.isCacheCancelled = true;
    _cancelAllCacheDownloads();
    onUpdate();
    LogUtils.d('用户取消缓存');
  }

  void dispose() {
    _cancelAllCacheDownloads();
  }

  Future<bool> _cacheSingleChapter(BookChapterInfo chapter) async {
    CancelToken? cancelToken;
    try {
      cancelToken = CancelToken();
      _cacheCancelTokens.add(cancelToken);

      final contentResult =
          await _chapterContentLoader.loadChapterOriginalContentResult(
        bookSourceId: state.bookInfo.bookSourceId,
        bookName: state.bookInfo.name,
        chapter: chapter,
        cancelToken: cancelToken,
      );
      if (contentResult.isFailure) {
        final error = contentResult.error!;
        if (error.code != ServiceErrorCodes.cancelled) {
          LogUtils.e('缓存失败: ${chapter.chapterName}, ${error.formatForLog()}');
        }
        return false;
      }
      return contentResult.requireData().isNotEmpty;
    } on DioException catch (e) {
      if (e.type != DioExceptionType.cancel) {
        LogUtils.d('缓存失败: ${chapter.chapterName}, $e');
      }
      return false;
    } catch (e) {
      LogUtils.d('缓存失败: ${chapter.chapterName}, $e');
      return false;
    } finally {
      if (cancelToken != null) {
        _cacheCancelTokens.remove(cancelToken);
      }
    }
  }

  Future<void> _runCacheWorkerPool(
    List<BookChapterInfo> chapters, {
    required int concurrencyLimit,
  }) async {
    var nextIndex = 0;
    final workerCount =
        chapters.length < concurrencyLimit ? chapters.length : concurrencyLimit;

    Future<void> worker() async {
      while (!state.isCacheCancelled) {
        final index = nextIndex;
        if (index >= chapters.length) return;
        nextIndex++;

        final chapter = chapters[index];
        final success = await _cacheSingleChapter(chapter);
        if (!success || state.isCacheCancelled) {
          continue;
        }

        state.cachedChapterCount++;
        final chapterIndex = chapter.chapterIndex;
        if (chapterIndex != null) {
          state.cachedChapterIndices.add(chapterIndex);
        }
        state.cacheProgress =
            state.cachedChapterCount / state.totalCacheChapterCount;
        onUpdate();
      }
    }

    await Future.wait(List.generate(workerCount, (_) => worker()));

    if (state.isCacheCancelled) {
      LogUtils.d('章节缓存被取消');
      Get.snackbar(
        '提示',
        '已取消缓存，已缓存 ${state.cachedChapterCount}/${state.totalCacheChapterCount} 章',
      );
    }
  }

  bool _isChapterCached(
    BookChapterInfo chapter,
    Set<int> cachedChapterIndices,
    Set<String> cachedChapterNames,
  ) {
    final chapterIndex = chapter.chapterIndex;
    if (chapterIndex != null && cachedChapterIndices.contains(chapterIndex)) {
      return true;
    }
    return cachedChapterNames.contains(chapter.chapterName);
  }

  Future<int> _resolveCacheConcurrencyLimit() async {
    final source = await _bookSourceDao.findById(state.bookInfo.bookSourceId);
    final rate = source?.concurrentRate?.trim();
    if (rate == null || rate.isEmpty) return 6;

    final parts = rate.split(',');
    final count = int.tryParse(parts.first.trim());
    if (count == null || count <= 0) return 4;
    if (count <= 1) return 1;
    if (count <= 3) return 2;
    if (count <= 6) return 4;
    return 6;
  }

  void _cancelAllCacheDownloads() {
    for (final token in _cacheCancelTokens) {
      token.cancel('取消缓存下载');
    }
    _cacheCancelTokens.clear();
  }
}
