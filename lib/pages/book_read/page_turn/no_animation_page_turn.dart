import 'package:flutter/material.dart';
import 'page_turn_base.dart';

/// 无动画翻页效果
/// 直接切换页面，无任何过渡动画
class NoAnimationPageTurn extends PageTurnBase {
  const NoAnimationPageTurn({
    super.key,
    required super.logic,
    required super.state,
    required super.constraints,
    required super.currentPageWidget,
    required super.targetPageWidget,
  });

  @override
  Widget build(BuildContext context) {
    // 无动画模式：只显示当前页内容
    return RepaintBoundary(child: currentPageWidget);
  }
}
