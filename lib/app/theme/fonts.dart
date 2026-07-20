class Fonts {
  // 系统字体
  static const String? system = null;

  // 汉仪细行楷
  static const String xiXingKai = '细行楷';

  /// 获取所有可用字体列表
  static List<Map<String, String?>> get availableFonts => [
    {'name': '系统字体', 'family': system},
    {'name': '汉仪细行楷', 'family': xiXingKai},
  ];

  /// 获取字体显示名称
  static String getDisplayName(String? fontFamily) {
    if (fontFamily == null || fontFamily.isEmpty) return '系统字体';
    switch (fontFamily) {
      case xiXingKai:
        return '细行楷';
      default:
        return fontFamily;
    }
  }
}
