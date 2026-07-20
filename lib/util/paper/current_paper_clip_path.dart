import 'package:flutter/widgets.dart';
import 'package:reader_nover/util/paper/paper_point_ireader.dart';

/// iReader 风格的当前页裁剪路径
///
/// 用于裁剪当前页面，使其在翻页时显示正确的卷曲效果
class CurrentPaperClipPath extends CustomClipper<Path> {
  final ValueNotifier<PaperPointIReader> paperPoint;
  final bool isNext;

  const CurrentPaperClipPath(this.paperPoint, this.isNext)
      : super(reclip: paperPoint);

  @override
  Path getClip(Size size) {
    final p = paperPoint.value;

    // 如果点无效或正在初始状态，返回全屏路径
    if (!p.isValid) {
      return _getFullScreenPath(size);
    }

    // 检查是否需要翻页效果
    final bool needsClip = _needsClipEffect(p, size);
    if (!needsClip) {
      return _getFullScreenPath(size);
    }

    try {
      // 创建全屏路径
      final curledPath = _buildCurledPath(p);

      if (p.anchorLeft) {
        // 上翻页（左侧锚点）：返回卷起区域，显示上一页滑入的部分
        return curledPath;
      }

      // 下翻页（右侧锚点）：直接拼出当前页剩余可见区域，
      // 避免每一帧都做 Path.combine 的差集运算。
      return _buildCurrentPageVisiblePath(p, size);
    } catch (e) {
      // 如果发生任何错误，返回全屏路径
      return _getFullScreenPath(size);
    }
  }

  /// 判断是否需要裁剪效果
  bool _needsClipEffect(PaperPointIReader p, Size size) {
    if (p.anchorLeft) {
      // 左侧翻页：A 点需要在左边界右侧
      return p.a.x > 0 && p.a.x < size.width * 1.5;
    } else {
      // 右侧翻页：A 点需要在右边界左侧
      return p.a.x < size.width && p.a.x > -size.width * 0.5;
    }
  }

  /// 构建卷起区域的路径
  Path _buildCurledPath(PaperPointIReader p) {
    final curledPath = Path();

    // 从 C 点开始
    curledPath.moveTo(p.c.x, p.c.y);

    // 绘制底部贝塞尔曲线 (C -> E -> B)
    curledPath.quadraticBezierTo(
      p.e.x,
      p.e.y,
      p.b.x,
      p.b.y,
    );

    // 直线到 A 点
    curledPath.lineTo(p.a.x, p.a.y);

    // 直线到 K 点
    curledPath.lineTo(p.k.x, p.k.y);

    // 绘制侧边贝塞尔曲线 (K -> H -> J)
    curledPath.quadraticBezierTo(
      p.h.x,
      p.h.y,
      p.j.x,
      p.j.y,
    );

    // 直线到 F 点
    curledPath.lineTo(p.f.x, p.f.y);

    // 闭合路径
    curledPath.close();

    return curledPath;
  }

  Path _buildCurrentPageVisiblePath(PaperPointIReader p, Size size) {
    final visiblePath = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, p.j.y.clamp(0.0, size.height))
      ..quadraticBezierTo(p.h.x, p.h.y, p.k.x, p.k.y)
      ..lineTo(p.a.x, p.a.y)
      ..lineTo(p.b.x, p.b.y)
      ..quadraticBezierTo(p.e.x, p.e.y, p.c.x, p.c.y)
      ..lineTo(0, size.height)
      ..close();
    return visiblePath;
  }

  /// 返回全屏路径
  Path _getFullScreenPath(Size size) {
    return Path()..addRect(Offset.zero & size);
  }

  @override
  bool shouldReclip(covariant CurrentPaperClipPath oldClipper) {
    return paperPoint != oldClipper.paperPoint || isNext != oldClipper.isNext;
  }
}
