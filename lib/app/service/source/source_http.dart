import 'dart:convert';
import 'dart:collection';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:reader_nover/app/database/drift/app_database.dart' as db;
import 'package:reader_nover/app/net/request_headers.dart';
import 'package:reader_nover/app/net/webview_service.dart';
import 'package:reader_nover/util/http_cache_manager.dart';
import 'package:reader_nover/util/log_utils.dart';
import 'source_check_policy.dart';
import 'source_rate_limiter.dart';
import 'source_login_service.dart';
import 'source_ui_bridge.dart';
import 'source_variable_store.dart';
import 'package:reader_nover/app/database/models/models.dart'
    show BookChapterInfo;
import 'package:reader_nover/rust/api/analyze_url.dart';
import 'package:reader_nover/rust/api/rule_engine.dart' hide BookInfo;
import 'package:reader_nover/rust/entities/rules.dart';
import 'package:reader_nover/util/analyze_url_utils.dart';

class SourceWebViewPendingRequest {
  const SourceWebViewPendingRequest({
    required this.method,
    required this.responseKey,
    this.requestKey,
    this.url = '',
    this.html,
    this.webJs,
    this.sourceRegex,
    this.overrideUrlRegex,
    this.headers,
    this.sourceKey,
    this.delayTime = 1000,
  });

  final String method;
  final String responseKey;
  final String? requestKey;
  final String url;
  final String? html;
  final String? webJs;
  final String? sourceRegex;
  final String? overrideUrlRegex;
  final Map<String, String>? headers;
  final String? sourceKey;

  /// Page settle delay after load (ms). Aligns with URL option `webViewDelayTime`.
  final int delayTime;

  static SourceWebViewPendingRequest? tryParse(Map<String, String> request) {
    final method = request['method']?.trim() ?? '';
    if (!_supportedMethods.contains(method)) return null;

    final responseKey = _nullIfEmpty(request['responseKey']);
    if (responseKey == null) return null;

    final sourceRegex = _nullIfEmpty(request['sourceRegex']) ??
        (method == 'webViewGetSource'
            ? _nullIfEmpty(request['pattern'])
            : null);
    final overrideUrlRegex = _nullIfEmpty(request['overrideUrlRegex']) ??
        (method == 'webViewGetOverrideUrl'
            ? _nullIfEmpty(request['pattern'])
            : null);

    return SourceWebViewPendingRequest(
      method: method,
      responseKey: responseKey,
      requestKey: _nullIfEmpty(request['requestKey']),
      url: _nullIfEmpty(request['url']) ?? '',
      html: _nullIfEmpty(request['html']),
      webJs: _nullIfEmpty(request['webJs']) ?? _nullIfEmpty(request['js']),
      sourceRegex: sourceRegex,
      overrideUrlRegex: overrideUrlRegex,
      headers: SourceHttp._decodeStringObject(request['headers']),
      sourceKey: _nullIfEmpty(request['sourceKey']),
      delayTime: _parseDelayTimeMs(request),
    );
  }

  static int _parseDelayTimeMs(Map<String, String> request) {
    for (final key in const [
      'delayTime',
      'webViewDelayTime',
      'delay',
    ]) {
      final raw = request[key]?.trim();
      if (raw == null || raw.isEmpty) continue;
      final n = int.tryParse(raw);
      if (n != null && n >= 0) return n.clamp(0, 120000);
    }
    return 1000;
  }

  static const Set<String> _supportedMethods = {
    'webView',
    'webViewGetSource',
    'webViewGetOverrideUrl',
  };
}

/// 书源 HTTP 请求基础设施。
///
/// 提供统一的网络请求、RuleEngine 创建、请求头构建等共享能力，
/// 供 [WebSearchService]、[WebBookDetailService]、[WebContentService] 使用。
class SourceHttp {
  SourceHttp._();

  static const int _maxBookRuleVarEntries = 256;
  static const int _maxChapterRuleVarEntries = 2048;
  static final LinkedHashMap<String, Map<String, String>> _bookRuleVars =
      LinkedHashMap<String, Map<String, String>>();
  static final LinkedHashMap<String, _ChapterRuleVariableEntry>
      _chapterRuleVars = LinkedHashMap<String, _ChapterRuleVariableEntry>();
  static final LinkedHashMap<String, _ChapterRuleVariableEntry>
      _chapterRuleVarsById = LinkedHashMap<String, _ChapterRuleVariableEntry>();
  static const String _sourceVariableKey = '__reader_source_variable';
  static const String _cachePrefix = '__reader_cache::';
  static const String _cacheDeadlinePrefix = '__reader_cache_deadline::';
  static const String _cacheMemoryPrefix = '__reader_cache_memory::';
  static const String _cacheFilePrefix = '__reader_cache_file::';
  static const String _cacheFileDeadlinePrefix =
      '__reader_cache_file_deadline::';
  static const String _webViewRequestKey = '__reader_webview_request';
  static const String _httpRequestKey = '__reader_http_request';
  static const String _fileDownloadRequestKey =
      '__reader_file_download_request';

  /// When set on RuleEngine, JS `java.ajax/post/get/connect` prefers the Dart
  /// SourceHttp pending bridge (CookieJar / cert / timeout alignment).
  static const String preferPlatformHttpKey = '__reader_prefer_platform_http';

  /// 统一准备请求上下文（请求头 + URL 解析结果）。
  static Future<PreparedSourceRequest> prepareRequest({
    required db.BookSource source,
    required String url,
    Map<String, String>? sourceHeaders,
    String? baseUrl,
    String? key,
    int? page,
    BookChapterInfo? chapter,
  }) async {
    final headers = sourceHeaders ?? await buildSourceHeaders(source);
    final rawSourceVariable = await SourceVariableStore.get(
      source.bookSourceUrl,
      sourceUrl: source.bookSourceUrl,
      preferCookieJar: source.enabledCookieJar == true,
      allowCookieJarFallback: source.enabledCookieJar == true,
    );
    final sourceVariable =
        _normalizeSourceVariableForRules(source, rawSourceVariable);
    final requiresJsonSourceVariable =
        _sourceRulesRequireJsonSourceVariable(source);
    if (rawSourceVariable.trim().isNotEmpty &&
        sourceVariable.isEmpty &&
        requiresJsonSourceVariable) {
      await SourceVariableStore.set(source.bookSourceUrl, '');
    }
    final fallbackSourceVariable =
        source.enabledCookieJar == true && !requiresJsonSourceVariable
            ? cookieHeaderFromHeaders(headers)
            : '';
    final contextVariables = _buildAnalyzeUrlContextVariables(
      source: source,
      url: url,
      baseUrl: baseUrl,
      key: key,
      page: page,
      sourceVariable:
          sourceVariable.isNotEmpty ? sourceVariable : fallbackSourceVariable,
      chapter: chapter,
    );
    await _mergePersistedBookVarsIntoContext(
      source: source,
      url: url,
      baseUrl: baseUrl,
      chapter: chapter,
      context: contextVariables,
    );
    final effectiveBaseUrl = (baseUrl?.trim().isNotEmpty == true)
        ? baseUrl!.trim()
        : source.bookSourceUrl;
    final analyzeRequest = AnalyzeUrlUtils.buildAnalyzeRequest(
      url: url,
      baseUrl: effectiveBaseUrl,
      key: key,
      page: page,
      headerMap: headers,
      jsLib: source.jsLib,
      sourceKey: source.bookSourceUrl,
      sourceVariable:
          sourceVariable.isNotEmpty ? sourceVariable : fallbackSourceVariable,
      loginUrl: source.loginUrl,
      sourceVariables: contextVariables.sourceVariables,
      sessionVariables: contextVariables.sessionVariables,
      bookVariables: contextVariables.bookVariables,
      chapterVariables: contextVariables.chapterVariables,
      book: contextVariables.book,
      chapter: contextVariables.chapter,
      respondTime: source.respondTime,
    );
    final fetchRequest = AnalyzeUrlUtils.buildFetchRequest(
      url: url,
      baseUrl: effectiveBaseUrl,
      key: key,
      page: page,
      headerMap: headers,
      jsLib: source.jsLib,
      sourceKey: source.bookSourceUrl,
      sourceVariable:
          sourceVariable.isNotEmpty ? sourceVariable : fallbackSourceVariable,
      loginUrl: source.loginUrl,
      sourceVariables: contextVariables.sourceVariables,
      sessionVariables: contextVariables.sessionVariables,
      bookVariables: contextVariables.bookVariables,
      chapterVariables: contextVariables.chapterVariables,
      book: contextVariables.book,
      chapter: contextVariables.chapter,
      respondTime: source.respondTime,
    );
    final urlResult = analyzeUrl(req: analyzeRequest);
    await AnalyzeUrlUtils.syncVarsToCookieJar(urlResult);
    await syncUrlVariablesToSourceStore(source, urlResult);

    return PreparedSourceRequest(
      sourceHeaders: headers,
      urlResult: urlResult,
      fetchRequest: fetchRequest,
      url: urlResult.url,
    );
  }

  /// 统一的网络请求（支持 HTTP 和 WebView）
  ///
  /// [respondTime] 书源超时毫秒数，null 时使用默认值
  /// [concurrentRate] 书源限速配置，格式 "N,ms"
  /// [overrideWebJs] ContentRule.webJs 回退值（URL 自身未指定 webJs 时使用）
  /// [sourceRegex] ContentRule.sourceRegex，WebView 资源嗅探正则
  static Future<FetchedPage> fetchHtml({
    required String url,
    required AnalyzeUrlResult urlResult,
    FetchUrlRequest? fetchRequest,
    String? sourceKey,
    CancelToken? cancelToken,
    int? respondTime,
    String? concurrentRate,
    String? overrideWebJs,
    String? sourceRegex,
    HttpCacheScene? cacheScene,
    HttpCachePolicy? cachePolicy,
    bool syncCookieToSourceVariable = false,
  }) async {
    final dataUrlDecoded = _tryDecodeDataUrl(url);
    if (dataUrlDecoded != null) {
      return FetchedPage(html: dataUrlDecoded, finalUrl: url);
    }

    await SourceRateLimiter.acquire(sourceKey ?? '', concurrentRate);

    final urlTimeout = _urlOptionInt(urlResult, '__reader_url_timeout');
    final receiveMs = (urlTimeout ?? respondTime ?? 180000).clamp(5000, 600000);
    final receiveTimeout = Duration(milliseconds: receiveMs);

    if (urlResult.useWebview) {
      _throwIfCancelled(cancelToken);
      final requestHeaders = RequestHeaders.build(urlResult.headers);
      final rustRequest = fetchRequest == null
          ? FetchUrlRequest(
              url: url,
              baseUrl: null,
              page: null,
              key: null,
              headerMap: requestHeaders,
              binaryAsHex: false,
            )
          : AnalyzeUrlUtils.copyFetchRequest(
              fetchRequest,
              binaryAsHex: false,
            );
      final rustResult = await AnalyzeUrlUtils.fetchRequest(rustRequest)
          .timeout(receiveTimeout + const Duration(seconds: 10));
      await AnalyzeUrlUtils.syncFetchVarsToCookieJar(rustResult);
      _throwIfCancelled(cancelToken);
      final webViewRequest = rustResult.webviewRequest;
      if (webViewRequest == null) {
        final message =
            rustResult.error ?? 'Rust 未返回 WebView 请求描述: ${rustResult.url}';
        throw DioException(
          requestOptions: RequestOptions(path: url),
          error: message,
        );
      }
      final effectiveWebJs = (webViewRequest.webjs?.isNotEmpty == true)
          ? webViewRequest.webjs
          : overrideWebJs;
      final effectiveSourceRegex =
          (sourceRegex?.trim().isNotEmpty == true) ? sourceRegex : null;
      final html = await WebViewService.fetch(
        url: webViewRequest.url,
        headers:
            webViewRequest.headers.isNotEmpty ? webViewRequest.headers : null,
        webJs: effectiveWebJs,
        method: webViewRequest.method,
        body: webViewRequest.body,
        sourceRegex: effectiveSourceRegex,
        delayTime: webViewRequest.webviewDelayTime > 0
            ? webViewRequest.webviewDelayTime
            : 1000,
        sourceKey: syncCookieToSourceVariable ? sourceKey : null,
        timeout: receiveMs,
      );
      return FetchedPage(html: html, finalUrl: webViewRequest.url);
    } else {
      _throwIfCancelled(cancelToken);
      final requestMethod = urlResult.method.toUpperCase();
      final requestData = requestMethod == 'GET' ? null : urlResult.body;
      final requestHeaders = RequestHeaders.build(urlResult.headers);
      final requestType = urlResult.updatedVars['__reader_url_type'];
      final binaryResponse = _isBinaryResponseType(requestType);
      final rustRequest = fetchRequest == null
          ? FetchUrlRequest(
              url: url,
              baseUrl: null,
              page: null,
              key: null,
              headerMap: requestHeaders,
              binaryAsHex: binaryResponse,
            )
          : AnalyzeUrlUtils.copyFetchRequest(
              fetchRequest,
              binaryAsHex: binaryResponse,
            );

      final options = Options(
        method: requestMethod,
        headers: requestHeaders,
        responseType: ResponseType.plain,
      );

      final response = await HttpCacheManager.request(
        () => _fetchViaRust(
          request: rustRequest,
          displayUrl: url,
          options: options,
        ),
        url: url,
        requestData: requestData,
        options: options,
        cacheScene: cacheScene,
        cachePolicy: cachePolicy,
      ).timeout(receiveTimeout + const Duration(seconds: 10));
      _throwIfCancelled(cancelToken);

      final status = response.statusCode ?? 0;
      // Align with Legado: do not hard-fail on HTTP 4xx/5xx. Some book sources use
      // placeholder URLs (e.g. baidu.com) only to carry params; the real request is
      // issued later in list/content JS via java.ajax. Throwing here aborts parsing.
      if (status >= 400) {
        LogUtils.w(
          'HTTP $status，仍继续规则解析 (Legado 兼容): url=$url',
        );
      }
      // Prefer original request URL on error so carrier-path params are not lost
      // if the site redirects to a generic error page.
      final responseUrl = status >= 400
          ? url
          : (response.realUri.toString().isNotEmpty
              ? response.realUri.toString()
              : url);
      if ((sourceKey ?? '').trim().isNotEmpty && syncCookieToSourceVariable) {
        await SourceVariableStore.syncFromCookieJar(sourceKey!, responseUrl);
      }
      return FetchedPage(
        html: response.data?.toString() ?? '',
        finalUrl: responseUrl,
      );
    }
  }

  /// 使用已准备好的请求上下文抓取页面，可选执行登录校验。
  static Future<FetchedPage> fetchPreparedPage({
    required db.BookSource source,
    required PreparedSourceRequest request,
    CancelToken? cancelToken,
    RuleEngine? engine,
    bool shouldRunLoginCheck = true,
    String? overrideWebJs,
    String? sourceRegex,
    HttpCacheScene? cacheScene,
    HttpCachePolicy? cachePolicy,
  }) async {
    var fetchResult = await fetchHtml(
      url: request.url,
      urlResult: request.urlResult,
      fetchRequest: request.fetchRequest,
      sourceKey: source.bookSourceUrl,
      cancelToken: cancelToken,
      respondTime: source.respondTime,
      concurrentRate: source.concurrentRate,
      overrideWebJs: overrideWebJs,
      sourceRegex: sourceRegex,
      cacheScene: cacheScene,
      cachePolicy: cachePolicy,
      syncCookieToSourceVariable: source.enabledCookieJar == true,
    );

    if (!shouldRunLoginCheck) {
      return fetchResult;
    }

    final loginEngine = engine ??
        await newRuleEngine(source, sourceHeaders: request.sourceHeaders);
    fetchResult = await runLoginCheck(
      engine: loginEngine,
      page: fetchResult,
      sourceId: source.id,
      sourceKey: source.bookSourceUrl,
      sourceName: source.bookSourceName,
      loginCheckJs: source.loginCheckJs,
      loginUrl: source.loginUrl,
      loginUi: source.loginUi,
    );
    await persistRuleEngineVariables(source, loginEngine);
    return fetchResult;
  }

  static Future<Response<String>> _fetchViaRust({
    required FetchUrlRequest request,
    required String displayUrl,
    required Options options,
  }) async {
    final result = await AnalyzeUrlUtils.fetchRequest(request);
    await AnalyzeUrlUtils.syncFetchVarsToCookieJar(result);
    if (result.error != null && (result.status <= 0 || result.body.isEmpty)) {
      throw DioException(
        requestOptions: RequestOptions(path: displayUrl),
        error: result.error,
      );
    }

    return Response<String>(
      requestOptions: RequestOptions(
        path: result.url.trim().isNotEmpty ? result.url : displayUrl,
        method: options.method,
        headers: options.headers,
        responseType: options.responseType,
        extra: options.extra,
      ),
      data: result.body,
      statusCode: result.status,
      headers: _dioHeadersFromRust(result.headers),
      isRedirect: false,
      redirects: const [],
      extra: <String, dynamic>{
        ...?options.extra,
        'updatedVars': result.updatedVars,
      },
    );
  }

  static void _throwIfCancelled(CancelToken? cancelToken) {
    if (cancelToken?.isCancelled != true) return;
    throw cancelToken!.cancelError ??
        DioException.requestCancelled(
          requestOptions: RequestOptions(),
          reason: 'cancelled',
        );
  }

  static Headers _dioHeadersFromRust(Map<String, List<String>> headers) {
    final out = Headers();
    for (final entry in headers.entries) {
      final name = entry.key.trim();
      if (name.isEmpty) continue;
      out.set(name, entry.value);
    }
    return out;
  }

  /// 创建并配置 RuleEngine 实例。
  ///
  /// [bookUrl] 非空时注入该书记的 `book.putVariable` 持久化值，并写入
  /// `bookUrl` 便于后续 snapshot/persist 关联。
  static Future<RuleEngine> newRuleEngine(
    db.BookSource source, {
    Map<String, String>? sourceHeaders,
    String? bookUrl,
  }) async {
    final engine = await RuleEngine.newInstance();
    final headers = sourceHeaders ?? await buildSourceHeaders(source);
    await engine.setSourceHeadersJson(
      headerJson: jsonEncode(headers),
    );
    await engine.setJsLib(lib: source.jsLib);
    await engine.setSourceVar(
        key: '__reader_source_key', value: source.bookSourceUrl);
    // Prefer Dart SourceHttp for java.ajax so CookieJar / cert / timeout match
    // top-level search requests. Pure Rust tests leave this unset and keep ureq.
    await engine.setSourceVar(key: preferPlatformHttpKey, value: '1');
    await _syncPersistentVariablesToRuleEngine(
      engine,
      source.bookSourceUrl,
      bookUrl: bookUrl,
    );
    final cookieHeader = headers.entries
        .firstWhere(
          (e) => e.key.toLowerCase() == 'cookie',
          orElse: () => const MapEntry('', ''),
        )
        .value;
    final rawSourceVariable = await SourceVariableStore.get(
      source.bookSourceUrl,
      sourceUrl: source.bookSourceUrl,
      preferCookieJar: source.enabledCookieJar == true,
      allowCookieJarFallback: source.enabledCookieJar == true,
    );
    final sourceVariable =
        _normalizeSourceVariableForRules(source, rawSourceVariable);
    final requiresJsonSourceVariable =
        _sourceRulesRequireJsonSourceVariable(source);
    if (rawSourceVariable.trim().isNotEmpty &&
        sourceVariable.isEmpty &&
        requiresJsonSourceVariable) {
      await SourceVariableStore.set(source.bookSourceUrl, '');
    }
    final effectiveSourceVariable = sourceVariable.isNotEmpty
        ? sourceVariable
        : (source.enabledCookieJar == true && !requiresJsonSourceVariable
            ? cookieHeader
            : '');
    if (source.bookSourceUrl.trim().isNotEmpty &&
        effectiveSourceVariable.isNotEmpty) {
      await SourceVariableStore.set(
        source.bookSourceUrl,
        effectiveSourceVariable,
      );
    }
    await engine.setSourceVar(
      key: '__reader_source_variable',
      value: effectiveSourceVariable,
    );
    final rawRespondTimeMs = source.respondTime ?? 180000;
    final respondTimeMs = rawRespondTimeMs <= 0 ? 180000 : rawRespondTimeMs;
    await engine.setSourceVar(
      key: '__reader_respond_time',
      value: respondTimeMs.toString(),
    );
    return engine;
  }

  /// Sync variables written by AnalyzeUrl JS (for example `java.put`) into
  /// the RuleEngine used by subsequent rules.
  static Future<void> syncUrlVariablesToRuleEngine(
    RuleEngine engine,
    AnalyzeUrlResult urlResult,
  ) async {
    for (final entry in urlResult.updatedVars.entries) {
      final key = entry.key.trim();
      if (key.isEmpty) continue;
      await engine.setSourceVar(key: key, value: entry.value);
    }
  }

  static Future<void> syncUrlVariablesToSourceStore(
    db.BookSource source,
    AnalyzeUrlResult urlResult,
  ) async {
    final value = urlResult.updatedVars['__reader_source_variable']?.trim();
    await persistRuleVariables(source, urlResult.updatedVars);
    if (value == null || value.isEmpty || source.bookSourceUrl.trim().isEmpty) {
      return;
    }
    await SourceVariableStore.set(source.bookSourceUrl, value);
  }

  static Future<void> persistRuleEngineVariables(
    db.BookSource source,
    RuleEngine engine,
  ) async {
    final variables = await snapshotRuleVariables(engine);
    await persistRuleVariables(source, variables);
  }

  static Future<void> persistRuleVariables(
    db.BookSource source,
    Map<String, String> variables,
  ) async {
    await persistRuleVariablesForTesting(
      sourceKey: source.bookSourceUrl,
      variables: variables,
    );
  }

  @visibleForTesting
  static Future<void> persistRuleVariablesForTesting({
    required String sourceKey,
    required Map<String, String> variables,
  }) async {
    final normalizedSourceKey = sourceKey.trim();
    if (normalizedSourceKey.isEmpty || variables.isEmpty) return;

    final sourceEntries = <String, String>{};
    final caches = <String, String>{};
    final cacheDeadlines = <String, String>{};
    final fileCaches = <String, String>{};
    final fileCacheDeadlines = <String, String>{};
    final bookVarScopeUrl = _bookUrlFromVariables(variables);

    for (final entry in variables.entries) {
      final key = entry.key.trim();
      if (key.isEmpty) continue;
      final value = entry.value;
      if (key == _sourceVariableKey) {
        await SourceVariableStore.set(normalizedSourceKey, value);
      } else if (key.startsWith(_bookVarPrefix)) {
        // book.putVariable → per-book store (not source entry whitelist).
        if (bookVarScopeUrl == null) continue;
        final shortKey = key.substring(_bookVarPrefix.length).trim();
        if (shortKey.isEmpty) continue;
        await SourceVariableStore.setBookVar(
          normalizedSourceKey,
          bookVarScopeUrl,
          shortKey,
          value,
        );
      } else if (key == SourceLoginService.sourceLoginHeaderKey ||
          key == SourceLoginService.sourceLoginInfoKey ||
          key.startsWith('loginHeader_') ||
          key.startsWith('userInfo_')) {
        sourceEntries[key] = value;
      } else if (key.startsWith(_cacheFileDeadlinePrefix)) {
        fileCacheDeadlines[key.substring(_cacheFileDeadlinePrefix.length)] =
            value;
      } else if (key.startsWith(_cacheFilePrefix)) {
        fileCaches[key.substring(_cacheFilePrefix.length)] = value;
      } else if (key.startsWith(_cacheMemoryPrefix)) {
        continue;
      } else if (key.startsWith(_cacheDeadlinePrefix)) {
        cacheDeadlines[key.substring(_cacheDeadlinePrefix.length)] = value;
      } else if (key.startsWith(_cachePrefix)) {
        caches[key.substring(_cachePrefix.length)] = value;
      } else if (_isPersistentSourceEntryKey(key)) {
        sourceEntries[key] = value;
      }
    }

    // Legado CacheManager: put stores v_{sourceKey}_{key}; get(short) reads it.
    // Dual-write both forms so disk + reload short-key get stay aligned.
    _expandLegadoSourcePutDualWrite(normalizedSourceKey, sourceEntries);

    await SourceVariableStore.setEntries(normalizedSourceKey, sourceEntries);
    await SourceVariableStore.setCaches(normalizedSourceKey, caches);
    await SourceVariableStore.setCacheDeadlines(
      normalizedSourceKey,
      cacheDeadlines,
    );
    await SourceVariableStore.setFileCaches(normalizedSourceKey, fileCaches);
    await SourceVariableStore.setFileCacheDeadlines(
      normalizedSourceKey,
      fileCacheDeadlines,
    );
  }

  /// Resolve book scope URL for `book.putVariable` persistence.
  /// Prefer `bookUrl`, fall back to `tocUrl`. Returns null when absent.
  static String? _bookUrlFromVariables(Map<String, String> variables) {
    final bookUrl = variables['bookUrl']?.trim() ?? '';
    if (bookUrl.isNotEmpty) return bookUrl;
    final tocUrl = variables['tocUrl']?.trim() ?? '';
    if (tocUrl.isNotEmpty) return tocUrl;
    return null;
  }

  /// Expand source.put entries so short, `v_{sourceKey}_{key}`, and
  /// `__reader_source_kv::{key}` forms are present (Legado CacheManager scope).
  static void _expandLegadoSourcePutDualWrite(
    String sourceKey,
    Map<String, String> sourceEntries,
  ) {
    if (sourceKey.isEmpty || sourceEntries.isEmpty) return;

    final prefix = 'v_${sourceKey}_';
    const markerPrefix = _sourceKvPrefix;
    final additions = <String, String>{};

    for (final entry in sourceEntries.entries) {
      final key = entry.key;
      final value = entry.value;

      // Skip login / other system keys — not CacheManager source.put keys.
      if (key.startsWith('__reader_') && !key.startsWith(markerPrefix)) {
        continue;
      }
      if (key.startsWith('loginHeader_') || key.startsWith('userInfo_')) {
        continue;
      }

      if (key.startsWith(markerPrefix)) {
        final shortKey = key.substring(markerPrefix.length);
        if (shortKey.isEmpty) continue;
        additions.putIfAbsent(shortKey, () => value);
        additions.putIfAbsent('$prefix$shortKey', () => value);
      } else if (key.startsWith(prefix)) {
        final shortKey = key.substring(prefix.length);
        if (shortKey.isEmpty) continue;
        additions.putIfAbsent(shortKey, () => value);
        additions.putIfAbsent('$markerPrefix$shortKey', () => value);
      }
      // Bare short keys are no longer accepted by the persist whitelist
      // (java.put session pool). Do not expand them into source entries.
    }

    for (final entry in additions.entries) {
      sourceEntries.putIfAbsent(entry.key, () => entry.value);
    }
  }

  /// Resolve stored source entries the same way reload injects them into the
  /// rule engine: every entry plus short keys derived from `v_{sourceKey}_*`
  /// and `__reader_source_kv::*`.
  @visibleForTesting
  static Map<String, String> resolveSourceEntriesForGetForTesting(
    String sourceKey,
    Map<String, String> entries,
  ) {
    final key = sourceKey.trim();
    if (key.isEmpty) return Map<String, String>.from(entries);

    final resolved = Map<String, String>.from(entries);
    final namespacedPrefix = 'v_${key}_';
    for (final entry in entries.entries) {
      if (entry.key.startsWith(namespacedPrefix)) {
        final shortKey = entry.key.substring(namespacedPrefix.length);
        if (shortKey.isEmpty) continue;
        // Namespaced form is CacheManager source of truth for source.get(short).
        resolved[shortKey] = entry.value;
        resolved['$_sourceKvPrefix$shortKey'] = entry.value;
      } else if (entry.key.startsWith(_sourceKvPrefix)) {
        final shortKey = entry.key.substring(_sourceKvPrefix.length);
        if (shortKey.isEmpty) continue;
        resolved[shortKey] = entry.value;
        resolved['$namespacedPrefix$shortKey'] = entry.value;
      }
    }
    return resolved;
  }

  /// Whitelist of keys that may be persisted as source entries.
  ///
  /// Aligns with Legado: only CacheManager `source.put` keys (`v_*`) and our
  /// marker prefix. Bare short keys are `java.put` session vars and must not
  /// land on disk as source entries.
  static bool _isPersistentSourceEntryKey(String key) {
    if (key.startsWith('v_')) return true;
    if (key.startsWith(_sourceKvPrefix)) return true;
    return false;
  }

  /// Marker written by Rust `source.put` alongside `v_{sourceKey}_{key}`.
  static const String _sourceKvPrefix = '__reader_source_kv::';

  /// Written by Rust `book.putVariable` via `java.put('__reader_book_var::'+k)`.
  static const String _bookVarPrefix = '__reader_book_var::';

  static Future<void> syncVariablesToRuleEngine(
    RuleEngine engine,
    Map<String, String>? variables,
  ) async {
    if (variables == null || variables.isEmpty) return;
    for (final entry in variables.entries) {
      final key = entry.key.trim();
      if (key.isEmpty) continue;
      await engine.setSourceVar(key: key, value: entry.value);
      await engine.setBookVar(key: key, value: entry.value);
    }
    // Re-inject disk book vars for this book after context sync.
    await _maybeInjectPersistedBookVariables(engine, variables);
  }

  static Future<void> _maybeInjectPersistedBookVariables(
    RuleEngine engine,
    Map<String, String> variables,
  ) async {
    final bookUrl = _bookUrlFromVariables(variables);
    if (bookUrl == null) return;

    var sourceKey = variables['__reader_source_key']?.trim() ??
        variables['bookSourceUrl']?.trim() ??
        variables['sourceUrl']?.trim() ??
        '';
    if (sourceKey.isEmpty) {
      sourceKey = (await engine.getVariable(key: '__reader_source_key')).trim();
    }
    if (sourceKey.isEmpty) return;
    await _injectPersistedBookVariables(engine, sourceKey, bookUrl);
  }

  static Future<Map<String, String>> snapshotRuleVariables(
    RuleEngine engine,
  ) async {
    final sourceVars = await engine.snapshotSourceVars();
    final sessionVars = await engine.snapshotSessionVars();
    return <String, String>{...sourceVars, ...sessionVars};
  }

  static Future<T> runWithWebViewBridge<T>({
    required db.BookSource source,
    required RuleEngine engine,
    required Future<T> Function() parse,
    Map<String, String>? sourceHeaders,
    CancelToken? cancelToken,
    int maxPasses = 8,
  }) async {
    try {
      T result = await parse();
      var passes = 0;
      while (passes < maxPasses) {
        _throwIfCancelled(cancelToken);
        final webViewHandled = await _resolvePendingWebViewRequest(
          source: source,
          engine: engine,
          sourceHeaders: sourceHeaders,
        );
        final uiHandled = !webViewHandled &&
            await SourceUiBridge.resolvePendingRequest(
              source: source,
              engine: engine,
              variables: await snapshotRuleVariables(engine),
            );
        final fileDownloadHandled = !webViewHandled &&
            !uiHandled &&
            await _resolvePendingFileDownloadRequest(
              source: source,
              engine: engine,
              sourceHeaders: sourceHeaders,
              cancelToken: cancelToken,
            );
        final httpHandled = !webViewHandled &&
            !uiHandled &&
            !fileDownloadHandled &&
            await _resolvePendingHttpRequest(
              source: source,
              engine: engine,
              sourceHeaders: sourceHeaders,
              cancelToken: cancelToken,
            );
        final handled =
            webViewHandled || uiHandled || fileDownloadHandled || httpHandled;
        if (!handled) break;
        result = await parse();
        passes++;
      }
      return result;
    } finally {
      await _syncEngineCookiesToJar(source, engine);
    }
  }

  /// Flush `cookieJar::*` / source variable cookies from RuleEngine to
  /// PersistCookieJar so the next search/detail request reuses them.
  static Future<void> _syncEngineCookiesToJar(
    db.BookSource source,
    RuleEngine engine,
  ) async {
    try {
      final variables = await snapshotRuleVariables(engine);
      await AnalyzeUrlUtils.syncUpdatedVarsToCookieJar(variables);
      if (source.enabledCookieJar == true &&
          source.bookSourceUrl.trim().isNotEmpty) {
        await SourceVariableStore.syncFromCookieJar(
          source.bookSourceUrl,
          source.bookSourceUrl,
        );
      }
    } catch (_) {
      // Cookie sync must not break search/parse results.
    }
  }

  static Future<bool> _resolvePendingWebViewRequest({
    required db.BookSource source,
    required RuleEngine engine,
    Map<String, String>? sourceHeaders,
  }) async {
    final variables = await snapshotRuleVariables(engine);
    final responseVars = await resolveWebViewRequestForTesting(
      source: source,
      variables: variables,
      sourceHeaders: sourceHeaders,
      fetch: ({
        required url,
        required headers,
        required html,
        required webJs,
        required sourceRegex,
        required overrideUrlRegex,
        required sourceKey,
        required timeout,
        required delayTime,
      }) {
        return WebViewService.fetch(
          url: url,
          headers: headers,
          html: html,
          webJs: webJs,
          sourceRegex: sourceRegex,
          overrideUrlRegex: overrideUrlRegex,
          sourceKey: sourceKey,
          timeout: timeout,
          delayTime: delayTime,
        );
      },
    );
    if (responseVars == null) return false;
    for (final entry in responseVars.entries) {
      await engine.setSourceVar(key: entry.key, value: entry.value);
    }
    return true;
  }

  @visibleForTesting
  static Future<Map<String, String>?> resolveWebViewRequestForTesting({
    required db.BookSource source,
    required Map<String, String> variables,
    Map<String, String>? sourceHeaders,
    required Future<String> Function({
      required String url,
      required Map<String, String>? headers,
      required String? html,
      required String? webJs,
      required String? sourceRegex,
      required String? overrideUrlRegex,
      required String? sourceKey,
      required int timeout,
      required int delayTime,
    }) fetch,
  }) async {
    final request = parseWebViewRequestForTesting(variables);
    if (request == null) return null;

    final headers = request.headers ?? sourceHeaders;
    final effectiveUrl =
        request.url.isNotEmpty ? request.url : source.bookSourceUrl;
    final timeout = (source.respondTime ?? 60000).clamp(5000, 600000).toInt();

    final result = await fetch(
      url: effectiveUrl,
      headers: headers,
      html: request.html,
      webJs: request.webJs,
      sourceRegex: request.sourceRegex,
      overrideUrlRegex: request.overrideUrlRegex,
      sourceKey: source.enabledCookieJar == true ? source.bookSourceUrl : null,
      timeout: timeout,
      delayTime: request.delayTime,
    );
    return <String, String>{
      request.responseKey: result,
      _webViewRequestKey: '',
    };
  }

  @visibleForTesting
  static SourceWebViewPendingRequest? parseWebViewRequestForTesting(
    Map<String, String> variables,
  ) {
    final raw = variables[_webViewRequestKey]?.trim();
    if (raw == null || raw.isEmpty) return null;
    final request = _decodeStringObject(raw);
    if (request == null) return null;
    return SourceWebViewPendingRequest.tryParse(request);
  }

  static Future<bool> _resolvePendingFileDownloadRequest({
    required db.BookSource source,
    required RuleEngine engine,
    Map<String, String>? sourceHeaders,
    CancelToken? cancelToken,
  }) async {
    final variables = await snapshotRuleVariables(engine);
    Map<String, String> fetchVars = const {};
    final responseVars = await resolveFileDownloadRequestForTesting(
      variables: variables,
      fetch: ({
        required url,
        required path,
        required binaryAsHex,
      }) async {
        _throwIfCancelled(cancelToken);
        final result = await _fetchRuleDownloadFile(
          source: source,
          url: url,
          binaryAsHex: binaryAsHex,
          ruleVariables: variables,
          sourceHeaders: sourceHeaders,
          cancelToken: cancelToken,
        );
        fetchVars = result.updatedVars;
        return result.body;
      },
    );
    if (responseVars == null) return false;

    for (final entry in fetchVars.entries) {
      final key = entry.key.trim();
      if (key.isEmpty) continue;
      await engine.setSourceVar(key: key, value: entry.value);
    }
    for (final entry in responseVars.entries) {
      await engine.setSourceVar(key: entry.key, value: entry.value);
    }
    return true;
  }

  static Future<bool> _resolvePendingHttpRequest({
    required db.BookSource source,
    required RuleEngine engine,
    Map<String, String>? sourceHeaders,
    CancelToken? cancelToken,
  }) async {
    final variables = await snapshotRuleVariables(engine);
    final responseVars = await resolveHttpRequestForTesting(
      source: source,
      variables: variables,
      sourceHeaders: sourceHeaders,
      fetch: ({
        required url,
        required method,
        required headers,
        required body,
        required sourceKey,
        required timeout,
      }) async {
        _throwIfCancelled(cancelToken);
        final result = await _fetchRuleInternalHttp(
          source: source,
          url: url,
          method: method,
          headers: headers,
          body: body,
          sourceKey: sourceKey,
          timeout: timeout,
          ruleVariables: variables,
          sourceHeaders: sourceHeaders,
        );
        _throwIfCancelled(cancelToken);
        return result;
      },
    );
    if (responseVars == null) return false;
    for (final entry in responseVars.entries) {
      await engine.setSourceVar(key: entry.key, value: entry.value);
    }
    return true;
  }

  @visibleForTesting
  static Future<Map<String, String>?> resolveHttpRequestForTesting({
    required db.BookSource source,
    required Map<String, String> variables,
    Map<String, String>? sourceHeaders,
    required Future<PendingHttpResponse> Function({
      required String url,
      required String method,
      required Map<String, String> headers,
      required String? body,
      required String sourceKey,
      required int timeout,
    }) fetch,
  }) async {
    final raw = variables[_httpRequestKey]?.trim();
    if (raw == null || raw.isEmpty) return null;

    final requests = _decodePendingHttpRequests(raw);
    if (requests.isEmpty) return null;

    final out = <String, String>{
      _httpRequestKey: '',
    };
    var handled = false;

    for (final request in requests) {
      final url = request['url']?.trim() ?? '';
      final responseKey = request['responseKey']?.trim() ?? '';
      if (url.isEmpty || responseKey.isEmpty) continue;

      final method = (request['method']?.trim().toUpperCase() ?? 'GET');
      final timeout = _parsePositiveInt(request['timeout']) ??
          (source.respondTime ?? 180000).clamp(5000, 600000).toInt();
      final headers = <String, String>{
        ...?sourceHeaders,
        ...?_decodeStringObject(request['headers']),
      };
      final sourceKey = (request['sourceKey']?.trim().isNotEmpty == true)
          ? request['sourceKey']!.trim()
          : source.bookSourceUrl;

      final response = await fetch(
        url: url,
        method: method,
        headers: headers,
        body: request['body'],
        sourceKey: sourceKey,
        timeout: timeout.clamp(5000, 600000).toInt(),
      );

      out[responseKey] = jsonEncode(response.toJson());
      out.addAll(response.updatedVars);
      handled = true;
    }

    return handled ? out : null;
  }

  /// Supports a single pending request object or a JSON array of requests
  /// (multi `java.ajax` in one JS evaluation).
  static List<Map<String, String>> _decodePendingHttpRequests(String raw) {
    Object? decoded;
    try {
      decoded = jsonDecode(raw);
    } catch (_) {
      return const [];
    }

    if (decoded is List) {
      final out = <Map<String, String>>[];
      for (final item in decoded) {
        if (item is! Map) continue;
        final mapped = <String, String>{};
        item.forEach((key, value) {
          if (key == null) return;
          final name = key.toString().trim();
          if (name.isEmpty || value == null) return;
          if (value is String) {
            mapped[name] = value;
          } else if (value is Map || value is List) {
            mapped[name] = jsonEncode(value);
          } else {
            mapped[name] = value.toString();
          }
        });
        if (mapped.isNotEmpty) out.add(mapped);
      }
      return out;
    }

    final single = _decodeStringObject(raw);
    if (single == null) return const [];
    return [single];
  }

  static Future<PendingHttpResponse> _fetchRuleInternalHttp({
    required db.BookSource source,
    required String url,
    required String method,
    required Map<String, String> headers,
    required String? body,
    required String sourceKey,
    required int timeout,
    required Map<String, String> ruleVariables,
    Map<String, String>? sourceHeaders,
  }) async {
    final requestHeaders = <String, String>{
      ...(sourceHeaders ?? await buildSourceHeaders(source)),
      ...headers,
    };
    var urlRule = url;
    final normalizedMethod = method.toUpperCase();
    if (normalizedMethod != 'GET' && normalizedMethod != 'HEAD') {
      final option = <String, Object?>{
        'method': normalizedMethod,
        'body': body ?? '',
        if (headers.isNotEmpty) 'headers': headers,
      };
      urlRule = '$url,${jsonEncode(option)}';
    } else if (headers.isNotEmpty) {
      urlRule = '$url,${jsonEncode({'headers': headers})}';
    }

    await SourceRateLimiter.acquire(sourceKey, source.concurrentRate);
    final request = AnalyzeUrlUtils.buildFetchRequest(
      url: urlRule,
      baseUrl: source.bookSourceUrl,
      headerMap: requestHeaders,
      jsLib: source.jsLib,
      sourceKey: sourceKey,
      sourceVariable: ruleVariables[_sourceVariableKey],
      loginUrl: source.loginUrl,
      sourceVariables: ruleVariables,
      sessionVariables: ruleVariables,
      respondTime: timeout,
    );
    final result = await AnalyzeUrlUtils.fetchRequest(request).timeout(
      Duration(milliseconds: timeout) + const Duration(seconds: 10),
    );
    await AnalyzeUrlUtils.syncFetchVarsToCookieJar(result);
    return PendingHttpResponse(
      url: result.url.trim().isNotEmpty ? result.url : url,
      body: normalizedMethod == 'HEAD' ? '' : result.body,
      status: result.status,
      headers: result.headers,
      updatedVars: result.updatedVars,
      error: result.error,
    );
  }

  @visibleForTesting
  static Future<Map<String, String>?> resolveFileDownloadRequestForTesting({
    required Map<String, String> variables,
    required Future<String> Function({
      required String url,
      required String path,
      required bool binaryAsHex,
    }) fetch,
  }) async {
    final raw = variables[_fileDownloadRequestKey]?.trim();
    if (raw == null || raw.isEmpty) return null;

    final request = _decodeStringObject(raw);
    if (request == null) return null;
    final url = request['url']?.trim() ?? '';
    final path = request['path']?.trim() ?? '';
    if (url.isEmpty || path.isEmpty) return null;

    final encoding = request['encoding']?.trim().toLowerCase() ?? 'auto';
    final body = await fetch(
      url: url,
      path: path,
      binaryAsHex: _fileDownloadShouldFetchHex(
        encoding: encoding,
        url: url,
        path: path,
      ),
    );

    final out = <String, String>{
      '$_cacheFilePrefix$path': body,
      _fileDownloadRequestKey: '',
    };
    final cacheKey = request['cacheKey']?.trim() ?? '';
    if (cacheKey.isNotEmpty) {
      out['$_cachePrefix$cacheKey'] = path;
    }
    return out;
  }

  static Future<FetchUrlResult> _fetchRuleDownloadFile({
    required db.BookSource source,
    required String url,
    required bool binaryAsHex,
    required Map<String, String> ruleVariables,
    Map<String, String>? sourceHeaders,
    CancelToken? cancelToken,
  }) async {
    final headers = sourceHeaders ?? await buildSourceHeaders(source);
    final timeout = (source.respondTime ?? 180000).clamp(5000, 600000).toInt();
    final request = AnalyzeUrlUtils.buildFetchRequest(
      url: url,
      baseUrl: source.bookSourceUrl,
      page: null,
      key: null,
      headerMap: headers,
      jsLib: source.jsLib,
      sourceKey: source.bookSourceUrl,
      sourceVariable: ruleVariables[_sourceVariableKey],
      loginUrl: source.loginUrl,
      sourceVariables: ruleVariables,
      sessionVariables: ruleVariables,
      respondTime: source.respondTime,
      binaryAsHex: binaryAsHex,
    );
    final result = await AnalyzeUrlUtils.fetchRequest(request).timeout(
      Duration(milliseconds: timeout) + const Duration(seconds: 10),
    );
    await AnalyzeUrlUtils.syncFetchVarsToCookieJar(result);
    _throwIfCancelled(cancelToken);
    if (result.error != null && (result.status <= 0 || result.body.isEmpty)) {
      throw DioException(
        requestOptions: RequestOptions(path: url),
        error: result.error,
      );
    }
    if (result.status >= 400) {
      throw DioException(
        requestOptions: RequestOptions(path: url),
        type: DioExceptionType.badResponse,
        error: 'HTTP ${result.status}',
      );
    }
    return result;
  }

  static Map<String, String>? _decodeStringObject(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    Object? decoded;
    try {
      decoded = jsonDecode(raw);
    } catch (_) {
      return null;
    }
    if (decoded is! Map) return null;
    final out = <String, String>{};
    decoded.forEach((key, value) {
      if (key == null) return;
      final name = key.toString().trim();
      if (name.isEmpty || value == null) return;
      if (value is String) {
        out[name] = value;
      } else if (value is Map || value is List) {
        out[name] = jsonEncode(value);
      } else {
        out[name] = value.toString();
      }
    });
    return out;
  }

  static int? _parsePositiveInt(String? raw) {
    final value = int.tryParse(raw?.trim() ?? '');
    if (value == null || value <= 0) return null;
    return value;
  }

  static bool _fileDownloadShouldFetchHex({
    required String encoding,
    required String url,
    required String path,
  }) {
    if (encoding == 'hex' || encoding == 'binary' || encoding == 'bytes') {
      return true;
    }
    if (encoding == 'text' || encoding == 'string') return false;

    final ext = _downloadExtension(path).isNotEmpty
        ? _downloadExtension(path)
        : _downloadExtension(url);
    if (ext.isEmpty) return true;
    return !_textDownloadExtensions.contains(ext);
  }

  static String _downloadExtension(String input) {
    var text = input.trim().toLowerCase();
    if (text.isEmpty) return '';
    final optionIndex = text.indexOf(',{');
    if (optionIndex >= 0) text = text.substring(0, optionIndex);
    final queryIndex = text.indexOf('?');
    if (queryIndex >= 0) text = text.substring(0, queryIndex);
    final fragmentIndex = text.indexOf('#');
    if (fragmentIndex >= 0) text = text.substring(0, fragmentIndex);
    final slashIndex = text.lastIndexOf('/');
    final name = slashIndex >= 0 ? text.substring(slashIndex + 1) : text;
    final dotIndex = name.lastIndexOf('.');
    if (dotIndex < 0 || dotIndex == name.length - 1) return '';
    return name.substring(dotIndex + 1);
  }

  static const Set<String> _textDownloadExtensions = {
    'txt',
    'text',
    'js',
    'json',
    'html',
    'htm',
    'css',
    'xml',
    'csv',
    'md',
    'm3u8',
    'ini',
    'log',
    'yaml',
    'yml',
    'svg',
    'srt',
    'vtt',
  };

  static Future<void> _syncPersistentVariablesToRuleEngine(
    RuleEngine engine,
    String sourceKey, {
    String? bookUrl,
  }) async {
    final key = sourceKey.trim();
    if (key.isEmpty) return;

    final entries = await SourceVariableStore.getEntries(key);
    final namespacedPrefix = 'v_${key}_';
    for (final entry in entries.entries) {
      await engine.setSourceVar(key: entry.key, value: entry.value);
      // Legado CacheManager keys: v_{sourceKey}_{userKey}
      // Also inject short + marker so source.get('userKey') works after reload.
      if (entry.key.startsWith(namespacedPrefix)) {
        final shortKey = entry.key.substring(namespacedPrefix.length);
        if (shortKey.isNotEmpty) {
          await engine.setSourceVar(key: shortKey, value: entry.value);
          await engine.setSourceVar(
            key: '$_sourceKvPrefix$shortKey',
            value: entry.value,
          );
        }
      } else if (entry.key.startsWith(_sourceKvPrefix)) {
        final shortKey = entry.key.substring(_sourceKvPrefix.length);
        if (shortKey.isNotEmpty) {
          await engine.setSourceVar(key: shortKey, value: entry.value);
          await engine.setSourceVar(
            key: '$namespacedPrefix$shortKey',
            value: entry.value,
          );
        }
      }
    }

    final caches = await SourceVariableStore.getCaches(key);
    for (final entry in caches.entries) {
      await engine.setSourceVar(
        key: '$_cachePrefix${entry.key}',
        value: entry.value,
      );
    }

    final cacheDeadlines = await SourceVariableStore.getCacheDeadlines(key);
    for (final entry in cacheDeadlines.entries) {
      await engine.setSourceVar(
        key: '$_cacheDeadlinePrefix${entry.key}',
        value: entry.value,
      );
    }

    final fileCaches = await SourceVariableStore.getFileCaches(key);
    for (final entry in fileCaches.entries) {
      await engine.setSourceVar(
        key: '$_cacheFilePrefix${entry.key}',
        value: entry.value,
      );
    }

    final fileCacheDeadlines =
        await SourceVariableStore.getFileCacheDeadlines(key);
    for (final entry in fileCacheDeadlines.entries) {
      await engine.setSourceVar(
        key: '$_cacheFileDeadlinePrefix${entry.key}',
        value: entry.value,
      );
    }

    final resolvedBookUrl = bookUrl?.trim() ?? '';
    if (resolvedBookUrl.isNotEmpty) {
      await engine.setSourceVar(key: 'bookUrl', value: resolvedBookUrl);
      await engine.setBookVar(key: 'bookUrl', value: resolvedBookUrl);
      await _injectPersistedBookVariables(engine, key, resolvedBookUrl);
    }
  }

  /// Inject stored `book.putVariable` values so `book.getVariable` works.
  /// Writes both `__reader_book_var::{key}` (java.get path) and engine book vars.
  static Future<void> _injectPersistedBookVariables(
    RuleEngine engine,
    String sourceKey,
    String bookUrl,
  ) async {
    final vars = await SourceVariableStore.getBookVars(sourceKey, bookUrl);
    if (vars.isEmpty) return;
    for (final entry in vars.entries) {
      final shortKey = entry.key.trim();
      if (shortKey.isEmpty) continue;
      await engine.setSourceVar(
        key: '$_bookVarPrefix$shortKey',
        value: entry.value,
      );
      await engine.setBookVar(key: shortKey, value: entry.value);
    }
  }

  static Future<void> _syncVariablesToSourceLayer(
    RuleEngine engine,
    Map<String, String>? variables,
  ) async {
    if (variables == null || variables.isEmpty) return;
    for (final entry in variables.entries) {
      final key = entry.key.trim();
      if (key.isEmpty) continue;
      await engine.setSourceVar(key: key, value: entry.value);
    }
  }

  /// Merge disk `book.putVariable` into AnalyzeUrl context maps (session/book).
  static Future<void> _mergePersistedBookVarsIntoContext({
    required db.BookSource source,
    required String url,
    String? baseUrl,
    BookChapterInfo? chapter,
    required _AnalyzeUrlContextVariables context,
  }) async {
    final sourceKey = source.bookSourceUrl.trim();
    if (sourceKey.isEmpty) return;

    final candidates = <String>[];
    void addCandidate(String? raw) {
      final value = raw?.trim() ?? '';
      if (value.isEmpty) return;
      if (!candidates.contains(value)) candidates.add(value);
    }

    addCandidate(chapter?.variables['bookUrl']);
    addCandidate(chapter?.variables['tocUrl']);
    addCandidate(context.bookVariables['bookUrl']);
    addCandidate(context.bookVariables['tocUrl']);
    addCandidate(baseUrl);
    addCandidate(url);

    for (final candidate in candidates) {
      final bookVars =
          await SourceVariableStore.getBookVars(sourceKey, candidate);
      if (bookVars.isEmpty) continue;
      for (final entry in bookVars.entries) {
        final shortKey = entry.key.trim();
        if (shortKey.isEmpty) continue;
        final prefixed = '$_bookVarPrefix$shortKey';
        context.sessionVariables.putIfAbsent(prefixed, () => entry.value);
        context.bookVariables.putIfAbsent(prefixed, () => entry.value);
        context.bookVariables.putIfAbsent(shortKey, () => entry.value);
        context.book.putIfAbsent(shortKey, () => entry.value);
      }
      // Prefer the first non-empty store hit as bookUrl scope.
      context.sessionVariables.putIfAbsent('bookUrl', () => candidate);
      context.bookVariables.putIfAbsent('bookUrl', () => candidate);
      break;
    }
  }

  static _AnalyzeUrlContextVariables _buildAnalyzeUrlContextVariables({
    required db.BookSource source,
    required String url,
    String? baseUrl,
    String? key,
    int? page,
    String? sourceVariable,
    BookChapterInfo? chapter,
  }) {
    final sourceVariables = <String, String>{};
    _putNonEmpty(sourceVariables, '__reader_source_key', source.bookSourceUrl);
    _putNonEmpty(sourceVariables, '__reader_source_variable', sourceVariable);
    _putNonEmpty(sourceVariables, '__reader_source_login_url', source.loginUrl);
    _putNonEmpty(sourceVariables, 'bookSourceUrl', source.bookSourceUrl);
    _putNonEmpty(sourceVariables, 'sourceUrl', source.bookSourceUrl);
    _putCookieJarVariable(
      sourceVariables,
      source.bookSourceUrl,
      sourceVariable,
    );
    _putCookieJarVariable(sourceVariables, url, sourceVariable);
    _putCookieJarVariable(sourceVariables, baseUrl, sourceVariable);
    if (source.respondTime != null && source.respondTime! > 0) {
      sourceVariables['__reader_respond_time'] = source.respondTime.toString();
    }

    final sessionVariables = <String, String>{};
    _putNonEmpty(sessionVariables, 'key', key);
    if (page != null) {
      sessionVariables['page'] = page.toString();
      sessionVariables['searchPage'] = page.toString();
    }

    final effectiveBaseUrl =
        (baseUrl?.trim().isNotEmpty == true) ? baseUrl!.trim() : url;
    _putIdentityVariablesFromUrl(sessionVariables, effectiveBaseUrl);
    _putIdentityVariablesFromUrl(sessionVariables, url);

    final bookVariables = <String, String>{};
    _putNonEmptyAll(
      bookVariables,
      getBookRuleVariables(sourceId: source.id, bookUrl: url),
    );
    if (baseUrl != null) {
      _putNonEmptyAll(
        bookVariables,
        getBookRuleVariables(sourceId: source.id, bookUrl: baseUrl),
      );
    }
    _putIdentityVariablesFromUrl(bookVariables, url);
    _putIdentityVariablesFromUrl(bookVariables, baseUrl);

    final chapterVariables = <String, String>{};
    _putNonEmptyAll(
      chapterVariables,
      getChapterRuleVariables(sourceId: source.id, chapterUrl: url),
    );
    if (baseUrl != null) {
      _putNonEmptyAll(
        chapterVariables,
        getChapterRuleVariables(sourceId: source.id, chapterUrl: baseUrl),
      );
    }
    if (chapter != null) {
      _putNonEmptyAll(
        chapterVariables,
        _chapterInfoRuleVariables(chapter, requestUrl: url),
      );
    }
    _putIdentityVariablesFromUrl(chapterVariables, url);

    final book = <String, Object?>{};
    _putNonEmptyObject(book, 'bookUrl', bookVariables['bookUrl'] ?? url);
    _putNonEmptyObject(book, 'tocUrl', bookVariables['tocUrl']);
    _putNonEmptyObject(book, 'bookSourceUrl', source.bookSourceUrl);
    for (final entry in bookVariables.entries) {
      _putNonEmptyObject(book, entry.key, entry.value);
    }

    final chapterObject = <String, Object?>{};
    if (chapter != null) {
      chapterObject.addAll(_chapterInfoObject(chapter, requestUrl: url));
    }
    _putNonEmptyObject(chapterObject, 'url', url);
    _putNonEmptyObject(chapterObject, 'chapterUrl', url);
    for (final entry in chapterVariables.entries) {
      _putNonEmptyObject(chapterObject, entry.key, entry.value);
    }

    return _AnalyzeUrlContextVariables(
      sourceVariables: sourceVariables,
      sessionVariables: sessionVariables,
      bookVariables: bookVariables,
      chapterVariables: chapterVariables,
      book: book,
      chapter: chapterObject,
    );
  }

  static Map<String, String> _chapterInfoRuleVariables(
    BookChapterInfo chapter, {
    String? requestUrl,
  }) {
    final variables = <String, String>{};
    _putNonEmptyAll(variables, chapter.variables);

    final effectiveUrl = (requestUrl?.trim().isNotEmpty == true)
        ? requestUrl!.trim()
        : chapter.chapterUrl?.trim();
    _putNonEmpty(variables, 'chapter_title', chapter.chapterName);
    _putNonEmpty(variables, 'title', chapter.chapterName);
    _putNonEmpty(variables, 'chapter_url', effectiveUrl);
    _putNonEmpty(variables, 'url', effectiveUrl);
    _putNonEmpty(variables, 'baseUrl', chapter.baseUrl);
    _putNonEmpty(variables, 'updateTime', chapter.updateTime);

    final index = chapter.chapterIndex;
    if (index != null) {
      variables['chapter_index'] = index.toString();
      variables['index'] = index.toString();
    }

    variables['isVolume'] = chapter.isVolume.toString();
    variables['isVip'] = chapter.isVip.toString();
    variables['isPay'] = chapter.isPay.toString();

    _putIdentityVariablesFromUrl(variables, effectiveUrl);
    final chapterId = _lastNumericPathSegment(effectiveUrl);
    if (chapterId != null) {
      variables.putIfAbsent('chapterId', () => chapterId);
      variables.putIfAbsent('chapter_id', () => chapterId);
      variables.putIfAbsent('cid', () => chapterId);
    }
    return variables;
  }

  @visibleForTesting
  static Map<String, String> normalizeChapterRuleVariables({
    required BookChapterInfo chapter,
    String? requestUrl,
  }) {
    return _chapterInfoRuleVariables(chapter, requestUrl: requestUrl);
  }

  static Map<String, Object?> _chapterInfoObject(
    BookChapterInfo chapter, {
    String? requestUrl,
  }) {
    final effectiveUrl = (requestUrl?.trim().isNotEmpty == true)
        ? requestUrl!.trim()
        : chapter.chapterUrl?.trim();
    final object = <String, Object?>{
      ...chapter.variables,
      'isVolume': chapter.isVolume,
      'isVip': chapter.isVip,
      'isPay': chapter.isPay,
    };

    if (chapter.chapterName?.trim().isNotEmpty == true) {
      object['title'] = chapter.chapterName!.trim();
      object['chapterName'] = chapter.chapterName!.trim();
    }
    if (effectiveUrl?.trim().isNotEmpty == true) {
      object['url'] = effectiveUrl!.trim();
      object['chapterUrl'] = effectiveUrl.trim();
    }
    if (chapter.baseUrl?.trim().isNotEmpty == true) {
      object['baseUrl'] = chapter.baseUrl!.trim();
    }
    if (chapter.updateTime?.trim().isNotEmpty == true) {
      object['tag'] = chapter.updateTime!.trim();
      object['updateTime'] = chapter.updateTime!.trim();
    }
    final index = chapter.chapterIndex;
    if (index != null) {
      object['index'] = index;
      object['chapterIndex'] = index;
    }
    return object;
  }

  static void cacheBookRuleVariables({
    required int sourceId,
    required String? bookUrl,
    String? tocUrl,
    required Map<String, String> variables,
    Map<String, String>? itemVariables,
  }) {
    final snapshot = Map<String, String>.from(variables);
    _putNonEmptyAll(snapshot, itemVariables);
    _putIdentityVariablesFromUrl(snapshot, bookUrl);
    _putIdentityVariablesFromUrl(snapshot, tocUrl);
    _putNonEmpty(snapshot, 'bookUrl', bookUrl);
    _putNonEmpty(snapshot, 'tocUrl', tocUrl);
    if (snapshot.isEmpty) return;

    for (final url in <String?>[bookUrl, tocUrl]) {
      final key = _ruleVarKey(sourceId, url);
      if (key == null) continue;
      _lruPut(
        _bookRuleVars,
        key,
        Map<String, String>.unmodifiable(snapshot),
        _maxBookRuleVarEntries,
      );
    }
  }

  static Map<String, String>? getBookRuleVariables({
    required int sourceId,
    required String? bookUrl,
    String? tocUrl,
  }) {
    for (final url in <String?>[tocUrl, bookUrl]) {
      final key = _ruleVarKey(sourceId, url);
      if (key == null) continue;
      final vars = _lruGet(_bookRuleVars, key);
      if (vars != null) return Map<String, String>.from(vars);
    }
    return null;
  }

  static Map<String, String> normalizeBookRuleVariables({
    required String? bookUrl,
    String? tocUrl,
    required Map<String, String> variables,
    Map<String, String>? itemVariables,
  }) {
    final snapshot = Map<String, String>.from(variables);
    _putNonEmptyAll(snapshot, itemVariables);
    _putIdentityVariablesFromUrl(snapshot, bookUrl);
    _putIdentityVariablesFromUrl(snapshot, tocUrl);
    _putNonEmpty(snapshot, 'bookUrl', bookUrl);
    _putNonEmpty(snapshot, 'tocUrl', tocUrl);
    return snapshot;
  }

  static void cacheChapterRuleVariables({
    required int sourceId,
    required String? chapterUrl,
    required Map<String, String> variables,
    Map<String, String>? itemVariables,
    String? bookUrl,
    String? tocUrl,
    Map<String, String>? sharedVariables,
  }) {
    final key = _ruleVarKey(sourceId, chapterUrl);
    final snapshot = <String, String>{};
    if (sharedVariables == null) {
      snapshot.addAll(variables);
    }
    _putNonEmptyAll(snapshot, itemVariables);
    _putIdentityVariablesFromUrl(snapshot, bookUrl);
    _putIdentityVariablesFromUrl(snapshot, tocUrl);
    _putNonEmpty(snapshot, 'bookUrl', bookUrl);
    _putNonEmpty(snapshot, 'tocUrl', tocUrl);

    final chapterId = _lastNumericPathSegment(chapterUrl);
    if (chapterId != null) {
      _putNonEmpty(snapshot, 'chapterId', chapterId);
      _putNonEmpty(snapshot, 'chapter_id', chapterId);
      _putNonEmpty(snapshot, 'cid', chapterId);
    }

    final shared = sharedVariables ?? const <String, String>{};
    if (key == null || (snapshot.isEmpty && shared.isEmpty)) return;
    final entry = _ChapterRuleVariableEntry(
      shared: shared,
      chapter: Map<String, String>.unmodifiable(snapshot),
    );
    _lruPut(_chapterRuleVars, key, entry, _maxChapterRuleVarEntries);

    if (chapterId != null) {
      _lruPut(
        _chapterRuleVarsById,
        '$sourceId::$chapterId',
        entry,
        _maxChapterRuleVarEntries,
      );
    }
  }

  static Map<String, String>? getChapterRuleVariables({
    required int sourceId,
    required String? chapterUrl,
  }) {
    final key = _ruleVarKey(sourceId, chapterUrl);
    final vars = key == null ? null : _lruGet(_chapterRuleVars, key);
    if (vars != null) return vars.merged();

    final chapterId = _lastNumericPathSegment(chapterUrl);
    if (chapterId == null) return null;
    final varsById = _lruGet(_chapterRuleVarsById, '$sourceId::$chapterId');
    return varsById?.merged();
  }

  /// Builds the immutable book-level part once for a full chapter list.
  static Map<String, String> sharedChapterRuleVariables({
    required Map<String, String> variables,
    String? bookUrl,
    String? tocUrl,
  }) {
    final shared = Map<String, String>.from(variables);
    _putIdentityVariablesFromUrl(shared, bookUrl);
    _putIdentityVariablesFromUrl(shared, tocUrl);
    _putNonEmpty(shared, 'bookUrl', bookUrl);
    _putNonEmpty(shared, 'tocUrl', tocUrl);
    return Map<String, String>.unmodifiable(shared);
  }

  static V? _lruGet<V>(LinkedHashMap<String, V> cache, String key) {
    final value = cache.remove(key);
    if (value != null) cache[key] = value;
    return value;
  }

  static void _lruPut<V>(
    LinkedHashMap<String, V> cache,
    String key,
    V value,
    int capacity,
  ) {
    cache.remove(key);
    cache[key] = value;
    while (cache.length > capacity) {
      cache.remove(cache.keys.first);
    }
  }

  @visibleForTesting
  static void clearRuleVariableCachesForTesting() {
    _bookRuleVars.clear();
    _chapterRuleVars.clear();
    _chapterRuleVarsById.clear();
  }

  @visibleForTesting
  static ({int books, int chapters, int chapterIds})
      get ruleVariableCacheSizesForTesting => (
            books: _bookRuleVars.length,
            chapters: _chapterRuleVars.length,
            chapterIds: _chapterRuleVarsById.length,
          );

  static String? _lastNumericPathSegment(String? rawUrl) {
    final url = rawUrl?.trim() ?? '';
    if (url.isEmpty) return null;
    final noOption = url.split(',').first.trim();
    final match = RegExp(r'/(\d+)(?:[/?#].*)?$').firstMatch(noOption);
    if (match != null) return match.group(1);

    final uri = Uri.tryParse(noOption);
    if (uri == null) return null;
    for (final segment in uri.pathSegments.reversed) {
      if (RegExp(r'^\d+$').hasMatch(segment)) {
        return segment;
      }
    }
    return null;
  }

  static void _putNonEmpty(
    Map<String, String> variables,
    String key,
    String? value,
  ) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return;
    variables[key] = text;
  }

  static void _putNonEmptyAll(
    Map<String, String> variables,
    Map<String, String>? values,
  ) {
    if (values == null || values.isEmpty) return;
    for (final entry in values.entries) {
      _putNonEmpty(variables, entry.key, entry.value);
    }
  }

  static void _putNonEmptyObject(
    Map<String, Object?> variables,
    String key,
    String? value,
  ) {
    final text = value?.trim() ?? '';
    if (key.trim().isEmpty || text.isEmpty) return;
    variables[key] = text;
  }

  static void _putCookieJarVariable(
    Map<String, String> variables,
    String? rawUrl,
    String? cookie,
  ) {
    final cookieText = cookie?.trim() ?? '';
    if (!_looksLikeCookieHeaderValue(cookieText)) return;
    final host = _hostFromUrl(rawUrl);
    if (host == null || host.isEmpty) return;
    variables['cookieJar::$host'] = cookieText;
  }

  static String? _hostFromUrl(String? rawUrl) {
    final text = rawUrl?.trim() ?? '';
    if (text.isEmpty) return null;
    final urlPart = text.split(',').first.trim();
    if (urlPart.isEmpty) return null;
    Uri? uri = Uri.tryParse(urlPart);
    if (uri != null && uri.host.isEmpty && !urlPart.startsWith('/')) {
      uri = Uri.tryParse('https://$urlPart');
    }
    final host = uri?.host.trim();
    return (host == null || host.isEmpty) ? null : host;
  }

  static void _putIdentityVariablesFromUrl(
    Map<String, String> variables,
    String? rawUrl,
  ) {
    final text = rawUrl?.trim() ?? '';
    if (text.isEmpty) return;

    final comma = text.indexOf(',');
    final urlPart = comma >= 0 ? text.substring(0, comma).trim() : text;
    final optionPart = comma >= 0 ? text.substring(comma + 1).trim() : '';

    final uri = Uri.tryParse(urlPart);
    if (uri != null) {
      for (final entry in uri.queryParameters.entries) {
        _putIdentityVariable(variables, entry.key, entry.value);
      }
    }

    if (optionPart.isEmpty) return;
    for (final match in _identityOptionPattern.allMatches(optionPart)) {
      final key = match.group(1);
      final value = match.group(2);
      _putIdentityVariable(variables, key, value);
    }
  }

  static final RegExp _identityOptionPattern = RegExp(
    r'''(?:^|[,{]\s*)["']?(id|bid|bookId|book_id|bookid|novel_id|novelId|chapterId|chapter_id|cid)["']?\s*:\s*["']?([^"',}\s]+)''',
  );

  static void _putIdentityVariable(
    Map<String, String> variables,
    String? rawKey,
    String? rawValue,
  ) {
    final key = rawKey?.trim() ?? '';
    final value = rawValue?.trim() ?? '';
    if (key.isEmpty || value.isEmpty) return;

    _putNonEmpty(variables, key, value);
    switch (key) {
      case 'novel_id':
      case 'novelId':
        _putNonEmpty(variables, 'novel_id', value);
        _putNonEmpty(variables, 'novelId', value);
        _putNonEmpty(variables, 'id', value);
        break;
      case 'bookId':
      case 'book_id':
      case 'bookid':
      case 'bid':
        _putNonEmpty(variables, 'bookId', value);
        _putNonEmpty(variables, 'book_id', value);
        _putNonEmpty(variables, 'bookid', value);
        _putNonEmpty(variables, 'bid', value);
        _putNonEmpty(variables, 'id', value);
        break;
      case 'chapterId':
      case 'chapter_id':
      case 'cid':
        // URL / body-derived chapter ids override stale list-item vars.
        _putNonEmpty(variables, 'chapterId', value);
        _putNonEmpty(variables, 'chapter_id', value);
        _putNonEmpty(variables, 'cid', value);
        break;
      case 'id':
        _putNonEmpty(variables, 'bid', value);
        break;
    }
  }

  static String? _ruleVarKey(int sourceId, String? rawUrl) {
    final url = rawUrl?.trim() ?? '';
    if (url.isEmpty) return null;
    return '$sourceId::${normalizeUrl(url)}';
  }

  /// 构建书源请求头（含 CookieJar 支持）。
  static Future<Map<String, String>> buildSourceHeaders(
      db.BookSource source) async {
    final headers = await _parseSourceHeaderMap(source);
    await _mergeStoredLoginHeaders(source, headers);
    if (source.enabledCookieJar == true) {
      headers['CookieJar'] = '1';
      final sourceVariable = await SourceVariableStore.get(
        source.bookSourceUrl,
        sourceUrl: source.bookSourceUrl,
        preferCookieJar: true,
        allowCookieJarFallback: true,
      );
      if (_looksLikeCookieHeaderValue(sourceVariable)) {
        final existingKey = RequestHeaders.findHeaderKey(headers, 'Cookie');
        final existingCookie =
            existingKey == null ? null : headers[existingKey];
        // Jar cookies as base; login/source Cookie header wins on same names.
        final merged = _mergeCookieHeaderValues(
          sourceVariable,
          existingCookie,
        );
        if (merged.isNotEmpty) {
          if (existingKey != null && existingKey != 'Cookie') {
            headers.remove(existingKey);
          }
          headers['Cookie'] = merged;
        }
      }
    }
    return headers;
  }

  static Future<void> _mergeStoredLoginHeaders(
    db.BookSource source,
    Map<String, String> headers,
  ) async {
    final sourceKey = source.bookSourceUrl.trim();
    if (sourceKey.isEmpty) return;

    final loginHeaders = await SourceLoginService.getLoginHeaders(sourceKey);
    if (loginHeaders.isEmpty) return;

    _mergeHeaderMaps(headers, loginHeaders);
  }

  static void _mergeHeaderMaps(
    Map<String, String> target,
    Map<String, String> source,
  ) {
    for (final entry in source.entries) {
      final key = entry.key.trim();
      final value = entry.value.trim();
      if (key.isEmpty || value.isEmpty || key.startsWith('__reader_')) {
        continue;
      }

      final existingKey = RequestHeaders.findHeaderKey(target, key);
      if (key.toLowerCase() == 'cookie') {
        final mergedCookie = _mergeCookieHeaderValues(
          existingKey == null ? null : target[existingKey],
          value,
        );
        if (mergedCookie.isEmpty) continue;
        if (existingKey != null && existingKey != key) {
          target.remove(existingKey);
        }
        target[key] = mergedCookie;
        continue;
      }

      if (existingKey != null && existingKey != key) {
        target.remove(existingKey);
      }
      target[key] = value;
    }
  }

  static String _mergeCookieHeaderValues(String? base, String? overlay) {
    final merged = <String, String>{};
    _putCookiePairs(merged, base);
    _putCookiePairs(merged, overlay);
    return RequestHeaders.normalizeCookieHeaderValue(
      merged.entries.map((e) => '${e.key}=${e.value}').join('; '),
    );
  }

  static void _putCookiePairs(Map<String, String> target, String? rawCookie) {
    final normalized = RequestHeaders.normalizeCookieHeaderValue(rawCookie);
    if (normalized.isEmpty) return;

    for (final part in normalized.split(';')) {
      final token = part.trim();
      if (token.isEmpty) continue;
      final eqIndex = token.indexOf('=');
      if (eqIndex <= 0) continue;
      final name = token.substring(0, eqIndex).trim();
      if (name.isEmpty) continue;
      target[name] = token.substring(eqIndex + 1).trim();
    }
  }

  static bool _looksLikeCookieHeaderValue(String value) {
    final text = value.trim();
    if (text.isEmpty || text.startsWith('{') || text.startsWith('[')) {
      return false;
    }
    if (text.contains('\r') || text.contains('\n')) return false;
    return text.split(';').any((part) {
      final token = part.trim();
      final eqIndex = token.indexOf('=');
      if (eqIndex <= 0) return false;
      final name = token.substring(0, eqIndex).trim();
      return name.isNotEmpty &&
          !name.contains(' ') &&
          !name.contains('\t') &&
          !name.contains(',');
    });
  }

  static String _normalizeSourceVariableForRules(
    db.BookSource source,
    String value,
  ) {
    final text = value.trim();
    if (text.isEmpty || !_sourceRulesRequireJsonSourceVariable(source)) {
      return text;
    }
    try {
      jsonDecode(text);
      return text;
    } catch (_) {
      return '';
    }
  }

  static bool _sourceRulesRequireJsonSourceVariable(db.BookSource source) {
    bool containsJsonParse(String? script) {
      final text = script?.trim();
      if (text == null || text.isEmpty) return false;
      final compact = text.replaceAll(RegExp(r'\s+'), '');
      return compact.contains('JSON.parse(source.getVariable())');
    }

    return containsJsonParse(source.jsLib) ||
        containsJsonParse(source.searchUrl) ||
        containsJsonParse(source.exploreUrl) ||
        containsJsonParse(source.loginUrl);
  }

  static Future<Map<String, String>> _parseSourceHeaderMap(
      db.BookSource source) async {
    final rawHeader = source.header?.trim();
    if (rawHeader == null || rawHeader.isEmpty) {
      return AnalyzeUrlUtils.parseHeaderMap(rawHeader);
    }

    final lower = rawHeader.toLowerCase();
    if (!lower.startsWith('@js:') && !lower.startsWith('<js>')) {
      return AnalyzeUrlUtils.parseHeaderMap(rawHeader);
    }

    final directHeaderJson = _tryExtractDirectHeaderJson(rawHeader);
    if (directHeaderJson != null) {
      return AnalyzeUrlUtils.parseHeaderMap(directHeaderJson);
    }

    try {
      // Prefer a full engine so header JS that calls java.ajax uses the same
      // platform HTTP bridge / CookieJar path as search. Avoid calling
      // buildSourceHeaders here (would recurse into this method).
      final engine = await RuleEngine.newInstance();
      await engine.setJsLib(lib: source.jsLib);
      await engine.setSourceVar(
          key: '__reader_source_key', value: source.bookSourceUrl);
      await engine.setSourceVar(key: preferPlatformHttpKey, value: '1');
      final respondTimeMs =
          SourceCheckPolicy.normalizeRequestTimeoutMs(source.respondTime);
      await engine.setSourceVar(
        key: '__reader_respond_time',
        value: respondTimeMs.toString(),
      );
      final rawSourceVariable = await SourceVariableStore.get(
        source.bookSourceUrl,
        sourceUrl: source.bookSourceUrl,
        preferCookieJar: source.enabledCookieJar == true,
        allowCookieJarFallback: source.enabledCookieJar == true,
      );
      final sourceVariable =
          _normalizeSourceVariableForRules(source, rawSourceVariable);
      final effectiveSourceVariable = sourceVariable.isNotEmpty
          ? sourceVariable
          : (source.enabledCookieJar == true &&
                  !_sourceRulesRequireJsonSourceVariable(source)
              ? rawSourceVariable
              : '');
      final seedHeaders = <String, String>{};
      if (source.enabledCookieJar == true) {
        seedHeaders['CookieJar'] = '1';
        if (_looksLikeCookieHeaderValue(effectiveSourceVariable)) {
          seedHeaders['Cookie'] = effectiveSourceVariable;
        }
      }
      await engine.setSourceHeadersJson(
        headerJson: jsonEncode(seedHeaders),
      );
      final contextVariables = _buildAnalyzeUrlContextVariables(
        source: source,
        url: source.bookSourceUrl,
        sourceVariable: effectiveSourceVariable,
      );
      await _syncVariablesToSourceLayer(
        engine,
        contextVariables.sourceVariables,
      );
      await _syncVariablesToSourceLayer(
        engine,
        contextVariables.sessionVariables,
      );
      final info = await runWithWebViewBridge(
        source: source,
        engine: engine,
        sourceHeaders: seedHeaders,
        parse: () => engine.extractBookInfo(
          html: '',
          rule: BookInfoRule(name: rawHeader),
          baseUrl: source.bookSourceUrl,
        ),
      );
      return AnalyzeUrlUtils.parseHeaderMap(info?.name);
    } catch (e, st) {
      LogUtils.e(
        '动态 header 解析失败: ${source.bookSourceName} (${source.bookSourceUrl})',
        error: e,
        stackTrace: st,
      );
      return AnalyzeUrlUtils.parseHeaderMap(null);
    }
  }

  static String? _tryExtractDirectHeaderJson(String rawHeader) {
    final js = _unwrapJsHeader(rawHeader)?.trim();
    if (js == null || js.isEmpty) return null;

    final stringifyMatch = RegExp(
      r'^\s*JSON\.stringify\s*\(([\s\S]*)\)\s*;?\s*$',
    ).firstMatch(js);
    final candidate = stringifyMatch?.group(1)?.trim() ?? js;
    if (!candidate.startsWith('{') || !candidate.endsWith('}')) {
      return null;
    }

    final parsed = AnalyzeUrlUtils.parseHeaderMap(
      candidate,
      ensureDefaultUserAgent: false,
    );
    return parsed.isEmpty ? null : candidate;
  }

  static String? _unwrapJsHeader(String rawHeader) {
    final text = rawHeader.trim();
    if (text.length >= 4 && text.substring(0, 4).toLowerCase() == '@js:') {
      return text.substring(4);
    }
    if (text.length >= 4 && text.substring(0, 4).toLowerCase() == '<js>') {
      final lower = text.toLowerCase();
      final end = lower.lastIndexOf('</js>');
      if (end >= 4) {
        return text.substring(4, end);
      }
      return text.substring(4);
    }
    return null;
  }

  /// 从 headers map 中提取 Cookie 值。
  static String cookieHeaderFromHeaders(Map<String, String>? headers) {
    if (headers == null) return '';
    return headers.entries
        .firstWhere(
          (e) => e.key.toLowerCase() == 'cookie',
          orElse: () => const MapEntry('', ''),
        )
        .value;
  }

  /// 登录校验。
  ///
  /// 在每次网络请求后调用。loginCheckJs 抛异常时表示需要登录，
  /// 正常返回则继续使用原始 HTML。
  static Future<FetchedPage> runLoginCheck({
    required RuleEngine engine,
    required FetchedPage page,
    int? sourceId,
    String? sourceKey,
    String? sourceName,
    String? loginCheckJs,
    String? loginUrl,
    String? loginUi,
  }) async {
    if (loginCheckJs == null || loginCheckJs.trim().isEmpty) return page;

    final escapedUrl = page.finalUrl
        .replaceAll('\\', '\\\\')
        .replaceAll("'", "\\'")
        .replaceAll('\n', '\\n')
        .replaceAll('\r', '\\r');

    // 构造兼容的 StrResponse 对象，loginCheckJs 可通过 result.body / result.url 访问
    final wrappedJs = "(function(){"
        "var __body=result;"
        "result={body:__body,url:'$escapedUrl'};"
        "$loginCheckJs;"
        "return __body;"
        "})()";

    final checkResult = await engine.extractContent(
      html: page.html,
      rule: ContentRule(content: '@js:$wrappedJs'),
      baseUrl: page.finalUrl,
    );

    // JS 抛异常 → extractContent 返回 null → 登录校验失败
    if (checkResult == null) {
      throw SourceLoginRequiredException(
        SourceLoginRequired(
          sourceId: sourceId,
          sourceKey: sourceKey,
          sourceName: sourceName,
          reason: SourceLoginRequiredReason.loginCheckFailed.value,
          loginUrl: loginUrl,
          loginUi: loginUi,
          pageUrl: page.finalUrl,
        ),
      );
    }
    return page;
  }

  /// 规范化 URL 用于去重比较。
  static String normalizeUrl(String url) {
    String normalized = url.trim();
    if (normalized.endsWith('/')) {
      normalized = normalized.substring(0, normalized.length - 1);
    }
    final hashIndex = normalized.indexOf('#');
    if (hashIndex > 0) {
      normalized = normalized.substring(0, hashIndex);
    }
    return normalized.toLowerCase();
  }

  static int? _urlOptionInt(AnalyzeUrlResult result, String key) {
    final raw = result.updatedVars[key]?.trim();
    if (raw == null || raw.isEmpty) return null;
    final value = int.tryParse(raw);
    if (value == null || value <= 0) return null;
    return value;
  }

  static bool _isBinaryResponseType(String? type) {
    return type?.trim().isNotEmpty == true;
  }

  static String? _tryDecodeDataUrl(String url) {
    if (!url.startsWith('data:')) return null;
    final commaIndex = url.indexOf(',');
    if (commaIndex < 0) return '';

    final meta = url.substring(5, commaIndex).toLowerCase();
    final payload = url.substring(commaIndex + 1).trim();

    if (meta.contains(';base64')) {
      final normalized = payload.replaceAll(RegExp(r'\s+'), '');
      if (normalized.isEmpty) return '';
      try {
        final bytes = base64Decode(normalized);
        return utf8.decode(bytes, allowMalformed: true);
      } catch (_) {
        return '';
      }
    }

    try {
      return Uri.decodeComponent(payload);
    } catch (_) {
      return payload;
    }
  }
}

String? _nullIfEmpty(String? value) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) return null;
  return trimmed;
}

class PreparedSourceRequest {
  final Map<String, String> sourceHeaders;
  final AnalyzeUrlResult urlResult;
  final FetchUrlRequest fetchRequest;
  final String url;

  const PreparedSourceRequest({
    required this.sourceHeaders,
    required this.urlResult,
    required this.fetchRequest,
    required this.url,
  });
}

class FetchedPage {
  final String html;
  final String finalUrl;

  const FetchedPage({
    required this.html,
    required this.finalUrl,
  });
}

class PendingHttpResponse {
  final String url;
  final String body;
  final int status;
  final Map<String, List<String>> headers;
  final Map<String, String> updatedVars;
  final String? error;

  const PendingHttpResponse({
    required this.url,
    required this.body,
    required this.status,
    this.headers = const {},
    this.updatedVars = const {},
    this.error,
  });

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'url': url,
      'body': body,
      'status': status,
      'headers': headers,
      if (error != null) 'error': error,
    };
  }
}

class _ChapterRuleVariableEntry {
  const _ChapterRuleVariableEntry({
    required this.shared,
    required this.chapter,
  });

  final Map<String, String> shared;
  final Map<String, String> chapter;

  Map<String, String> merged() => <String, String>{
        ...shared,
        ...chapter,
      };
}

class _AnalyzeUrlContextVariables {
  final Map<String, String> sourceVariables;
  final Map<String, String> sessionVariables;
  final Map<String, String> bookVariables;
  final Map<String, String> chapterVariables;
  final Map<String, Object?> book;
  final Map<String, Object?> chapter;

  const _AnalyzeUrlContextVariables({
    required this.sourceVariables,
    required this.sessionVariables,
    required this.bookVariables,
    required this.chapterVariables,
    required this.book,
    required this.chapter,
  });
}

/// 校验异常 - 用于分类校验失败原因
class CheckException implements Exception {
  /// 失败分类标签（如 "搜索失效"、"目录失效"）
  final String tag;

  /// 详细错误信息
  final String message;

  /// 安全诊断信息，会进入书源校验阶段明细。
  final Map<String, Object?> diagnostics;

  CheckException(
    this.tag,
    this.message, {
    this.diagnostics = const <String, Object?>{},
  });

  @override
  String toString() => '$tag: $message';
}
