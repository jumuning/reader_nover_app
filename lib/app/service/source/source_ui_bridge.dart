import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reader_nover/app/database/drift/app_database.dart' as db;
import 'package:reader_nover/app/net/webview_service.dart';
import 'package:reader_nover/app/service/source/source_check_policy.dart';
import 'package:reader_nover/app/service/source/source_http.dart';
import 'package:reader_nover/pages/home/source/webview/login_webview_page.dart';
import 'package:reader_nover/rust/api/rule_engine.dart';

typedef SourceUiVerificationPrompt = Future<String?> Function({
  required db.BookSource source,
  required String imageUrl,
});

/// Loads captcha image bytes with book-source headers / CookieJar.
typedef SourceUiCaptchaImageLoader = Future<Uint8List?> Function({
  required db.BookSource source,
  required String imageUrl,
});

typedef SourceUiInternalBrowser = Future<SourceLoginWebViewResult> Function({
  required db.BookSource source,
  required String url,
  required String title,
  bool captureHtmlOnFinish,
  String? sourceRegex,
});

typedef SourceUiBrowserFetcher = Future<String> Function({
  required db.BookSource source,
  required String url,
});

typedef SourceUiCookieSync = Future<void> Function(
  String url, {
  String? sourceKey,
});

class SourceVerificationRequired implements Exception {
  const SourceVerificationRequired(this.request);

  final SourceUiPendingRequest request;

  @override
  String toString() {
    return 'SourceVerificationRequired(${request.method}: ${request.url})';
  }
}

class SourceUiPendingRequest {
  const SourceUiPendingRequest({
    required this.method,
    required this.url,
    this.imageUrl,
    this.title,
    this.mimeType,
    this.requestKey,
    this.responseKey,
    this.sourceRegex,
    this.refetchAfterSuccess = true,
  });

  final String method;
  final String url;
  final String? imageUrl;
  final String? title;
  final String? mimeType;
  final String? requestKey;
  final String? responseKey;
  /// Optional URL regex (Legado `sourceRegex` / override success pattern).
  /// When set, WebView auto-finishes once the current URL matches.
  final String? sourceRegex;
  final bool refetchAfterSuccess;

  bool get expectsResponse =>
      method == 'getVerificationCode' || method == 'startBrowserAwait';

  static SourceUiPendingRequest? tryParse(Map<String, String> request) {
    final method = request['method']?.trim() ?? '';
    if (!_supportedMethods.contains(method)) return null;

    final rawUrl = request['url']?.trim() ?? '';
    final imageUrl = _nullIfEmpty(request['imageUrl']);
    final url = method == 'getVerificationCode' ? (imageUrl ?? rawUrl) : rawUrl;
    if (url.isEmpty) return null;

    final responseKey = _nullIfEmpty(request['responseKey']);
    if ((method == 'getVerificationCode' || method == 'startBrowserAwait') &&
        responseKey == null) {
      return null;
    }

    return SourceUiPendingRequest(
      method: method,
      url: url,
      imageUrl: imageUrl,
      title: _nullIfEmpty(request['title']),
      mimeType: _nullIfEmpty(request['mimeType']),
      requestKey: _nullIfEmpty(request['requestKey']),
      responseKey: responseKey,
      sourceRegex: _nullIfEmpty(request['sourceRegex']) ??
          _nullIfEmpty(request['overrideUrl']),
      refetchAfterSuccess: _parseBool(request['refetchAfterSuccess']) ?? true,
    );
  }

  static const Set<String> _supportedMethods = {
    'getVerificationCode',
    'startBrowser',
    'startBrowserAwait',
    'openUrl',
  };
}

class SourceUiBridge {
  SourceUiBridge._();

  static const String _uiRequestKey = '__reader_ui_request';
  static const String webviewFallbackKey = '__reader_webview_fallback';

  static final Dio _captchaDio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 30),
      responseType: ResponseType.bytes,
      followRedirects: true,
      validateStatus: (code) => code != null && code >= 200 && code < 400,
    ),
  );

  static SourceUiVerificationPrompt _promptVerificationCodeHook =
      _promptVerificationCode;
  static SourceUiCaptchaImageLoader _captchaImageLoaderHook =
      _defaultLoadVerificationImageBytes;
  static SourceUiInternalBrowser _openInternalBrowserHook =
      _openInternalBrowser;
  static SourceUiBrowserFetcher _fetchBrowserResultHook = _fetchBrowserResult;
  static SourceUiCookieSync _cookieSyncHook = WebViewService.syncCookiesToStore;

  @visibleForTesting
  static void setTestHooks({
    SourceUiVerificationPrompt? promptVerificationCode,
    SourceUiCaptchaImageLoader? captchaImageLoader,
    SourceUiInternalBrowser? openInternalBrowser,
    SourceUiBrowserFetcher? fetchBrowserResult,
    SourceUiCookieSync? cookieSync,
  }) {
    _promptVerificationCodeHook =
        promptVerificationCode ?? _promptVerificationCode;
    _captchaImageLoaderHook =
        captchaImageLoader ?? _defaultLoadVerificationImageBytes;
    _openInternalBrowserHook = openInternalBrowser ?? _openInternalBrowser;
    _fetchBrowserResultHook = fetchBrowserResult ?? _fetchBrowserResult;
    _cookieSyncHook = cookieSync ?? WebViewService.syncCookiesToStore;
  }

  /// Builds an [ImageProvider] for captcha URLs, including `data:image/...;base64,`.
  /// Returns null when the value cannot be decoded as an image source.
  ///
  /// For http(s) without a [db.BookSource], falls back to [NetworkImage]
  /// (no Cookie/header). Prefer [loadVerificationImageBytes] when a source is
  /// available so CookieJar + book-source headers are applied.
  @visibleForTesting
  static ImageProvider? verificationImageProvider(String imageUrl) {
    final url = imageUrl.trim();
    if (url.isEmpty) return null;

    if (url.startsWith('data:image')) {
      final comma = url.indexOf(',');
      if (comma <= 0 || comma >= url.length - 1) return null;
      final meta = url.substring(0, comma).toLowerCase();
      if (!meta.contains(';base64')) return null;
      try {
        final bytes = base64Decode(url.substring(comma + 1));
        if (bytes.isEmpty) return null;
        return MemoryImage(bytes);
      } catch (_) {
        return null;
      }
    }

    final uri = Uri.tryParse(url);
    if (uri == null) return null;
    if (uri.isScheme('http') || uri.isScheme('https')) {
      return NetworkImage(url);
    }
    return null;
  }

  /// Short preview for dialogs: full http(s) URL, truncated data URL, or raw text.
  @visibleForTesting
  static String verificationImageLabel(String imageUrl, {int maxLen = 120}) {
    final url = imageUrl.trim();
    if (url.isEmpty) return '';
    if (url.startsWith('data:image')) {
      final comma = url.indexOf(',');
      final meta = comma > 0 ? url.substring(0, comma) : 'data:image';
      final payloadLen =
          comma > 0 && comma < url.length - 1 ? url.length - comma - 1 : 0;
      return '$meta,...($payloadLen chars)';
    }
    if (url.length <= maxLen) return url;
    return '${url.substring(0, maxLen)}…';
  }

  /// Loads captcha image bytes via the current [SourceUiCaptchaImageLoader] hook
  /// (default: CookieJar + [SourceHttp.buildSourceHeaders] for http(s)).
  @visibleForTesting
  static Future<Uint8List?> loadVerificationImageBytes({
    required db.BookSource source,
    required String imageUrl,
  }) {
    return _captchaImageLoaderHook(source: source, imageUrl: imageUrl);
  }

  /// Default captcha loader:
  /// - `data:image/...;base64,` → local decode
  /// - http(s) → Dio GET with [SourceHttp.buildSourceHeaders] (CookieJar when
  ///   [db.BookSource.enabledCookieJar] is true)
  /// - other / failure → null
  static Future<Uint8List?> _defaultLoadVerificationImageBytes({
    required db.BookSource source,
    required String imageUrl,
  }) async {
    final url = imageUrl.trim();
    if (url.isEmpty) return null;

    if (url.startsWith('data:image')) {
      final provider = verificationImageProvider(url);
      if (provider is MemoryImage) {
        return Uint8List.fromList(provider.bytes);
      }
      return null;
    }

    final uri = Uri.tryParse(url);
    if (uri == null) return null;
    if (!uri.isScheme('http') && !uri.isScheme('https')) return null;

    try {
      final headers = await SourceHttp.buildSourceHeaders(source);
      final timeoutMs =
          SourceCheckPolicy.normalizeRequestTimeoutMs(source.respondTime);
      final response = await _captchaDio.get<List<int>>(
        url,
        options: Options(
          headers: headers,
          sendTimeout: Duration(milliseconds: timeoutMs),
          receiveTimeout: Duration(milliseconds: timeoutMs),
        ),
      );
      final raw = response.data;
      if (raw == null || raw.isEmpty) return null;
      return Uint8List.fromList(raw);
    } catch (_) {
      return null;
    }
  }

  static Future<bool> resolvePendingRequest({
    required db.BookSource source,
    required RuleEngine engine,
    required Map<String, String> variables,
  }) async {
    final responseVars = await resolvePendingRequestForTesting(
      source: source,
      variables: variables,
      promptVerificationCode: _promptVerificationCodeHook,
      openInternalBrowser: _openInternalBrowserHook,
      fetchBrowserResult: _fetchBrowserResultHook,
    );
    if (responseVars == null) return false;
    for (final entry in responseVars.entries) {
      await engine.setSourceVar(key: entry.key, value: entry.value);
    }
    return true;
  }

  @visibleForTesting
  static SourceUiPendingRequest? parsePendingRequestForTesting(
    Map<String, String> variables,
  ) {
    final raw = variables[_uiRequestKey]?.trim();
    if (raw == null || raw.isEmpty) return null;
    final request = _decodeStringObject(raw);
    if (request == null) return null;
    return SourceUiPendingRequest.tryParse(request);
  }

  @visibleForTesting
  static Future<Map<String, String>?> resolvePendingRequestForTesting({
    required db.BookSource source,
    required Map<String, String> variables,
    SourceUiVerificationPrompt? promptVerificationCode,
    SourceUiInternalBrowser? openInternalBrowser,
    SourceUiBrowserFetcher? fetchBrowserResult,
    SourceUiCookieSync? cookieSync,
  }) async {
    final request = parsePendingRequestForTesting(variables);
    if (request == null) return null;

    final prompt = promptVerificationCode ?? _promptVerificationCode;
    final opener = openInternalBrowser ?? _openInternalBrowser;
    final fetcher = fetchBrowserResult ?? _fetchBrowserResult;
    final syncCookies = cookieSync ?? _cookieSyncHook;

    switch (request.method) {
      case 'getVerificationCode':
        final responseKey = request.responseKey;
        if (responseKey == null) return null;
        final code = await prompt(
          source: source,
          imageUrl: request.imageUrl ?? request.url,
        );
        final normalized = (code ?? '').trim();
        return <String, String>{
          responseKey: code ?? '',
          _uiRequestKey: '',
          webviewFallbackKey: normalized.isEmpty
              ? 'getVerificationCode:user_cancelled'
              : 'getVerificationCode:platform_response',
        };
      case 'startBrowserAwait':
        final responseKey = request.responseKey;
        if (responseKey == null) return null;
        final opened = await opener(
          source: source,
          url: request.url,
          title: request.title ?? '浏览器验证',
          captureHtmlOnFinish: !request.refetchAfterSuccess,
          sourceRegex: request.sourceRegex,
        );
        // Login page already syncs on finish; re-flush CookieManager → jar /
        // SourceVariableStore so subsequent ajax/refetch sees session cookies.
        if (opened.success) {
          await ensureCookiesSyncedAfterBrowserSuccess(
            source: source,
            url: request.url,
            syncCookies: syncCookies,
          );
        }
        final html = opened.success
            ? await resolveBrowserAwaitHtmlForTest(
                source: source,
                url: request.url,
                opened: opened,
                refetchAfterSuccess: request.refetchAfterSuccess,
                fetchBrowserResult: fetcher,
              )
            : '';
        return <String, String>{
          responseKey: html,
          _uiRequestKey: '',
          webviewFallbackKey: opened.success
              ? 'startBrowserAwait:platform_response'
              : 'startBrowserAwait:user_cancelled',
        };
      case 'startBrowser':
      case 'openUrl':
        final opened = await opener(
          source: source,
          url: request.url,
          title: request.title ?? source.bookSourceName,
          sourceRegex: request.sourceRegex,
        );
        if (opened.success) {
          await ensureCookiesSyncedAfterBrowserSuccess(
            source: source,
            url: request.url,
            syncCookies: syncCookies,
          );
        }
        return <String, String>{
          _uiRequestKey: '',
          webviewFallbackKey: opened.success
              ? '${request.method}:opened'
              : '${request.method}:user_cancelled',
        };
    }
    return null;
  }

  static Future<String?> _promptVerificationCode({
    required db.BookSource source,
    required String imageUrl,
  }) async {
    final label = verificationImageLabel(imageUrl);
    Uint8List? imageBytes;
    String? loadError;
    try {
      imageBytes = await _captchaImageLoaderHook(
        source: source,
        imageUrl: imageUrl,
      );
      if (imageBytes == null || imageBytes.isEmpty) {
        imageBytes = null;
        loadError = '验证码图片加载失败';
      }
    } catch (_) {
      imageBytes = null;
      loadError = '验证码图片加载失败';
    }

    final context = Get.overlayContext ?? Get.context;
    if (context == null || !context.mounted) return null;

    final controller = TextEditingController();
    try {
      return showDialog<String>(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          final theme = Theme.of(context);
          return AlertDialog(
            title: const Text('输入验证码'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (imageBytes != null)
                  ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxHeight: 160,
                      maxWidth: 280,
                    ),
                    child: Image.memory(
                      imageBytes,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return SelectableText(
                          label.isNotEmpty ? label : imageUrl,
                        );
                      },
                    ),
                  )
                else ...[
                  if (label.isNotEmpty) SelectableText(label),
                  if (loadError != null) ...[
                    if (label.isNotEmpty) const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        loadError,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                      ),
                    ),
                  ],
                ],
                if (imageBytes != null && label.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: SelectableText(
                      label,
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                TextField(
                  controller: controller,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: '验证码',
                    border: OutlineInputBorder(),
                  ),
                  textInputAction: TextInputAction.done,
                  onSubmitted: (value) => Navigator.of(context).pop(value),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(''),
                child: const Text('取消'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(controller.text),
                child: const Text('确定'),
              ),
            ],
          );
        },
      );
    } finally {
      controller.dispose();
    }
  }

  static Future<SourceLoginWebViewResult> _openInternalBrowser({
    required db.BookSource source,
    required String url,
    required String title,
    bool captureHtmlOnFinish = false,
    String? sourceRegex,
  }) async {
    final result = await Get.to<SourceLoginWebViewResult>(
      () => SourceLoginWebViewPage(
        title: title.trim().isNotEmpty ? title.trim() : '浏览器验证',
        url: url,
        sourceKey: source.bookSourceUrl,
        captureHtmlOnFinish: captureHtmlOnFinish,
        sourceRegex: sourceRegex,
      ),
    );
    return result ?? const SourceLoginWebViewResult(success: false);
  }

  static Future<String> _fetchBrowserResult({
    required db.BookSource source,
    required String url,
  }) async {
    try {
      return await WebViewService.fetch(
        url: url,
        sourceKey:
            source.enabledCookieJar == true ? source.bookSourceUrl : null,
        timeout: SourceCheckPolicy.normalizeRequestTimeoutMs(source.respondTime),
      );
    } catch (_) {
      return '';
    }
  }

  @visibleForTesting
  static Future<String> resolveBrowserAwaitHtmlForTest({
    required db.BookSource source,
    required String url,
    required SourceLoginWebViewResult opened,
    required bool refetchAfterSuccess,
    SourceUiBrowserFetcher? fetchBrowserResult,
  }) async {
    if (!opened.success) return '';
    if (!refetchAfterSuccess) return opened.html ?? '';
    final fetcher = fetchBrowserResult ?? _fetchBrowserResult;
    return fetcher(source: source, url: url);
  }

  /// After a successful internal browser (login / startBrowserAwait), re-sync
  /// WebView CookieManager cookies into Dio CookieJar + [SourceVariableStore].
  ///
  /// [SourceLoginWebViewPage] already syncs on load-stop / finish; this is a
  /// belt-and-suspenders flush so platform refetch / ajax sees the session.
  /// Skips when CookieJar is disabled or [url] is empty.
  @visibleForTesting
  static Future<void> ensureCookiesSyncedAfterBrowserSuccess({
    required db.BookSource source,
    required String url,
    Future<void> Function(String url, {String? sourceKey})? syncCookies,
  }) async {
    if (source.enabledCookieJar != true) return;
    final target = url.trim();
    if (target.isEmpty) return;
    final key = source.bookSourceUrl.trim();
    if (key.isEmpty) return;
    final sync = syncCookies ?? _cookieSyncHook;
    try {
      await sync(target, sourceKey: key);
    } catch (_) {
      // Cookie flush is best-effort; browser page already tried once.
    }
  }

  static Map<String, String>? _decodeStringObject(String raw) {
    Object? decoded;
    try {
      decoded = jsonDecode(raw);
    } catch (_) {
      return null;
    }
    if (decoded is! Map) return null;
    final out = <String, String>{};
    decoded.forEach((key, value) {
      if (key == null || value == null) return;
      final name = key.toString().trim();
      if (name.isEmpty) return;
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
}

bool? _parseBool(String? value) {
  final normalized = value?.trim().toLowerCase();
  if (normalized == null || normalized.isEmpty) return null;
  if (normalized == 'true' || normalized == '1') return true;
  if (normalized == 'false' || normalized == '0') return false;
  return null;
}

String? _nullIfEmpty(String? value) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) return null;
  return trimmed;
}
