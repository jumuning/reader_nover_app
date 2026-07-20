import 'dart:collection';

import 'package:dio/dio.dart';

import '../../../util/log_utils.dart';
import '../../../util/performance_log_helper.dart';
import '../../database/dao/book_content_info_dao.dart';
import '../../database/dao/book_source_dao.dart';
import '../../database/drift/app_database.dart' as db;
import '../../database/models/models.dart';
import 'service_result.dart';
import '../source/source_http.dart';
import '../source/source_login_service.dart';
import '../source/web_content_service.dart';
import '../local_book/local_book_content_loader.dart';
import '../local_book/local_book_constants.dart';

enum ChapterContentHitSource {
  memoryCache,
  dbCache,
  network,
}

class _CachedChapterContentLookup {
  const _CachedChapterContentLookup.hit({
    required this.content,
    required this.source,
  });

  const _CachedChapterContentLookup.miss()
      : content = null,
        source = null;

  final String? content;
  final ChapterContentHitSource? source;
}

/// 统一章节正文加载入口：缓存优先，缺失时走网络并回填缓存。
class ChapterContentLoader {
  static const int _maxMemoryCacheEntries = 24;

  final db.AppDatabase _db;
  late final BookContentInfoDao _contentInfoDao =
      BookContentInfoDao(database: _db);
  late final BookSourceDao _bookSourceDao = BookSourceDao(database: _db);
  late final LocalBookContentLoader _localBookContentLoader =
      LocalBookContentLoader(database: _db);
  final LinkedHashMap<String, String> _memoryContentCache =
      LinkedHashMap<String, String>();

  ChapterContentLoader({db.AppDatabase? database})
      : _db = database ?? db.AppDatabase.instance;

  /// 仅从缓存读取章节正文。
  Future<String?> loadCachedContent({
    required int bookSourceId,
    required String bookName,
    required String chapterName,
  }) async {
    final cached = await _readValidCachedContent(
      bookSourceId: bookSourceId,
      bookName: bookName,
      chapterName: chapterName,
    );
    return cached.content;
  }

  /// 获取章节正文（缓存优先，缓存不存在时可选网络回退）。
  Future<String?> loadChapterOriginalContent({
    required int bookSourceId,
    required String bookName,
    required BookChapterInfo chapter,
    bool allowNetwork = true,
    bool forceRefresh = false,
    CancelToken? cancelToken,
  }) async {
    final result = await loadChapterOriginalContentResult(
      bookSourceId: bookSourceId,
      bookName: bookName,
      chapter: chapter,
      allowNetwork: allowNetwork,
      forceRefresh: forceRefresh,
      cancelToken: cancelToken,
    );
    if (result.isFailure && result.error?.code != ServiceErrorCodes.cancelled) {
      LogUtils.e('正文抓取失败: ${result.error!.formatForLog()}');
    }
    return result.data;
  }

  Future<ServiceResult<String>> loadChapterOriginalContentResult({
    required int bookSourceId,
    required String bookName,
    required BookChapterInfo chapter,
    bool allowNetwork = true,
    bool forceRefresh = false,
    CancelToken? cancelToken,
  }) async {
    final chapterName = chapter.chapterName ?? '';
    final perf = PerformanceLogHelper.start(
      'reader.chapterContent',
      fields: <String, Object?>{
        'bookSourceId': bookSourceId,
        'bookName': bookName,
        'chapterIndex': chapter.chapterIndex,
        'chapterName': chapterName,
      },
    );
    if (forceRefresh) {
      _forgetMemoryContent(
        bookSourceId: bookSourceId,
        bookName: bookName,
        chapterName: chapterName,
      );
    } else {
      final cached = await _readValidCachedContent(
        bookSourceId: bookSourceId,
        bookName: bookName,
        chapterName: chapterName,
      );
      if (cached.content != null) {
        return perf.completeWith(
          ServiceResult<String>.success(cached.content!),
          fields: <String, Object?>{
            'source': _hitSourceLabel(cached.source!),
            'cacheHit': true,
            'contentLength': cached.content!.length,
          },
        );
      }
    }

    if (LocalBookConstants.isLocalBookSource(bookSourceId) ||
        LocalBookConstants.isLocalChapterUrl(chapter.chapterUrl)) {
      return _loadLocalChapterOriginalContentResult(
        perf: perf,
        bookSourceId: bookSourceId,
        bookName: bookName,
        chapter: chapter,
        chapterName: chapterName,
      );
    }

    if (!allowNetwork) {
      return perf.completeWith(
        ServiceResult<String>.failure(
          ServiceError(
            code: ServiceErrorCodes.contentNetworkDisabled,
            userMessage: '正文未缓存，且当前不允许联网获取',
            context: _contentContext(
              bookSourceId: bookSourceId,
              bookName: bookName,
              chapter: chapter,
            ),
          ),
        ),
        fields: const <String, Object?>{
          'source': 'miss',
          'cacheHit': false,
          'status': 'cache_miss',
        },
      );
    }

    final chapterUrl = chapter.chapterUrl?.trim() ?? '';
    if (chapterUrl.isEmpty) {
      return perf.completeWith(
        ServiceResult<String>.failure(
          ServiceError(
            code: ServiceErrorCodes.contentChapterUrlMissing,
            userMessage: '正文地址为空，暂时无法获取内容',
            context: _contentContext(
              bookSourceId: bookSourceId,
              bookName: bookName,
              chapter: chapter,
            ),
          ),
        ),
        fields: const <String, Object?>{
          'source': 'miss',
          'cacheHit': false,
          'status': 'chapter_url_missing',
        },
      );
    }

    final source = await _bookSourceDao.findById(bookSourceId);
    if (source == null) {
      return perf.completeWith(
        ServiceResult<String>.failure(
          ServiceError(
            code: ServiceErrorCodes.contentSourceMissing,
            userMessage: '当前书源不存在，无法获取正文',
            context: _contentContext(
              bookSourceId: bookSourceId,
              bookName: bookName,
              chapter: chapter,
            ),
          ),
        ),
        fields: const <String, Object?>{
          'source': 'miss',
          'cacheHit': false,
          'status': 'source_missing',
        },
      );
    }

    String content;
    try {
      content = await WebContentService.getContent(
        source,
        chapter,
        cancelToken: cancelToken,
        forceRefresh: forceRefresh,
      );
    } on SourceLoginRequiredException catch (e) {
      return perf.completeWith(
        ServiceResult<String>.failure(
          ServiceError(
            code: '${ServiceErrorCodes.contentFetchFailed}.login_required',
            userMessage: e.message,
            debugMessage: 'tag: 登录校验',
            context: <String, Object?>{
              ..._contentContext(
                bookSourceId: bookSourceId,
                bookName: bookName,
                chapter: chapter,
              ),
              ...e.loginRequired.toJson(),
            },
            cause: e,
          ),
        ),
        fields: <String, Object?>{
          'source': _hitSourceLabel(ChapterContentHitSource.network),
          'cacheHit': false,
          'status': 'login_required',
        },
      );
    } on CheckException catch (e) {
      return perf.completeWith(
        ServiceResult<String>.failure(
          ServiceError(
            code: '${ServiceErrorCodes.contentFetchFailed}.rule_failed',
            userMessage: e.message,
            debugMessage: 'tag: ${e.tag}',
            context: _contentContext(
              bookSourceId: bookSourceId,
              bookName: bookName,
              chapter: chapter,
            ),
            cause: e,
          ),
        ),
        fields: <String, Object?>{
          'source': _hitSourceLabel(ChapterContentHitSource.network),
          'cacheHit': false,
          'status': 'rule_failed',
        },
      );
    } on DioException catch (e) {
      return perf.completeWith(
        ServiceResult<String>.failure(
          ServiceError(
            code: e.type == DioExceptionType.cancel
                ? ServiceErrorCodes.cancelled
                : ServiceErrorCodes.contentFetchFailed,
            userMessage:
                e.type == DioExceptionType.cancel ? '正文加载已取消' : '正文加载失败，请稍后重试',
            debugMessage: e.toString(),
            context: _contentContext(
              bookSourceId: bookSourceId,
              bookName: bookName,
              chapter: chapter,
            ),
            cause: e,
          ),
        ),
        fields: <String, Object?>{
          'source': _hitSourceLabel(ChapterContentHitSource.network),
          'cacheHit': false,
          'status': e.type == DioExceptionType.cancel ? 'cancelled' : 'failed',
        },
      );
    } catch (e, stackTrace) {
      return perf.completeWith(
        ServiceResult<String>.failure(
          ServiceError(
            code: ServiceErrorCodes.contentFetchFailed,
            userMessage: '正文加载失败，请稍后重试',
            debugMessage: e.toString(),
            context: _contentContext(
              bookSourceId: bookSourceId,
              bookName: bookName,
              chapter: chapter,
            ),
            cause: e,
            stackTrace: stackTrace,
          ),
        ),
        fields: <String, Object?>{
          'source': _hitSourceLabel(ChapterContentHitSource.network),
          'cacheHit': false,
          'status': 'failed',
        },
      );
    }

    final normalized = normalizeContent(content);
    if (normalized.isEmpty) {
      return perf.completeWith(
        ServiceResult<String>.failure(
          ServiceError(
            code: ServiceErrorCodes.contentEmpty,
            userMessage: '正文为空，暂时无法阅读',
            context: _contentContext(
              bookSourceId: bookSourceId,
              bookName: bookName,
              chapter: chapter,
            ),
          ),
        ),
        fields: <String, Object?>{
          'source': _hitSourceLabel(ChapterContentHitSource.network),
          'cacheHit': false,
          'status': 'empty',
        },
      );
    }

    try {
      await _upsertCache(
        bookSourceId: bookSourceId,
        bookName: bookName,
        chapterName: chapterName,
        chapterIndex: chapter.chapterIndex,
        content: normalized,
      );
    } catch (e) {
      LogUtils.e(
        '正文缓存写入失败: ${ServiceError(
          code: ServiceErrorCodes.contentFetchFailed,
          userMessage: '正文已获取，但写入缓存失败',
          debugMessage: e.toString(),
          context: _contentContext(
            bookSourceId: bookSourceId,
            bookName: bookName,
            chapter: chapter,
          ),
          cause: e,
        ).formatForLog()}',
      );
    }

    return perf.completeWith(
      ServiceResult<String>.success(normalized),
      fields: <String, Object?>{
        'source': _hitSourceLabel(ChapterContentHitSource.network),
        'cacheHit': false,
        'contentLength': normalized.length,
      },
    );
  }

  /// 统一正文标准化，保证缓存内容一致。
  static String normalizeContent(String? content) {
    if (content == null) return '';
    return content
        .split('\n')
        .map((p) => p.trim())
        .where((p) => p.isNotEmpty)
        .join('\n');
  }

  Future<_CachedChapterContentLookup> _readValidCachedContent({
    required int bookSourceId,
    required String bookName,
    required String chapterName,
  }) async {
    final cacheKey = _contentCacheKey(
      bookSourceId: bookSourceId,
      bookName: bookName,
      chapterName: chapterName,
    );
    final memoryCached = _memoryContentCache.remove(cacheKey);
    if (memoryCached != null && memoryCached.isNotEmpty) {
      _memoryContentCache[cacheKey] = memoryCached;
      return _CachedChapterContentLookup.hit(
        content: memoryCached,
        source: ChapterContentHitSource.memoryCache,
      );
    }

    final cached = await _contentInfoDao.findByChapter(
      bookSourceId: bookSourceId,
      bookName: bookName,
      chapterName: chapterName,
    );
    if (cached == null) {
      return const _CachedChapterContentLookup.miss();
    }

    final normalized = normalizeContent(cached.bookContent);
    if (normalized.isEmpty) {
      await _contentInfoDao.deleteById(cached.id);
      return const _CachedChapterContentLookup.miss();
    }
    _rememberMemoryContent(cacheKey, normalized);
    return _CachedChapterContentLookup.hit(
      content: normalized,
      source: ChapterContentHitSource.dbCache,
    );
  }

  Map<String, Object?> _contentContext({
    required int bookSourceId,
    required String bookName,
    required BookChapterInfo chapter,
  }) {
    return <String, Object?>{
      'bookSourceId': bookSourceId,
      'bookName': bookName,
      'chapterIndex': chapter.chapterIndex,
      'chapterName': chapter.chapterName,
      'chapterUrl': chapter.chapterUrl,
    };
  }

  void _rememberMemoryContent(String cacheKey, String content) {
    if (content.isEmpty) return;
    _memoryContentCache.remove(cacheKey);
    while (_memoryContentCache.length >= _maxMemoryCacheEntries) {
      _memoryContentCache.remove(_memoryContentCache.keys.first);
    }
    _memoryContentCache[cacheKey] = content;
  }

  void _forgetMemoryContent({
    required int bookSourceId,
    required String bookName,
    required String chapterName,
  }) {
    _memoryContentCache.remove(
      _contentCacheKey(
        bookSourceId: bookSourceId,
        bookName: bookName,
        chapterName: chapterName,
      ),
    );
  }

  String _contentCacheKey({
    required int bookSourceId,
    required String bookName,
    required String chapterName,
  }) {
    return '$bookSourceId|$bookName|$chapterName';
  }

  String _hitSourceLabel(ChapterContentHitSource source) {
    switch (source) {
      case ChapterContentHitSource.memoryCache:
        return 'memory_cache';
      case ChapterContentHitSource.dbCache:
        return 'db_cache';
      case ChapterContentHitSource.network:
        return 'network';
    }
  }

  Future<void> _upsertCache({
    required int bookSourceId,
    required String bookName,
    required String chapterName,
    required int? chapterIndex,
    required String content,
  }) async {
    _rememberMemoryContent(
      _contentCacheKey(
        bookSourceId: bookSourceId,
        bookName: bookName,
        chapterName: chapterName,
      ),
      content,
    );
    await _contentInfoDao.upsert(
      bookSourceId: bookSourceId,
      bookName: bookName,
      chapterName: chapterName,
      chapterIndex: chapterIndex,
      content: content,
    );
  }

  Future<ServiceResult<String>> _loadLocalChapterOriginalContentResult({
    required PerformanceLogScope perf,
    required int bookSourceId,
    required String bookName,
    required BookChapterInfo chapter,
    required String chapterName,
  }) async {
    final localResult = await _localBookContentLoader.loadChapterContent(
      chapterUrl: chapter.chapterUrl,
    );
    if (localResult.isFailure) {
      return perf.completeWith(
        ServiceResult<String>.failure(localResult.error!),
        fields: const <String, Object?>{
          'source': 'local',
          'cacheHit': false,
          'status': 'local_file_failed',
        },
      );
    }

    final normalized = normalizeContent(localResult.requireData());
    _rememberMemoryContent(
      _contentCacheKey(
        bookSourceId: bookSourceId,
        bookName: bookName,
        chapterName: chapterName,
      ),
      normalized,
    );

    return perf.completeWith(
      ServiceResult<String>.success(normalized),
      fields: <String, Object?>{
        'source': 'local',
        'cacheHit': false,
        'contentLength': normalized.length,
      },
    );
  }
}
