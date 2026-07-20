import 'dart:async';

import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:screen_brightness/screen_brightness.dart';

import 'package:reader_nover/app/constants/default_setting.dart';
import 'package:reader_nover/app/database/drift/app_database.dart' as db;
import 'package:reader_nover/util/log_utils.dart';

import '../state.dart';

class BookReadSettingsController {
  BookReadSettingsController({
    required this.state,
    required db.AppDatabase database,
    required this.onUpdate,
    required this.onSplitBookContent,
    required this.onRelocateCurrentPage,
  }) : _database = database;

  final BookReadState state;
  final db.AppDatabase _database;
  final VoidCallback onUpdate;
  final VoidCallback onSplitBookContent;
  final VoidCallback onRelocateCurrentPage;

  Timer? _settingsDebounceTimer;
  bool _hasPendingSettings = false;
  double? _systemBrightness;
  Color? _previousBackgroundColor;

  static const Color _nightModeColor = Color(0xFF121212);
  static const Color _nightModeTextColor = Color(0xFFD0D0D0);

  Future<void> loadSavedSettings() async {
    final settings = await (_database.select(_database.bookReadSettings)
          ..where((table) =>
              table.id.equals(DefaultSetting.defaultBookReadSettingId)))
        .getSingleOrNull();
    state.fontSize =
        settings?.fontSize ?? DefaultSetting.defaultBookReadSettingFontSize;
    state.lineSpacing =
        settings?.fontHeight ?? DefaultSetting.defaultBookReadSettingFontHeight;
    state.letterSpacing = settings?.letterSpacing ??
        DefaultSetting.defaultBookReadSettingLetterSpacing;
    state.brightness = settings?.brightness ?? 0.8;
    state.backgroundColor = settings?.backgroundColor != null
        ? Color(settings!.backgroundColor!)
        : const Color(0xFFF8F9E8);
    state.pageTurnType =
        settings?.pageTurnType ?? DefaultSetting.pageTurnTypeSimulation;
    state.isEyeProtectionMode = settings?.isEyeProtectionMode ?? false;
    state.fontFamily = settings?.fontFamily;
    state.ttsRate = settings?.ttsRate ?? DefaultSetting.defaultTtsRate;
    state.ttsPitch = settings?.ttsPitch ?? DefaultSetting.defaultTtsPitch;
    state.ttsVolume = settings?.ttsVolume ?? DefaultSetting.defaultTtsVolume;
    state.ttsVoiceName = settings?.ttsVoiceName;
    state.ttsAutoNextPage =
        settings?.ttsAutoNextPage ?? DefaultSetting.defaultTtsAutoNextPage;
    state.ttsAutoNextChapter = settings?.ttsAutoNextChapter ??
        DefaultSetting.defaultTtsAutoNextChapter;
    state.ttsResumeAfterInterrupt = settings?.ttsResumeAfterInterrupt ??
        DefaultSetting.defaultTtsResumeAfterInterrupt;
    state.updateTextColors();
    state.contentStyle = TextStyle(
      fontSize: state.fontSize,
      height: state.lineSpacing,
      wordSpacing: DefaultSetting.defaultBookReadSettingWordSpacing,
      letterSpacing: state.letterSpacing,
      fontFamily: state.fontFamily,
      color: state.textColor,
    );
  }

  Future<void> captureSystemBrightness() async {
    try {
      _systemBrightness = await ScreenBrightness().current;
    } catch (error) {
      LogUtils.e('获取系统亮度失败: $error');
    }
  }

  Future<void> restoreBrightness() async {
    try {
      if (_systemBrightness != null) {
        await ScreenBrightness().resetScreenBrightness();
      }
    } catch (error) {
      LogUtils.e('恢复屏幕亮度失败: $error');
    }
  }

  Future<void> updateBrightness(double value) async {
    state.brightness = value;
    try {
      await ScreenBrightness().setScreenBrightness(value);
    } catch (error) {
      LogUtils.e('设置屏幕亮度失败: $error');
    }
    _saveSettings();
    onUpdate();
  }

  void updateFontSize(double value) {
    state.fontSize = value;
    state.contentStyle = state.contentStyle.copyWith(fontSize: value);
    _onStyleChanged();
  }

  void updateFontFamily(String? value) {
    state.fontFamily = value;
    state.contentStyle = state.contentStyle.copyWith(fontFamily: value);
    _onStyleChanged();
  }

  void updateBackgroundColor(Color value) {
    state.backgroundColor = value;
    state.updateTextColors();
    _saveSettings();
    onUpdate();
  }

  void updatePageTurnType(String value) {
    state.pageTurnType = value;
    _saveSettings();
    onUpdate();
  }

  void updateLineSpacing(double value) {
    state.lineSpacing = value;
    state.contentStyle = state.contentStyle.copyWith(height: value);
    _onStyleChanged();
  }

  void updateLetterSpacing(double value) {
    state.letterSpacing = value;
    state.contentStyle = state.contentStyle.copyWith(letterSpacing: value);
    _onStyleChanged();
  }

  void updateTtsRate(double value) {
    state.ttsRate = value.clamp(0.1, 1.0);
    _saveSettings();
    onUpdate();
  }

  void updateTtsPitch(double value) {
    state.ttsPitch = value.clamp(0.5, 2.0);
    _saveSettings();
    onUpdate();
  }

  void updateTtsVolume(double value) {
    state.ttsVolume = value.clamp(0.0, 1.0);
    _saveSettings();
    onUpdate();
  }

  void updateTtsVoiceName(String? value) {
    state.ttsVoiceName = value?.trim().isEmpty == true ? null : value;
    _saveSettings();
    onUpdate();
  }

  void updateTtsAutoNextPage(bool value) {
    state.ttsAutoNextPage = value;
    _saveSettings();
    onUpdate();
  }

  void updateTtsAutoNextChapter(bool value) {
    state.ttsAutoNextChapter = value;
    _saveSettings();
    onUpdate();
  }

  void updateTtsResumeAfterInterrupt(bool value) {
    state.ttsResumeAfterInterrupt = value;
    _saveSettings();
    onUpdate();
  }

  void updateEyeProtectionMode() {
    state.isEyeProtectionMode = !state.isEyeProtectionMode;
    _saveSettings();
    onUpdate();
  }

  bool isNightMode() => state.backgroundColor.computeLuminance() < 0.2;

  void toggleNightMode() {
    if (isNightMode()) {
      state.backgroundColor =
          _previousBackgroundColor ?? const Color(0xFFF8F9E8);
      _previousBackgroundColor = null;
      state.updateTextColors();
    } else {
      _previousBackgroundColor = state.backgroundColor;
      state.backgroundColor = _nightModeColor;
      state.textColor = _nightModeTextColor;
      state.secondaryTextColor = _nightModeTextColor.withValues(alpha: 0.7);
      state.iconColor = _nightModeTextColor;
      state.isEyeProtectionMode = false;
    }
    _saveSettings();
    onUpdate();
  }

  void dispose() {
    _settingsDebounceTimer?.cancel();
    if (_hasPendingSettings) unawaited(_flushSettings());
  }

  void _onStyleChanged() {
    state.isFontSizeChanged = true;
    onSplitBookContent();
    onRelocateCurrentPage();
    _saveSettings();
    onUpdate();
  }

  void _saveSettings() {
    _hasPendingSettings = true;
    _settingsDebounceTimer?.cancel();
    _settingsDebounceTimer = Timer(const Duration(milliseconds: 500), () {
      _settingsDebounceTimer = null;
      unawaited(_flushSettings());
    });
  }

  Future<void> _flushSettings() async {
    if (!_hasPendingSettings) return;
    _hasPendingSettings = false;
    try {
      await _database.into(_database.bookReadSettings).insertOnConflictUpdate(
            db.BookReadSettingsCompanion.insert(
              id: const drift.Value(DefaultSetting.defaultBookReadSettingId),
              updateTime: DateTime.now(),
              fontSize: drift.Value(state.fontSize),
              fontHeight: drift.Value(state.lineSpacing),
              letterSpacing: drift.Value(state.letterSpacing),
              brightness: drift.Value(state.brightness),
              backgroundColor: drift.Value(state.backgroundColor.toARGB32()),
              pageTurnType: drift.Value(state.pageTurnType),
              isEyeProtectionMode: drift.Value(state.isEyeProtectionMode),
              ttsRate: drift.Value(state.ttsRate),
              ttsPitch: drift.Value(state.ttsPitch),
              ttsVolume: drift.Value(state.ttsVolume),
              ttsVoiceName: drift.Value(state.ttsVoiceName),
              ttsAutoNextPage: drift.Value(state.ttsAutoNextPage),
              ttsAutoNextChapter: drift.Value(state.ttsAutoNextChapter),
              ttsResumeAfterInterrupt:
                  drift.Value(state.ttsResumeAfterInterrupt),
              fontFamily: drift.Value(state.fontFamily),
            ),
          );
    } catch (error) {
      _hasPendingSettings = true;
      LogUtils.e('保存阅读设置失败: $error');
    }
  }
}
