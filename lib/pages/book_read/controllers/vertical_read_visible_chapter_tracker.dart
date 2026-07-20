import '../state.dart';

class VerticalReadVisibleChapterTracker {
  VerticalReadVisibleChapterTracker({
    double fallbackChapterExtent = 720.0,
  }) : _fallbackChapterExtent = fallbackChapterExtent;

  final Map<int, double> _chapterExtentCache = <int, double>{};
  final List<int> _orderedChapterIndices = <int>[];
  final List<double> _chapterTrailingOffsets = <double>[];

  double _fallbackChapterExtent;
  double _averageMeasuredExtent = 0.0;
  double _leadingScrollExtent = 0.0;
  bool _rangesDirty = true;
  int? _visibleChapterIndex;

  int? get visibleChapterIndex => _visibleChapterIndex;

  void updateFallbackChapterExtent(double extent) {
    if (extent <= 0 || extent == _fallbackChapterExtent) return;
    _fallbackChapterExtent = extent;
    _rangesDirty = true;
  }

  void updateLoadedChapters(List<VerticalChapterData> chapters) {
    final nextIndices =
        chapters.map((chapter) => chapter.chapterIndex).toList(growable: false);
    if (_isSameChapterOrder(nextIndices)) return;

    _orderedChapterIndices
      ..clear()
      ..addAll(nextIndices);
    _rangesDirty = true;
  }

  void setVisibleChapterIndex(int chapterIndex) {
    _visibleChapterIndex = chapterIndex;
  }

  void invalidateMeasuredExtents() {
    if (_chapterExtentCache.isEmpty) return;
    _chapterExtentCache.clear();
    _averageMeasuredExtent = 0.0;
    _rangesDirty = true;
  }

  bool recordChapterExtent({
    required int chapterIndex,
    required double extent,
  }) {
    if (extent <= 0) return false;

    final previousExtent = _chapterExtentCache[chapterIndex];
    if (previousExtent != null && (previousExtent - extent).abs() < 0.5) {
      return false;
    }

    _chapterExtentCache[chapterIndex] = extent;
    _recomputeAverageMeasuredExtent();
    _rangesDirty = true;
    return true;
  }

  double resolveChapterExtent(int chapterIndex) {
    return _chapterExtentCache[chapterIndex] ?? _estimateChapterExtent();
  }

  int? resolveVisibleChapterIndex({
    required double scrollOffset,
    required double viewportExtent,
    required double leadingScrollExtent,
  }) {
    if (_orderedChapterIndices.isEmpty) return null;
    if (viewportExtent <= 0) {
      return _visibleChapterIndex ?? _orderedChapterIndices.first;
    }

    _ensureChapterRanges(leadingScrollExtent);
    final anchorOffset = scrollOffset + viewportExtent / 2;
    if (anchorOffset <= _leadingScrollExtent) {
      return _orderedChapterIndices.first;
    }

    var left = 0;
    var right = _chapterTrailingOffsets.length - 1;
    while (left < right) {
      final middle = left + ((right - left) >> 1);
      if (anchorOffset < _chapterTrailingOffsets[middle]) {
        right = middle;
      } else {
        left = middle + 1;
      }
    }
    return _orderedChapterIndices[left];
  }

  double _estimateChapterExtent() {
    if (_averageMeasuredExtent > 0) return _averageMeasuredExtent;
    return _fallbackChapterExtent;
  }

  void _ensureChapterRanges(double leadingScrollExtent) {
    if (!_rangesDirty && _leadingScrollExtent == leadingScrollExtent) return;

    _leadingScrollExtent = leadingScrollExtent;
    _chapterTrailingOffsets.clear();

    var trailingOffset = leadingScrollExtent;
    for (final chapterIndex in _orderedChapterIndices) {
      trailingOffset += resolveChapterExtent(chapterIndex);
      _chapterTrailingOffsets.add(trailingOffset);
    }
    _rangesDirty = false;
  }

  void _recomputeAverageMeasuredExtent() {
    if (_chapterExtentCache.isEmpty) {
      _averageMeasuredExtent = 0.0;
      return;
    }

    var totalExtent = 0.0;
    for (final extent in _chapterExtentCache.values) {
      totalExtent += extent;
    }
    _averageMeasuredExtent = totalExtent / _chapterExtentCache.length;
  }

  bool _isSameChapterOrder(List<int> nextIndices) {
    if (_orderedChapterIndices.length != nextIndices.length) return false;
    for (var index = 0; index < nextIndices.length; index++) {
      if (_orderedChapterIndices[index] != nextIndices[index]) {
        return false;
      }
    }
    return true;
  }
}
