import 'dart:async';
import 'package:drift/drift.dart' as drift;
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reader_nover/app/database/dao/book_source_dao.dart';
import 'package:reader_nover/app/database/dao/book_read_progress_dao.dart';
import 'package:reader_nover/app/database/dao/bookshelf_dao.dart';
import 'package:reader_nover/app/constants/default_setting.dart';
import 'package:reader_nover/app/database/models/models.dart';
import 'package:reader_nover/app/routes/route_args.dart';
import 'package:reader_nover/app/service/book/service_result.dart';
import 'package:reader_nover/pages/book_read/page_turn/pagination_service.dart';
import 'package:reader_nover/pages/home/source/controllers/source_login_controller.dart';
import 'package:reader_nover/app/service/book/book_change_service.dart';
import 'package:reader_nover/app/service/book/bookshelf_service.dart';
import '../../app/database/drift/app_database.dart' as db;
import '../../app/service/book/read_chapter_service.dart';
import '../../app/service/book/reader_locator.dart';
import '../../app/service/annotation/reader_annotation_range.dart';
import '../../app/service/source/web_content_service.dart';
import '../../util/dialog/dialog_utils.dart';
import '../../util/log_utils.dart';
import '../../app/service/book/chapter_content_loader.dart';
import '../../app/service/tts/tts_service.dart';
import 'page_turn/page_turn_gesture_controller.dart';
import '../../app/service/book/read_history_service.dart';
import 'controllers/book_read_bookmark_controller.dart';
import 'controllers/book_read_annotation_controller.dart';
import '../../app/service/annotation/book_annotation.dart';
import 'controllers/book_read_cache_controller.dart';
import 'controllers/book_read_library_controller.dart';
import 'controllers/book_read_lifecycle_controller.dart';
import 'controllers/book_read_navigation_controller.dart';
import 'controllers/book_read_page_settle_controller.dart';
import 'controllers/book_read_page_turn_state_controller.dart';
import 'controllers/book_read_paragraph_action_controller.dart';
import 'controllers/book_read_preview_controller.dart';
import 'controllers/book_read_progress_controller.dart';
import 'controllers/book_read_session_controller.dart';
import 'controllers/book_read_settings_controller.dart';
import 'controllers/book_read_tts_controller.dart';
import 'controllers/book_read_ui_refresh_controller.dart';
import 'state.dart';

class BookReadLogic extends GetxController with GetTickerProviderStateMixin {
  BookReadLogic({
    required BookReadArgs args,
  })  : state = BookReadState(args: args),
        _onRefreshBookshelf = args.onRefreshBookshelf;

  final BookReadState state;
  final VoidCallback? _onRefreshBookshelf;
  late TextPainter _textPainter;
  late PaginationService _paginationService;

  final db.AppDatabase _db = db.AppDatabase.instance;
  late final ChapterContentLoader _chapterContentLoader;
  late final ReadHistoryService _readHistoryService;
  late final ReadChapterService _readChapterService;
  late final BookChangeService _bookChangeService;
  late final BookshelfDao _bookshelfDao = BookshelfDao(database: _db);
  late final BookSourceDao _bookSourceDao = BookSourceDao(database: _db);
  late final BookReadProgressDao _readProgressDao =
      BookReadProgressDao(database: _db);
  late final PageTurnGestureController _pageTurnGestureController;
  late final BookshelfService _bookshelfService;
  late final BookReadSettingsController _settingsController;
  late final BookReadBookmarkController _bookmarkController;
  late final BookReadAnnotationController _annotationController;
  late final BookReadCacheController _cacheController;
  late final BookReadLibraryController _libraryController;
  late final BookReadLifecycleController _lifecycleController;
  late final AppLifecycleListener _appLifecycleListener;
  late final BookReadNavigationController _navigationController;
  late final BookReadPageSettleController _pageSettleController;
  late final BookReadParagraphActionController _paragraphActionController;
  late final BookReadPageTurnStateController _pageTurnStateController;
  late final BookReadPreviewController _previewController;
  late final BookReadProgressController _progressController;
  late final BookReadSessionController _sessionController;
  late final BookReadTtsController _ttsController;
  final SourceLoginController _sourceLoginController =
      const SourceLoginController();
  final TtsService _voicePreviewTtsService = TtsService();
  bool _isVoicePreviewInitialized = false;
  late final BookReadUiRefreshController _uiRefreshController =
      BookReadUiRefreshController(
    state: state,
    updater: (ids) => update(ids),
  );

  /// 换源搜索取消令牌列表
  final List<CancelToken> _sourceCancelTokens = [];
  late final Future<void> _readerBootstrapFuture;
  int _initialLoadEpoch = 0;

  BookReadUiRefreshController get uiRefreshController => _uiRefreshController;

  @override
  void onInit() {
    super.onInit();
    _chapterContentLoader = ChapterContentLoader(database: _db);
    _readHistoryService = ReadHistoryService(database: _db);
    _readChapterService = ReadChapterService(database: _db);
    _bookChangeService = BookChangeService(database: _db);
    _bookshelfService = BookshelfService(database: _db);
    _lifecycleController = BookReadLifecycleController(
      state: state,
      readHistoryService: _readHistoryService,
    );
    _appLifecycleListener = AppLifecycleListener(
      onResume: () => unawaited(_lifecycleController.beginReadHistory()),
      onInactive: () => unawaited(_lifecycleController.endReadHistory()),
      onPause: () => unawaited(_lifecycleController.endReadHistory()),
      onHide: () => unawaited(_lifecycleController.endReadHistory()),
      onDetach: () => unawaited(_lifecycleController.endReadHistory()),
    );
    _pageSettleController = BookReadPageSettleController(state: state);
    _pageTurnStateController = BookReadPageTurnStateController(
      state: state,
      onAnimationStateChanged: _uiRefreshController.animation,
    );
    _paragraphActionController = BookReadParagraphActionController();
    _previewController = BookReadPreviewController(
      state: state,
      onPreviewChanged: _uiRefreshController.playbackHighlight,
    );
    _progressController = BookReadProgressController(
      database: _db,
      state: state,
    );
    _settingsController = BookReadSettingsController(
      state: state,
      database: _db,
      onUpdate: _uiRefreshController.all,
      onSplitBookContent: _splitBookContent,
      onRelocateCurrentPage: _relocateCurrentPage,
    );
    _bookmarkController = BookReadBookmarkController(
      state: state,
      database: _db,
      onUpdate: _uiRefreshController.chromeAndOverlay,
      onJumpToLocator: _jumpToLocator,
    );
    _annotationController = BookReadAnnotationController(
      state: state,
      onUpdate: _uiRefreshController.contentChromeAndOverlay,
      onJumpToChapter: jumpToChapter,
    );
    unawaited(loadAnnotations());
    _sessionController = BookReadSessionController(
      state: state,
      chapterContentLoader: _chapterContentLoader,
      paginationService: () => _paginationService,
      onUpdate: _uiRefreshController.contentAndChrome,
      onToggleAppBarVisibility: toggleAppBarVisibility,
      onStartReadHistory: _lifecycleController.beginReadHistory,
      onEndReadHistory: _lifecycleController.endReadHistory,
      onLoadReadChapters: loadReadChapters,
      onSaveReadProgress: _scheduleReadProgressSave,
      onSyncBookmarkStatus: _bookmarkController.syncCurrentChapterBookmarkFlag,
      onOpenSourceLoginForChapter: _openSourceLoginForChapter,
    );
    _navigationController = BookReadNavigationController(
      state: state,
      sessionController: _sessionController,
      pageSettleController: _pageSettleController,
      onHandleReadingPositionChanged: ({bool forceResume = false}) =>
          _ttsController.handleReadingPositionChanged(
        forceResume: forceResume,
      ),
    );
    _cacheController = BookReadCacheController(
      state: state,
      database: _db,
      chapterContentLoader: _chapterContentLoader,
      onUpdate: _uiRefreshController.chromeAndOverlay,
      onToggleAppBarVisibility: toggleAppBarVisibility,
      onLoadChapter: _navigationController.loadChapter,
      onLoadCachedChapters: loadCachedChapters,
    );
    _libraryController = BookReadLibraryController(
      state: state,
      database: _db,
      bookChangeService: _bookChangeService,
      bookshelfService: _bookshelfService,
      onUpdate: _uiRefreshController.contentAndChrome,
      onRefreshBookshelf: _onRefreshBookshelf,
      onToggleAppBarVisibility: toggleAppBarVisibility,
      onReloadCurrentChapter: reloadCurrentChapter,
      onSyncBookmarkStatus: _bookmarkController.syncCurrentChapterBookmarkFlag,
    );
    _pageTurnGestureController = PageTurnGestureController(
      state: state,
      vsync: this,
      pageTurnStateController: _pageTurnStateController,
      onToggleAppBarVisibility: toggleAppBarVisibility,
      onPreviousPage: previousPage,
      onNextPage: nextPage,
    );
    _ttsController = BookReadTtsController(
      state: state,
      ttsService: TtsService(),
      onUpdate: _uiRefreshController.ttsFloatingAndHighlight,
      onPlaybackVisualUpdate: _uiRefreshController.playbackHighlight,
      onJumpToPageAndSettle: _navigationController.jumpToPageAndSettle,
      onJumpToChapterAndSettle: _navigationController.jumpToChapterAndSettle,
      onNextChapterAndSettle: _navigationController.nextChapterAndSettle,
      onLoadChapterCache: _sessionController.loadChapterCacheForIndex,
      onWaitForReadPageSettled: _navigationController.waitForReadPageSettled,
    );
    _readerBootstrapFuture = _initSettings();
    _lifecycleController.beginReadHistory();
  }

  Future<void> _initSettings() async {
    await _lifecycleController.initializeReader(
      context: Get.context!,
      onCheckBookshelfStatus: _libraryController.checkBookshelfStatus,
      onLoadReadChapters: loadReadChapters,
      onLoadSavedSettings: _settingsController.loadSavedSettings,
      onLoadBookmarks: loadBookmarks,
      onInitTts: _ttsController.init,
      onUpdate: _uiRefreshController.all,
    );
  }

  @override
  void onReady() {
    super.onReady();

    _paginationService = PaginationService();

    _textPainter = TextPainter(
      text: TextSpan(
        text: "测试",
        style: state.contentStyle,
      ),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout(
        minWidth: 0,
        maxWidth: state.contentStyle.fontSize ??
            DefaultSetting.defaultBookReadSettingFontSize * 2);

    unawaited(_bootstrapInitialChapter());

    // 应用保存的亮度设置
    unawaited(_settingsController.captureSystemBrightness());
  }

  Future<void> _bootstrapInitialChapter() async {
    final epoch = ++_initialLoadEpoch;
    state.initialLoadErrorMessage = null;
    try {
      await _readerBootstrapFuture;
      await _hydrateBookDetailIfNeeded();
      final loaded = await _sessionController.loadInitialChapter(
        chapter: state.currentChapterIndex,
        initialPage: state.initialPageIndex,
      );
      if (loaded) {
        await _restoreCanonicalReadPosition();
      }
      if (!loaded && state.bookContentList.isEmpty) {
        state.initialLoadErrorMessage = '正文加载失败，请检查网络后重试';
      }
      await loadReadChapters();
    } catch (e, stackTrace) {
      LogUtils.e('阅读页初始化失败: $e', stackTrace: stackTrace);
      if (state.bookContentList.isEmpty) {
        state.initialLoadErrorMessage = '阅读页初始化失败，请重试';
      }
    } finally {
      if (epoch == _initialLoadEpoch) {
        state.isInitialLoading = false;
        _uiRefreshController.all();
      }
    }
  }

  Future<void> _restoreCanonicalReadPosition() async {
    final progress = await _readProgressDao.findByBook(
      bookSourceId: state.bookInfo.bookSourceId,
      bookName: state.bookInfo.name,
    );
    if (progress == null ||
        progress.chapterIndex != state.currentChapterIndex ||
        state.bookContentList.isEmpty) {
      return;
    }
    try {
      final locator = ReaderLocator.decode(progress.locatorJson);
      final resolution = const ReaderLocatorService().resolve(
        locator: locator,
        chapterText: state.bookContent,
      );
      var consumed = 0;
      var pageIndex = 0;
      for (var index = 0; index < state.bookContentList.length; index++) {
        final next = consumed + state.bookContentList[index].length;
        pageIndex = index;
        if (resolution.offsetUtf16 < next) break;
        consumed = next;
      }
      state.currentPage = state.isTwoPageMode ? pageIndex ~/ 2 * 2 : pageIndex;
      state.lastBookContent = state.bookContentList[state.currentPage];
      _uiRefreshController.contentAndChrome();
    } on FormatException catch (error) {
      LogUtils.e('阅读进度定位数据无效: $error');
    }
  }

  void retryInitialLoad() {
    state.isInitialLoading = true;
    state.initialLoadErrorMessage = null;
    _uiRefreshController.all();
    _sessionController.cancelCurrentChapterLoad('重试初始章节加载');
    unawaited(_bootstrapInitialChapter());
  }

  Future<bool> _openSourceLoginForChapter(ServiceError error) async {
    final sourceId = _sourceIdFromLoginRequiredError(error);
    if (sourceId == null) {
      LogUtils.d('正文登录重试缺少 sourceId: ${error.formatForLog()}');
      return false;
    }

    final source = await _bookSourceDao.findById(sourceId);
    if (source == null) {
      LogUtils.d('正文登录重试未找到书源: sourceId=$sourceId');
      return false;
    }

    if (!_sourceLoginController.hasOpenableSourceLoginEntry(source)) {
      LogUtils.d('正文登录重试无可用登录入口: sourceId=$sourceId');
      return false;
    }

    return _sourceLoginController.openSourceLogin(source);
  }

  /// 执行当前章节书源 `payAction`，成功后重载当前章节正文。
  Future<void> executePayActionAndReload() async {
    final sourceId = state.bookInfo.bookSourceId;
    final source = await _bookSourceDao.findById(sourceId);
    if (source == null) {
      DialogUtils.waring('未找到书源');
      return;
    }
    final chapters = state.bookDetail.chapters;
    if (chapters == null ||
        state.currentChapterIndex < 0 ||
        state.currentChapterIndex >= chapters.length) {
      DialogUtils.waring('当前章节不可用');
      return;
    }
    final chapter = chapters[state.currentChapterIndex];
    try {
      await DialogUtils.loading();
      final ok = await WebContentService.executePayAction(source, chapter);
      await DialogUtils.dismiss();
      if (!ok) {
        DialogUtils.waring('该书源未配置 payAction');
        return;
      }
      DialogUtils.success('已执行，正在刷新正文');
      retryInitialLoad();
    } catch (e, st) {
      await DialogUtils.dismiss();
      LogUtils.e('payAction 失败: $e', stackTrace: st);
      DialogUtils.waring('付费动作执行失败');
    }
  }

  int? _sourceIdFromLoginRequiredError(ServiceError error) {
    final sourceId = _intFromObject(error.context['sourceId']);
    if (sourceId != null) {
      return sourceId;
    }
    return _intFromObject(error.context['bookSourceId']) ??
        state.bookInfo.bookSourceId;
  }

  int? _intFromObject(Object? value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value.trim());
    return null;
  }

  Future<void> _hydrateBookDetailIfNeeded() async {
    final existingChapters = state.bookDetail.chapters;
    if (existingChapters != null && existingChapters.isNotEmpty) {
      return;
    }

    final matchedBook = await _bookshelfDao.findBook(
      bookSourceId: state.bookInfo.bookSourceId,
      bookName: state.bookInfo.name,
    );
    if (matchedBook == null) {
      return;
    }

    final chapterRecords = await _bookshelfDao.listChaptersByBookId(
      matchedBook.id,
    );
    if (chapterRecords.isEmpty) {
      return;
    }

    final chapters = chapterRecords
        .map(
          (chapter) => BookChapterInfo(
            bookSourceId: chapter.bookSourceId,
            chapterIndex: chapter.chapterIndex,
            chapterName: chapter.chapterName,
            chapterUrl: chapter.chapterUrl,
          ),
        )
        .toList(growable: false);

    state.bookDetail = state.bookDetail.copyWith(chapters: chapters);
    state.isAscending = state.bookDetail.isAscending;
  }

  @override
  void onClose() {
    _appLifecycleListener.dispose();
    _lifecycleController.dispose();
    _lifecycleController.endReadHistory();
    _textPainter.dispose();
    _paginationService.dispose();
    _pageTurnGestureController.dispose();
    _sessionController.dispose();
    _uiRefreshController.dispose();
    unawaited(_ttsController.dispose());
    unawaited(_voicePreviewTtsService.dispose());
    _cancelAllSourceSearches();
    _cacheController.dispose();
    _paragraphActionController.dispose();
    unawaited(
      _progressController.dispose(
        flushBeforeDispose: true,
        forceSave: true,
      ),
    );
    unawaited(_settingsController.restoreBrightness());
    _settingsController.dispose();
    super.onClose();
  }

  /// 取消所有换源搜索
  void _cancelAllSourceSearches() {
    for (var token in _sourceCancelTokens) {
      token.cancel('取消换源搜索');
    }
    _sourceCancelTokens.clear();
  }

  // ==================== 手势翻页入口（委托给独立控制器） ====================
  void onDragStart(DragStartDetails details, BoxConstraints constraints) {
    _pageTurnGestureController.onDragStart(details, constraints);
  }

  void onDragUpdate(DragUpdateDetails details, BoxConstraints constraints) {
    _pageTurnGestureController.onDragUpdate(details, constraints);
  }

  void onDragEnd(DragEndDetails details, BoxConstraints constraints) {
    _pageTurnGestureController.onDragEnd(details, constraints);
  }

  void onVerticalDragStart(
      DragStartDetails details, BoxConstraints constraints) {
    _pageTurnGestureController.onVerticalDragStart(details, constraints);
  }

  void onVerticalDragUpdate(
      DragUpdateDetails details, BoxConstraints constraints) {
    _pageTurnGestureController.onVerticalDragUpdate(details, constraints);
  }

  void onVerticalDragEnd(DragEndDetails details, BoxConstraints constraints) {
    _pageTurnGestureController.onVerticalDragEnd(details, constraints);
  }

  /// 切换 AppBar 显示隐藏
  void toggleAppBarVisibility() {
    state.isAppBarVisible = !state.isAppBarVisible;
    _uiRefreshController.chromeAndTtsFloating();
  }

  void hideAppBar() {
    if (!state.isAppBarVisible) return;
    state.isAppBarVisible = false;
    _uiRefreshController.chromeAndTtsFloating();
  }

  void showAppBar() {
    if (state.isAppBarVisible) return;
    state.isAppBarVisible = true;
    _uiRefreshController.chromeAndTtsFloating();
  }

  void beginParagraphActionGesture(
    Offset globalPosition,
    Future<void> Function() onTrigger,
  ) {
    _paragraphActionController.beginGesture(globalPosition, onTrigger);
  }

  void updateParagraphActionGesture(Offset globalPosition) {
    _paragraphActionController.updateGesture(globalPosition);
  }

  void cancelParagraphActionGesture() {
    _paragraphActionController.cancelGesture();
  }

  bool consumeParagraphTapSuppression() {
    return _paragraphActionController.consumeTapSuppression();
  }

  /// 上一页
  void previousPage() {
    _navigationController.previousPage();
  }

  /// 拖拽进度条跳页
  void jumpToPage(int page) {
    _navigationController.jumpToPage(page);
  }

  Future<void> jumpToPageAndSettle(int page) async {
    await _navigationController.jumpToPageAndSettle(page);
  }

  Future<void> jumpToChapterAndSettle(int chapterIndex) async {
    await _navigationController.jumpToChapterAndSettle(chapterIndex);
  }

  /// 下一页
  void nextPage() {
    _navigationController.nextPage();
  }

  /// 加载章节内容
  Future<void> loadChapter(
      {required int chapter,
      required bool preChapter,
      int initialPage = 0}) async {
    await _navigationController.loadChapter(
      chapter: chapter,
      preChapter: preChapter,
      initialPage: initialPage,
    );
  }

  /// 上一章
  Future<void> previousChapter(bool pre) async {
    await _navigationController.previousChapter(pre);
  }

  /// 下一章
  Future<void> nextChapter(bool pre) async {
    await _navigationController.nextChapter(pre);
  }

  String? getUpcomingNextChapterName() {
    return _sessionController.getUpcomingNextChapterName();
  }

  Future<void> retryCrossChapterTransition() async {
    await _sessionController.retryCrossChapterTransition();
  }

  void dismissCrossChapterTransition() {
    _sessionController.dismissCrossChapterTransition();
  }

  Future<void> nextChapterAndSettle(
    bool pre, {
    FutureOr<void> Function()? onContentReady,
  }) async {
    await _navigationController.nextChapterAndSettle(
      pre,
      onContentReady: onContentReady,
    );
  }

  // ==================== 垂直滚动模式专用方法 ====================

  /// 更新垂直滚动模式下的当前章节信息（不触发完整加载）
  void updateCurrentChapterForVerticalScroll(int chapterIndex) {
    _navigationController.updateCurrentChapterForVerticalScroll(chapterIndex);
  }

  /// 为垂直滚动模式加载指定章节的内容（不显示 loading，不分页）
  Future<String?> loadChapterContentForVerticalScroll(int chapterIndex) async {
    return _navigationController.loadChapterContentForVerticalScroll(
      chapterIndex,
    );
  }

  // ==================== PageFactory 逻辑 ====================

  /// 获取下一页内容（可能是下一章的第一页）
  String? getNextPageContent() {
    return _navigationController.getNextPageContent();
  }

  /// 获取上一页内容（可能是上一章的最后页）
  String? getPrevPageContent() {
    return _navigationController.getPrevPageContent();
  }

  /// 获取下一页的章节名称（用于跨章节时显示标题）
  String? getNextPageChapterName() {
    return _navigationController.getNextPageChapterName();
  }

  /// 获取上一页的章节名称（用于跨章节时显示标题）
  String? getPrevPageChapterName() {
    return _navigationController.getPrevPageChapterName();
  }

  /// 判断下一页是否跨章节
  bool isNextPageCrossChapter() {
    return _navigationController.isNextPageCrossChapter();
  }

  /// 判断上一页是否跨章节
  bool isPrevPageCrossChapter() {
    return _navigationController.isPrevPageCrossChapter();
  }

  Future<bool> moveToNextChapterWithCache() async {
    return _navigationController.moveToNextChapterWithCache();
  }

  Future<bool> moveToPrevChapterWithCache() async {
    return _navigationController.moveToPrevChapterWithCache();
  }

  /// 将书的内容分页（完全基于 TextPainter，100% 准确）
  void _splitBookContent() {
    _sessionController.splitCurrentBookContent();
  }

  //跳转指定页
  Future<void> jumpToChapter(int index) async {
    await _navigationController.jumpToChapter(index);
  }

  /// 加载已阅读章节索引
  Future<void> loadReadChapters() async {
    state.readChapterIndices = await _readChapterService.loadReadChapterIndices(
      bookSourceId: state.bookInfo.bookSourceId,
      bookName: state.bookInfo.name,
      chapters: state.bookDetail.chapters ?? [],
    );
    await loadCachedChapters();
  }

  /// 加载已缓存章节索引
  Future<void> loadCachedChapters() async {
    state.cachedChapterIndices =
        await _readChapterService.loadCachedChapterIndices(
      bookSourceId: state.bookInfo.bookSourceId,
      bookName: state.bookInfo.name,
      chapters: state.bookDetail.chapters ?? [],
    );
    _uiRefreshController.chromeAndOverlay();
  }

  void _scheduleReadProgressSave({bool immediate = false}) {
    _progressController.scheduleSave(immediate: immediate);
  }

  void updateBrightness(double value) async {
    _settingsController.updateBrightness(value);
  }

  void updateFontSize(double value) {
    _settingsController.updateFontSize(value);
  }

  void updateFontFamily(String? fontFamily) {
    _settingsController.updateFontFamily(fontFamily);
  }

  void updateTtsRate(double value) {
    _settingsController.updateTtsRate(value);
    unawaited(_ttsController.updateRate(state.ttsRate));
  }

  void updateTtsPitch(double value) {
    _settingsController.updateTtsPitch(value);
    unawaited(_ttsController.updatePitch(state.ttsPitch));
  }

  void updateTtsVolume(double value) {
    _settingsController.updateTtsVolume(value);
    unawaited(_ttsController.updateVolume(state.ttsVolume));
  }

  void updateTtsVoice(String? voiceName) {
    _settingsController.updateTtsVoiceName(voiceName);
    unawaited(_ttsController.updateVoiceName(state.ttsVoiceName));
  }

  void updateTtsAutoNextPage(bool value) {
    _settingsController.updateTtsAutoNextPage(value);
  }

  void updateTtsAutoNextChapter(bool value) {
    _settingsController.updateTtsAutoNextChapter(value);
  }

  void updateTtsResumeAfterInterrupt(bool value) {
    _settingsController.updateTtsResumeAfterInterrupt(value);
  }

  Future<void> loadTtsVoices() => _ttsController.loadVoices();

  void previewTtsVoice(String? voiceName) {
    unawaited(_previewTtsVoice(voiceName));
  }

  Future<void> _previewTtsVoice(String? voiceName) async {
    final normalized = voiceName?.trim();
    if (normalized == null || normalized.isEmpty) return;

    try {
      await _ttsController.stop();
      if (!_isVoicePreviewInitialized) {
        await _voicePreviewTtsService.init();
        _isVoicePreviewInitialized = true;
      }
      await _voicePreviewTtsService.setRate(state.ttsRate);
      await _voicePreviewTtsService.setPitch(state.ttsPitch);
      final previewVolume =
          state.ttsVolume <= 0 ? 1.0 : state.ttsVolume.clamp(0.2, 1.0);
      await _voicePreviewTtsService.setVolume(previewVolume.toDouble());
      await _voicePreviewTtsService.setVoiceByName(normalized);
      await _voicePreviewTtsService.speak(
        text: '这是一段有声书试听。风过庭前，灯影微动，故事正缓缓展开。',
        voiceName: normalized,
      );
    } catch (e) {
      LogUtils.e('试听 TTS 音色失败: $e');
      await DialogUtils.waring('试听音色失败：$e');
    }
  }

  Future<void> toggleTts() async {
    await _ttsController.toggle();
  }

  void showParagraphPreviewForPage({
    required int pageIndex,
    required int chapterIndex,
    required int start,
    required int end,
  }) {
    _previewController.showParagraphPreviewForPage(
      pageIndex: pageIndex,
      chapterIndex: chapterIndex,
      start: start,
      end: end,
    );
  }

  void showParagraphPreviewForChapter({
    required int chapterIndex,
    required int start,
    required int end,
  }) {
    _previewController.showParagraphPreviewForChapter(
      chapterIndex: chapterIndex,
      start: start,
      end: end,
    );
  }

  void clearParagraphPreview() {
    _previewController.clearParagraphPreview();
  }

  Future<void> waitForReadPageSettled() async {
    await _navigationController.waitForReadPageSettled();
  }

  Future<void> startTts() async {
    await _ttsController.start();
  }

  Future<void> startTtsFromCurrentPageParagraph(int pageTextOffset) async {
    final started = await _ttsController
        .startFromCurrentPageParagraphOffset(pageTextOffset);
    if (!started) {
      await DialogUtils.tips('当前段落无法朗读');
    }
  }

  Future<void> startTtsFromPageParagraph({
    required int pageIndex,
    required int pageTextOffset,
  }) async {
    final started = await _ttsController.startFromPageParagraphOffset(
      pageIndex: pageIndex,
      pageTextOffset: pageTextOffset,
    );
    if (!started) await DialogUtils.tips('当前段落无法朗读');
  }

  Future<void> startTtsFromChapterParagraph({
    required int chapterIndex,
    required int chapterOffset,
  }) async {
    final started = await _ttsController.startFromChapterParagraphOffset(
      chapterIndex: chapterIndex,
      chapterOffset: chapterOffset,
    );
    if (!started) {
      await DialogUtils.tips('当前段落无法朗读');
    }
  }

  Future<void> pauseTts() async {
    await _ttsController.pause();
  }

  Future<void> stopTts({bool showFeedback = false}) async {
    final wasVisible = state.isTtsPlaying || state.isTtsPaused;
    if (state.isTtsLongPressStopping) {
      state.isTtsLongPressStopping = false;
      _uiRefreshController.ttsFloating();
    }
    await _ttsController.stop();
    if (showFeedback && wasVisible) {
      await DialogUtils.tips('已停止朗读');
    }
  }

  void setTtsLongPressStopping(bool value) {
    if (state.isTtsLongPressStopping == value) return;
    state.isTtsLongPressStopping = value;
    _uiRefreshController.ttsFloating();
  }

  Future<void> exitReadPage() async {
    _initialLoadEpoch++;
    _sessionController.cancelCurrentChapterLoad('退出阅读页');
    if (state.pageTurnType == DefaultSetting.pageTurnTypeVertical) {
      _sessionController.syncCurrentChapterFromVisiblePosition();
    }
    await _lifecycleController.exitReader(
      onStopTts: stopTts,
      onSaveReadProgress: _progressController.saveCurrentProgress,
      onPopBack: () => Get.back(
        result: BookReadExitResult(
          chapterIndex: state.currentChapterIndex,
          pageIndex: state.currentPage,
        ),
      ),
    );
  }

  void updateBackgroundColor(Color color) {
    _settingsController.updateBackgroundColor(color);
  }

  void updatePageTurnType(String type) {
    _settingsController.updatePageTurnType(type);
  }

  void updateLineSpacing(double value) {
    _settingsController.updateLineSpacing(value);
  }

  void updateLetterSpacing(double value) {
    _settingsController.updateLetterSpacing(value);
  }

  void updateEyeProtectionMode() {
    _settingsController.updateEyeProtectionMode();
  }

  bool isNightMode() {
    return _settingsController.isNightMode();
  }

  void toggleNightMode() {
    _settingsController.toggleNightMode();
  }

  //章节排序
  void sortChapters() {
    // 切换排序状态
    state.isAscending = !state.isAscending;

    state.bookDetail =
        state.bookDetail.copyWith(isAscending: state.isAscending);
    unawaited(_persistChapterSortPreference());
    _uiRefreshController.contentChromeAndOverlay();
  }

  Future<void> _persistChapterSortPreference() async {
    if (!state.isInBookshelf) return;
    try {
      final existingBook = await _bookshelfDao.findBook(
        bookSourceId: state.bookInfo.bookSourceId,
        bookName: state.bookInfo.name,
      );
      if (existingBook == null) return;
      await _bookshelfDao.updateBook(
        bookId: existingBook.id,
        book: db.BooksCompanion(
          isAscending: drift.Value(state.isAscending),
        ),
      );
    } catch (e) {
      LogUtils.e('保存目录排序偏好失败: $e');
    }
  }

  // ==================== 书签功能 ====================

  Future<void> loadBookmarks() async {
    await _bookmarkController.loadBookmarks();
  }

  Future<void> loadAnnotations() async {
    try {
      await _annotationController.load();
    } catch (error) {
      LogUtils.e('加载批注失败: $error');
    }
  }

  Future<void> createAnnotation({
    required BookAnnotationType type,
    required int chapterIndex,
    required String chapterName,
    required String chapterText,
    required int start,
    required int end,
    String note = '',
  }) =>
      _annotationController.create(
        type: type,
        chapterIndex: chapterIndex,
        chapterName: chapterName,
        chapterText: chapterText,
        start: start,
        end: end,
        note: note,
      );

  Future<void> updateAnnotation(BookAnnotation annotation, String note) =>
      _annotationController.update(annotation, note);

  Future<void> deleteAnnotation(BookAnnotation annotation) =>
      _annotationController.delete(annotation);

  Future<void> jumpToAnnotation(BookAnnotation annotation) async {
    await _annotationController.jumpTo(annotation);
    if (state.bookContentList.isEmpty) return;
    try {
      final locator = ReaderLocator.decode(annotation.locatorJson);
      final resolution = const ReaderLocatorService().resolve(
        locator: locator,
        chapterText: state.bookContent,
      );
      var consumed = 0;
      for (var index = 0; index < state.bookContentList.length; index++) {
        final next = consumed + state.bookContentList[index].length;
        if (resolution.offsetUtf16 < next ||
            index == state.bookContentList.length - 1) {
          state.currentPage = index;
          state.lastBookContent = state.bookContentList[index];
          break;
        }
        consumed = next;
      }
      _uiRefreshController.contentAndChrome();
    } on FormatException catch (error) {
      LogUtils.e('批注定位数据无效: $error');
    }
  }

  List<ReaderAnnotationRange> annotationRangesForContent({
    required int chapterIndex,
    required String chapterText,
    required int contentOffsetInChapter,
    required int contentLength,
  }) {
    final contentEnd = contentOffsetInChapter + contentLength;
    final ranges = <ReaderAnnotationRange>[];
    for (final annotation in state.annotationList) {
      if (annotation.chapterIndex != chapterIndex) continue;
      try {
        final locator = ReaderLocator.decode(annotation.locatorJson);
        final resolved = const ReaderLocatorService().resolve(
          locator: locator,
          chapterText: chapterText,
        );
        final quoteLength = locator.quote?.length ?? annotation.excerpt.length;
        final start = resolved.offsetUtf16;
        final end = (start + quoteLength).clamp(start, chapterText.length);
        if (end <= contentOffsetInChapter || start >= contentEnd) continue;
        ranges.add(
          ReaderAnnotationRange(
            start: (start - contentOffsetInChapter).clamp(0, contentLength),
            end: (end - contentOffsetInChapter).clamp(0, contentLength),
            type: annotation.type,
            colorValue: annotation.colorValue,
          ),
        );
      } on FormatException {
        continue;
      }
    }
    ranges.sort((a, b) => a.start.compareTo(b.start));
    return ranges;
  }

  Future<void> toggleBookmark() async {
    await _bookmarkController.toggleBookmark();
  }

  Future<void> updateBookmark(db.Bookmark bookmark, String content) async {
    await _bookmarkController.updateBookmark(bookmark, content);
  }

  Future<void> deleteBookmark(db.Bookmark bookmark) async {
    await _bookmarkController.deleteBookmark(bookmark);
  }

  Future<void> jumpToBookmark(db.Bookmark bookmark) =>
      _bookmarkController.jumpToBookmark(bookmark);

  Future<void> _jumpToLocator(ReaderLocator locator) async {
    await jumpToChapter(locator.chapterIndex);
    if (state.bookContentList.isEmpty) return;
    final resolution = const ReaderLocatorService().resolve(
      locator: locator,
      chapterText: state.bookContent,
    );
    var consumed = 0;
    for (var index = 0; index < state.bookContentList.length; index++) {
      final next = consumed + state.bookContentList[index].length;
      if (resolution.offsetUtf16 < next ||
          index == state.bookContentList.length - 1) {
        state.currentPage = index;
        state.lastBookContent = state.bookContentList[index];
        break;
      }
      consumed = next;
    }
    _uiRefreshController.contentAndChrome();
  }

  /// 横竖屏变化时触发重新计算并分页
  void onOrientationChanged(Orientation orientation, Size size) {
    _lifecycleController.handleOrientationChanged(
      context: Get.context!,
      orientation: orientation,
      size: size,
      onSplitBookContent: _splitBookContent,
      onRelocateCurrentPage: _relocateCurrentPage,
      onUpdate: _uiRefreshController.contentAndChrome,
    );
  }

  /// 重新定位当前页面（字体/行距变化后调用）
  void _relocateCurrentPage() {
    if (state.bookContentList.isEmpty) return;
    final newIndex = _paginationService.relocatePage(
      state.bookContentList,
      state.lastBookContent,
    );
    state.currentPage = newIndex.clamp(0, state.pageSize - 1);
    if (state.isTwoPageMode) {
      state.currentPage = state.currentPage ~/ 2 * 2;
    }
    state.lastBookContent = state.bookContentList[state.currentPage];
  }

  Future<void> showSourceDialog() async {
    await stopTts();
    await _libraryController.showSourceDialog();
  }

  Future<void> toggleBookshelf() async {
    await _libraryController.toggleBookshelf();
  }

  /// 重新加载当前章节（强制从网络获取）
  Future<void> reloadCurrentChapter() async {
    await stopTts();
    await _cacheController.reloadCurrentChapter();
  }

  Future<void> cacheAllChapters() async {
    await _cacheController.cacheAllChapters();
  }

  /// 取消缓存
  void cancelCache() {
    _cacheController.cancelCache();
  }
}
