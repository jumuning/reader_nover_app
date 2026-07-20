import 'package:flutter/material.dart';
import '../logic.dart';
import '../state.dart';

/// 翻页策略基类
/// 所有翻页方式都需要实现此接口
abstract class PageTurnBase extends StatelessWidget {
  final BookReadLogic logic;
  final BookReadState state;
  final BoxConstraints constraints;

  /// 当前页内容组件
  final Widget currentPageWidget;

  /// 目标页内容组件（翻页后显示的页面）
  final Widget targetPageWidget;

  const PageTurnBase({
    super.key,
    required this.logic,
    required this.state,
    required this.constraints,
    required this.currentPageWidget,
    required this.targetPageWidget,
  });
}

/// 翻页动画方向
enum PageTurnDirection {
  /// 下一页（向左滑动）
  next,

  /// 上一页（向右滑动）
  previous,
}
