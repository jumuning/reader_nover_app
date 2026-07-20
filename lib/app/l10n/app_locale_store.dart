import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppLocaleStore {
  static const prefsKey = 'app_locale';

  Future<String> loadCode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(prefsKey) ?? 'system';
  }

  Future<void> saveCode(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(prefsKey, code);
  }

  Locale? localeForCode(String code) => switch (code) {
        'zh' => const Locale('zh'),
        'en' => const Locale('en'),
        _ => null,
      };
}
