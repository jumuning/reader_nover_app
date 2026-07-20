import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

import '../../net/http_client.dart';
import '../../net/request_headers.dart';

class SourceVariableStore {
  static const String _prefix = 'source_variable::';
  static const String _entryPrefix = 'source_entry::';
  static const String _cachePrefix = 'source_cache::';
  static const String _cacheDeadlinePrefix = 'source_cache_deadline::';
  static const String _cacheFilePrefix = 'source_cache_file::';
  static const String _cacheFileDeadlinePrefix = 'source_cache_file_deadline::';
  /// book.putVariable: `source_book_var::{sourceKey}::{normalizedBookUrl}::{key}`
  static const String _bookVarPrefix = 'source_book_var::';

  const SourceVariableStore._();

  static Future<String> get(
    String sourceKey, {
    String? sourceUrl,
    bool preferCookieJar = false,
    bool allowCookieJarFallback = true,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString('$_prefix$sourceKey') ?? '';
    final targetUrl =
        (sourceUrl == null || sourceUrl.trim().isEmpty) ? sourceKey : sourceUrl;

    if (preferCookieJar) {
      final jarCookie = await _readCookieFromJar(targetUrl);
      if (jarCookie.isNotEmpty) {
        if (jarCookie != stored) {
          await prefs.setString('$_prefix$sourceKey', jarCookie);
        }
        return jarCookie;
      }
    }

    if (stored.isNotEmpty) return stored;

    if (!allowCookieJarFallback) return '';

    final jarCookie = await _readCookieFromJar(targetUrl);
    if (jarCookie.isNotEmpty) {
      await prefs.setString('$_prefix$sourceKey', jarCookie);
      return jarCookie;
    }
    return '';
  }

  static Future<void> set(String sourceKey, String value) async {
    final prefs = await SharedPreferences.getInstance();
    final normalized = value.trim();
    if (normalized.isEmpty) {
      await prefs.remove('$_prefix$sourceKey');
    } else {
      await prefs.setString('$_prefix$sourceKey', normalized);
    }
  }

  static Future<String> getEntry(String sourceKey, String key) async {
    final namespacedKey = _namespacedKey(_entryPrefix, sourceKey, key);
    if (namespacedKey == null) return '';
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(namespacedKey) ?? '';
  }

  static Future<void> setEntry(
    String sourceKey,
    String key,
    String value,
  ) async {
    final namespacedKey = _namespacedKey(_entryPrefix, sourceKey, key);
    if (namespacedKey == null) return;
    await _setPrefValue(namespacedKey, value);
  }

  static Future<void> setEntries(
    String sourceKey,
    Map<String, String> values,
  ) async {
    if (sourceKey.trim().isEmpty || values.isEmpty) return;
    for (final entry in values.entries) {
      await setEntry(sourceKey, entry.key, entry.value);
    }
  }

  static Future<Map<String, String>> getEntries(String sourceKey) async {
    final key = sourceKey.trim();
    if (key.isEmpty) return const <String, String>{};

    final prefs = await SharedPreferences.getInstance();
    final prefix = '$_entryPrefix$key::';
    final values = <String, String>{};
    for (final prefKey in prefs.getKeys()) {
      if (!prefKey.startsWith(prefix)) continue;
      final entryKey = prefKey.substring(prefix.length).trim();
      if (entryKey.isEmpty) continue;
      final value = prefs.getString(prefKey);
      if (value == null) continue;
      values[entryKey] = value;
    }
    return values;
  }

  static Future<void> removeEntry(String sourceKey, String key) async {
    final namespacedKey = _namespacedKey(_entryPrefix, sourceKey, key);
    if (namespacedKey == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(namespacedKey);
  }

  static Future<String> getCache(String sourceKey, String key) async {
    final prefs = await SharedPreferences.getInstance();
    return _getCacheValue(
      prefs,
      valuePrefix: _cachePrefix,
      deadlinePrefix: _cacheDeadlinePrefix,
      sourceKey: sourceKey,
      key: key,
    );
  }

  static Future<void> setCache(
    String sourceKey,
    String key,
    String value,
  ) async {
    final namespacedKey = _namespacedKey(_cachePrefix, sourceKey, key);
    if (namespacedKey == null) return;
    await _setPrefValue(namespacedKey, value);
  }

  static Future<void> setCaches(
    String sourceKey,
    Map<String, String> values,
  ) async {
    if (sourceKey.trim().isEmpty || values.isEmpty) return;
    for (final entry in values.entries) {
      await setCache(sourceKey, entry.key, entry.value);
    }
  }

  static Future<Map<String, String>> getCaches(String sourceKey) async {
    final prefs = await SharedPreferences.getInstance();
    return _getCacheValues(
      prefs,
      valuePrefix: _cachePrefix,
      deadlinePrefix: _cacheDeadlinePrefix,
      sourceKey: sourceKey,
    );
  }

  static Future<void> setCacheDeadline(
    String sourceKey,
    String key,
    String value,
  ) async {
    final namespacedKey = _namespacedKey(_cacheDeadlinePrefix, sourceKey, key);
    if (namespacedKey == null) return;
    await _setPrefValue(namespacedKey, value);
  }

  static Future<void> setCacheDeadlines(
    String sourceKey,
    Map<String, String> values,
  ) async {
    if (sourceKey.trim().isEmpty || values.isEmpty) return;
    for (final entry in values.entries) {
      await setCacheDeadline(sourceKey, entry.key, entry.value);
    }
  }

  static Future<Map<String, String>> getCacheDeadlines(String sourceKey) async {
    final prefs = await SharedPreferences.getInstance();
    await _removeExpiredCacheValues(
      prefs,
      valuePrefix: _cachePrefix,
      deadlinePrefix: _cacheDeadlinePrefix,
      sourceKey: sourceKey,
    );
    return _getNamespacedValuesWithPrefs(
        prefs, _cacheDeadlinePrefix, sourceKey);
  }

  static Future<String> getFileCache(String sourceKey, String key) async {
    final prefs = await SharedPreferences.getInstance();
    return _getCacheValue(
      prefs,
      valuePrefix: _cacheFilePrefix,
      deadlinePrefix: _cacheFileDeadlinePrefix,
      sourceKey: sourceKey,
      key: key,
    );
  }

  static Future<void> setFileCache(
    String sourceKey,
    String key,
    String value,
  ) async {
    final namespacedKey = _namespacedKey(_cacheFilePrefix, sourceKey, key);
    if (namespacedKey == null) return;
    await _setPrefValue(namespacedKey, value);
  }

  static Future<void> setFileCaches(
    String sourceKey,
    Map<String, String> values,
  ) async {
    if (sourceKey.trim().isEmpty || values.isEmpty) return;
    for (final entry in values.entries) {
      await setFileCache(sourceKey, entry.key, entry.value);
    }
  }

  static Future<Map<String, String>> getFileCaches(String sourceKey) async {
    final prefs = await SharedPreferences.getInstance();
    return _getCacheValues(
      prefs,
      valuePrefix: _cacheFilePrefix,
      deadlinePrefix: _cacheFileDeadlinePrefix,
      sourceKey: sourceKey,
    );
  }

  static Future<void> setFileCacheDeadline(
    String sourceKey,
    String key,
    String value,
  ) async {
    final namespacedKey =
        _namespacedKey(_cacheFileDeadlinePrefix, sourceKey, key);
    if (namespacedKey == null) return;
    await _setPrefValue(namespacedKey, value);
  }

  static Future<void> setFileCacheDeadlines(
    String sourceKey,
    Map<String, String> values,
  ) async {
    if (sourceKey.trim().isEmpty || values.isEmpty) return;
    for (final entry in values.entries) {
      await setFileCacheDeadline(sourceKey, entry.key, entry.value);
    }
  }

  static Future<Map<String, String>> getFileCacheDeadlines(
    String sourceKey,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await _removeExpiredCacheValues(
      prefs,
      valuePrefix: _cacheFilePrefix,
      deadlinePrefix: _cacheFileDeadlinePrefix,
      sourceKey: sourceKey,
    );
    return _getNamespacedValuesWithPrefs(
      prefs,
      _cacheFileDeadlinePrefix,
      sourceKey,
    );
  }

  static Future<void> syncFromCookieJar(
    String sourceKey,
    String requestUrl,
  ) async {
    if (sourceKey.trim().isEmpty || requestUrl.trim().isEmpty) return;
    final jarCookie = await _readCookieFromJar(requestUrl);
    if (jarCookie.isEmpty) return;
    await set(sourceKey, jarCookie);
  }

  /// Persist a single `book.putVariable` value scoped to [sourceKey]+[bookUrl].
  static Future<void> setBookVar(
    String sourceKey,
    String bookUrl,
    String key,
    String value,
  ) async {
    final namespacedKey = _bookVarPrefKey(sourceKey, bookUrl, key);
    if (namespacedKey == null) return;
    await _setPrefValue(namespacedKey, value);
  }

  /// All book vars for one source+book (short keys, without store prefix).
  static Future<Map<String, String>> getBookVars(
    String sourceKey,
    String bookUrl,
  ) async {
    final source = sourceKey.trim();
    final normalizedBook = _normalizeBookUrl(bookUrl);
    if (source.isEmpty || normalizedBook.isEmpty) {
      return const <String, String>{};
    }

    final prefs = await SharedPreferences.getInstance();
    final prefix = '$_bookVarPrefix$source::$normalizedBook::';
    final values = <String, String>{};
    for (final prefKey in prefs.getKeys()) {
      if (!prefKey.startsWith(prefix)) continue;
      final entryKey = prefKey.substring(prefix.length).trim();
      if (entryKey.isEmpty) continue;
      final value = prefs.getString(prefKey);
      if (value == null) continue;
      values[entryKey] = value;
    }
    return values;
  }

  static Future<void> remove(
    String sourceKey, {
    String? sourceUrl,
  }) async {
    if (sourceKey.trim().isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_prefix$sourceKey');
    await _removeNamespacedValues(prefs, _entryPrefix, sourceKey);
    await _removeNamespacedValues(prefs, _cachePrefix, sourceKey);
    await _removeNamespacedValues(prefs, _cacheDeadlinePrefix, sourceKey);
    await _removeNamespacedValues(prefs, _cacheFilePrefix, sourceKey);
    await _removeNamespacedValues(prefs, _cacheFileDeadlinePrefix, sourceKey);
    await _removeBookVarsForSource(prefs, sourceKey);

    final targetUrl =
        (sourceUrl == null || sourceUrl.trim().isEmpty) ? sourceKey : sourceUrl;
    final uri = _parseUri(targetUrl);
    if (uri == null) return;

    try {
      await Http.instance.cookieJar.delete(uri, true);
    } catch (_) {}
  }

  static Future<void> removeAll(Iterable<String> sourceKeys) async {
    for (final sourceKey in sourceKeys) {
      final key = sourceKey.trim();
      if (key.isEmpty) continue;
      await remove(key, sourceUrl: key);
    }
  }

  static Future<void> _setPrefValue(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    final normalized = value.trim();
    if (normalized.isEmpty) {
      await prefs.remove(key);
    } else {
      await prefs.setString(key, normalized);
    }
  }

  static String? _namespacedKey(String prefix, String sourceKey, String key) {
    final source = sourceKey.trim();
    final itemKey = key.trim();
    if (source.isEmpty || itemKey.isEmpty) return null;
    return '$prefix$source::$itemKey';
  }

  static Map<String, String> _getNamespacedValuesWithPrefs(
    SharedPreferences prefs,
    String entryPrefix,
    String sourceKey,
  ) {
    final source = sourceKey.trim();
    if (source.isEmpty) return const <String, String>{};

    final prefix = '$entryPrefix$source::';
    final values = <String, String>{};
    for (final prefKey in prefs.getKeys()) {
      if (!prefKey.startsWith(prefix)) continue;
      final entryKey = prefKey.substring(prefix.length).trim();
      if (entryKey.isEmpty) continue;
      final value = prefs.getString(prefKey);
      if (value == null) continue;
      values[entryKey] = value;
    }
    return values;
  }

  static Future<String> _getCacheValue(
    SharedPreferences prefs, {
    required String valuePrefix,
    required String deadlinePrefix,
    required String sourceKey,
    required String key,
  }) async {
    final valueKey = _namespacedKey(valuePrefix, sourceKey, key);
    final deadlineKey = _namespacedKey(deadlinePrefix, sourceKey, key);
    if (valueKey == null || deadlineKey == null) return '';

    if (_isDeadlineExpired(prefs.getString(deadlineKey))) {
      await prefs.remove(valueKey);
      await prefs.remove(deadlineKey);
      return '';
    }
    return prefs.getString(valueKey) ?? '';
  }

  static Future<Map<String, String>> _getCacheValues(
    SharedPreferences prefs, {
    required String valuePrefix,
    required String deadlinePrefix,
    required String sourceKey,
  }) async {
    await _removeExpiredCacheValues(
      prefs,
      valuePrefix: valuePrefix,
      deadlinePrefix: deadlinePrefix,
      sourceKey: sourceKey,
    );
    return _getNamespacedValuesWithPrefs(prefs, valuePrefix, sourceKey);
  }

  static Future<void> _removeExpiredCacheValues(
    SharedPreferences prefs, {
    required String valuePrefix,
    required String deadlinePrefix,
    required String sourceKey,
  }) async {
    final source = sourceKey.trim();
    if (source.isEmpty) return;
    final deadlineKeyPrefix = '$deadlinePrefix$source::';
    final expiredItemKeys = prefs
        .getKeys()
        .where((key) => key.startsWith(deadlineKeyPrefix))
        .where((key) => _isDeadlineExpired(prefs.getString(key)))
        .map((key) => key.substring(deadlineKeyPrefix.length))
        .where((key) => key.trim().isNotEmpty)
        .toList(growable: false);

    for (final itemKey in expiredItemKeys) {
      await prefs.remove('$valuePrefix$source::$itemKey');
      await prefs.remove('$deadlinePrefix$source::$itemKey');
    }
  }

  static bool _isDeadlineExpired(String? deadline) {
    if (deadline == null) return false;
    final timestamp = int.tryParse(deadline.trim());
    if (timestamp == null || timestamp <= 0) return false;
    return DateTime.now().millisecondsSinceEpoch > timestamp;
  }

  static Future<void> _removeNamespacedValues(
    SharedPreferences prefs,
    String entryPrefix,
    String sourceKey,
  ) async {
    final source = sourceKey.trim();
    if (source.isEmpty) return;
    final prefix = '$entryPrefix$source::';
    final keys = prefs
        .getKeys()
        .where((key) => key.startsWith(prefix))
        .toList(growable: false);
    for (final key in keys) {
      await prefs.remove(key);
    }
  }

  static Future<void> _removeBookVarsForSource(
    SharedPreferences prefs,
    String sourceKey,
  ) async {
    final source = sourceKey.trim();
    if (source.isEmpty) return;
    final prefix = '$_bookVarPrefix$source::';
    final keys = prefs
        .getKeys()
        .where((key) => key.startsWith(prefix))
        .toList(growable: false);
    for (final key in keys) {
      await prefs.remove(key);
    }
  }

  /// Pref key: `source_book_var::{sourceKey}::{normalizedBookUrl}::{key}`.
  static String? _bookVarPrefKey(
    String sourceKey,
    String bookUrl,
    String key,
  ) {
    final source = sourceKey.trim();
    final itemKey = key.trim();
    final normalizedBook = _normalizeBookUrl(bookUrl);
    if (source.isEmpty || itemKey.isEmpty || normalizedBook.isEmpty) {
      return null;
    }
    return '$_bookVarPrefix$source::$normalizedBook::$itemKey';
  }

  static String _normalizeBookUrl(String bookUrl) {
    var normalized = bookUrl.trim();
    if (normalized.isEmpty) return '';
    if (normalized.endsWith('/')) {
      normalized = normalized.substring(0, normalized.length - 1);
    }
    final hashIndex = normalized.indexOf('#');
    if (hashIndex > 0) {
      normalized = normalized.substring(0, hashIndex);
    }
    return normalized.toLowerCase();
  }

  static Uri? _parseUri(String rawUrl) {
    Uri? uri;
    try {
      uri = Uri.parse(rawUrl);
    } catch (_) {
      uri = null;
    }

    if (uri == null || (!uri.hasScheme && uri.host.isEmpty)) {
      try {
        uri = Uri.parse('https://$rawUrl');
      } catch (_) {
        return null;
      }
    } else if (!uri.hasScheme) {
      uri = uri.replace(scheme: 'https');
    }
    return uri;
  }

  static Future<String> _readCookieFromJar(String rawUrl) async {
    final uri = _parseUri(rawUrl);
    if (uri == null) return '';

    try {
      final cookies = await Http.instance.cookieJar.loadForRequest(uri);
      if (cookies.isEmpty) return '';
      return RequestHeaders.normalizeCookieHeaderValue(
        cookies
            .where((c) => c.name.trim().isNotEmpty)
            .map((Cookie c) => '${c.name}=${c.value}')
            .join(';'),
      );
    } catch (_) {
      return '';
    }
  }
}
