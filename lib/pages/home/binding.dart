import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:reader_nover/app/theme/app_theme_palette.dart';
import 'package:reader_nover/pages/home/book/logic.dart';
import 'package:reader_nover/pages/home/store/logic.dart';
import 'package:reader_nover/pages/home/setting/logic.dart';
import 'package:reader_nover/pages/home/source/logic.dart';
import 'logic.dart';

class HomeBinding extends Bindings {
  HomeBinding({
    void Function(ThemeMode mode)? onThemeModeChanged,
    Future<void> Function(AppThemePalette palette)? onThemePaletteChanged,
    Future<void> Function()? onReloadThemeAsset,
  })  : _onThemeModeChanged = onThemeModeChanged,
        _onThemePaletteChanged = onThemePaletteChanged,
        _onReloadThemeAsset = onReloadThemeAsset;

  final void Function(ThemeMode mode)? _onThemeModeChanged;
  final Future<void> Function(AppThemePalette palette)? _onThemePaletteChanged;
  final Future<void> Function()? _onReloadThemeAsset;

  @override
  void dependencies() {
    final storeLogic = StoreLogic();
    final settingLogic = SettingLogic(
      onThemeModeChanged: _onThemeModeChanged,
      onThemePaletteChanged: _onThemePaletteChanged,
      onReloadThemeAsset: _onReloadThemeAsset,
    );
    final bookLogic = BookLogic(
      onToggleBookshelfLayout: settingLogic.toggleBookshelfLayout,
      currentLayoutProvider: () => settingLogic.state.bookshelfLayout,
    );
    final sourceLogic = SourceLogic();
    final homeLogic = HomeLogic(
      bookLogic: bookLogic,
      settingLogic: settingLogic,
      // 书城分类首次 onReady 解析后缓存，切换 Tab 不再触发解析
      onEnterBookshelfPage: bookLogic.refreshBooks,
    );

    Get.lazyPut(() => storeLogic);
    Get.lazyPut(() => settingLogic);
    Get.lazyPut(() => bookLogic);
    Get.lazyPut(() => sourceLogic);
    Get.lazyPut(() => homeLogic);
  }
}
