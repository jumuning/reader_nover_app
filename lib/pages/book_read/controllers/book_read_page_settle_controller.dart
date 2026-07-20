import 'package:flutter/widgets.dart';

import '../state.dart';

class BookReadPageSettleController {
  const BookReadPageSettleController({
    required this.state,
  });

  final BookReadState state;

  Future<void> waitForPageSettled() async {
    const int maxChecks = 12;
    const int requiredStablePasses = 2;

    _ReadPageSnapshot? previousSnapshot;
    var stablePasses = 0;

    for (var index = 0; index < maxChecks; index++) {
      await WidgetsBinding.instance.endOfFrame;

      final snapshot = _captureSnapshot();
      final isReady = _isPageReady();
      if (!isReady) {
        stablePasses = 0;
      } else if (snapshot == previousSnapshot) {
        stablePasses++;
      } else {
        stablePasses = 1;
      }

      previousSnapshot = snapshot;
      if (isReady && stablePasses >= requiredStablePasses) {
        return;
      }
    }
  }

  bool _isPageReady() {
    if (state.isInitialLoading || state.isAnimating) {
      return false;
    }
    if (state.pageSize <= 0 || state.bookContentList.isEmpty) {
      return false;
    }
    if (state.currentPage < 0 || state.currentPage >= state.pageSize) {
      return false;
    }
    return true;
  }

  _ReadPageSnapshot _captureSnapshot() {
    return _ReadPageSnapshot(
      chapterIndex: state.currentChapterIndex,
      currentPage: state.currentPage,
      pageSize: state.pageSize,
      pageCount: state.bookContentList.length,
      currentPageHash: state.bookContentList.isNotEmpty &&
              state.currentPage >= 0 &&
              state.currentPage < state.bookContentList.length
          ? state.bookContentList[state.currentPage].hashCode
          : 0,
      isAnimating: state.isAnimating,
    );
  }
}

class _ReadPageSnapshot {
  const _ReadPageSnapshot({
    required this.chapterIndex,
    required this.currentPage,
    required this.pageSize,
    required this.pageCount,
    required this.currentPageHash,
    required this.isAnimating,
  });

  final int chapterIndex;
  final int currentPage;
  final int pageSize;
  final int pageCount;
  final int currentPageHash;
  final bool isAnimating;

  @override
  bool operator ==(Object other) {
    return other is _ReadPageSnapshot &&
        other.chapterIndex == chapterIndex &&
        other.currentPage == currentPage &&
        other.pageSize == pageSize &&
        other.pageCount == pageCount &&
        other.currentPageHash == currentPageHash &&
        other.isAnimating == isAnimating;
  }

  @override
  int get hashCode => Object.hash(
        chapterIndex,
        currentPage,
        pageSize,
        pageCount,
        currentPageHash,
        isAnimating,
      );
}
