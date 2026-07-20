import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:reader_nover/util/paper/paper_math.dart';
import 'package:reader_nover/util/paper/paper_point_ireader.dart';

/// iReader 风格翻页绘制器
///
/// 绘制翻页效果的阴影、背面和边缘高光
class PaperPainter extends CustomPainter {
  final ValueNotifier<PaperPointIReader> paperPoint;
  final Color? pageBackColor;

  // 页面厚度效果
  static const double _pageThickness = 2.0;
  // 基础阴影强度
  static const double _baseShadowIntensity = 0.35;

  // 缓存计算结果
  late final bool _isDarkMode;
  late final Color _shadowColor;
  late final Color _highlightColor;

  PaperPainter(this.paperPoint, this.pageBackColor) : super(repaint: paperPoint) {
    // 根据背景颜色判断是否为深色模式
    final bgColor = pageBackColor ?? Colors.grey.shade300;
    _isDarkMode = _isColorDark(bgColor);

    // 深色模式使用更亮的阴影，浅色模式使用黑色阴影
    if (_isDarkMode) {
      _shadowColor = Colors.black;
      _highlightColor = Colors.white.withValues(alpha: 0.15);
    } else {
      _shadowColor = Colors.black;
      _highlightColor = Colors.white.withValues(alpha: 0.4);
    }
  }

  /// 判断颜色是否为深色
  bool _isColorDark(Color color) {
    // 使用相对亮度公式判断
    final luminance = (0.299 * color.r + 0.587 * color.g + 0.114 * color.b);
    return luminance < 0.5;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final p = paperPoint.value;

    // 裁剪画布到屏幕范围
    canvas.clipRect(Offset.zero & size);

    // 如果点无效，不绘制
    if (!p.isValid) return;

    // 如果 A 和 F 重合或 Y 坐标相同，无需绘制
    if (_isPointsEqual(p.a, p.f) || (p.a.y - p.f.y).abs() < 0.001) return;

    // 计算翻页进度（用于动态调整阴影强度）
    final double progress = _calculateProgress(p, size);
    final double dynamicShadowIntensity = _baseShadowIntensity * (0.5 + progress * 0.5);

    // 绘制各层效果
    _drawShadows(canvas, size, p, dynamicShadowIntensity);
    _drawPageBack(canvas, size, p, dynamicShadowIntensity);
    _drawBottomShadow(canvas, size, p, dynamicShadowIntensity);
  }

  /// 计算翻页进度 (0.0 ~ 1.0)
  double _calculateProgress(PaperPointIReader p, Size size) {
    if (p.anchorLeft) {
      // 左侧翻页：A 越靠右，进度越大
      return (p.a.x / size.width).clamp(0.0, 1.0);
    } else {
      // 右侧翻页：A 越靠左，进度越大
      return ((size.width - p.a.x) / size.width).clamp(0.0, 1.0);
    }
  }

  /// 检查两点是否相等
  bool _isPointsEqual(Point<double> a, Point<double> b) {
    return (a.x - b.x).abs() < 0.001 && (a.y - b.y).abs() < 0.001;
  }

  /// 绘制翻页阴影（只在下一页时绘制，保持上下翻页效果一致）
  void _drawShadows(Canvas canvas, Size size, PaperPointIReader p, double intensity) {
    // 只在下一页（从右向左翻）时绘制左侧阴影
    // 上一页（从左向右翻）不绘制边缘阴影，保持效果一致
    if (!p.anchorLeft) {
      Path pathAB = _buildPathAB(p);
      _drawLeftShadow(canvas, size, p, pathAB, intensity);
    }
  }

  /// 构建 AB 合并区域的路径
  Path _buildPathAB(PaperPointIReader p) {
    Path path = Path();
    path.moveTo(p.c.x, p.c.y);
    path.quadraticBezierTo(p.e.x, p.e.y, p.b.x, p.b.y);
    path.lineTo(p.a.x, p.a.y);
    path.lineTo(p.k.x, p.k.y);
    path.quadraticBezierTo(p.h.x, p.h.y, p.j.x, p.j.y);
    path.lineTo(p.f.x, p.f.y);
    path.close();
    return path;
  }

  /// 绘制左侧阴影
  void _drawLeftShadow(Canvas canvas, Size size, PaperPointIReader p, Path pathAB, double intensity) {
    final double xDelta = p.a.x - p.p1.x;
    final double yDelta = p.a.y - p.p1.y;

    Path shadowPath = Path();
    shadowPath.moveTo(p.c.x - xDelta, p.c.y);
    shadowPath.quadraticBezierTo(
      p.e.x - xDelta,
      p.e.y - yDelta,
      p.b.x - xDelta,
      p.b.y - yDelta,
    );
    shadowPath.lineTo(p.p1.x, p.p1.y);
    shadowPath.lineTo(p.k.x, p.k.y);
    shadowPath.lineTo(p.f.x, p.f.y);
    shadowPath.close();

    Path combinedPath = Path.combine(PathOperation.reverseDifference, pathAB, shadowPath);

    // 深色模式下降低阴影强度，避免过于突兀
    final double adjustedIntensity = _isDarkMode ? intensity * 0.5 : intensity;

    Paint paint = Paint()
      ..style = PaintingStyle.fill
      ..shader = ui.Gradient.linear(
        Offset(p.a.x, p.a.y),
        Offset(p.p1.x, p.p1.y),
        [
          _shadowColor.withValues(alpha: adjustedIntensity * 0.6),
          _shadowColor.withValues(alpha: adjustedIntensity * 0.2),
          Colors.transparent,
        ],
        [0.0, 0.5, 1.0],
      );

    canvas.drawPath(combinedPath, paint);
  }

  /// 绘制翻起页面的背面
  void _drawPageBack(Canvas canvas, Size size, PaperPointIReader p, double intensity) {
    // 构建 AB 区域
    Path pathAB = _buildPathAB(p);

    // 构建 B 区域三角形（页面背面）
    Path triangleB = Path();
    triangleB.moveTo(p.d.x, p.d.y);
    triangleB.lineTo(p.a.x, p.a.y);
    triangleB.lineTo(p.i.x, p.i.y);
    triangleB.close();

    // 计算页面背面区域
    Path pathB = Path.combine(PathOperation.intersect, pathAB, triangleB);

    // 页面背面颜色
    final Color backColor = pageBackColor ?? Colors.grey.shade300;

    Paint paint = Paint()
      ..style = PaintingStyle.fill
      ..shader = ui.Gradient.linear(
        Offset(p.a.x, p.a.y),
        Offset(p.g.x, p.g.y),
        [
          backColor,
          Color.lerp(backColor, Colors.grey.shade400, 0.3)!,
        ],
      );

    canvas.drawPath(pathB, paint);

    // 绘制页面边缘高光
    _drawPageEdgeHighlight(canvas, pathB);
  }

  /// 绘制页面边缘高光效果
  void _drawPageEdgeHighlight(Canvas canvas, Path pagePath) {
    // 高光效果（深色模式下减弱）
    Paint highlightPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = _pageThickness
      ..color = _highlightColor;

    canvas.drawPath(pagePath, highlightPaint);

    // 细微边缘阴影（深色模式下减弱）
    final double edgeShadowAlpha = _isDarkMode ? 0.08 : 0.15;
    Paint edgeShadowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = _pageThickness * 0.5
      ..color = _shadowColor.withValues(alpha: edgeShadowAlpha);

    canvas.drawPath(pagePath, edgeShadowPaint);
  }

  /// 绘制底部阴影
  void _drawBottomShadow(Canvas canvas, Size size, PaperPointIReader p, double intensity) {
    // 构建阴影区域
    Path shadowRegion = Path();
    shadowRegion.moveTo(p.c.x, p.c.y);
    shadowRegion.lineTo(p.j.x, p.j.y);
    shadowRegion.lineTo(p.h.x, p.h.y);
    shadowRegion.lineTo(p.e.x, p.e.y);
    shadowRegion.close();

    Path pathAB = _buildPathAB(p);

    // 构建 B 区域三角形
    Path triangleB = Path();
    triangleB.moveTo(p.d.x, p.d.y);
    triangleB.lineTo(p.a.x, p.a.y);
    triangleB.lineTo(p.i.x, p.i.y);
    triangleB.close();

    Path pathB = Path.combine(PathOperation.intersect, pathAB, triangleB);

    // 计算阴影区域
    Path combineBC = Path.combine(PathOperation.intersect, shadowRegion, pathAB);
    Path combineC = Path.combine(PathOperation.difference, combineBC, pathB);

    // 计算阴影渐变的起点
    Offset u = Offset(
      calculateIntersectionOfTwoLines(p.a, p.f, p.d, p.i).x,
      calculateIntersectionOfTwoLines(p.a, p.f, p.d, p.i).y,
    );

    // 深色模式下降低阴影强度
    final double adjustedIntensity = _isDarkMode ? intensity * 0.5 : intensity;

    Paint paint = Paint()
      ..style = PaintingStyle.fill
      ..shader = ui.Gradient.linear(
        u,
        Offset(p.g.x, p.g.y),
        [
          _shadowColor.withValues(alpha: adjustedIntensity * 0.8),
          _shadowColor.withValues(alpha: adjustedIntensity * 0.3),
          Colors.transparent,
        ],
        [0.0, 0.4, 1.0],
      );

    canvas.drawPath(combineC, paint);
  }

  @override
  bool shouldRepaint(covariant PaperPainter oldDelegate) {
    return paperPoint != oldDelegate.paperPoint || pageBackColor != oldDelegate.pageBackColor;
  }
}
