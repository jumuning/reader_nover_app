import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import 'network_security_settings_store.dart';

class Http {
  static Http? _instance;

  static Future<void> init() async {
    if (_instance != null) {
      return;
    }
    final instance =
        Http._internal(directory: await getApplicationCacheDirectory());
    await instance._loadSecuritySettings();
    _instance = instance;
  }

  static Http get instance {
    if (_instance == null) {
      throw Exception('在使用Http.instance之前必须调用init');
    }
    return _instance!;
  }

  late final PersistCookieJar cookieJar;
  final NetworkSecuritySettingsStore _securitySettingsStore =
      NetworkSecuritySettingsStore();
  bool _allowInsecureCertificates = false;

  Http._internal({required Directory directory}) {
    if (!kIsWeb) {
      final String path = '${directory.path}/cookie_jar';

      if (!Directory(path).existsSync()) {
        Directory(path).createSync();
      }
      cookieJar = PersistCookieJar(
        storage: FileStorage(path),
        ignoreExpires: true,
      );
    }
  }

  Future<void> _loadSecuritySettings() async {
    _allowInsecureCertificates =
        await _securitySettingsStore.loadAllowInsecureCertificates();
  }

  bool get allowInsecureCertificates => _allowInsecureCertificates;

  Future<void> setAllowInsecureCertificates(bool value) async {
    _allowInsecureCertificates = value;
    await _securitySettingsStore.saveAllowInsecureCertificates(value);
  }
}
