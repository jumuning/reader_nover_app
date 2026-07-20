import 'package:flutter/material.dart';
import '../../../app/constants/default_setting.dart';
import '../logic.dart';
import '../state.dart';
import 'cover_page_turn.dart';
import 'no_animation_page_turn.dart';
import 'simulation_page_turn.dart';
import 'slide_page_turn.dart';
import 'vertical_page_turn.dart';

/// 统一的翻页组件入口
/// 根据设置自动选择对应的翻页效果
class PageTurnWidget extends StatelessWidget {
  final BookReadLogic logic;
  final BookReadState state;
  final BoxConstraints constraints;
  final Widget currentPageWidget;
  final Widget targetPageWidget;

  const PageTurnWidget({
    super.key,
    required this.logic,
    required this.state,
    required this.constraints,
    required this.currentPageWidget,
    required this.targetPageWidget,
  });

  @override
  Widget build(BuildContext context) {
    // 根据翻页类型返回对应的翻页组件
    switch (state.pageTurnType) {
      case DefaultSetting.pageTurnTypeSimulation:
        return SimulationPageTurn(
          logic: logic,
          state: state,
          constraints: constraints,
          currentPageWidget: currentPageWidget,
          targetPageWidget: targetPageWidget,
        );

      case DefaultSetting.pageTurnTypeCover:
        return CoverPageTurn(
          logic: logic,
          state: state,
          constraints: constraints,
          currentPageWidget: currentPageWidget,
          targetPageWidget: targetPageWidget,
        );

      case DefaultSetting.pageTurnTypeSlide:
        return SlidePageTurn(
          logic: logic,
          state: state,
          constraints: constraints,
          currentPageWidget: currentPageWidget,
          targetPageWidget: targetPageWidget,
        );

      case DefaultSetting.pageTurnTypeVertical:
        return VerticalPageTurn(
          logic: logic,
          state: state,
          constraints: constraints,
          currentPageWidget: currentPageWidget,
          targetPageWidget: targetPageWidget,
        );

      case DefaultSetting.pageTurnTypeNoAnimation:
        return NoAnimationPageTurn(
          logic: logic,
          state: state,
          constraints: constraints,
          currentPageWidget: currentPageWidget,
          targetPageWidget: targetPageWidget,
        );

      default:
        // 默认使用仿真翻页
        return SimulationPageTurn(
          logic: logic,
          state: state,
          constraints: constraints,
          currentPageWidget: currentPageWidget,
          targetPageWidget: targetPageWidget,
        );
    }
  }
}
