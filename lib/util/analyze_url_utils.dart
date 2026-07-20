import 'dart:convert';
import 'dart:io' as io;

import 'package:reader_nover/app/net/http_client.dart';
import 'package:reader_nover/app/net/request_headers.dart';
import 'package:reader_nover/rust/api/analyze_url.dart';

/// Dart wrapper for URL analysis
class AnalyzeUrlUtils {
  static const String _ctxJsLibKey = '__reader_ctx_js_lib';
  static const String _ctxSourceKey = '__reader_ctx_source_key';
  static const String _ctxSourceVariable = '__reader_ctx_source_variable';
  static const String _ctxLoginUrl = '__reader_ctx_login_url';
  static const String _ctxSourceVarsJson = '__reader_ctx_source_vars_json';
  static const String _ctxSessionVarsJson = '__reader_ctx_session_vars_json';
  static const String _ctxBookVarsJson = '__reader_ctx_book_vars_json';
  static const String _ctxChapterVarsJson = '__reader_ctx_chapter_vars_json';
  static const String _ctxBookJson = '__reader_ctx_book_json';
  static const String _ctxChapterJson = '__reader_ctx_chapter_json';
  static const String _ctxRespondTime = '__reader_ctx_respond_time';
  static const String _cookieJarPrefix = 'cookieJar::';

  /// Parse header JSON text to `Map<String, String>` and ensure default UA.
  static Map<String, String> parseHeaderMap(
    String? headerJson, {
    bool ensureDefaultUserAgent = true,
  }) {
    final out = <String, String>{};
    final raw = headerJson?.trim();
    if (raw != null && raw.isNotEmpty) {
      final decodedMap = _decodeHeaderObject(raw);
      if (decodedMap != null) {
        out.addAll(decodedMap);
      } else if (_looksLikeUserAgent(raw)) {
        out['User-Agent'] = raw;
      }
    }
    return RequestHeaders.build(
      out,
      ensureDefaultUserAgent: ensureDefaultUserAgent,
    );
  }

  static Map<String, String>? _decodeHeaderObject(String raw) {
    Object? decoded;
    try {
      decoded = jsonDecode(raw);
    } catch (_) {
      decoded = _LooseJsonParser(raw).parse();
    }

    if (decoded is! Map) return null;
    final out = <String, String>{};
    decoded.forEach((key, value) {
      if (key == null) return;
      out[key.toString()] = value?.toString() ?? '';
    });
    return out;
  }

  static bool _looksLikeUserAgent(String raw) {
    final lower = raw.toLowerCase();
    return lower.contains('mozilla/') ||
        lower.startsWith('okhttp/') ||
        lower.startsWith('dalvik/') ||
        lower.startsWith('dart/');
  }

  static AnalyzeUrlRequest buildAnalyzeRequest({
    required String url,
    String? baseUrl,
    int? page,
    String? key,
    Map<String, String>? headerMap,
    String? jsLib,
    String? sourceKey,
    String? sourceVariable,
    String? loginUrl,
    Map<String, String>? sourceVariables,
    Map<String, String>? sessionVariables,
    Map<String, String>? bookVariables,
    Map<String, String>? chapterVariables,
    Map<String, Object?>? book,
    Map<String, Object?>? chapter,
    int? respondTime,
  }) {
    return AnalyzeUrlRequest(
      url: url,
      baseUrl: baseUrl,
      page: page,
      key: key,
      headerMap: buildContextHeaderMap(
        baseUrl: baseUrl,
        headerMap: headerMap,
        jsLib: jsLib,
        sourceKey: sourceKey,
        sourceVariable: sourceVariable,
        loginUrl: loginUrl,
        sourceVariables: sourceVariables,
        sessionVariables: sessionVariables,
        bookVariables: bookVariables,
        chapterVariables: chapterVariables,
        book: book,
        chapter: chapter,
        respondTime: respondTime,
      ),
    );
  }

  static FetchUrlRequest buildFetchRequest({
    required String url,
    String? baseUrl,
    int? page,
    String? key,
    Map<String, String>? headerMap,
    String? jsLib,
    String? sourceKey,
    String? sourceVariable,
    String? loginUrl,
    Map<String, String>? sourceVariables,
    Map<String, String>? sessionVariables,
    Map<String, String>? bookVariables,
    Map<String, String>? chapterVariables,
    Map<String, Object?>? book,
    Map<String, Object?>? chapter,
    int? respondTime,
    bool binaryAsHex = false,
  }) {
    return FetchUrlRequest(
      url: url,
      baseUrl: baseUrl,
      page: page,
      key: key,
      headerMap: buildContextHeaderMap(
        baseUrl: baseUrl,
        headerMap: headerMap,
        jsLib: jsLib,
        sourceKey: sourceKey,
        sourceVariable: sourceVariable,
        loginUrl: loginUrl,
        sourceVariables: sourceVariables,
        sessionVariables: sessionVariables,
        bookVariables: bookVariables,
        chapterVariables: chapterVariables,
        book: book,
        chapter: chapter,
        respondTime: respondTime,
      ),
      binaryAsHex: binaryAsHex,
    );
  }

  static FetchUrlRequest copyFetchRequest(
    FetchUrlRequest request, {
    required bool binaryAsHex,
  }) {
    return FetchUrlRequest(
      url: request.url,
      baseUrl: request.baseUrl,
      page: request.page,
      key: request.key,
      headerMap: request.headerMap,
      binaryAsHex: binaryAsHex,
    );
  }

  static Future<FetchUrlResult> fetchRequest(FetchUrlRequest request) {
    return fetchUrl(req: request);
  }

  static Map<String, String> buildContextHeaderMap({
    String? baseUrl,
    Map<String, String>? headerMap,
    String? jsLib,
    String? sourceKey,
    String? sourceVariable,
    String? loginUrl,
    Map<String, String>? sourceVariables,
    Map<String, String>? sessionVariables,
    Map<String, String>? bookVariables,
    Map<String, String>? chapterVariables,
    Map<String, Object?>? book,
    Map<String, Object?>? chapter,
    int? respondTime,
  }) {
    final mergedHeaders = <String, String>{...(headerMap ?? const {})};
    if (jsLib != null && jsLib.trim().isNotEmpty) {
      mergedHeaders[_ctxJsLibKey] = jsLib;
    }
    final effectiveSourceKey = (sourceKey ?? baseUrl ?? '').trim();
    if (effectiveSourceKey.isNotEmpty) {
      mergedHeaders[_ctxSourceKey] = effectiveSourceKey;
    }
    if (sourceVariable != null && sourceVariable.trim().isNotEmpty) {
      mergedHeaders[_ctxSourceVariable] = sourceVariable;
    }
    if (loginUrl != null && loginUrl.trim().isNotEmpty) {
      mergedHeaders[_ctxLoginUrl] = loginUrl;
    }
    _putContextJson(mergedHeaders, _ctxSourceVarsJson, sourceVariables);
    _putContextJson(mergedHeaders, _ctxSessionVarsJson, sessionVariables);
    _putContextJson(mergedHeaders, _ctxBookVarsJson, bookVariables);
    _putContextJson(mergedHeaders, _ctxChapterVarsJson, chapterVariables);
    _putContextJson(mergedHeaders, _ctxBookJson, book);
    _putContextJson(mergedHeaders, _ctxChapterJson, chapter);
    if (respondTime != null && respondTime > 0) {
      mergedHeaders[_ctxRespondTime] = respondTime.toString();
    }
    return mergedHeaders;
  }

  static void _putContextJson(
    Map<String, String> headers,
    String key,
    Map<String, Object?>? value,
  ) {
    if (value == null || value.isEmpty) return;
    final clean = <String, Object?>{};
    for (final entry in value.entries) {
      final k = entry.key.trim();
      if (k.isEmpty) continue;
      final v = entry.value;
      if (v == null) continue;
      clean[k] = v;
    }
    if (clean.isEmpty) return;
    headers[key] = jsonEncode(clean);
  }

  /// Check if URL analysis has error
  static bool hasError(AnalyzeUrlResult result) {
    return result.error != null;
  }

  /// Get error message
  static String? getError(AnalyzeUrlResult result) {
    return result.error;
  }

  /// 将 Rust 侧 JS 执行后的 cookieJar::* 变量同步回 Dart PersistCookieJar
  ///
  /// 解决 Rust ureq（java.ajax()）获取的 Cookie 与 Dart Dio 层隔离问题。
  /// 调用时机：每次 analyzeUrl() 之后，在发起 Dio 请求之前。
  static Future<void> syncVarsToCookieJar(AnalyzeUrlResult result) async {
    await syncUpdatedVarsToCookieJar(result.updatedVars);
  }

  static Future<void> syncFetchVarsToCookieJar(FetchUrlResult result) async {
    await syncUpdatedVarsToCookieJar(result.updatedVars);
  }

  static Future<void> syncUpdatedVarsToCookieJar(
    Map<String, String> updatedVars,
  ) async {
    for (final entry in updatedVars.entries) {
      if (!entry.key.startsWith(_cookieJarPrefix)) continue;
      final host = entry.key.substring(_cookieJarPrefix.length);
      final cookieStr = entry.value.trim();
      if (host.isEmpty || cookieStr.isEmpty) continue;

      final uri = Uri.tryParse('https://$host');
      if (uri == null) continue;

      final cookies = RequestHeaders.normalizeCookieHeaderValue(cookieStr)
          .split(';')
          .where((s) => s.contains('='))
          .map((s) {
            final eq = s.indexOf('=');
            final name = s.substring(0, eq).trim();
            final value = s.substring(eq + 1).trim();
            final cookie = io.Cookie(name, value);
            cookie.domain = host;
            cookie.path = '/';
            return cookie;
          })
          .where((c) => c.name.isNotEmpty)
          .toList();

      if (cookies.isNotEmpty) {
        try {
          await Http.instance.cookieJar.saveFromResponse(uri, cookies);
        } catch (_) {
          // cookieJar 未初始化（Web 平台）时忽略
        }
      }
    }
  }
}

class _LooseJsonParser {
  _LooseJsonParser(this.input);

  final String input;
  int _pos = 0;

  Object? parse() {
    try {
      final value = _parseValue();
      _skipWhitespaceAndComments();
      return _eof ? value : null;
    } catch (_) {
      return null;
    }
  }

  bool get _eof => _pos >= input.length;

  int? get _peek => _eof ? null : input.codeUnitAt(_pos);

  Object? _parseValue() {
    _skipWhitespaceAndComments();
    final ch = _peek;
    if (ch == null) {
      throw const FormatException('unexpected end');
    }
    if (ch == _leftBrace) return _parseObject();
    if (ch == _leftBracket) return _parseArray();
    if (ch == _singleQuote || ch == _doubleQuote) return _parseString();
    return _parseBareValue();
  }

  Map<String, Object?> _parseObject() {
    _expect(_leftBrace);
    final object = <String, Object?>{};

    while (true) {
      _skipWhitespaceAndComments();
      if (_consume(_rightBrace)) break;

      final key = _parseKey();
      _skipWhitespaceAndComments();
      _expect(_colon);
      object[key] = _parseValue();

      _skipWhitespaceAndComments();
      if (_consume(_comma)) continue;
      _expect(_rightBrace);
      break;
    }

    return object;
  }

  List<Object?> _parseArray() {
    _expect(_leftBracket);
    final array = <Object?>[];

    while (true) {
      _skipWhitespaceAndComments();
      if (_consume(_rightBracket)) break;

      array.add(_parseValue());

      _skipWhitespaceAndComments();
      if (_consume(_comma)) continue;
      _expect(_rightBracket);
      break;
    }

    return array;
  }

  String _parseKey() {
    _skipWhitespaceAndComments();
    final ch = _peek;
    if (ch == _singleQuote || ch == _doubleQuote) {
      return _parseString();
    }

    final start = _pos;
    while (!_eof) {
      final ch = _peek!;
      if (ch == _colon) break;
      if (ch == _comma ||
          ch == _leftBrace ||
          ch == _rightBrace ||
          ch == _leftBracket ||
          ch == _rightBracket) {
        throw const FormatException('invalid object key');
      }
      _pos++;
    }

    final key = input.substring(start, _pos).trim();
    if (key.isEmpty) {
      throw const FormatException('empty object key');
    }
    return key;
  }

  String _parseString() {
    final quote = _peek;
    if (quote != _singleQuote && quote != _doubleQuote) {
      throw const FormatException('expected string');
    }
    _pos++;
    final out = StringBuffer();

    while (!_eof) {
      final ch = input.codeUnitAt(_pos++);
      if (ch == quote) return out.toString();

      if (ch == _backslash) {
        out.write(_parseEscape());
      } else {
        out.writeCharCode(ch);
      }
    }

    throw const FormatException('unterminated string');
  }

  String _parseEscape() {
    if (_eof) throw const FormatException('bad escape');
    final ch = input.codeUnitAt(_pos++);
    switch (ch) {
      case _doubleQuote:
        return '"';
      case _singleQuote:
        return "'";
      case _backslash:
        return r'\';
      case _slash:
        return '/';
      case _b:
        return '\b';
      case _f:
        return '\f';
      case _n:
        return '\n';
      case _r:
        return '\r';
      case _t:
        return '\t';
      case _u:
        return _parseUnicodeEscape();
      case _lineFeed:
        return '\n';
      case _carriageReturn:
        if (_peek == _lineFeed) _pos++;
        return '\n';
      default:
        return String.fromCharCode(ch);
    }
  }

  String _parseUnicodeEscape() {
    final code = _parseHex4();
    if (code >= 0xD800 && code <= 0xDBFF) {
      final checkpoint = _pos;
      if (_consume(_backslash) && _consume(_u)) {
        final low = _parseHex4();
        if (low >= 0xDC00 && low <= 0xDFFF) {
          final combined = 0x10000 + ((code - 0xD800) << 10) + (low - 0xDC00);
          return String.fromCharCode(combined);
        }
      }
      _pos = checkpoint;
      return String.fromCharCode(0xFFFD);
    }
    if (code >= 0xDC00 && code <= 0xDFFF) {
      return String.fromCharCode(0xFFFD);
    }
    return String.fromCharCode(code);
  }

  int _parseHex4() {
    if (_pos + 4 > input.length) {
      throw const FormatException('bad unicode escape');
    }
    var code = 0;
    for (var i = 0; i < 4; i++) {
      final digit = int.tryParse(input[_pos++], radix: 16);
      if (digit == null) {
        throw const FormatException('bad unicode escape');
      }
      code = (code << 4) | digit;
    }
    return code;
  }

  Object? _parseBareValue() {
    final start = _pos;
    while (!_eof) {
      final ch = _peek!;
      if (ch == _comma || ch == _rightBrace || ch == _rightBracket) break;
      _pos++;
    }

    final raw = input.substring(start, _pos).trim();
    if (raw.isEmpty) {
      throw const FormatException('empty value');
    }

    if (raw == 'true') return true;
    if (raw == 'false') return false;
    if (raw == 'null') return null;
    return num.tryParse(raw) ?? raw.replaceAll(RegExp(r'''^['"]|['"]$'''), '');
  }

  void _skipWhitespaceAndComments() {
    while (true) {
      while (!_eof && _isWhitespace(_peek!)) {
        _pos++;
      }

      if (input.startsWith('//', _pos)) {
        _pos += 2;
        while (!_eof) {
          final ch = input.codeUnitAt(_pos++);
          if (ch == _lineFeed || ch == _carriageReturn) break;
        }
        continue;
      }

      if (input.startsWith('/*', _pos)) {
        _pos += 2;
        while (!_eof) {
          if (input.startsWith('*/', _pos)) {
            _pos += 2;
            break;
          }
          _pos++;
        }
        continue;
      }

      break;
    }
  }

  bool _consume(int expected) {
    if (_peek == expected) {
      _pos++;
      return true;
    }
    return false;
  }

  void _expect(int expected) {
    if (!_consume(expected)) {
      throw const FormatException('unexpected token');
    }
  }

  bool _isWhitespace(int ch) =>
      ch == 0x20 || ch == _lineFeed || ch == _carriageReturn || ch == 0x09;

  static const _leftBrace = 0x7B;
  static const _rightBrace = 0x7D;
  static const _leftBracket = 0x5B;
  static const _rightBracket = 0x5D;
  static const _colon = 0x3A;
  static const _comma = 0x2C;
  static const _singleQuote = 0x27;
  static const _doubleQuote = 0x22;
  static const _backslash = 0x5C;
  static const _slash = 0x2F;
  static const _lineFeed = 0x0A;
  static const _carriageReturn = 0x0D;
  static const _b = 0x62;
  static const _f = 0x66;
  static const _n = 0x6E;
  static const _r = 0x72;
  static const _t = 0x74;
  static const _u = 0x75;
}
