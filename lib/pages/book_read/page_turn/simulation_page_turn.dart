import 'package:flutter/material.dart';
import '../../../util/paper/current_paper_clip_path.dart';
import '../../../util/paper/paper_painter.dart';
import 'page_turn_base.dart';

/// 仿真翻页效果
/// 模拟真实书籍翻页的卷曲效果
class SimulationPageTurn extends PageTurnBase {
  const SimulationPageTurn({
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
          state.paperPoint,
          logic.uiRefreshController.pageTurnStateListenable,
        ],
      ),
      builder: (context, _) {
        final paperPoint = state.paperPoint.value;
        if (!state.isAnimating && !paperPoint.isValid) {
          return RepaintBoundary(child: currentPageWidget);
        }

        final Widget bottomPage =
            state.isNext ? targetPageWidget : currentPageWidget;
        final Widget topPage =
            state.isNext ? currentPageWidget : targetPageWidget;

        return Stack(
          children: [
            RepaintBoundary(child: bottomPage),
            if (paperPoint.isValid)
              ClipPath(
                clipBehavior: Clip.hardEdge,
                clipper: CurrentPaperClipPath(state.paperPoint, state.isNext),
                child: RepaintBoundary(
                  // Cache the full page layer separately so the changing clip
                  // does not force the text subtree to repaint every frame.
                  child: topPage,
                ),
              ),
            if (paperPoint.isValid)
              RepaintBoundary(
                child: CustomPaint(
                  size: Size(constraints.maxWidth, constraints.maxHeight),
                  willChange: true,
                  painter:
                      PaperPainter(state.paperPoint, state.backgroundColor),
                ),
              ),
          ],
        );
      },
    );
  }
}
