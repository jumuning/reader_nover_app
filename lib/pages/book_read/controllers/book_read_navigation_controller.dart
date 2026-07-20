import 'dart:async';

import '../state.dart';
import 'book_read_page_settle_controller.dart';
import 'book_read_session_controller.dart';

class BookReadNavigationController {
  BookReadNavigationController({
    required this.state,
    required BookReadSessionController sessionController,
    required BookReadPageSettleController pageSettleController,
    required Future<void> Function({bool forceResume})
        onHandleReadingPositionChanged,
  })  : _sessionController = sessionController,
        _pageSettleController = pageSettleController,
        _onHandleReadingPositionChanged = onHandleReadingPositionChanged;

  final BookReadState state;
  final BookReadSessionController _sessionController;
  final BookReadPageSettleController _pageSettleController;
  final Future<void> Function({bool forceResume})
      _onHandleReadingPositionChanged;

  void previousPage() {
    final previousChapterIndex = state.currentChapterIndex;
    final previousPage = state.currentPage;
    _sessionController.previousPage();
    _syncTtsAfterManualPositionChange(
      previousChapterIndex: previousChapterIndex,
      previousPage: previousPage,
    );
  }

  void jumpToPage(int page) {
    final previousChapterIndex = state.currentChapterIndex;
    final previousPage = state.currentPage;
    _sessionController.jumpToPage(page);
    _syncTtsAfterManualPositionChange(
      previousChapterIndex: previousChapterIndex,
      previousPage: previousPage,
    );
  }

  Future<void> jumpToPageAndSettle(int page) async {
    _sessionController.jumpToPage(page);
    await waitForReadPageSettled();
  }

  Future<void> jumpToChapterAndSettle(int chapterIndex) async {
    if (state.currentChapterIndex != chapterIndex ||
        state.bookContentList.isEmpty) {
      await _sessionController.jumpToChapter(chapterIndex);
    }
    await waitForReadPageSettled();
  }

  void nextPage() {
    final previousChapterIndex = state.currentChapterIndex;
    final previousPage = state.currentPage;
    _sessionController.nextPage();
    _syncTtsAfterManualPositionChange(
      previousChapterIndex: previousChapterIndex,
      previousPage: previousPage,
    );
  }

  Future<void> loadChapter({
    required int chapter,
    required bool preChapter,
    int initialPage = 0,
    bool forceRefresh = false,
  }) async {
    await _sessionController.loadChapter(
      chapter: chapter,
      preChapter: preChapter,
      initialPage: initialPage,
      forceRefresh: forceRefresh,
    );
    await _onHandleReadingPositionChanged();
  }

  Future<void> previousChapter(bool pre) async {
    final previousChapterIndex = state.currentChapterIndex;
    final previousPage = state.currentPage;
    await _sessionController.previousChapter(pre);
    _syncTtsAfterManualPositionChange(
      previousChapterIndex: previousChapterIndex,
      previousPage: previousPage,
    );
  }

  Future<void> nextChapter(bool pre) async {
    final previousChapterIndex = state.currentChapterIndex;
    final previousPage = state.currentPage;
    await _sessionController.nextChapter(pre);
    _syncTtsAfterManualPositionChange(
      previousChapterIndex: previousChapterIndex,
      previousPage: previousPage,
    );
  }

  Future<void> nextChapterAndSettle(
    bool pre, {
    FutureOr<void> Function()? onContentReady,
  }) async {
    var movedWithCache = await _sessionController.moveToNextChapterWithCache(
      deferReadHistoryStart: true,
    );
    if (!movedWithCache) {
      final cacheReady = await _sessionController.ensureNextChapterCacheReady();
      if (cacheReady) {
        movedWithCache = await _sessionController.moveToNextChapterWithCache(
          deferReadHistoryStart: true,
        );
      }
    }
    if (!movedWithCache) {
      await _sessionController.nextChapterSilently(
        pre,
        deferReadChaptersRefresh: true,
        deferReadHistoryStart: true,
      );
    }
    if (onContentReady != null) {
      await onContentReady();
    }
    await waitForReadPageSettled();
  }

  void updateCurrentChapterForVerticalScroll(int chapterIndex) {
    _sessionController.updateCurrentChapterForVerticalScroll(chapterIndex);
  }

  Future<String?> loadChapterContentForVerticalScroll(int chapterIndex) async {
    return _sessionController.loadChapterContentForVerticalScroll(chapterIndex);
  }

  String? getNextPageContent() => _sessionController.getNextPageContent();

  String? getPrevPageContent() => _sessionController.getPrevPageContent();

  String? getNextPageChapterName() =>
      _sessionController.getNextPageChapterName();

  String? getPrevPageChapterName() =>
      _sessionController.getPrevPageChapterName();

  bool isNextPageCrossChapter() => _sessionController.isNextPageCrossChapter();

  bool isPrevPageCrossChapter() => _sessionController.isPrevPageCrossChapter();

  Future<bool> moveToNextChapterWithCache() async {
    return _sessionController.moveToNextChapterWithCache();
  }

  Future<bool> moveToPrevChapterWithCache() async {
    return _sessionController.moveToPrevChapterWithCache();
  }

  Future<void> jumpToChapter(int index) async {
    final previousChapterIndex = state.currentChapterIndex;
    final previousPage = state.currentPage;
    await _sessionController.jumpToChapter(index);
    _syncTtsAfterManualPositionChange(
      previousChapterIndex: previousChapterIndex,
      previousPage: previousPage,
    );
  }

  Future<void> waitForReadPageSettled() async {
    await _pageSettleController.waitForPageSettled();
  }

  void _syncTtsAfterManualPositionChange({
    required int previousChapterIndex,
    required int previousPage,
  }) {
    if (state.currentChapterIndex == previousChapterIndex &&
        state.currentPage == previousPage) {
      return;
    }
    unawaited(_onHandleReadingPositionChanged(forceResume: true));
  }
}
