import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:reader_nover/app/constants/default_setting.dart';
import 'package:reader_nover/app/database/drift/app_database.dart' as db;
import 'package:shared_preferences/shared_preferences.dart';
import 'app_theme.dart';
import 'app_theme_palette.dart';
import 'theme_config.dart';

class AppThemeController extends GetxController {
  static const palettePrefsKey = 'app_theme_palette';

  ThemeData lightTheme = appLightTheme;
  ThemeData darkTheme = appDarkTheme;
  ThemeMode themeMode = ThemeMode.light;
  AppThemePalette palette = AppThemePalette.money;

  @override
  void onInit() {
    super.onInit();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await _loadPaletteFromPrefs();
    _applyPaletteThemes();
    await _loadFromAsset();
    await _loadThemeModeFromDb();
    // 资产里的 scheme 不覆盖用户已选配色；仅在用户未设置时可作为默认
    update();
  }

  Future<void> _loadPaletteFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getString(palettePrefsKey);
      if (stored != null && stored.isNotEmpty) {
        palette = AppThemePaletteX.fromStorage(stored);
      }
    } catch (_) {}
  }

  Future<void> _loadFromAsset() async {
    try {
      final s = await rootBundle.loadString('assets/json/theme.json');
      final map = jsonDecode(s) as Map<String, dynamic>;
      final cfg = ThemeConfig.fromJson(map);
      // 用户未主动选过配色时，才用 asset 的 scheme 作为初始
      final prefs = await SharedPreferences.getInstance();
      final hasUserPalette = prefs.containsKey(palettePrefsKey);
      if (!hasUserPalette && cfg.scheme != null) {
        palette = AppThemePaletteX.fromStorage(cfg.scheme);
      }
      _applyPaletteThemes();
    } catch (_) {
      _applyPaletteThemes();
    }
  }

  /// 从数据库加载用户保存的主题模式
  Future<void> _loadThemeModeFromDb() async {
    try {
      final database = db.AppDatabase.instance;
      final settings = await (database.select(database.bookReadSettings)
            ..where((t) => t.id.equals(DefaultSetting.defaultBookReadSettingId)))
          .getSingleOrNull();
      if (settings?.themeMode != null) {
        final mode = _parseThemeMode(settings!.themeMode!);
        themeMode = mode;
        Get.changeThemeMode(mode);
      }
      // 若 DB 也存了 palette 列则优先（兼容后续迁移字段）；当前走 prefs
    } catch (_) {}
  }

  ThemeMode _parseThemeMode(String mode) {
    switch (mode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  Future<void> reloadFromAsset() async {
    await _loadFromAsset();
    update();
  }

  void apply(ThemeConfig cfg) {
    // 兼容旧调用：按 config 重建，但不强制改用户 palette（除非 scheme 明确）
    if (cfg.scheme != null) {
      palette = AppThemePaletteX.fromStorage(cfg.scheme);
    }
    _applyPaletteThemes();
    final m = cfg.buildThemeMode();
    if (m != null) {
      themeMode = m;
      Get.changeThemeMode(m);
    }
    update();
  }

  void setThemeMode(ThemeMode mode) {
    themeMode = mode;
    Get.changeThemeMode(mode);
    update();
  }

  Future<void> setPalette(AppThemePalette value) async {
    if (palette == value) return;
    palette = value;
    _applyPaletteThemes();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(palettePrefsKey, value.storageValue);
    } catch (_) {}
    // 同步到 GetMaterialApp
    Get.changeTheme(lightTheme);
    update();
  }

  void _applyPaletteThemes() {
    lightTheme = palette.buildLight();
    darkTheme = palette.buildDark();
  }
}
