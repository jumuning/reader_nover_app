class TwoPageSpreadStrategy {
  const TwoPageSpreadStrategy._();

  static const double minimumViewportWidth = 840;
  static const double gutter = 20;

  static bool isEnabled({
    required double viewportWidth,
    required bool isVerticalMode,
  }) {
    return !isVerticalMode && viewportWidth >= minimumViewportWidth;
  }

  static double columnWidth(double viewportWidth) {
    return ((viewportWidth - gutter) / 2).clamp(0, viewportWidth);
  }

  static int anchorFor(int pageIndex) => pageIndex < 1 ? 0 : pageIndex ~/ 2 * 2;

  static int nextAnchor(int currentAnchor, int pageCount) {
    return (anchorFor(currentAnchor) + 2).clamp(0, pageCount - 1);
  }

  static int previousAnchor(int currentAnchor) {
    return (anchorFor(currentAnchor) - 2).clamp(0, currentAnchor);
  }

  static List<int> visiblePages(int anchor, int pageCount) {
    if (pageCount <= 0) return const [];
    final left = anchorFor(anchor).clamp(0, pageCount - 1);
    return [left, if (left + 1 < pageCount) left + 1];
  }
}
