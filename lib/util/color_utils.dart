import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ColorUtils {
  /// 根据字符串生成颜色
  static Color randomColorByStr(String str) {
    int hash = 0;
    for (int i = 0; i < str.length; i++) {
      hash = str.codeUnitAt(i) + ((hash << 5) - hash);
    }
    final int finalHash = hash.abs() % 0xffffff;
    // 在颜色值的最高位加上0xff作为alpha值，确保颜色不透明
    final int colorValue = (0xff << 24) | finalHash;
    return Color(colorValue);
  }

  /// 根据字符串生成颜色，并针对当前页面背景修正明暗，避免文字太贴近标签底色。
  static Color readableRandomColorByStr(String str, Color surfaceColor) {
    final isDarkSurface = isDarkColor(surfaceColor);
    final seedColor = randomColorByStr(str);
    final hsl = HSLColor.fromColor(seedColor);
    final color = hsl
        .withSaturation(_clampDouble(hsl.saturation, 0.5, 0.8))
        .withLightness(isDarkSurface
            ? _clampDouble(hsl.lightness, 0.62, 0.78)
            : _clampDouble(hsl.lightness, 0.28, 0.42))
        .toColor();

    final labelBackground = Color.alphaBlend(
      color.withValues(alpha: 0.15),
      surfaceColor,
    );
    return _ensureContrastColor(
      color,
      labelBackground,
      preferLighter: isDarkSurface,
      minContrast: 3.2,
    );
  }

  /// 计算颜色的亮度 (0-1)
  /// 使用相对亮度公式: L = 0.299*R + 0.587*G + 0.114*B
  /// Flutter 的 color.r/g/b 返回 0-1 范围的值
  static double getLuminance(Color color) {
    return 0.299 * color.r + 0.587 * color.g + 0.114 * color.b;
  }

  /// 判断颜色是否为深色
  /// 阈值使用 0.5，因为 r/g/b 是 0-1 范围
  static bool isDarkColor(Color color) {
    final luminance = getLuminance(color);
    return luminance < 0.5;
  }

  /// 根据背景颜色获取合适的文字颜色
  /// 深色背景返回浅色文字，浅色背景返回深色文字
  /// 增加对比度：使用纯白和纯黑
  static Color getContrastTextColor(Color backgroundColor) {
    return isDarkColor(backgroundColor) ? Colors.white : Colors.black;
  }

  /// 根据背景颜色获取次要文字颜色（透明度稍低）
  static Color getContrastSecondaryTextColor(Color backgroundColor) {
    return isDarkColor(backgroundColor)
        ? Colors.white.withValues(alpha: 0.8)
        : Colors.black.withValues(alpha: 0.6);
  }

  /// 从网络图片URL提取主色调
  static Future<Color?> getDominantColorFromUrl(String? imageUrl) async {
    if (imageUrl == null || imageUrl.isEmpty) return null;

    try {
      final ImageProvider imageProvider = CachedNetworkImageProvider(imageUrl);
      final PaletteGenerator paletteGenerator =
          await PaletteGenerator.fromImageProvider(
        imageProvider,
        size: const Size(100, 100), // 使用小尺寸加快处理速度
        maximumColorCount: 10,
      );

      // 优先使用主色调，其次使用最常见的颜色
      return paletteGenerator.dominantColor?.color ??
          paletteGenerator.colors.firstOrNull;
    } catch (e) {
      return null;
    }
  }

  /// 从网络图片URL获取适合的文字颜色
  static Future<Color> getTextColorFromImageUrl(String? imageUrl,
      {Color defaultColor = Colors.black87}) async {
    final dominantColor = await getDominantColorFromUrl(imageUrl);
    if (dominantColor == null) return defaultColor;
    return getContrastTextColor(dominantColor);
  }

  static Color _ensureContrastColor(
    Color color,
    Color backgroundColor, {
    required bool preferLighter,
    double minContrast = 4.5,
  }) {
    if (_contrastRatio(color, backgroundColor) >= minContrast) {
      return color;
    }

    final hsl = HSLColor.fromColor(color);
    Color bestColor = color;
    double bestRatio = _contrastRatio(color, backgroundColor);

    for (int step = 1; step <= 12; step++) {
      final factor = step / 12;
      final lightness = preferLighter
          ? hsl.lightness + (1 - hsl.lightness) * factor
          : hsl.lightness * (1 - factor);
      final candidate =
          hsl.withLightness(_clampDouble(lightness, 0.0, 1.0)).toColor();
      final ratio = _contrastRatio(candidate, backgroundColor);
      if (ratio > bestRatio) {
        bestColor = candidate;
        bestRatio = ratio;
      }
      if (ratio >= minContrast) {
        return candidate;
      }
    }

    final fallback = preferLighter ? Colors.white : Colors.black87;
    return _contrastRatio(fallback, backgroundColor) > bestRatio
        ? fallback
        : bestColor;
  }

  static double _contrastRatio(Color foreground, Color background) {
    final fg = foreground.computeLuminance();
    final bg = background.computeLuminance();
    final lighter = fg > bg ? fg : bg;
    final darker = fg > bg ? bg : fg;
    return (lighter + 0.05) / (darker + 0.05);
  }

  static double _clampDouble(double value, double min, double max) {
    return value.clamp(min, max).toDouble();
  }
}
