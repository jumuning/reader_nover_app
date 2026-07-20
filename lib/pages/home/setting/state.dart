import 'package:flutter/material.dart';
import 'package:reader_nover/app/theme/app_theme_palette.dart';

import '../book/state.dart';

class SettingState {
  ThemeMode themeMode = ThemeMode.light;
  AppThemePalette themePalette = AppThemePalette.money;
  BookshelfLayout bookshelfLayout = BookshelfLayout.list;
  bool allowInsecureCertificates = false;
  bool isCheckingLocalBookStorage = false;
  String localeCode = 'system';
}
