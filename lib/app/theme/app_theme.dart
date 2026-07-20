import 'app_theme_palette.dart';

// 默认仍为墨绿；设置页可选「经典白」
final appLightTheme = AppThemePalette.money.buildLight();
final appDarkTheme = AppThemePalette.money.buildDark();

// 经典白（优化前偏白风格）
final appClassicWhiteLightTheme = AppThemePalette.classicWhite.buildLight();
final appClassicWhiteDarkTheme = AppThemePalette.classicWhite.buildDark();

class ConfirmTheme {
  static const radius = 4.0;
  static const dialogWidth = 270.0;
  static const dialogContentMinHeight = 60.0;
  static const dialogBottomActionHeight = 44.0;
  static const dialogDividerWidth = 1.0;
  static const padding = 16.0;
}

class BookReadTheme {
  static const radius = 4.0;
  static const padding = 16.0;
  static const horizontal = 16.0;
  static const vertical = 16.0;
}
