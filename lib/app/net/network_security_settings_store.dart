import 'package:shared_preferences/shared_preferences.dart';

class NetworkSecuritySettingsStore {
  static const String _allowInsecureCertificatesKey =
      'allow_insecure_certificates';

  Future<bool> loadAllowInsecureCertificates() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_allowInsecureCertificatesKey) ?? false;
  }

  Future<void> saveAllowInsecureCertificates(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_allowInsecureCertificatesKey, value);
  }
}
