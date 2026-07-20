import 'dart:convert';

import 'package:reader_nover/util/analyze_url_utils.dart';

import 'source_variable_store.dart';

enum SourceLoginRequiredReason {
  loginCheckFailed,
  missingCredentials,
  expired,
  manual,
}

extension SourceLoginRequiredReasonValue on SourceLoginRequiredReason {
  String get value {
    switch (this) {
      case SourceLoginRequiredReason.loginCheckFailed:
        return 'loginCheckJs failed';
      case SourceLoginRequiredReason.missingCredentials:
        return 'missing credentials';
      case SourceLoginRequiredReason.expired:
        return 'login expired';
      case SourceLoginRequiredReason.manual:
        return 'manual login required';
    }
  }
}

class SourceLoginRequired {
  const SourceLoginRequired({
    this.sourceId,
    this.sourceKey,
    this.sourceName,
    required this.reason,
    this.loginUrl,
    this.loginUi,
    this.pageUrl,
  });

  final int? sourceId;
  final String? sourceKey;
  final String? sourceName;
  final String reason;
  final String? loginUrl;
  final String? loginUi;
  final String? pageUrl;

  bool get canRetryAfterLogin =>
      (loginUrl?.trim().isNotEmpty ?? false) ||
      (loginUi?.trim().isNotEmpty ?? false);

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'sourceId': sourceId,
      'sourceKey': sourceKey,
      'sourceName': sourceName,
      'reason': reason,
      'loginUrl': loginUrl,
      'loginUi': loginUi,
      'pageUrl': pageUrl,
      'canRetryAfterLogin': canRetryAfterLogin,
    };
  }

  @override
  String toString() {
    return 'SourceLoginRequired(${toJson()})';
  }
}

class SourceLoginCheckResult {
  const SourceLoginCheckResult.passed() : loginRequired = null;

  const SourceLoginCheckResult.required(this.loginRequired);

  final SourceLoginRequired? loginRequired;

  bool get passed => loginRequired == null;
  bool get requiresLogin => loginRequired != null;
}

class SourceLoginRequiredException implements Exception {
  SourceLoginRequiredException(this.loginRequired);

  SourceLoginRequiredException.fromFields({
    int? sourceId,
    String? sourceKey,
    String? sourceName,
    required String reason,
    String? loginUrl,
    String? loginUi,
    String? pageUrl,
  }) : loginRequired = SourceLoginRequired(
          sourceId: sourceId,
          sourceKey: sourceKey,
          sourceName: sourceName,
          reason: reason,
          loginUrl: loginUrl,
          loginUi: loginUi,
          pageUrl: pageUrl,
        );

  final SourceLoginRequired loginRequired;

  int? get sourceId => loginRequired.sourceId;
  String? get sourceKey => loginRequired.sourceKey;
  String? get sourceName => loginRequired.sourceName;
  String get reason => loginRequired.reason;
  String? get loginUrl => loginRequired.loginUrl;
  String? get loginUi => loginRequired.loginUi;
  String? get pageUrl => loginRequired.pageUrl;
  bool get canRetryAfterLogin => loginRequired.canRetryAfterLogin;

  String get message {
    if (canRetryAfterLogin) {
      return '书源登录态失效，请打开书源登录后重试';
    }
    return '书源登录态失效，但未配置可用登录入口';
  }

  @override
  String toString() {
    return '登录校验: $message, sourceId=$sourceId, sourceName=$sourceName, '
        'reason=$reason, canRetryAfterLogin=$canRetryAfterLogin, '
        'pageUrl=$pageUrl';
  }
}

class SourceLoginState {
  const SourceLoginState({
    required this.sourceKey,
    required this.rawLoginHeader,
    required this.loginHeaders,
    required this.loginInfo,
  });

  final String sourceKey;
  final String rawLoginHeader;
  final Map<String, String> loginHeaders;
  final String loginInfo;

  bool get isEmpty => rawLoginHeader.isEmpty && loginInfo.isEmpty;
}

class SourceLoginRetryPlan<T> {
  const SourceLoginRetryPlan({
    required this.loginRequired,
    required Future<T> Function() retry,
  }) : _retry = retry;

  final SourceLoginRequired loginRequired;
  final Future<T> Function() _retry;

  Future<T> retryAfterLogin() => _retry();
}

class SourceLoginUiSchema {
  const SourceLoginUiSchema({
    required this.fields,
  });

  final List<SourceLoginUiField> fields;

  bool get isEmpty => fields.isEmpty;
}

class SourceLoginUiField {
  const SourceLoginUiField({
    required this.key,
    required this.label,
    required this.type,
    required this.required,
    this.hint = '',
    this.defaultValue = '',
  });

  final String key;
  final String label;
  final String type;
  final bool required;
  final String hint;
  final String defaultValue;

  bool get obscureText {
    final normalized = type.toLowerCase();
    return normalized == 'password' || normalized == 'pwd';
  }
}

class SourceLoginService {
  const SourceLoginService._();

  static const String sourceLoginHeaderKey = '__reader_source_login_header';
  static const String sourceLoginInfoKey = '__reader_source_login_info';

  static Future<SourceLoginState> getState(String sourceKey) async {
    final rawLoginHeader = await getLoginHeader(sourceKey);
    return SourceLoginState(
      sourceKey: sourceKey.trim(),
      rawLoginHeader: rawLoginHeader,
      loginHeaders: parseLoginHeaders(rawLoginHeader),
      loginInfo: await getLoginInfo(sourceKey),
    );
  }

  static Future<String> getLoginHeader(String sourceKey) async {
    final source = sourceKey.trim();
    if (source.isEmpty) return '';

    final canonical = await SourceVariableStore.getEntry(
      source,
      sourceLoginHeaderKey,
    );
    if (canonical.trim().isNotEmpty) return canonical;
    return SourceVariableStore.getEntry(source, _legacyLoginHeaderKey(source));
  }

  static Map<String, String> parseLoginHeaders(String? rawLoginHeader) {
    return AnalyzeUrlUtils.parseHeaderMap(
      rawLoginHeader,
      ensureDefaultUserAgent: false,
    );
  }

  static Future<Map<String, String>> getLoginHeaders(String sourceKey) async {
    return parseLoginHeaders(await getLoginHeader(sourceKey));
  }

  static Future<void> setLoginHeader(String sourceKey, String value) async {
    final source = sourceKey.trim();
    if (source.isEmpty) return;
    await SourceVariableStore.setEntry(source, sourceLoginHeaderKey, value);
  }

  static Future<void> clearLoginHeader(String sourceKey) async {
    final source = sourceKey.trim();
    if (source.isEmpty) return;
    await SourceVariableStore.removeEntry(source, sourceLoginHeaderKey);
    await SourceVariableStore.removeEntry(
        source, _legacyLoginHeaderKey(source));
  }

  static Future<String> getLoginInfo(String sourceKey) async {
    final source = sourceKey.trim();
    if (source.isEmpty) return '';

    final canonical = await SourceVariableStore.getEntry(
      source,
      sourceLoginInfoKey,
    );
    if (canonical.trim().isNotEmpty) return canonical;
    return SourceVariableStore.getEntry(source, _legacyLoginInfoKey(source));
  }

  static Future<void> setLoginInfo(String sourceKey, String value) async {
    final source = sourceKey.trim();
    if (source.isEmpty) return;
    await SourceVariableStore.setEntry(source, sourceLoginInfoKey, value);
  }

  static Future<void> saveLoginUiInfo(
    String sourceKey,
    Map<String, String> values,
  ) async {
    final source = sourceKey.trim();
    if (source.isEmpty || values.isEmpty) return;
    final normalized = <String, String>{};
    for (final entry in values.entries) {
      final key = entry.key.trim();
      if (key.isEmpty) continue;
      normalized[key] = entry.value;
    }
    if (normalized.isEmpty) return;
    await setLoginInfo(source, encodeLoginInfoMap(normalized));
  }

  static Future<void> clearLoginInfo(String sourceKey) async {
    final source = sourceKey.trim();
    if (source.isEmpty) return;
    await SourceVariableStore.removeEntry(source, sourceLoginInfoKey);
    await SourceVariableStore.removeEntry(source, _legacyLoginInfoKey(source));
  }

  static Future<void> clearLoginData(String sourceKey) async {
    await clearLoginHeader(sourceKey);
    await clearLoginInfo(sourceKey);
  }

  static SourceLoginRetryPlan<T> createRetryPlan<T>({
    required SourceLoginRequired loginRequired,
    required Future<T> Function() retry,
  }) {
    return SourceLoginRetryPlan<T>(
      loginRequired: loginRequired,
      retry: retry,
    );
  }

  static SourceLoginUiSchema? parseLoginUi(String? rawLoginUi) {
    final raw = rawLoginUi?.trim() ?? '';
    if (raw.isEmpty) return null;

    final decoded = _decodeJson(raw);
    if (decoded == null) return null;

    final fields = <SourceLoginUiField>[];
    if (decoded is List) {
      for (final item in decoded) {
        final field = _parseLoginUiField(item);
        if (field != null) fields.add(field);
      }
    } else if (decoded is Map) {
      final formItems = decoded['formItems'] ??
          decoded['fields'] ??
          decoded['items'] ??
          decoded['rows'] ??
          decoded['loginUi'];
      if (formItems is List) {
        for (final item in formItems) {
          final field = _parseLoginUiField(item);
          if (field != null) fields.add(field);
        }
      } else {
        final field = _parseLoginUiField(decoded);
        if (field != null) fields.add(field);
      }
    }

    if (fields.isEmpty) return null;
    return SourceLoginUiSchema(fields: List.unmodifiable(fields));
  }

  static String encodeLoginInfoMap(Map<String, String> values) {
    final normalized = <String, String>{};
    for (final entry in values.entries) {
      final key = entry.key.trim();
      if (key.isEmpty) continue;
      normalized[key] = entry.value;
    }
    return jsonEncode(normalized);
  }

  static Map<String, String> parseLoginInfoMap(String? rawLoginInfo) {
    final decoded = _decodeJson(rawLoginInfo?.trim() ?? '');
    if (decoded is! Map) return const <String, String>{};
    final values = <String, String>{};
    for (final entry in decoded.entries) {
      final key = entry.key.toString().trim();
      if (key.isEmpty || entry.value == null) continue;
      values[key] = entry.value.toString();
    }
    return values;
  }

  static String _legacyLoginHeaderKey(String sourceKey) {
    return 'loginHeader_$sourceKey';
  }

  static String _legacyLoginInfoKey(String sourceKey) {
    return 'userInfo_$sourceKey';
  }

  static Object? _decodeJson(String raw) {
    try {
      return jsonDecode(raw);
    } catch (_) {
      return null;
    }
  }

  static SourceLoginUiField? _parseLoginUiField(Object? raw) {
    if (raw is! Map) return null;
    final map = raw.cast<Object?, Object?>();
    final type = _stringValue(map, const [
      'type',
      'inputType',
      'viewType',
      'kind',
    ]).toLowerCase();
    if (!_isSupportedLoginUiFieldType(type)) return null;

    final key = _stringValue(map, const [
      'name',
      'key',
      'id',
      'field',
      'variable',
      'var',
    ]).trim();
    if (key.isEmpty) return null;

    final label = _stringValue(map, const [
      'label',
      'title',
      'text',
      'hint',
      'name',
    ]).trim();
    final defaultValue = _stringValue(map, const [
      'value',
      'defaultValue',
      'default',
    ]);
    final required =
        _boolValue(map, const ['required', 'require', 'notNull']) ??
            _defaultRequired(type);

    return SourceLoginUiField(
      key: key,
      label: label.isNotEmpty ? label : key,
      type: type.isNotEmpty ? type : 'text',
      required: required,
      hint: _stringValue(map, const ['hint', 'placeholder', 'desc']),
      defaultValue: defaultValue,
    );
  }

  static bool _isSupportedLoginUiFieldType(String type) {
    if (type.isEmpty) return true;
    return type == 'text' ||
        type == 'input' ||
        type == 'edit' ||
        type == 'password' ||
        type == 'pwd' ||
        type == 'number' ||
        type == 'email' ||
        type == 'tel';
  }

  static bool _defaultRequired(String type) {
    return type.isEmpty ||
        type == 'text' ||
        type == 'input' ||
        type == 'edit' ||
        type == 'password' ||
        type == 'pwd';
  }

  static String _stringValue(Map<Object?, Object?> map, List<String> keys) {
    for (final key in keys) {
      final value = map[key];
      if (value == null) continue;
      final text = value.toString();
      if (text.trim().isNotEmpty) return text;
    }
    return '';
  }

  static bool? _boolValue(Map<Object?, Object?> map, List<String> keys) {
    for (final key in keys) {
      final value = map[key];
      if (value is bool) return value;
      if (value is num) return value != 0;
      if (value is String) {
        final normalized = value.trim().toLowerCase();
        if (normalized.isEmpty) continue;
        if (normalized == 'true' ||
            normalized == '1' ||
            normalized == 'yes' ||
            normalized == 'required') {
          return true;
        }
        if (normalized == 'false' ||
            normalized == '0' ||
            normalized == 'no' ||
            normalized == 'optional') {
          return false;
        }
      }
    }
    return null;
  }
}
