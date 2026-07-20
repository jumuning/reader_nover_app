import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:reader_nover/app/constants/default_setting.dart';
import 'package:reader_nover/app/database/drift/app_database.dart' as db;
import 'package:reader_nover/app/l10n/app_locale_store.dart';
import 'package:reader_nover/app/net/http_client.dart';
import 'package:reader_nover/app/service/local_book/local_book_storage_repair_service.dart';
import 'package:reader_nover/app/theme/app_theme_controller.dart';
import 'package:reader_nover/app/theme/app_theme_palette.dart';
import 'package:reader_nover/util/log_utils.dart';

import '../book/state.dart';
import 'state.dart';

class SettingLogic extends GetxController {
  SettingLogic({
    void Function(ThemeMode mode)? onThemeModeChanged,
    Future<void> Function(AppThemePalette palette)? onThemePaletteChanged,
    Future<void> Function()? onReloadThemeAsset,
    LocalBookStorageRepairService? localBookStorageRepairService,
  })  : _onThemeModeChanged = onThemeModeChanged,
        _onThemePaletteChanged = onThemePaletteChanged,
        _onReloadThemeAsset = onReloadThemeAsset,
        _localBookStorageRepairService =
            localBookStorageRepairService ?? LocalBookStorageRepairService();

  final SettingState state = SettingState();
  final db.AppDatabase _db = db.AppDatabase.instance;
  final void Function(ThemeMode mode)? _onThemeModeChanged;
  final Future<void> Function(AppThemePalette palette)? _onThemePaletteChanged;
  final Future<void> Function()? _onReloadThemeAsset;
  final LocalBookStorageRepairService _localBookStorageRepairService;
  final AppLocaleStore _localeStore = AppLocaleStore();

  @override
  void onInit() {
    super.onInit();
    _loadInitialSettings();
  }

  Future<void> _loadInitialSettings() async {
    await _loadSettings();
    state.localeCode = await _localeStore.loadCode();
    if (Get.isRegistered<AppThemeController>()) {
      state.themePalette = Get.find<AppThemeController>().palette;
    } else {
      final prefs = await SharedPreferences.getInstance();
      state.themePalette = AppThemePaletteX.fromStorage(
        prefs.getString(AppThemeController.palettePrefsKey),
      );
    }
    update();
  }

  Future<void> _loadSettings() async {
    try {
      final settings = await (_db.select(_db.bookReadSettings)
            ..where((table) =>
                table.id.equals(DefaultSetting.defaultBookReadSettingId)))
          .getSingleOrNull();
      if (settings == null) {
        await _db.into(_db.bookReadSettings).insert(
              db.BookReadSettingsCompanion.insert(
                id: const drift.Value(DefaultSetting.defaultBookReadSettingId),
                updateTime: DateTime.now(),
              ),
            );
      } else {
        state.themeMode = _parseThemeMode(settings.themeMode);
        state.bookshelfLayout = _parseBookshelfLayout(settings.bookshelfLayout);
      }
      state.allowInsecureCertificates = Http.instance.allowInsecureCertificates;
    } catch (error) {
      LogUtils.e('加载设置失败: $error');
    }
  }

  Future<void> changeLocale(String code) async {
    state.localeCode = code;
    await _localeStore.saveCode(code);
    final locale = _localeStore.localeForCode(code);
    Get.updateLocale(
        locale ?? WidgetsBinding.instance.platformDispatcher.locale);
    update();
  }

  void changeThemeMode(ThemeMode? mode) {
    if (mode == null) return;
    state.themeMode = mode;
    _onThemeModeChanged?.call(mode);
    _saveSettings();
    update();
  }

  Future<void> changeThemePalette(AppThemePalette palette) async {
    state.themePalette = palette;
    update();
    final callback = _onThemePaletteChanged;
    if (callback != null) {
      await callback(palette);
    } else if (Get.isRegistered<AppThemeController>()) {
      await Get.find<AppThemeController>().setPalette(palette);
    }
  }

  Future<void> reloadThemeAsset() async => _onReloadThemeAsset?.call();

  void toggleBookshelfLayout() {
    state.bookshelfLayout = state.bookshelfLayout == BookshelfLayout.list
        ? BookshelfLayout.grid
        : BookshelfLayout.list;
    _saveSettings();
    update();
  }

  Future<void> changeAllowInsecureCertificates(bool value) async {
    state.allowInsecureCertificates = value;
    update();
    try {
      await Http.instance.setAllowInsecureCertificates(value);
    } catch (error) {
      state.allowInsecureCertificates = !value;
      update();
      LogUtils.e('保存 HTTPS 证书设置失败: $error');
    }
  }

  Future<void> checkLocalBookStorage() async {
    if (state.isCheckingLocalBookStorage) return;
    state.isCheckingLocalBookStorage = true;
    update();
    try {
      await _localBookStorageRepairService.inspectAndRepair();
      Get.snackbar('本地存储检查完成', '已完成本地书籍存储检查');
    } catch (error) {
      LogUtils.e('本地书籍存储检查失败: $error');
      Get.snackbar('本地存储检查失败', '无法完成本地书籍存储检查');
    } finally {
      state.isCheckingLocalBookStorage = false;
      update();
    }
  }

  Future<void> _saveSettings() async {
    await (_db.update(_db.bookReadSettings)
          ..where((table) =>
              table.id.equals(DefaultSetting.defaultBookReadSettingId)))
        .write(
      db.BookReadSettingsCompanion(
        updateTime: drift.Value(DateTime.now()),
        themeMode: drift.Value(_themeModeToString(state.themeMode)),
        bookshelfLayout:
            drift.Value(_bookshelfLayoutToString(state.bookshelfLayout)),
      ),
    );
  }

  ThemeMode _parseThemeMode(String? value) => switch (value) {
        'dark' => ThemeMode.dark,
        'light' => ThemeMode.light,
        _ => ThemeMode.system,
      };

  BookshelfLayout _parseBookshelfLayout(String? value) =>
      value == 'grid' ? BookshelfLayout.grid : BookshelfLayout.list;

  String _themeModeToString(ThemeMode value) => switch (value) {
        ThemeMode.light => 'light',
        ThemeMode.dark => 'dark',
        ThemeMode.system => 'system',
      };

  String _bookshelfLayoutToString(BookshelfLayout value) =>
      value == BookshelfLayout.grid ? 'grid' : 'list';
}
