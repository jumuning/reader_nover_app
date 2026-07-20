import 'dart:math';
import 'dart:ui';

import 'line.dart';
import 'paper_math.dart';

/// iReader 风格翻页几何点计算
///
/// 核心设计：
/// - 右侧翻页（下一页）：锚点在右下角，页面向左卷起
/// - 左侧翻页（上一页）：锚点在左下角，页面向右卷起
/// - 支持从屏幕中部拖动（固定 Y 轴到底部）
class PaperPointIReader {
  /// 手指拖拽点
  Point<double> a;

  /// 锚点（固定角）
  late Point<double> f;

  /// 中点 G（A 和 F 的中点，EH 线即为 AF 的垂直平分线）
  late Point<double> g;

  /// 贝塞尔曲线控制点
  late Point<double> b, c, d, e;
  late Point<double> h, i, j, k;

  /// 阴影投影点
  late Point<double> p1, p2;

  /// 页面尺寸
  final Size size;

  /// 阴影深度
  final double elevationC;

  /// 是否为左侧锚点（上一页翻页）
  final bool anchorLeft;

  /// AH 线的斜率和截距
  late double ahSlope;
  late double ahIntercept;

  /// 点是否有效
  bool isValid = true;

  PaperPointIReader(
    this.a,
    this.size, {
    required this.anchorLeft,
    this.elevationC = 10,
  }) {
    _calculate();
  }

  /// 核心几何计算
  void _calculate() {
    // 设置锚点 F
    if (anchorLeft) {
      f = Point(0, size.height); // 左侧锚点：左下角
    } else {
      f = Point(size.width, size.height); // 右侧锚点：右下角
    }

    // 计算 AF 中点 G
    g = Point((a.x + f.x) / 2, (a.y + f.y) / 2);

    // 处理特殊情况：避免除零或无翻页效果
    if ((a.x - f.x).abs() < 0.001) {
      isValid = false;
      _setDefaultPoints();
      return;
    }

    if ((a.y - f.y).abs() < 0.001) {
      isValid = false;
      _setDefaultPoints();
      return;
    }

    // 计算 E 点（贝塞尔控制点，在底部边缘）
    final double gfDy = f.y - g.y;
    final double gfDx = f.x - g.x;

    if (gfDx.abs() < 0.001) {
      isValid = false;
      _setDefaultPoints();
      return;
    }

    e = Point(g.x - (gfDy * gfDy) / gfDx, f.y);

    // 计算 C 点（底部边缘上的端点）
    double cx = e.x - (f.x - e.x) / 2;

    // 边界限制：真正的镜像逻辑（核心修正）
    if (anchorLeft) {
      // 左侧翻页：C 点不能超过右边界（cx ≤ size.width）
      if (cx >= size.width) {
        final double fc = cx - f.x; // C 点到 F 点的距离
        final double fa = a.x - f.x; // A 点到 F 点的距离
        if (fc.abs() > 0.001 && fa.abs() > 0.001) {
          // 按比例缩放 A 点，使 C 点刚好在右边界
          final double bb1 = size.width * fa / fc;
          final double fd1 = f.y - a.y;
          final double fd = bb1 * fd1 / fa;
          a = Point(f.x + bb1, f.y - fd);
          g = Point((a.x + f.x) / 2, (a.y + f.y) / 2);
          if ((g.x - f.x).abs() > 0.001) {
            e = Point(g.x - (pow(f.y - g.y, 2) / (f.x - g.x)), f.y);
          }
          // 重新计算 cx
          cx = e.x - (f.x - e.x) / 2;
        }
        // 左侧翻页越界：固定到右边界
        cx = size.width;
      }
      // 补充：左侧翻页也防止 C 点小于左边界（兜底）
      if (cx <= 0) {
        cx = 0;
      }
    } else {
      // 右侧翻页：C 点不能小于左边界（cx ≥ 0）
      if (cx <= 0) {
        final double fc = f.x - cx;
        final double fa = f.x - a.x;
        if (fc.abs() > 0.001 && fa.abs() > 0.001) {
          final double bb1 = size.width * fa / fc;
          final double fd1 = f.y - a.y;
          final double fd = bb1 * fd1 / fa;
          a = Point(f.x - bb1, f.y - fd);
          g = Point((a.x + f.x) / 2, (a.y + f.y) / 2);
          if ((f.x - g.x).abs() > 0.001) {
            e = Point(g.x - (pow(f.y - g.y, 2) / (f.x - g.x)), f.y);
          }
          // 重新计算 cx
          cx = e.x - (f.x - e.x) / 2;
        }
        // 右侧翻页越界：固定到左边界
        cx = 0;
      }
      // 补充：右侧翻页也防止 C 点超过右边界（兜底）
      if (cx >= size.width) {
        cx = size.width;
      }
    }

    c = Point(cx, f.y);

    // 计算 H 点（在锚点所在边缘上的控制点）
    final double hDenom = f.y - g.y;
    if (hDenom.abs() < 0.001) {
      isValid = false;
      _setDefaultPoints();
      return;
    }

    h = Point(f.x, g.y - (pow(f.x - g.x, 2) / hDenom));

    // 计算 J 点（H 和 F 之间的点）
    j = Point(f.x, h.y - (f.y - h.y) / 2);

    // 计算 AH 线方程
    Line ah = calculateLineEquation(a, h);
    ahSlope = ah.slope;
    ahIntercept = ah.intercept;

    // 计算 AE 线方程
    Line ae = calculateLineEquation(a, e);

    // 计算 B 和 K 点（曲线端点）
    b = calculateIntersectionOfTwoLines(c, j, a, e);
    k = calculateIntersectionOfTwoLines(c, j, a, h);

    // 计算 D 和 I 点（贝塞尔曲线的中间控制点）
    final Point<double> tp = Point((c.x + b.x) / 2, (c.y + b.y) / 2);
    final Point<double> to = Point((j.x + k.x) / 2, (j.y + k.y) / 2);
    d = Point((tp.x + e.x) / 2, (tp.y + e.y) / 2);
    i = Point((to.x + h.x) / 2, (to.y + h.y) / 2);

    // 计算阴影投影点
    p1 = projectPointToLine(ah, elevationC);
    p2 = projectPointToLine(ae, elevationC);

    // 验证所有点是否有效
    isValid = _validatePoints();
  }

  /// 设置默认点（当计算无效时）
  void _setDefaultPoints() {
    if (anchorLeft) {
      f = Point(0, size.height);
      c = Point(0, size.height);
      e = Point(0, size.height);
      j = Point(0, size.height);
      h = Point(0, size.height);
    } else {
      f = Point(size.width, size.height);
      c = Point(size.width, size.height);
      e = Point(size.width, size.height);
      j = Point(size.width, size.height);
      h = Point(size.width, size.height);
    }
    g = Point((a.x + f.x) / 2, (a.y + f.y) / 2);
    b = f;
    k = f;
    d = f;
    i = f;
    p1 = a;
    p2 = a;
    ahSlope = 0;
    ahIntercept = 0;
  }

  /// 验证所有点是否有效
  bool _validatePoints() {
    return !a.x.isNaN && !a.y.isNaN &&
           !b.x.isNaN && !b.y.isNaN &&
           !c.x.isNaN && !c.y.isNaN &&
           !d.x.isNaN && !d.y.isNaN &&
           !e.x.isNaN && !e.y.isNaN &&
           !f.x.isNaN && !f.y.isNaN &&
           !g.x.isNaN && !g.y.isNaN &&
           !h.x.isNaN && !h.y.isNaN &&
           !i.x.isNaN && !i.y.isNaN &&
           !j.x.isNaN && !j.y.isNaN &&
           !k.x.isNaN && !k.y.isNaN &&
           !p1.x.isNaN && !p1.y.isNaN &&
           !p2.x.isNaN && !p2.y.isNaN;
  }

  /// 创建空状态（无翻页效果）
  factory PaperPointIReader.empty(Size size, {bool anchorLeft = false}) {
    final Point<double> defaultPoint = anchorLeft
        ? Point(0, size.height)
        : Point(size.width, size.height);
    return PaperPointIReader(defaultPoint, size, anchorLeft: anchorLeft);
  }
}
