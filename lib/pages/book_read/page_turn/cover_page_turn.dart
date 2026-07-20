import 'package:flutter/material.dart';
import 'page_turn_base.dart';

/// 覆盖翻页效果
/// 主流阅读App的覆盖翻页：
/// - 翻下一页：当前页向左滑出，露出底层的下一页
/// - 翻上一页：上一页从左侧滑入覆盖当前页（下一页动画的回退效果）
class CoverPageTurn extends PageTurnBase {
  const CoverPageTurn({
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

        final bool isGoingNext = state.isNext;
        final double progress = (offsetX.abs() / screenWidth).clamp(0.0, 1.0);
        final double shadowOpacity = 0.4 * progress;

        if (isGoingNext) {
          final double topPageOffset = offsetX;
          return Stack(
            children: [
              Positioned.fill(
                child: RepaintBoundary(child: targetPageWidget),
              ),
              Positioned(
                left: topPageOffset,
                top: 0,
                width: screenWidth,
                height: constraints.maxHeight,
                child: RepaintBoundary(
                  child: Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black
                              .withValues(alpha: 0.3 * (1 - progress)),
                          blurRadius: 15,
                          spreadRadius: 0,
                          offset: const Offset(-5, 0),
                        ),
                      ],
                    ),
                    child: currentPageWidget,
                  ),
                ),
              ),
            ],
          );
        }

        final double topPageOffset = -screenWidth + offsetX;
        return Stack(
          children: [
            Positioned.fill(
              child: RepaintBoundary(child: currentPageWidget),
            ),
            Positioned(
              left: topPageOffset,
              top: 0,
              width: screenWidth,
              height: constraints.maxHeight,
              child: RepaintBoundary(
                child: Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: shadowOpacity),
                        blurRadius: 15,
                        spreadRadius: 0,
                        offset: const Offset(-5, 0),
                      ),
                    ],
                  ),
                  child: targetPageWidget,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
