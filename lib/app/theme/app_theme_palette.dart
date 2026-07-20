import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';

import 'fonts.dart';

/// App 全局配色方案（与亮/暗模式正交）。
enum AppThemePalette {
  /// 优化前的偏白浅色（Material 低混合）
  classicWhite,

  /// 当前默认墨绿（FlexScheme.money）
  money,
}

extension AppThemePaletteX on AppThemePalette {
  String get storageValue {
    switch (this) {
      case AppThemePalette.classicWhite:
        return 'white';
      case AppThemePalette.money:
        return 'money';
    }
  }

  String get label {
    switch (this) {
      case AppThemePalette.classicWhite:
        return '经典白';
      case AppThemePalette.money:
        return '墨绿';
    }
  }

  String get description {
    switch (this) {
      case AppThemePalette.classicWhite:
        return '简洁白色界面，接近优化前的浅色风格';
      case AppThemePalette.money:
        return '当前默认配色，偏墨绿强调色';
    }
  }

  static AppThemePalette fromStorage(String? value) {
    switch (value) {
      case 'white':
      case 'classic':
      case 'classicWhite':
        return AppThemePalette.classicWhite;
      case 'money':
      default:
        return AppThemePalette.money;
    }
  }

  ThemeData buildLight() {
    switch (this) {
      case AppThemePalette.classicWhite:
        return FlexThemeData.light(
          scheme: FlexScheme.material,
          surfaceMode: FlexSurfaceMode.highScaffoldLowSurface,
          blendLevel: 0,
          subThemesData: const FlexSubThemesData(
            blendOnLevel: 0,
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
            // 更接近纯白表面
            scaffoldBackgroundSchemeColor: SchemeColor.surface,
          ),
          visualDensity: FlexColorScheme.comfortablePlatformDensity,
          fontFamily: Fonts.xiXingKai,
          useMaterial3: true,
          swapLegacyOnMaterial3: true,
        );
      case AppThemePalette.money:
        return FlexThemeData.light(
          scheme: FlexScheme.money,
          surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
          blendLevel: 7,
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
          fontFamily: Fonts.xiXingKai,
          visualDensity: FlexColorScheme.comfortablePlatformDensity,
          useMaterial3: true,
          swapLegacyOnMaterial3: true,
        );
    }
  }

  ThemeData buildDark() {
    switch (this) {
      case AppThemePalette.classicWhite:
        return FlexThemeData.dark(
          scheme: FlexScheme.material,
          surfaceMode: FlexSurfaceMode.highScaffoldLowSurface,
          blendLevel: 4,
          subThemesData: const FlexSubThemesData(
            blendOnLevel: 8,
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
          fontFamily: Fonts.xiXingKai,
          visualDensity: FlexColorScheme.comfortablePlatformDensity,
          useMaterial3: true,
          swapLegacyOnMaterial3: true,
        );
      case AppThemePalette.money:
        return FlexThemeData.dark(
          scheme: FlexScheme.money,
          surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
          blendLevel: 13,
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
          fontFamily: Fonts.xiXingKai,
          visualDensity: FlexColorScheme.comfortablePlatformDensity,
          useMaterial3: true,
          swapLegacyOnMaterial3: true,
        );
    }
  }
}
