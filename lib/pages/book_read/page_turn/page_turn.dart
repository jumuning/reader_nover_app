/// 翻页组件统一导出
///
/// 支持的翻页方式：
/// - simulation: 仿真翻页（模拟真实书籍卷曲效果）
/// - cover: 覆盖翻页（新页面从边缘滑入覆盖）
/// - slide: 平移翻页（当前页和目标页同时滑动）
/// - vertical: 上下滑动（垂直方向翻页）
/// - noAnimation: 无动画（直接切换）
library page_turn;

export 'page_turn_base.dart';
export 'page_turn_widget.dart';
export 'simulation_page_turn.dart';
export 'cover_page_turn.dart';
export 'slide_page_turn.dart';
export 'vertical_page_turn.dart';
export 'no_animation_page_turn.dart';
