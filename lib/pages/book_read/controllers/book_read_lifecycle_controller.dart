import 'dart:async';

import 'package:flutter/material.dart';

import '../../../util/log_utils.dart';
import '../../../app/service/book/read_history_service.dart';
import '../../../app/service/book/reader_locator.dart';
import '../state.dart';

class BookReadLifecycleController {
  BookReadLifecycleController({
    required this.state,
    required ReadHistoryService readHistoryService,
  }) : _readHistoryService = readHistoryService;

  final BookReadState state;
  final ReadHistoryService _readHistoryService;

  bool _isLeavingReader = false;
  bool _isDisposed = false;

  void dispose() {
    _isDisposed = true;
  }

  Future<void> beginReadHistory() async {
    try {
      await _readHistoryService.startHistory(
        bookSourceId: state.bookInfo.bookSourceId,
        bookName: state.bookInfo.name,
        chapterName: state.currentChapter,
        chapterIndex: state.currentChapterIndex,
        locator: _currentLocator(),
      );
    } catch (e) {
      LogUtils.e('开始阅读历史记录失败: $e');
    }
  }

  Future<void> endReadHistory() async {
    try {
      await _readHistoryService.endHistory(locator: _currentLocator());
    } catch (e) {
      LogUtils.e('结束阅读历史记录失败: $e');
    }
  }

  ReaderLocator _currentLocator() {
    final page = state.currentPage.clamp(0, state.bookContentList.length);
    final offset = state.bookContentList
        .take(page)
        .fold<int>(0, (total, text) => total + text.length);
    return const ReaderLocatorService().create(
      chapterIndex: state.currentChapterIndex,
      chapterName: state.currentChapter,
      chapterText: state.bookContent,
      offsetUtf16: offset,
    );
  }

  Future<void> initializeReader({
    required BuildContext context,
    required Future<void> Function() onCheckBookshelfStatus,
    required Future<void> Function() onLoadReadChapters,
    required Future<void> Function() onLoadSavedSettings,
    required Future<void> Function() onLoadBookmarks,
    required Future<void> Function() onInitTts,
    required VoidCallback onUpdate,
  }) async {
    state.initScreenSize(context);

    final settingsFuture = onLoadSavedSettings();
    await settingsFuture;
    if (!_isDisposed) onUpdate();

    unawaited(_initializeDeferred(
      onCheckBookshelfStatus: onCheckBookshelfStatus,
      onLoadReadChapters: onLoadReadChapters,
      onLoadBookmarks: onLoadBookmarks,
      onInitTts: onInitTts,
      onUpdate: onUpdate,
    ));
  }

  Future<void> _initializeDeferred({
    required Future<void> Function() onCheckBookshelfStatus,
    required Future<void> Function() onLoadReadChapters,
    required Future<void> Function() onLoadBookmarks,
    required Future<void> Function() onInitTts,
    required VoidCallback onUpdate,
  }) async {
    Future<void> runSafely(
      String operation,
      Future<void> Function() action,
    ) async {
      try {
        await action();
      } catch (e, stackTrace) {
        LogUtils.e('$operation失败，阅读页继续启动: $e', stackTrace: stackTrace);
      }
    }

    await Future.wait([
      runSafely('书架状态初始化', onCheckBookshelfStatus),
      runSafely('已读章节初始化', onLoadReadChapters),
      runSafely('书签初始化', onLoadBookmarks),
      runSafely('TTS 初始化', onInitTts),
    ]);
    if (!_isDisposed) onUpdate();
  }

  Future<void> exitReader({
    required Future<void> Function() onStopTts,
    required Future<void> Function() onSaveReadProgress,
    required VoidCallback onPopBack,
  }) async {
    if (_isLeavingReader) return;
    _isLeavingReader = true;
    try {
      await onStopTts();
      await onSaveReadProgress();
    } finally {
      onPopBack();
    }
  }

  void handleOrientationChanged({
    required BuildContext context,
    required Orientation orientation,
    required Size size,
    required VoidCallback onSplitBookContent,
    required VoidCallback onRelocateCurrentPage,
    required VoidCallback onUpdate,
  }) {
    final media = MediaQuery.of(context);

    final isOrientationChanged = state.currentOrientation != orientation ||
        state.screenWidth != size.width ||
        state.screenHeight != size.height;

    state.currentOrientation = orientation;
    state.screenWidth = size.width;
    state.screenHeight = size.height;
    state.safePadding = media.padding;
    state.textScaler = media.textScaler;

    if (state.bookContent.isNotEmpty && isOrientationChanged) {
      state.isFontSizeChanged = true;
      onSplitBookContent();
      onRelocateCurrentPage();
      onUpdate();
    }
  }
}
