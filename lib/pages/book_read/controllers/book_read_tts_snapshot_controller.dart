import 'dart:math' as math;

import '../models/tts_page_snapshot.dart';
import '../state.dart';
import '../services/tts_utterance_planner.dart';

class BookReadTtsSnapshotController {
  BookReadTtsSnapshotController({
    required this.state,
  });

  final BookReadState state;
  final TtsUtterancePlanner _planner = const TtsUtterancePlanner();
  final Map<String, TtsPageSnapshot> _snapshotCache =
      <String, TtsPageSnapshot>{};
  String? _chapterPlanCacheKey;
  TtsChapterUtterancePlan? _chapterPlan;

  TtsPageSnapshot? getCurrentPageSnapshot({
    required int chapterIndex,
    required int pageIndex,
  }) {
    if (state.bookContentList.isEmpty ||
        pageIndex < 0 ||
        pageIndex >= state.bookContentList.length) {
      return null;
    }

    final pagesSignature = Object.hashAll(
      state.bookContentList
          .map((page) => Object.hash(page.length, page.hashCode)),
    );
    final cacheKey = '$chapterIndex:$pagesSignature';
    if (_chapterPlanCacheKey != cacheKey) {
      _chapterPlan = _planner.planChapter(
        chapterIndex: chapterIndex,
        pageTexts: state.bookContentList,
      );
      _chapterPlanCacheKey = cacheKey;
    }
    return _chapterPlan!.pages[pageIndex].snapshot;
  }

  TtsPageSnapshot getSnapshotForText({
    required int chapterIndex,
    required int pageIndex,
    required String pageText,
    required int pageStartOffsetInChapter,
  }) {
    final cacheKey = '$chapterIndex:$pageIndex:${pageText.hashCode}:'
        '$pageStartOffsetInChapter';
    final cached = _snapshotCache[cacheKey];
    if (cached != null) {
      return cached;
    }

    if (_snapshotCache.length >= 96) {
      _snapshotCache.clear();
    }

    final snapshot = _planner
        .planPage(
          chapterIndex: chapterIndex,
          pageIndex: pageIndex,
          pageText: pageText,
          pageStartOffsetInChapter: pageStartOffsetInChapter,
        )
        .snapshot;
    _snapshotCache[cacheKey] = snapshot;
    return snapshot;
  }

  int computePageStartOffsetInChapter(int pageIndex) {
    if (pageIndex <= 0 || state.bookContentList.isEmpty) return 0;

    var offset = 0;
    final limit = math.min(pageIndex, state.bookContentList.length);
    for (var index = 0; index < limit; index++) {
      offset += state.bookContentList[index].length;
    }
    return offset;
  }

  int locatePageIndexForChapterOffset(int chapterOffset) {
    if (state.bookContentList.isEmpty) return -1;

    var pageStart = 0;
    for (var index = 0; index < state.bookContentList.length; index++) {
      final pageLength = state.bookContentList[index].length;
      final pageEnd = pageStart + pageLength;
      if (chapterOffset < pageEnd ||
          index == state.bookContentList.length - 1) {
        return index;
      }
      pageStart = pageEnd;
    }

    return state.bookContentList.length - 1;
  }

  int? findSentenceIndexForPageOffset(
    TtsPageSnapshot snapshot,
    int pageOffset,
  ) {
    if (snapshot.segments.isEmpty) return null;

    for (var index = 0; index < snapshot.segments.length; index++) {
      final segment = snapshot.segments[index];
      if (segment.end <= pageOffset) {
        continue;
      }
      return index;
    }

    return snapshot.segments.length - 1;
  }

  void clear() {
    _snapshotCache.clear();
    _chapterPlanCacheKey = null;
    _chapterPlan = null;
  }
}
