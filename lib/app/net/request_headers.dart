class RequestHeaders {
  const RequestHeaders._();

  static const String defaultUserAgent =
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36';

  static Map<String, String> build(
    Map<String, String>? headers, {
    Map<String, String>? defaults,
    bool ensureDefaultUserAgent = true,
  }) {
    final merged = <String, String>{};
    _mergeInto(merged, defaults);
    _mergeInto(merged, headers);
    if (ensureDefaultUserAgent) {
      _ensureDefaultUserAgent(merged);
    }
    _normalizeCookieHeader(merged);
    return merged;
  }

  static void applyHttpDefaults(Map<String, dynamic> headers) {
    headers.removeWhere(
      (key, value) => _shouldDropHeaderEntry(key.toString(), value?.toString()),
    );

    final userAgentKey = findHeaderKey(headers, 'User-Agent');
    if (userAgentKey == null) {
      headers['User-Agent'] = defaultUserAgent;
    } else if (headers[userAgentKey]?.toString() == 'null') {
      headers.remove(userAgentKey);
    }

    _putIfAbsentIgnoreCase(headers, 'Keep-Alive', '300');
    _putIfAbsentIgnoreCase(headers, 'Connection', 'Keep-Alive');
    _putIfAbsentIgnoreCase(headers, 'Cache-Control', 'no-cache');
    _normalizeCookieHeaderDynamic(headers);
  }

  static String normalizeCookieHeaderValue(String? rawCookie) {
    final raw = rawCookie?.trim();
    if (raw == null || raw.isEmpty) return '';

    final normalized = <String>[];
    for (final part in raw.split(';')) {
      final token = part.trim();
      if (token.isEmpty) continue;
      final eqIndex = token.indexOf('=');
      if (eqIndex <= 0) continue;

      final name = token.substring(0, eqIndex).trim();
      if (name.isEmpty) continue;
      final value = token.substring(eqIndex + 1).trim();
      normalized.add('$name=$value');
    }
    return normalized.isNotEmpty ? normalized.join(';') : raw;
  }

  static String? getHeaderValue(Map<String, String> headers, String name) {
    final key = _findHeaderKeyString(headers, name);
    if (key == null) return null;
    return headers[key];
  }

  static String? findHeaderKey(Map<String, dynamic> headers, String name) {
    final lower = name.toLowerCase();
    for (final key in headers.keys) {
      if (key.toLowerCase() == lower) {
        return key;
      }
    }
    return null;
  }

  static void _mergeInto(
    Map<String, String> target,
    Map<String, String>? source,
  ) {
    if (source == null) return;
    for (final entry in source.entries) {
      if (_shouldDropHeaderEntry(entry.key, entry.value)) continue;
      final existing = _findHeaderKeyString(target, entry.key);
      if (existing != null && existing != entry.key) {
        target.remove(existing);
      }
      target[entry.key] = entry.value;
    }
  }

  static void _ensureDefaultUserAgent(Map<String, String> headers) {
    final uaKey = _findHeaderKeyString(headers, 'User-Agent');
    if (uaKey == null) {
      headers['User-Agent'] = defaultUserAgent;
    }
  }

  static void _normalizeCookieHeader(Map<String, String> headers) {
    final cookieKey = _findHeaderKeyString(headers, 'Cookie');
    if (cookieKey == null) return;

    final normalized = normalizeCookieHeaderValue(headers[cookieKey]);
    if (normalized.isEmpty) {
      headers.remove(cookieKey);
    } else {
      headers[cookieKey] = normalized;
    }
  }

  static void _normalizeCookieHeaderDynamic(Map<String, dynamic> headers) {
    final cookieKey = findHeaderKey(headers, 'Cookie');
    if (cookieKey == null) return;

    final normalized =
        normalizeCookieHeaderValue(headers[cookieKey]?.toString());
    if (normalized.isEmpty) {
      headers.remove(cookieKey);
    } else {
      headers[cookieKey] = normalized;
    }
  }

  static String? _findHeaderKeyString(
    Map<String, String> headers,
    String name,
  ) {
    final lower = name.toLowerCase();
    for (final key in headers.keys) {
      if (key.toLowerCase() == lower) {
        return key;
      }
    }
    return null;
  }

  static void _putIfAbsentIgnoreCase(
    Map<String, dynamic> headers,
    String key,
    String value,
  ) {
    if (findHeaderKey(headers, key) == null) {
      headers[key] = value;
    }
  }

  static bool _shouldDropHeaderEntry(String key, String? value) {
    if (key.isEmpty || key.startsWith('__reader_')) return true;
    return key.contains('\r') ||
        key.contains('\n') ||
        (value?.contains('\r') ?? false) ||
        (value?.contains('\n') ?? false);
  }
}
