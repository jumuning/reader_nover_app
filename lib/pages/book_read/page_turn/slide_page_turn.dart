import 'package:flutter/material.dart';
import 'page_turn_base.dart';

/// 平移翻页效果
/// 当前页和目标页同时移动，类似图片轮播效果
class SlidePageTurn extends PageTurnBase {
  const SlidePageTurn({
    super.key,
    required super.logic,
    required super.state,
    required super.constraints,
    required super.currentPageWidget,
    required super.targetPageWidget,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge(
        <Listenable>[
          state.slideOffsetX,
          logic.uiRefreshController.pageTurnStateListenable,
        ],
      ),
      builder: (context, _) {
        final screenWidth = constraints.maxWidth;
        final offsetX = state.slideOffsetX.value;
        if (!state.isAnimating && offsetX == 0) {
          return RepaintBoundary(child: currentPageWidget);
        }

        final isGoingNext = state.isNext;
        final currentPageOffset = offsetX;
        final targetPageOffset =
            isGoingNext ? screenWidth + offsetX : -screenWidth + offsetX;

        final Widget bottomPageWidget;
        final double bottomPageOffset;
        final Widget topPageWidget;
        final double topPageOffset;

        if (isGoingNext) {
          bottomPageWidget = targetPageWidget;
          bottomPageOffset = targetPageOffset;
          topPageWidget = currentPageWidget;
          topPageOffset = currentPageOffset;
        } else {
          bottomPageWidget = currentPageWidget;
          bottomPageOffset = currentPageOffset;
          topPageWidget = targetPageWidget;
          topPageOffset = targetPageOffset;
        }

        return Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: bottomPageOffset,
              top: 0,
              width: screenWidth,
              height: constraints.maxHeight,
              child: RepaintBoundary(child: bottomPageWidget),
            ),
            Positioned(
              left: topPageOffset,
              top: 0,
              width: screenWidth,
              height: constraints.maxHeight,
              child: RepaintBoundary(child: topPageWidget),
            ),
          ],
        );
      },
    );
  }
}
