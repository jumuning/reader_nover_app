import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'fonts.dart';

class ThemeConfig {
  final String? scheme;
  final int? blendLevelLight;
  final int? blendLevelDark;
  final bool? useMaterial3;
  final bool? swapLegacyOnMaterial3;
  final String? fontFamily;
  final String? themeMode;

  ThemeConfig({
    this.scheme,
    this.blendLevelLight,
    this.blendLevelDark,
    this.useMaterial3,
    this.swapLegacyOnMaterial3,
    this.fontFamily,
    this.themeMode,
  });

  factory ThemeConfig.fromJson(Map<String, dynamic> json) {
    return ThemeConfig(
      scheme: json['scheme'] as String?,
      blendLevelLight: json['blendLevelLight'] as int?,
      blendLevelDark: json['blendLevelDark'] as int?,
      useMaterial3: json['useMaterial3'] as bool?,
      swapLegacyOnMaterial3: json['swapLegacyOnMaterial3'] as bool?,
      fontFamily: json['fontFamily'] as String?,
      themeMode: json['themeMode'] as String?,
    );
  }

  FlexScheme _resolveScheme() {
    final name = scheme;
    if (name == null) return FlexScheme.money;
    return FlexScheme.values.firstWhere(
      (e) => e.name == name,
      orElse: () => FlexScheme.money,
    );
  }

  ThemeMode? buildThemeMode() {
    final m = themeMode?.toLowerCase();
    switch (m) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
      default:
        return null;
    }
  }

  ThemeData buildLight() {
    return FlexThemeData.light(
      scheme: _resolveScheme(),
      surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
      blendLevel: blendLevelLight ?? 7,
      subThemesData: const FlexSubThemesData(
        blendOnLevel: 10,
        blendOnColors: false,
        useMaterial3Typography: true,
        useM2StyleDividerInM3: true,
        alignedDropdown: true,
        useInputDecoratorThemeInDialogs: true,
        appBarCenterTitle: true,
        textButtonRadius: 4.0,
        filledButtonRadius: 4.0,
        elevatedButtonRadius: 4.0,
        outlinedButtonRadius: 4.0,
        segmentedButtonRadius: 8.0,
        segmentedButtonBorderWidth: 0.5,
      ),
      fontFamily: fontFamily ?? Fonts.xiXingKai,
      visualDensity: FlexColorScheme.comfortablePlatformDensity,
      useMaterial3: useMaterial3 ?? true,
      swapLegacyOnMaterial3: swapLegacyOnMaterial3 ?? true,
    );
  }

  ThemeData buildDark() {
    return FlexThemeData.dark(
      scheme: _resolveScheme(),
      surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
      blendLevel: blendLevelDark ?? 13,
      subThemesData: const FlexSubThemesData(
        blendOnLevel: 20,
        useMaterial3Typography: true,
        useM2StyleDividerInM3: true,
        alignedDropdown: true,
        useInputDecoratorThemeInDialogs: true,
        appBarCenterTitle: true,
        textButtonRadius: 4.0,
        filledButtonRadius: 4.0,
        elevatedButtonRadius: 4.0,
        outlinedButtonRadius: 4.0,
        segmentedButtonRadius: 8.0,
        segmentedButtonBorderWidth: 0.5,
      ),
      fontFamily: fontFamily ?? Fonts.xiXingKai,
      visualDensity: FlexColorScheme.comfortablePlatformDensity,
      useMaterial3: useMaterial3 ?? true,
      swapLegacyOnMaterial3: swapLegacyOnMaterial3 ?? true,
    );
  }
}
