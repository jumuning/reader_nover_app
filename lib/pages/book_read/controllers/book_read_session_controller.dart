import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'package:reader_nover/app/database/models/models.dart';
import 'package:reader_nover/app/service/book/chapter_content_loader.dart';
import 'package:reader_nover/app/service/book/service_result.dart';
import 'package:reader_nover/pages/book_read/page_turn/pagination_service.dart';
import 'package:reader_nover/util/dialog/dialog_utils.dart';
import 'package:reader_nover/util/log_utils.dart';

import '../state.dart';
import '../page_turn/two_page_spread_strategy.dart';

typedef LoadReadChaptersCallback = Future<void> Function();
typedef AsyncVoidCallback = Future<void> Function();
typedef SaveReadProgressCallback = void Function();
typedef OpenSourceLoginForChapterCallback = Future<bool> Function(
  ServiceError error,
);

class _ChapterLoadFailure implements Exception {
  const _ChapterLoadFailure(this.error);

  final ServiceError error;
}

enum _CrossChapterAdvanceOutcome {
  success,
  stopped,
  failed,
}

class _CrossChapterRecoveryRetryTask {
  const _CrossChapterRecoveryRetryTask({
    required this.pre,
    required this.nextChapterInfo,
    required this.deferReadChaptersRefresh,
    required this.deferReadHistoryStart,
    required this.transitionEpoch,
  });

  final bool pre;
  final BookChapterInfo nextChapterInfo;
  final bool deferReadChaptersRefresh;
  final bool deferReadHistoryStart;
  final int transitionEpoch;
}

class BookReadSessionController {
  BookReadSessionController({
    required this.state,
    required ChapterContentLoader chapterContentLoader,
    required PaginationService Function() paginationService,
    required this.onUpdate,
    required this.onToggleAppBarVisibility,
    required this.onStartReadHistory,
    required this.onEndReadHistory,
    required this.onLoadReadChapters,
    required this.onSaveReadProgress,
    required this.onSyncBookmarkStatus,
    required this.onOpenSourceLoginForChapter,
  })  : _chapterContentLoader = chapterContentLoader,
        _paginationService = paginationService;

  final BookReadState state;
  final ChapterContentLoader _chapterContentLoader;
  final PaginationService Function() _paginationService;
  final VoidCallback onUpdate;
  final VoidCallback onToggleAppBarVisibility;
  final AsyncVoidCallback onStartReadHistory;
  final AsyncVoidCallback onEndReadHistory;
  final LoadReadChaptersCallback onLoadReadChapters;
  final SaveReadProgressCallback onSaveReadProgress;
  final VoidCallback onSyncBookmarkStatus;
  final OpenSourceLoginForChapterCallback onOpenSourceLoginForChapter;

  CancelToken? _chapterCancelToken;
  final Map<String, Future<_PreparedChapterData?>> _chapterLoadTasks =
      <String, Future<_PreparedChapterData?>>{};
  static final RegExp _newlinePattern = RegExp(r'\n+');
  static const Duration _deferredPreloadDelay = Duration(milliseconds: 350);
  static const Duration _initialEntryPreloadDelay =
      Duration(milliseconds: 1200);
  static const Duration _lookAheadPreloadGap = Duration(milliseconds: 120);
  static const Duration _crossChapterSlowFeedbackDelay =
      Duration(milliseconds: 1500);
  static const String _loginRequiredErrorCode =
      '${ServiceErrorCodes.contentFetchFailed}.login_required';
  static const List<Duration> _crossChapterAutoRetryDelays = <Duration>[
    Duration(milliseconds: 900),
    Duration(milliseconds: 1800),
  ];
  int _readHistoryTransitionEpoch = 0;
  int _preloadScheduleEpoch = 0;
  int _crossChapterTransitionEpoch = 0;
  bool _isDisposed = false;
  ServiceError? _lastChapterLoadFailureError;
  StreamSubscription<List<ConnectivityResult>>?
      _crossChapterRecoveryConnectivitySubscription;
  _CrossChapterRecoveryRetryTask? _crossChapterRecoveryRetryTask;
  bool _hasUsedCrossChapterRecoveryRetry = false;

  void dispose() {
    _isDisposed = true;
    _preloadScheduleEpoch++;
    _clearCrossChapterTransition(notify: false, cancelLoading: true);
    _cancelCrossChapterRecoveryRetry();
    _cancelCurrentChapterLoadToken('释放阅读会话');
    _chapterLoadTasks.clear();
    state.sessionChapterCache.clear();
  }

  void cancelCurrentChapterLoad([String reason = '取消章节加载']) {
    _cancelCurrentChapterLoadToken(reason);
  }

  void _cancelCurrentChapterLoadToken(String reason) {
    final token = _chapterCancelToken;
    _chapterCancelToken = null;
    _cancelTokenIfActive(token, reason);
  }

  static void _cancelTokenIfActive(CancelToken? token, String reason) {
    if (token == null || token.isCancelled) return;
    token.cancel(reason);
  }

  void previousPage() {
    _clearCrossChapterTransition(notify: false, cancelLoading: true);
    if (state.bookContentList.isEmpty || state.pageSize == 0) {
      LogUtils.d('没有内容或分页，无法翻页');
      return;
    }

    if (state.currentPage <= 0) {
      if (_findCurrentListIndex() <= 0) {
        state.currentPage = 0;
        return;
      }

      moveToPrevChapterWithCache().then((success) {
        if (!success) {
          previousChapter(true);
        }
      });
      return;
    }

    state.currentPage = state.isTwoPageMode
        ? TwoPageSpreadStrategy.previousAnchor(state.currentPage)
        : state.currentPage - 1;
    onSaveReadProgress();

    if (state.isAppBarVisible) onToggleAppBarVisibility();
    onUpdate();
  }

  void jumpToPage(int page) {
    _clearCrossChapterTransition(notify: false, cancelLoading: true);
    if (page < 0 || page >= state.pageSize) return;
    state.currentPage =
        state.isTwoPageMode ? TwoPageSpreadStrategy.anchorFor(page) : page;
    onSaveReadProgress();
    onUpdate();
  }

  void nextPage() {
    if (state.isCrossChapterTransition) {
      return;
    }
    if (state.bookContentList.isEmpty || state.pageSize == 0) return;

    final nextPage =
        state.isTwoPageMode ? state.currentPage + 2 : state.currentPage + 1;
    if (nextPage >= state.pageSize) {
      final currentListIndex = _findCurrentListIndex();
      final chapters = state.bookDetail.chapters;
      if (currentListIndex < 0 ||
          currentListIndex >= (chapters?.length ?? 0) - 1) {
        LogUtils.d('已经是最后一章');
        state.currentPage = state.isTwoPageMode
            ? TwoPageSpreadStrategy.anchorFor(state.pageSize - 1)
            : state.pageSize - 1;
        return;
      }

      final nextChapterInfo = chapters![currentListIndex + 1];
      if (!_hasReadyNextChapterCache()) {
        _ensureCrossChapterTransitionActive(nextChapterInfo);
      }
      unawaited(
        _advanceToNextChapter(
          pre: false,
          nextChapterInfo: nextChapterInfo,
        ),
      );
      return;
    }

    state.currentPage = nextPage;
    onSaveReadProgress();

    if (state.isAppBarVisible) onToggleAppBarVisibility();
    onUpdate();
  }

  Future<void> loadChapter({
    required int chapter,
    required bool preChapter,
    int initialPage = 0,
    bool forceRefresh = false,
  }) async {
    _clearCrossChapterTransition(notify: false, cancelLoading: true);
    await _loadChapterInternal(
      chapter: chapter,
      preChapter: preChapter,
      initialPage: initialPage,
      chapterUrlOverride: state.currentChapterUrl,
      showLoadingOverlay: true,
      preserveCurrentContentUntilReady: false,
      forceRefresh: forceRefresh,
    );
  }

  Future<bool> loadInitialChapter({
    required int chapter,
    int initialPage = 0,
  }) async {
    _clearCrossChapterTransition(notify: false, cancelLoading: true);
    return _loadChapterInternal(
      chapter: chapter,
      preChapter: false,
      initialPage: initialPage,
      chapterUrlOverride: state.currentChapterUrl,
      showLoadingOverlay: false,
      preserveCurrentContentUntilReady: false,
      preloadPrev: false,
      preloadNext: true,
      preloadLookAhead: false,
      preloadDelay: _initialEntryPreloadDelay,
    );
  }

  Future<void> nextChapterSilently(
    bool pre, {
    bool deferReadChaptersRefresh = false,
    bool deferReadHistoryStart = false,
  }) async {
    final chapters = state.bookDetail.chapters;
    if (chapters == null || chapters.isEmpty) return;

    final currentListIndex = _findCurrentListIndex();
    if (currentListIndex < 0 || currentListIndex >= chapters.length - 1) {
      LogUtils.d('已经是最后一章');
      return;
    }

    final nextChapterInfo = chapters[currentListIndex + 1];
    final nextChapterIndex = nextChapterInfo.chapterIndex;
    if (nextChapterIndex == null) return;

    state.prevChapterCache = _snapshotCurrentChapterCache();
    final endReadHistoryFuture = onEndReadHistory();
    final success = await _loadChapterInternal(
      chapter: nextChapterIndex,
      preChapter: pre,
      chapterUrlOverride: nextChapterInfo.chapterUrl ?? '',
      showLoadingOverlay: false,
      preserveCurrentContentUntilReady: true,
    );
    if (!success) {
      return;
    }
    await _completeReadHistoryTransition(
      endReadHistoryFuture,
      deferReadHistoryStart: deferReadHistoryStart,
      expectedChapterIndex: state.currentChapterIndex,
    );
    if (deferReadChaptersRefresh) {
      unawaited(onLoadReadChapters());
    } else {
      await onLoadReadChapters();
    }
  }

  String? getUpcomingNextChapterName() =>
      _findAdjacentChapterInfo(isNext: true)?.chapterName;

  Future<void> retryCrossChapterTransition() async {
    if (!state.isCrossChapterTransition ||
        !state.isCrossChapterTransitionFailed ||
        state.crossChapterIndex == null) {
      return;
    }

    final nextChapterInfo = BookChapterInfo(
      bookSourceId: state.bookInfo.bookSourceId,
      chapterIndex: state.crossChapterIndex,
      chapterName: state.crossChapterName,
      chapterUrl: state.crossChapterUrl,
    );
    await _advanceToNextChapter(
      pre: false,
      nextChapterInfo: nextChapterInfo,
    );
  }

  void dismissCrossChapterTransition() {
    _clearCrossChapterTransition(cancelLoading: true);
  }

  Future<void> _advanceToNextChapter({
    required bool pre,
    required BookChapterInfo nextChapterInfo,
    bool deferReadChaptersRefresh = false,
    bool deferReadHistoryStart = false,
  }) async {
    final showInlineTransition = !_hasReadyNextChapterCache() ||
        (state.isCrossChapterTransition &&
            state.crossChapterIndex == nextChapterInfo.chapterIndex);
    final transitionEpoch = showInlineTransition
        ? _ensureCrossChapterTransitionActive(nextChapterInfo)
        : _crossChapterTransitionEpoch;

    Future<void> refreshReadChapters() async {
      if (deferReadChaptersRefresh) {
        unawaited(onLoadReadChapters());
      } else {
        await onLoadReadChapters();
      }
    }

    _cancelCrossChapterRecoveryRetry();

    var autoRetryAttempt = 0;
    while (true) {
      final outcome = await _advanceToNextChapterOnce(
        pre: pre,
        nextChapterInfo: nextChapterInfo,
        deferReadChaptersRefresh: deferReadChaptersRefresh,
        deferReadHistoryStart: deferReadHistoryStart,
        showInlineTransition: showInlineTransition,
        transitionEpoch: transitionEpoch,
        refreshReadChapters: refreshReadChapters,
      );
      switch (outcome) {
        case _CrossChapterAdvanceOutcome.success:
        case _CrossChapterAdvanceOutcome.stopped:
          return;
        case _CrossChapterAdvanceOutcome.failed:
          break;
      }

      if (!showInlineTransition ||
          !_isCrossChapterTransitionEpochActive(transitionEpoch)) {
        return;
      }

      if (_isLastChapterLoadLoginRequiredFailure()) {
        _markCrossChapterTransitionFailed(
          _lastChapterLoadFailureError?.userMessage ?? '书源登录态失效，请登录后重试',
        );
        return;
      }

      if (autoRetryAttempt < _crossChapterAutoRetryDelays.length) {
        autoRetryAttempt++;
        _setCrossChapterTransitionLoadingState(
          '网络波动，正在重试（$autoRetryAttempt/${_crossChapterAutoRetryDelays.length}）',
        );
        await Future<void>.delayed(
          _crossChapterAutoRetryDelays[autoRetryAttempt - 1],
        );
        continue;
      }

      final waitingForRecovery = await _waitForNetworkRecoveryRetry(
        pre: pre,
        nextChapterInfo: nextChapterInfo,
        deferReadChaptersRefresh: deferReadChaptersRefresh,
        deferReadHistoryStart: deferReadHistoryStart,
        transitionEpoch: transitionEpoch,
      );
      if (waitingForRecovery) {
        return;
      }

      if (_isCrossChapterTransitionEpochActive(transitionEpoch)) {
        _markCrossChapterTransitionFailed(
          state.crossChapterStatusMessage ?? '下一章加载失败，请重试',
        );
      }
      return;
    }
  }

  Future<_CrossChapterAdvanceOutcome> _advanceToNextChapterOnce({
    required bool pre,
    required BookChapterInfo nextChapterInfo,
    required bool deferReadChaptersRefresh,
    required bool deferReadHistoryStart,
    required bool showInlineTransition,
    required int transitionEpoch,
    required Future<void> Function() refreshReadChapters,
  }) async {
    final nextChapterIndex = nextChapterInfo.chapterIndex;
    if (nextChapterIndex == null) {
      return _CrossChapterAdvanceOutcome.stopped;
    }

    try {
      final movedWithCache = await moveToNextChapterWithCache(
        deferReadHistoryStart: deferReadHistoryStart,
      );
      if (movedWithCache) {
        await refreshReadChapters();
        return _CrossChapterAdvanceOutcome.success;
      }

      if (showInlineTransition &&
          !_isCrossChapterTransitionEpochActive(
            transitionEpoch,
          )) {
        return _CrossChapterAdvanceOutcome.stopped;
      }

      final cacheReady = await ensureNextChapterCacheReady();
      if (showInlineTransition &&
          !_isCrossChapterTransitionEpochActive(
            transitionEpoch,
          )) {
        return _CrossChapterAdvanceOutcome.stopped;
      }

      if (cacheReady) {
        final movedAfterWarmup = await moveToNextChapterWithCache(
          deferReadHistoryStart: deferReadHistoryStart,
        );
        if (movedAfterWarmup) {
          await refreshReadChapters();
          return _CrossChapterAdvanceOutcome.success;
        }
      }

      state.prevChapterCache = _snapshotCurrentChapterCache();
      final endReadHistoryFuture = onEndReadHistory();
      final success = await _loadChapterInternal(
        chapter: nextChapterIndex,
        preChapter: pre,
        chapterUrlOverride: nextChapterInfo.chapterUrl ?? '',
        showLoadingOverlay: false,
        preserveCurrentContentUntilReady: true,
      );
      if (!success) {
        if (showInlineTransition &&
            !_isCrossChapterTransitionEpochActive(
              transitionEpoch,
            )) {
          return _CrossChapterAdvanceOutcome.stopped;
        }
        return _CrossChapterAdvanceOutcome.failed;
      }
      await _completeReadHistoryTransition(
        endReadHistoryFuture,
        deferReadHistoryStart: deferReadHistoryStart,
        expectedChapterIndex: state.currentChapterIndex,
      );
      await refreshReadChapters();
      return _CrossChapterAdvanceOutcome.success;
    } catch (e, stackTrace) {
      LogUtils.e('跨章节切换失败: $e', stackTrace: stackTrace);
      if (showInlineTransition &&
          !_isCrossChapterTransitionEpochActive(transitionEpoch)) {
        return _CrossChapterAdvanceOutcome.stopped;
      }
      return _CrossChapterAdvanceOutcome.failed;
    }
  }

  void _setCrossChapterTransitionLoadingState(String message) {
    if (!state.isCrossChapterTransition) return;
    state.isCrossChapterTransitionFailed = false;
    state.isCrossChapterTransitionSlow = true;
    state.crossChapterStatusMessage = message;
    onUpdate();
  }

  Future<bool> _waitForNetworkRecoveryRetry({
    required bool pre,
    required BookChapterInfo nextChapterInfo,
    required bool deferReadChaptersRefresh,
    required bool deferReadHistoryStart,
    required int transitionEpoch,
  }) async {
    if (_hasUsedCrossChapterRecoveryRetry) {
      return false;
    }
    if (!_isCrossChapterTransitionEpochActive(transitionEpoch)) {
      return false;
    }

    final connectivityResults = await Connectivity().checkConnectivity();
    if (_hasAvailableConnectivity(connectivityResults)) {
      return false;
    }

    _hasUsedCrossChapterRecoveryRetry = true;
    _setCrossChapterTransitionLoadingState('网络不可用，恢复后将自动重试');

    _crossChapterRecoveryRetryTask = _CrossChapterRecoveryRetryTask(
      pre: pre,
      nextChapterInfo: nextChapterInfo,
      deferReadChaptersRefresh: deferReadChaptersRefresh,
      deferReadHistoryStart: deferReadHistoryStart,
      transitionEpoch: transitionEpoch,
    );
    await _crossChapterRecoveryConnectivitySubscription?.cancel();
    _crossChapterRecoveryConnectivitySubscription =
        Connectivity().onConnectivityChanged.listen((results) {
      if (!_hasAvailableConnectivity(results)) {
        return;
      }
      final task = _crossChapterRecoveryRetryTask;
      if (task == null) {
        return;
      }
      if (!_isCrossChapterTransitionEpochActive(task.transitionEpoch)) {
        _cancelCrossChapterRecoveryRetry();
        return;
      }
      _cancelCrossChapterRecoveryRetry();
      unawaited(_retryCrossChapterAfterNetworkRecovery(task));
    });
    return true;
  }

  Future<void> _retryCrossChapterAfterNetworkRecovery(
    _CrossChapterRecoveryRetryTask task,
  ) async {
    if (!_isCrossChapterTransitionEpochActive(task.transitionEpoch)) {
      return;
    }

    _setCrossChapterTransitionLoadingState('网络已恢复，正在重试');
    final outcome = await _advanceToNextChapterOnce(
      pre: task.pre,
      nextChapterInfo: task.nextChapterInfo,
      deferReadChaptersRefresh: task.deferReadChaptersRefresh,
      deferReadHistoryStart: task.deferReadHistoryStart,
      showInlineTransition: true,
      transitionEpoch: task.transitionEpoch,
      refreshReadChapters: () async {
        if (task.deferReadChaptersRefresh) {
          unawaited(onLoadReadChapters());
        } else {
          await onLoadReadChapters();
        }
      },
    );
    if (outcome == _CrossChapterAdvanceOutcome.failed &&
        _isCrossChapterTransitionEpochActive(task.transitionEpoch)) {
      _markCrossChapterTransitionFailed(
        state.crossChapterStatusMessage ?? '下一章加载失败，请重试',
      );
    }
  }

  bool _hasAvailableConnectivity(List<ConnectivityResult> results) {
    return results.any((item) => item != ConnectivityResult.none);
  }

  void _cancelCrossChapterRecoveryRetry() {
    _crossChapterRecoveryRetryTask = null;
    final subscription = _crossChapterRecoveryConnectivitySubscription;
    _crossChapterRecoveryConnectivitySubscription = null;
    if (subscription != null) {
      unawaited(subscription.cancel());
    }
  }

  int _ensureCrossChapterTransitionActive(BookChapterInfo chapter) {
    if (state.isCrossChapterTransition &&
        !state.isCrossChapterTransitionFailed &&
        state.crossChapterIndex == chapter.chapterIndex &&
        state.crossChapterUrl == chapter.chapterUrl) {
      return _crossChapterTransitionEpoch;
    }
    return _startCrossChapterTransition(chapter);
  }

  int _startCrossChapterTransition(BookChapterInfo chapter) {
    _cancelCrossChapterRecoveryRetry();
    _hasUsedCrossChapterRecoveryRetry = false;
    final epoch = ++_crossChapterTransitionEpoch;
    state.crossChapterIndex = chapter.chapterIndex;
    state.crossChapterName = chapter.chapterName;
    state.crossChapterUrl = chapter.chapterUrl;
    state.crossChapterContent = null;
    state.isCrossChapterTransition = true;
    state.isCrossChapterTransitionSlow = false;
    state.isCrossChapterTransitionFailed = false;
    state.crossChapterStatusMessage = '正在加载下一章';
    onUpdate();
    unawaited(_markCrossChapterTransitionSlowLater(epoch));
    return epoch;
  }

  Future<void> _markCrossChapterTransitionSlowLater(int epoch) async {
    await Future<void>.delayed(_crossChapterSlowFeedbackDelay);
    if (!_isCrossChapterTransitionEpochActive(epoch) ||
        state.isCrossChapterTransitionFailed) {
      return;
    }
    state.isCrossChapterTransitionSlow = true;
    if (state.crossChapterStatusMessage == null ||
        state.crossChapterStatusMessage == '正在加载下一章') {
      state.crossChapterStatusMessage = '网络较慢，继续加载中';
    }
    onUpdate();
  }

  bool _isCrossChapterTransitionEpochActive(int epoch) {
    return !_isDisposed &&
        state.isCrossChapterTransition &&
        epoch == _crossChapterTransitionEpoch;
  }

  void _markCrossChapterTransitionFailed(String message) {
    if (!state.isCrossChapterTransition) return;
    state.isCrossChapterTransitionSlow = false;
    state.isCrossChapterTransitionFailed = true;
    state.crossChapterStatusMessage = message;
    onUpdate();
  }

  void _clearCrossChapterTransition({
    bool notify = true,
    bool cancelLoading = false,
  }) {
    _crossChapterTransitionEpoch++;
    _cancelCrossChapterRecoveryRetry();
    _hasUsedCrossChapterRecoveryRetry = false;
    if (cancelLoading) {
      _cancelCurrentChapterLoadToken('取消跨章节加载');
    }
    state.isCrossChapterTransition = false;
    state.isCrossChapterTransitionSlow = false;
    state.isCrossChapterTransitionFailed = false;
    state.crossChapterStatusMessage = null;
    state.crossChapterIndex = null;
    state.crossChapterName = null;
    state.crossChapterUrl = null;
    state.crossChapterContent = null;
    if (notify) {
      onUpdate();
    }
  }

  bool _hasReadyNextChapterCache() {
    final nextChapter = _findAdjacentChapterInfo(isNext: true);
    final nextChapterIndex = nextChapter?.chapterIndex;
    if (nextChapterIndex == null) return false;
    final existingCache = _findCachedChapter(nextChapterIndex);
    return _isChapterCacheCompatible(existingCache);
  }

  Future<bool> _loadChapterInternal({
    required int chapter,
    required bool preChapter,
    required String chapterUrlOverride,
    int initialPage = 0,
    required bool showLoadingOverlay,
    required bool preserveCurrentContentUntilReady,
    bool preloadPrev = true,
    bool preloadNext = true,
    bool preloadLookAhead = true,
    Duration preloadDelay = _deferredPreloadDelay,
    Duration? loadTimeout,
    bool forceRefresh = false,
    bool allowLoginRetry = true,
  }) async {
    var loadingOverlayVisible = false;
    if (showLoadingOverlay) {
      DialogUtils.loading();
      loadingOverlayVisible = true;
    }

    _cancelCurrentChapterLoadToken('加载新章节');
    _chapterCancelToken = CancelToken();

    final oldChapterIndex = state.currentChapterIndex;
    final oldChapterName = state.currentChapter;
    final oldChapterUrl = state.currentChapterUrl;
    final oldPageSize = state.pageSize;
    final oldBookContentList = List<String>.from(state.bookContentList);
    final oldBookContent = state.bookContent;
    final oldLastBookContent = state.lastBookContent;

    try {
      LogUtils.d('章节标签：$chapter');

      final chapters = state.bookDetail.chapters;
      final effectiveChapters = chapters != null && chapters.isNotEmpty
          ? chapters
          : <BookChapterInfo>[
              BookChapterInfo(
                bookSourceId: state.bookInfo.bookSourceId,
                chapterIndex: chapter,
                chapterName: state.currentChapter,
                chapterUrl: chapterUrlOverride,
              ),
            ];

      final currentListIndex = effectiveChapters.indexWhere(
        (item) => item.chapterIndex == chapter,
      );
      final currentChapterInfo = currentListIndex >= 0
          ? effectiveChapters[currentListIndex]
          : effectiveChapters[0];
      final resolvedChapterIndex = currentChapterInfo.chapterIndex ?? chapter;
      final ruleContentUrl = chapterUrlOverride.trim().isNotEmpty
          ? chapterUrlOverride
          : (currentChapterInfo.chapterUrl ?? '');
      LogUtils.d('搜索地址: $ruleContentUrl');

      if (!preserveCurrentContentUntilReady) {
        state.pageSize = 0;
        state.bookContentList = const <String>[];
        state.lastBookContent = ' ';
        state.currentChapterIndex = resolvedChapterIndex;
        state.currentChapter = currentChapterInfo.chapterName ?? '';
      }

      final preparedChapter = await _loadPreparedChapter(
        chapterIndex: resolvedChapterIndex,
        chapterName: currentChapterInfo.chapterName ?? '',
        chapterUrl: ruleContentUrl,
        cancelToken: _chapterCancelToken,
        timeout: loadTimeout,
        forceRefresh: forceRefresh,
      );
      if (preparedChapter == null || preparedChapter.pages.isEmpty) {
        throw Exception('章节加载结果为空');
      }

      _lastChapterLoadFailureError = null;
      state.currentChapterIndex = resolvedChapterIndex;
      state.currentChapter = currentChapterInfo.chapterName ?? '';
      state.currentChapterUrl = ruleContentUrl;
      state.bookContent = preparedChapter.content;
      state.bookContentList = preparedChapter.pages;
      state.pageSize = preparedChapter.pages.length;

      if (preChapter) {
        state.currentPage = state.isTwoPageMode
            ? TwoPageSpreadStrategy.anchorFor(state.pageSize - 1)
            : state.pageSize - 1;
      } else if (initialPage > 0 && initialPage < state.pageSize) {
        state.currentPage = state.isTwoPageMode
            ? TwoPageSpreadStrategy.anchorFor(initialPage)
            : initialPage;
      } else {
        state.currentPage = 0;
      }
      state.lastBookContent = state.bookContentList[state.currentPage];

      _clearCrossChapterTransition(notify: false, cancelLoading: false);
      onSaveReadProgress();
      _updateCurrentChapterCache(
        paginationCacheKey: preparedChapter.paginationCacheKey,
      );
      onSyncBookmarkStatus();
      onUpdate();
      _scheduleAdjacentChapterPreloads(
        includePrev: preloadPrev,
        includeNext: preloadNext,
        includeLookAhead: preloadLookAhead,
        delay: preloadDelay,
      );
      return true;
    } on _ChapterLoadFailure catch (e) {
      if (e.error.code == ServiceErrorCodes.cancelled) {
        LogUtils.d('章节加载已取消');
        _lastChapterLoadFailureError = null;
      } else {
        _lastChapterLoadFailureError = e.error;
        LogUtils.e('加载章节失败: ${e.error.formatForLog()}');
        if (state.isCrossChapterTransition) {
          state.crossChapterStatusMessage = e.error.userMessage;
        }
        _restoreChapterState(
          chapterIndex: oldChapterIndex,
          chapterName: oldChapterName,
          chapterUrl: oldChapterUrl,
          pageSize: oldPageSize,
          bookContentList: oldBookContentList,
          bookContent: oldBookContent,
          lastBookContent: oldLastBookContent,
        );
        if (allowLoginRetry && _isLoginRequiredError(e.error)) {
          final retried = await _openLoginAndRetryChapterLoad(
            error: e.error,
            chapter: chapter,
            preChapter: preChapter,
            chapterUrlOverride: chapterUrlOverride,
            initialPage: initialPage,
            showLoadingOverlay: showLoadingOverlay,
            preserveCurrentContentUntilReady: preserveCurrentContentUntilReady,
            preloadPrev: preloadPrev,
            preloadNext: preloadNext,
            preloadLookAhead: preloadLookAhead,
            preloadDelay: preloadDelay,
            loadTimeout: loadTimeout,
            onLoadingOverlayDismissed: () {
              loadingOverlayVisible = false;
            },
          );
          if (retried) {
            return true;
          }
        }
        if (!state.isCrossChapterTransition) {
          await DialogUtils.tips(e.error.userMessage);
        }
      }
      return false;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) {
        LogUtils.d('章节加载已取消');
      } else {
        _lastChapterLoadFailureError = null;
        LogUtils.e('加载章节失败: $e');
        if (state.isCrossChapterTransition) {
          state.crossChapterStatusMessage = '网络连接失败，请检查网络后重试';
        }
        _restoreChapterState(
          chapterIndex: oldChapterIndex,
          chapterName: oldChapterName,
          chapterUrl: oldChapterUrl,
          pageSize: oldPageSize,
          bookContentList: oldBookContentList,
          bookContent: oldBookContent,
          lastBookContent: oldLastBookContent,
        );
        if (!state.isCrossChapterTransition) {
          await DialogUtils.tips('网络连接失败，请检查网络后重试');
        }
      }
      return false;
    } catch (e) {
      _lastChapterLoadFailureError = null;
      LogUtils.e('加载章节失败: $e');
      if (state.isCrossChapterTransition) {
        state.crossChapterStatusMessage = '章节加载失败，请稍后重试';
      }
      _restoreChapterState(
        chapterIndex: oldChapterIndex,
        chapterName: oldChapterName,
        chapterUrl: oldChapterUrl,
        pageSize: oldPageSize,
        bookContentList: oldBookContentList,
        bookContent: oldBookContent,
        lastBookContent: oldLastBookContent,
      );
      if (!state.isCrossChapterTransition) {
        await DialogUtils.tips('章节加载失败，请稍后重试');
      }
      return false;
    } finally {
      if (loadingOverlayVisible) {
        await DialogUtils.dismiss();
      }
    }
  }

  bool _isLoginRequiredError(ServiceError error) {
    return error.code == _loginRequiredErrorCode;
  }

  bool _isLastChapterLoadLoginRequiredFailure() {
    final error = _lastChapterLoadFailureError;
    return error != null && _isLoginRequiredError(error);
  }

  Future<bool> _openLoginAndRetryChapterLoad({
    required ServiceError error,
    required int chapter,
    required bool preChapter,
    required String chapterUrlOverride,
    required int initialPage,
    required bool showLoadingOverlay,
    required bool preserveCurrentContentUntilReady,
    required bool preloadPrev,
    required bool preloadNext,
    required bool preloadLookAhead,
    required Duration preloadDelay,
    required Duration? loadTimeout,
    required VoidCallback onLoadingOverlayDismissed,
  }) async {
    if (showLoadingOverlay) {
      await DialogUtils.dismiss();
      onLoadingOverlayDismissed();
    }

    final openedLogin = await onOpenSourceLoginForChapter(error);
    if (!openedLogin || _isDisposed) {
      return false;
    }

    LogUtils.d('书源登录返回，自动重试当前章节加载');
    return _loadChapterInternal(
      chapter: chapter,
      preChapter: preChapter,
      initialPage: initialPage,
      chapterUrlOverride: chapterUrlOverride,
      showLoadingOverlay: showLoadingOverlay,
      preserveCurrentContentUntilReady: preserveCurrentContentUntilReady,
      preloadPrev: preloadPrev,
      preloadNext: preloadNext,
      preloadLookAhead: preloadLookAhead,
      preloadDelay: preloadDelay,
      loadTimeout: loadTimeout,
      forceRefresh: true,
      allowLoginRetry: false,
    );
  }

  Future<void> previousChapter(bool pre) async {
    _clearCrossChapterTransition(notify: false, cancelLoading: true);
    final chapters = state.bookDetail.chapters;
    if (chapters == null || chapters.isEmpty) return;

    final currentListIndex = _findCurrentListIndex();
    if (currentListIndex > 0) {
      if (await moveToPrevChapterWithCache()) {
        await onLoadReadChapters();
        return;
      }

      state.nextChapterCache = _snapshotCurrentChapterCache();
      await onEndReadHistory();
      final prevChapter = chapters[currentListIndex - 1];
      state.currentChapterUrl = prevChapter.chapterUrl ?? '';
      await loadChapter(chapter: prevChapter.chapterIndex!, preChapter: pre);
      await onStartReadHistory();
      await onLoadReadChapters();
      LogUtils.d('上一章页数: ${state.pageSize}');
      onUpdate();
    } else {
      LogUtils.d('已经是第一章');
    }
  }

  Future<void> nextChapter(bool pre) async {
    if (state.isCrossChapterTransition &&
        !state.isCrossChapterTransitionFailed) {
      return;
    }
    final chapters = state.bookDetail.chapters;
    if (chapters == null || chapters.isEmpty) return;

    final currentListIndex = _findCurrentListIndex();
    if (currentListIndex >= 0 && currentListIndex < chapters.length - 1) {
      final nextChapterInfo = chapters[currentListIndex + 1];
      if (!_hasReadyNextChapterCache()) {
        _ensureCrossChapterTransitionActive(nextChapterInfo);
      }
      await _advanceToNextChapter(
        pre: pre,
        nextChapterInfo: nextChapterInfo,
      );
    } else {
      LogUtils.d('已经是最后一章');
    }
  }

  void updateCurrentChapterForVerticalScroll(int chapterIndex) {
    final chapters = state.bookDetail.chapters;
    if (chapters == null || chapters.isEmpty) return;

    final chapterInfo = chapters.firstWhere(
      (item) => item.chapterIndex == chapterIndex,
      orElse: () => chapters.first,
    );

    state.currentChapterIndex = chapterIndex;
    state.currentChapter = chapterInfo.chapterName ?? '';
    state.currentChapterUrl = chapterInfo.chapterUrl ?? '';
    onSyncBookmarkStatus();
    onSaveReadProgress();
    unawaited(_restartReadHistoryForVisibleChapter(chapterIndex));
  }

  void syncCurrentChapterFromVisiblePosition() {
    final trackedChapterIndex = state.verticalVisibleChapterIndex;
    final visibleChapter = _findChapterInfoByIndex(trackedChapterIndex) ??
        _findChapterInfoByIndex(state.currentChapterIndex);
    if (visibleChapter == null) return;

    state.verticalVisibleChapterIndex =
        visibleChapter.chapterIndex ?? trackedChapterIndex;
    _applyVisibleChapterState(
      chapterIndex: visibleChapter.chapterIndex ?? state.currentChapterIndex,
      chapterName: visibleChapter.chapterName ?? state.currentChapter,
      chapterUrl: visibleChapter.chapterUrl ?? state.currentChapterUrl,
    );
  }

  Future<String?> loadChapterContentForVerticalScroll(int chapterIndex) async {
    try {
      final chapters = state.bookDetail.chapters;
      if (chapters == null || chapters.isEmpty) return null;

      final chapterInfo = chapters.firstWhere(
        (item) => item.chapterIndex == chapterIndex,
        orElse: () => chapters.first,
      );

      final chapterInfoObj = BookChapterInfo(
        bookSourceId: state.bookInfo.bookSourceId,
        chapterIndex: chapterInfo.chapterIndex,
        chapterName: chapterInfo.chapterName,
        chapterUrl: chapterInfo.chapterUrl,
      );

      var contentResult =
          await _chapterContentLoader.loadChapterOriginalContentResult(
        bookSourceId: state.bookInfo.bookSourceId,
        bookName: state.bookInfo.name,
        chapter: chapterInfoObj,
      );
      if (contentResult.isFailure &&
          _isLoginRequiredError(contentResult.error!)) {
        LogUtils.d(
          '垂直滚动章节需要登录，尝试登录后重试: '
          '${contentResult.error!.formatForLog()}',
        );
        final opened = await onOpenSourceLoginForChapter(contentResult.error!);
        if (opened && !_isDisposed) {
          contentResult =
              await _chapterContentLoader.loadChapterOriginalContentResult(
            bookSourceId: state.bookInfo.bookSourceId,
            bookName: state.bookInfo.name,
            chapter: chapterInfoObj,
            forceRefresh: true,
          );
        }
      }
      if (contentResult.isFailure) {
        LogUtils.e(
          '垂直滚动模式加载章节失败: ${contentResult.error!.formatForLog()}',
        );
        return null;
      }

      final originalContent = contentResult.requireData();

      state.readChapterIndices.add(chapterIndex);
      state.cachedChapterIndices.add(chapterIndex);
      return _formatContentWithIndent(originalContent);
    } catch (e) {
      LogUtils.e('垂直滚动模式加载章节失败: $e');
      return null;
    }
  }

  String? getNextPageContent() {
    final cur = state.curChapterCache;
    final isLastPageOfChapter = cur != null
        ? state.currentPage >= cur.pages.length - 1
        : state.currentPage >= state.bookContentList.length - 1;

    if (!isLastPageOfChapter) {
      if (cur != null && state.currentPage + 1 < cur.pages.length) {
        return cur.getPage(state.currentPage + 1);
      }
      if (state.currentPage + 1 < state.bookContentList.length) {
        return state.bookContentList[state.currentPage + 1];
      }
    }

    final next = state.nextChapterCache;
    if (next != null && next.pages.isNotEmpty) {
      return next.getPage(0);
    }

    return null;
  }

  String? getPrevPageContent() {
    final isFirstPageOfChapter = state.currentPage <= 0;

    if (!isFirstPageOfChapter) {
      final cur = state.curChapterCache;
      if (cur != null &&
          state.currentPage - 1 >= 0 &&
          state.currentPage - 1 < cur.pages.length) {
        return cur.getPage(state.currentPage - 1);
      }
      if (state.currentPage - 1 >= 0 &&
          state.currentPage - 1 < state.bookContentList.length) {
        return state.bookContentList[state.currentPage - 1];
      }
    }

    final prev = state.prevChapterCache;
    if (prev != null && prev.pages.isNotEmpty) {
      return prev.lastPage;
    }

    return null;
  }

  String? getNextPageChapterName() {
    final cur = state.curChapterCache;
    if (cur == null) {
      if (state.currentPage >= state.bookContentList.length - 1) {
        return state.nextChapterCache?.chapterName;
      }
      return null;
    }

    if (state.currentPage >= cur.pages.length - 1) {
      return state.nextChapterCache?.chapterName;
    }
    return null;
  }

  String? getPrevPageChapterName() {
    final cur = state.curChapterCache;
    if (cur == null) {
      if (state.currentPage == 0) {
        return state.prevChapterCache?.chapterName;
      }
      return null;
    }

    if (state.currentPage == 0) {
      return state.prevChapterCache?.chapterName;
    }
    return null;
  }

  bool isNextPageCrossChapter() {
    final cur = state.curChapterCache;
    if (cur == null) {
      return state.currentPage >= state.bookContentList.length - 1 &&
          state.nextChapterCache != null;
    }
    return state.currentPage >= cur.pages.length - 1 &&
        state.nextChapterCache != null;
  }

  bool isPrevPageCrossChapter() {
    return state.currentPage == 0 && state.prevChapterCache != null;
  }

  Future<bool> moveToNextChapterWithCache({
    bool deferReadHistoryStart = false,
  }) async {
    final chapters = state.bookDetail.chapters;
    if (chapters == null || chapters.isEmpty) return false;

    final currentListIndex = _findCurrentListIndex();
    if (currentListIndex < 0 || currentListIndex >= chapters.length - 1) {
      return false;
    }

    state.prevChapterCache = state.curChapterCache;
    final nextChapter = chapters[currentListIndex + 1];
    ChapterCache? nextCache = state.nextChapterCache;
    if (!_isChapterCacheCompatible(nextCache)) {
      nextCache = nextChapter.chapterIndex == null
          ? null
          : await loadChapterCacheForIndex(nextChapter.chapterIndex!);
      if (nextCache != null &&
          nextCache.chapterIndex == nextChapter.chapterIndex) {
        state.nextChapterCache = nextCache;
      }
    }

    if (nextCache != null &&
        nextCache.chapterIndex == nextChapter.chapterIndex) {
      state.curChapterCache = nextCache;
      state.nextChapterCache = null;

      _applyChapterCache(
        state.curChapterCache!,
        pageIndex: 0,
      );
      _clearCrossChapterTransition(notify: false, cancelLoading: false);

      final endReadHistoryFuture = onEndReadHistory();
      onSaveReadProgress();
      onSyncBookmarkStatus();
      onUpdate();
      _scheduleAdjacentChapterPreloads(includeNext: true);
      await _completeReadHistoryTransition(
        endReadHistoryFuture,
        deferReadHistoryStart: deferReadHistoryStart,
        expectedChapterIndex: state.currentChapterIndex,
      );
      return true;
    }

    return false;
  }

  Future<bool> moveToPrevChapterWithCache() async {
    final chapters = state.bookDetail.chapters;
    if (chapters == null || chapters.isEmpty) return false;

    final currentListIndex = _findCurrentListIndex();
    if (currentListIndex <= 0) {
      return false;
    }

    state.nextChapterCache = state.curChapterCache;
    final prevChapter = chapters[currentListIndex - 1];
    ChapterCache? prevCache = state.prevChapterCache;
    if (!_isChapterCacheCompatible(prevCache)) {
      prevCache = prevChapter.chapterIndex == null
          ? null
          : await loadChapterCacheForIndex(prevChapter.chapterIndex!);
      if (prevCache != null &&
          prevCache.chapterIndex == prevChapter.chapterIndex) {
        state.prevChapterCache = prevCache;
      }
    }

    if (prevCache != null &&
        prevCache.chapterIndex == prevChapter.chapterIndex) {
      state.curChapterCache = prevCache;
      state.prevChapterCache = null;

      _applyChapterCache(
        state.curChapterCache!,
        pageIndex: state.curChapterCache!.lastPageIndex,
      );

      await onEndReadHistory();
      await onStartReadHistory();
      onSaveReadProgress();
      onSyncBookmarkStatus();
      onUpdate();
      _scheduleAdjacentChapterPreloads(includePrev: true);
      return true;
    }

    return false;
  }

  Future<ChapterCache?> loadChapterCacheForIndex(int chapterIndex) async {
    final existingCache = _findCachedChapter(chapterIndex);
    if (existingCache != null && _isChapterCacheCompatible(existingCache)) {
      return existingCache;
    }

    final targetChapter = _findChapterInfoByIndex(chapterIndex);
    if (targetChapter == null || targetChapter.chapterIndex == null) {
      return null;
    }

    try {
      final preparedChapter = await _loadPreparedChapter(
        chapterIndex: targetChapter.chapterIndex!,
        chapterName: targetChapter.chapterName ?? '',
        chapterUrl: targetChapter.chapterUrl ?? '',
      );
      if (preparedChapter == null || preparedChapter.pages.isEmpty) {
        return null;
      }

      return ChapterCache(
        chapterName: targetChapter.chapterName ?? '',
        chapterUrl: targetChapter.chapterUrl ?? '',
        chapterIndex: targetChapter.chapterIndex!,
        content: preparedChapter.content,
        pages: preparedChapter.pages,
        paginationCacheKey: preparedChapter.paginationCacheKey,
      );
    } on _ChapterLoadFailure catch (e) {
      if (e.error.code != ServiceErrorCodes.cancelled) {
        LogUtils.e(
          '预热章节缓存失败: chapterIndex=$chapterIndex, ${e.error.formatForLog()}',
        );
      } else {
        LogUtils.d('预热章节缓存已取消: chapterIndex=$chapterIndex');
      }
      return null;
    } catch (e, stackTrace) {
      LogUtils.e(
        '预热章节缓存异常: chapterIndex=$chapterIndex, error=$e',
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  Future<bool> ensureNextChapterCacheReady() async {
    final nextChapter = _findAdjacentChapterInfo(isNext: true);
    final nextChapterIndex = nextChapter?.chapterIndex;
    if (nextChapterIndex == null) return false;
    if (state.nextChapterCache?.chapterIndex == nextChapterIndex) {
      return true;
    }

    final expectedCurrentChapterIndex = state.currentChapterIndex;
    final cache = await loadChapterCacheForIndex(nextChapterIndex);
    if (cache == null ||
        state.currentChapterIndex != expectedCurrentChapterIndex) {
      return false;
    }

    state.nextChapterCache = cache;
    return true;
  }

  void splitCurrentBookContent() {
    if (state.screenWidth <= 0 || state.screenHeight <= 0) {
      LogUtils.d('splitCurrentBookContent: 屏幕尺寸未初始化，跳过分页');
      return;
    }
    if (state.bookContent.isEmpty && state.currentChapter.trim().isEmpty) {
      LogUtils.d('splitCurrentBookContent: 内容和章节名为空，跳过分页');
      return;
    }

    final paginationResult = _paginationService().splitContentWithCache(
      state.bookContent,
      _buildPaginationConfig(),
      cacheIdentity: _buildPaginationCacheIdentity(state.currentChapterIndex),
      chapterTitle: state.currentChapter,
    );
    state.bookContentList = paginationResult.pages;
    state.pageSize = paginationResult.pages.length;
    _updateCurrentChapterCache(
      paginationCacheKey: paginationResult.cacheKey,
    );
  }

  Future<void> jumpToChapter(int index) async {
    _clearCrossChapterTransition(notify: false, cancelLoading: true);
    await onEndReadHistory();

    final chapterList = state.bookDetail.chapters;
    BookChapterInfo? targetChapter;
    if (chapterList != null && chapterList.isNotEmpty) {
      targetChapter = chapterList.firstWhere(
        (item) => item.chapterIndex == index,
        orElse: () => chapterList.first,
      );
    }
    state.currentChapterUrl = targetChapter?.chapterUrl ?? '';

    await loadChapter(chapter: index, preChapter: false);
    await onStartReadHistory();
    await onLoadReadChapters();
    onSaveReadProgress();
    onUpdate();
  }

  int _findCurrentListIndex() {
    final chapters = state.bookDetail.chapters;
    if (chapters == null || chapters.isEmpty) return -1;
    return chapters.indexWhere(
      (chapter) => chapter.chapterIndex == state.currentChapterIndex,
    );
  }

  void _restoreChapterState({
    required int chapterIndex,
    required String chapterName,
    required String chapterUrl,
    required int pageSize,
    required List<String> bookContentList,
    required String bookContent,
    required String lastBookContent,
  }) {
    state.currentChapterIndex = chapterIndex;
    state.currentChapter = chapterName;
    state.currentChapterUrl = chapterUrl;
    state.pageSize = pageSize;
    state.bookContentList = bookContentList;
    state.bookContent = bookContent;
    state.lastBookContent = lastBookContent;
    onSyncBookmarkStatus();
    onUpdate();
  }

  void _updateCurrentChapterCache({
    String? paginationCacheKey,
  }) {
    state.curChapterCache = ChapterCache(
      chapterName: state.currentChapter,
      chapterUrl: state.currentChapterUrl,
      chapterIndex: state.currentChapterIndex,
      content: state.bookContent,
      pages: List.from(state.bookContentList),
      paginationCacheKey:
          paginationCacheKey ?? _buildCurrentPaginationCacheKey(),
    );
    _rememberSessionChapterCache(state.curChapterCache!);
  }

  void _applyChapterCache(
    ChapterCache cache, {
    required int pageIndex,
  }) {
    _rememberSessionChapterCache(cache);
    state.currentChapterIndex = cache.chapterIndex;
    state.currentChapter = cache.chapterName;
    state.currentChapterUrl = cache.chapterUrl;
    state.bookContentList = List<String>.from(cache.pages);
    state.pageSize = cache.pageSize;
    state.bookContent = cache.content;
    state.currentPage = pageIndex.clamp(0, cache.lastPageIndex);
    if (state.isTwoPageMode) {
      state.currentPage = TwoPageSpreadStrategy.anchorFor(state.currentPage);
    }
    state.lastBookContent = state.bookContentList.isNotEmpty
        ? state.bookContentList[state.currentPage]
        : '';
  }

  ChapterCache? _snapshotCurrentChapterCache() {
    final currentCache = state.curChapterCache;
    if (currentCache != null &&
        currentCache.chapterIndex == state.currentChapterIndex) {
      _rememberSessionChapterCache(currentCache);
      return currentCache;
    }
    if (state.bookContentList.isEmpty) return null;

    final snapshot = ChapterCache(
      chapterName: state.currentChapter,
      chapterUrl: state.currentChapterUrl,
      chapterIndex: state.currentChapterIndex,
      content: state.bookContent,
      pages: List<String>.from(state.bookContentList),
      paginationCacheKey: state.curChapterCache?.paginationCacheKey ??
          _buildCurrentPaginationCacheKey(),
    );
    _rememberSessionChapterCache(snapshot);
    return snapshot;
  }

  BookChapterInfo? _findChapterInfoByIndex(int chapterIndex) {
    final chapters = state.bookDetail.chapters;
    if (chapters == null || chapters.isEmpty) return null;

    for (final chapter in chapters) {
      if (chapter.chapterIndex == chapterIndex) {
        return chapter;
      }
    }
    return null;
  }

  BookChapterInfo? _findAdjacentChapterInfo({required bool isNext}) {
    final chapters = state.bookDetail.chapters;
    if (chapters == null || chapters.isEmpty) return null;

    final currentListIndex = _findCurrentListIndex();
    if (isNext) {
      if (currentListIndex < 0 || currentListIndex >= chapters.length - 1) {
        return null;
      }
      return chapters[currentListIndex + 1];
    }

    if (currentListIndex <= 0) {
      return null;
    }
    return chapters[currentListIndex - 1];
  }

  ChapterCache? _findCachedChapter(int chapterIndex) {
    final caches = <ChapterCache?>[
      state.curChapterCache,
      state.nextChapterCache,
      state.prevChapterCache,
      _findSessionChapterCache(chapterIndex),
    ];

    for (final cache in caches) {
      if (cache?.chapterIndex == chapterIndex) {
        return cache;
      }
    }
    return null;
  }

  Future<void> _preloadAdjacentChapter({required bool isNext}) async {
    final isPreloading =
        isNext ? state.isPreloadingNext : state.isPreloadingPrev;
    if (isPreloading) return;

    try {
      final chapters = state.bookDetail.chapters;
      if (chapters == null || chapters.isEmpty) return;

      final currentListIndex = _findCurrentListIndex();

      if (isNext) {
        if (currentListIndex < 0 || currentListIndex >= chapters.length - 1) {
          state.nextChapterCache = null;
          return;
        }
      } else {
        if (currentListIndex <= 0) {
          state.prevChapterCache = null;
          return;
        }
      }

      final targetChapter = isNext
          ? chapters[currentListIndex + 1]
          : chapters[currentListIndex - 1];

      final existingCache =
          isNext ? state.nextChapterCache : state.prevChapterCache;
      if (existingCache?.chapterIndex == targetChapter.chapterIndex) return;

      if (isNext) {
        state.isPreloadingNext = true;
      } else {
        state.isPreloadingPrev = true;
      }

      final chapterIndex = targetChapter.chapterIndex;
      if (chapterIndex == null) {
        return;
      }

      final preparedChapter = await _loadPreparedChapter(
        chapterIndex: chapterIndex,
        chapterName: targetChapter.chapterName ?? '',
        chapterUrl: targetChapter.chapterUrl ?? '',
      );

      if (preparedChapter != null && preparedChapter.pages.isNotEmpty) {
        final cache = ChapterCache(
          chapterName: targetChapter.chapterName ?? '',
          chapterUrl: targetChapter.chapterUrl ?? '',
          chapterIndex: chapterIndex,
          content: preparedChapter.content,
          pages: preparedChapter.pages,
          paginationCacheKey: preparedChapter.paginationCacheKey,
        );
        _rememberSessionChapterCache(cache);
        if (isNext) {
          state.nextChapterCache = cache;
        } else {
          state.prevChapterCache = cache;
        }
        final direction = isNext ? '下一章' : '上一章';
        LogUtils.d(
          '预加载$direction成功: ${targetChapter.chapterName}, ${preparedChapter.pages.length}页',
        );
      }
    } catch (e) {
      final direction = isNext ? '下一章' : '上一章';
      LogUtils.d('预加载$direction失败: $e');
    } finally {
      if (isNext) {
        state.isPreloadingNext = false;
      } else {
        state.isPreloadingPrev = false;
      }
    }
  }

  Future<void> _preloadPrevChapter() => _preloadAdjacentChapter(isNext: false);

  Future<void> _preloadNextChapterWithCache() =>
      _preloadAdjacentChapter(isNext: true);

  void _scheduleAdjacentChapterPreloads({
    bool includePrev = false,
    bool includeNext = false,
    bool includeLookAhead = true,
    Duration delay = _deferredPreloadDelay,
  }) {
    if (!includePrev && !includeNext) return;
    if (state.isCaching) return;

    final scheduleEpoch = ++_preloadScheduleEpoch;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_runDeferredAdjacentChapterPreloads(
        scheduleEpoch: scheduleEpoch,
        includePrev: includePrev,
        includeNext: includeNext,
        includeLookAhead: includeLookAhead,
        delay: delay,
      ));
    });
  }

  Future<void> _runDeferredAdjacentChapterPreloads({
    required int scheduleEpoch,
    required bool includePrev,
    required bool includeNext,
    required bool includeLookAhead,
    required Duration delay,
  }) async {
    await Future<void>.delayed(delay);
    if (!_isPreloadScheduleActive(scheduleEpoch)) return;
    if (state.isCaching) return;

    if (includePrev) {
      await _preloadPrevChapter();
      if (!_isPreloadScheduleActive(scheduleEpoch)) return;
    }

    if (includeNext) {
      await _preloadNextChapterWithCache();
      if (!_isPreloadScheduleActive(scheduleEpoch)) return;

      if (!includeLookAhead) {
        return;
      }
      await Future<void>.delayed(_lookAheadPreloadGap);
      if (!_isPreloadScheduleActive(scheduleEpoch)) return;
      await _preloadLookAheadChapter(offset: 2);
    }
  }

  bool _isPreloadScheduleActive(int scheduleEpoch) {
    return !_isDisposed &&
        !state.isCaching &&
        scheduleEpoch == _preloadScheduleEpoch;
  }

  Future<void> _preloadLookAheadChapter({
    required int offset,
  }) async {
    if (state.isCaching) return;
    if (offset <= 1) return;
    final chapters = state.bookDetail.chapters;
    if (chapters == null || chapters.isEmpty) return;

    final currentListIndex = _findCurrentListIndex();
    final lookAheadIndex = currentListIndex + offset;
    if (lookAheadIndex < 0 || lookAheadIndex >= chapters.length) {
      return;
    }

    final lookAheadChapter = chapters[lookAheadIndex];
    final chapterIndex = lookAheadChapter.chapterIndex;
    if (chapterIndex == null) return;
    if (_findSessionChapterCache(chapterIndex) != null) return;

    final cache = await loadChapterCacheForIndex(chapterIndex);
    if (cache != null) {
      _rememberSessionChapterCache(cache);
    }
  }

  Future<_PreparedChapterData?> _loadPreparedChapter({
    required int chapterIndex,
    required String chapterName,
    required String chapterUrl,
    CancelToken? cancelToken,
    Duration? timeout,
    bool forceRefresh = false,
  }) async {
    final taskKey = _chapterLoadTaskKey(chapterIndex, chapterUrl);
    if (timeout != null || forceRefresh) {
      _chapterLoadTasks.remove(taskKey);
    }
    final existingTask = _chapterLoadTasks[taskKey];
    if (existingTask != null) {
      return existingTask;
    }

    final task = _loadPreparedChapterInternal(
      chapterIndex: chapterIndex,
      chapterName: chapterName,
      chapterUrl: chapterUrl,
      cancelToken: cancelToken,
      timeout: timeout,
      forceRefresh: forceRefresh,
    );
    _chapterLoadTasks[taskKey] = task;
    void removeCompletedTask() {
      if (identical(_chapterLoadTasks[taskKey], task)) {
        _chapterLoadTasks.remove(taskKey);
      }
    }

    // Handle both branches on the cleanup future. Ignoring the Future returned
    // by whenComplete would report the original load failure a second time as
    // an unhandled asynchronous exception.
    unawaited(
      task.then<void>(
        (_) => removeCompletedTask(),
        onError: (Object _, StackTrace __) => removeCompletedTask(),
      ),
    );
    return task;
  }

  Future<_PreparedChapterData?> _loadPreparedChapterInternal({
    required int chapterIndex,
    required String chapterName,
    required String chapterUrl,
    CancelToken? cancelToken,
    Duration? timeout,
    bool forceRefresh = false,
  }) async {
    try {
      final chapter = BookChapterInfo(
        bookSourceId: state.bookInfo.bookSourceId,
        chapterIndex: chapterIndex,
        chapterName: chapterName,
        chapterUrl: chapterUrl,
      );

      Future<ServiceResult<String>> contentLoad =
          _chapterContentLoader.loadChapterOriginalContentResult(
        bookSourceId: state.bookInfo.bookSourceId,
        bookName: state.bookInfo.name,
        chapter: chapter,
        cancelToken: cancelToken,
        forceRefresh: forceRefresh,
      );
      if (timeout != null) {
        contentLoad = contentLoad.timeout(
          timeout,
          onTimeout: () {
            _cancelTokenIfActive(cancelToken, '初次章节加载超时');
            if (identical(cancelToken, _chapterCancelToken)) {
              _chapterCancelToken = null;
            }
            return ServiceResult<String>.failure(
              ServiceError(
                code: '${ServiceErrorCodes.contentFetchFailed}.timeout',
                userMessage: '网络较慢，正文加载超时，请稍后重试',
                debugMessage: 'chapter content load timed out',
                context: <String, Object?>{
                  'bookSourceId': state.bookInfo.bookSourceId,
                  'bookName': state.bookInfo.name,
                  'chapterIndex': chapterIndex,
                  'chapterName': chapterName,
                  'chapterUrl': chapterUrl,
                  'timeoutMs': timeout.inMilliseconds,
                },
              ),
            );
          },
        );
      }

      final contentResult = await contentLoad;
      if (contentResult.isFailure) {
        throw _ChapterLoadFailure(contentResult.error!);
      }

      final content = contentResult.requireData();

      final formattedContent = _formatContentWithIndent(content);
      final paginationResult = _paginationService().splitContentWithCache(
        formattedContent,
        _buildPaginationConfig(),
        cacheIdentity: _buildPaginationCacheIdentity(chapterIndex),
        chapterTitle: chapterName,
      );
      final pages = paginationResult.pages;
      if (pages.isEmpty) {
        throw _ChapterLoadFailure(
          ServiceError(
            code: ServiceErrorCodes.contentEmpty,
            userMessage: '正文为空，暂时无法阅读',
            debugMessage: 'pagination produced no pages',
            context: <String, Object?>{
              'bookSourceId': state.bookInfo.bookSourceId,
              'bookName': state.bookInfo.name,
              'chapterIndex': chapterIndex,
              'chapterName': chapterName,
              'chapterUrl': chapterUrl,
            },
          ),
        );
      }
      return _PreparedChapterData(
        content: formattedContent,
        pages: pages,
        paginationCacheKey: paginationResult.cacheKey,
      );
    } on _ChapterLoadFailure {
      rethrow;
    } catch (e) {
      LogUtils.d('加载章节页面失败: $e');
      return null;
    }
  }

  String _chapterLoadTaskKey(int chapterIndex, String chapterUrl) {
    return '$chapterIndex|${chapterUrl.trim()}';
  }

  PaginationConfig _buildPaginationConfig() {
    return PaginationConfig(
      screenWidth: state.isTwoPageMode
          ? TwoPageSpreadStrategy.columnWidth(state.screenWidth)
          : state.screenWidth,
      screenHeight: state.screenHeight,
      safePadding: state.safePadding,
      textScaler: state.textScaler,
      contentStyle: state.contentStyle,
      endPadding: state.endPadding,
    );
  }

  PaginationCacheIdentity _buildPaginationCacheIdentity(int chapterIndex) {
    return PaginationCacheIdentity(
      bookSourceId: state.bookInfo.bookSourceId.toString(),
      bookName: state.bookInfo.name,
      chapterIndex: chapterIndex,
    );
  }

  String _buildCurrentPaginationCacheKey() {
    return _paginationService().buildStableCacheKey(
      _buildPaginationCacheIdentity(state.currentChapterIndex),
      _buildPaginationConfig(),
      chapterTitle: state.currentChapter,
    );
  }

  bool _isChapterCacheCompatible(ChapterCache? cache) {
    if (cache == null) return false;
    final expectedKey = _paginationService().buildStableCacheKey(
      _buildPaginationCacheIdentity(cache.chapterIndex),
      _buildPaginationConfig(),
      chapterTitle: cache.chapterName,
    );
    return cache.paginationCacheKey == expectedKey;
  }

  ChapterCache? _findSessionChapterCache(int chapterIndex) {
    final cached = state.sessionChapterCache.remove(chapterIndex);
    if (cached == null) return null;
    if (!_isChapterCacheCompatible(cached)) {
      return null;
    }
    state.sessionChapterCache[chapterIndex] = cached;
    return cached;
  }

  void _rememberSessionChapterCache(ChapterCache cache) {
    state.sessionChapterCache.remove(cache.chapterIndex);
    while (
        state.sessionChapterCache.length >= state.maxSessionChapterCacheCount) {
      state.sessionChapterCache.remove(state.sessionChapterCache.keys.first);
    }
    state.sessionChapterCache[cache.chapterIndex] = cache;
  }

  String _formatContentWithIndent(String content) {
    if (content.isEmpty) return content;

    final lines = content.split(_newlinePattern);
    final formattedLines = <String>[];

    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;

      if (trimmed.startsWith('　　')) {
        formattedLines.add(trimmed);
      } else {
        formattedLines.add('　　$trimmed');
      }
    }

    return formattedLines.join('\n');
  }

  Future<void> _completeReadHistoryTransition(
    Future<void> endReadHistoryFuture, {
    required bool deferReadHistoryStart,
    required int expectedChapterIndex,
  }) async {
    final transitionEpoch = ++_readHistoryTransitionEpoch;

    if (deferReadHistoryStart) {
      unawaited(
        () async {
          await endReadHistoryFuture;
          if (transitionEpoch != _readHistoryTransitionEpoch) return;
          if (state.currentChapterIndex != expectedChapterIndex) return;
          await onStartReadHistory();
        }(),
      );
      return;
    }

    await endReadHistoryFuture;
    if (transitionEpoch != _readHistoryTransitionEpoch) return;
    if (state.currentChapterIndex != expectedChapterIndex) return;
    await onStartReadHistory();
  }

  Future<void> _restartReadHistoryForVisibleChapter(int chapterIndex) async {
    final endReadHistoryFuture = onEndReadHistory();
    await _completeReadHistoryTransition(
      endReadHistoryFuture,
      deferReadHistoryStart: false,
      expectedChapterIndex: chapterIndex,
    );
  }

  void _applyVisibleChapterState({
    required int chapterIndex,
    required String chapterName,
    required String chapterUrl,
  }) {
    if (state.currentChapterIndex == chapterIndex &&
        state.currentChapter == chapterName &&
        state.currentChapterUrl == chapterUrl) {
      return;
    }

    state.currentChapterIndex = chapterIndex;
    state.currentChapter = chapterName;
    state.currentChapterUrl = chapterUrl;
    onSyncBookmarkStatus();
    onUpdate();
  }
}

class _PreparedChapterData {
  const _PreparedChapterData({
    required this.content,
    required this.pages,
    required this.paginationCacheKey,
  });

  final String content;
  final List<String> pages;
  final String paginationCacheKey;
}
