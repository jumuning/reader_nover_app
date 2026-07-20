import '../theme/fonts.dart';

class DefaultSetting {
  static const int defaultBookReadSettingId = 1;
  static const double defaultBookReadSettingFontSize = 16.0;
  static const double defaultBookReadSettingFontHeight = 1.8;
  static const double defaultBookReadSettingWordSpacing = 1.0;
  static const double defaultBookReadSettingLetterSpacing = 0.5;

  // 默认字体（null 表示系统字体）
  static const String defaultBookReadSettingFontFamily = Fonts.xiXingKai;
  static const double defaultTtsRate = 0.5;
  static const double defaultTtsPitch = 1.0;
  static const double defaultTtsVolume = 1.0;
  static const bool defaultTtsAutoNextPage = true;
  static const bool defaultTtsAutoNextChapter = true;
  static const bool defaultTtsResumeAfterInterrupt = true;

  // 翻页类型常量
  static const String pageTurnTypeSimulation = 'simulation';
  static const String pageTurnTypeCover = 'cover';
  static const String pageTurnTypeSlide = 'slide';
  static const String pageTurnTypeVertical = 'vertical';
  static const String pageTurnTypeNoAnimation = 'noAnimation';
}
