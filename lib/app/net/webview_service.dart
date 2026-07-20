import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;

import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:reader_nover/app/net/http_client.dart';
import 'package:reader_nover/app/net/request_headers.dart';
import 'package:reader_nover/app/service/source/source_variable_store.dart';
import 'package:reader_nover/util/log_utils.dart';

/// Headless WebView load-stop decision for sourceRegex / overrideUrl modes.
enum WebViewLoadStopAction {
  /// No regex mode — read HTML / run webJs and complete.
  completeHtml,

  /// overrideUrlRegex matched the finished URL — complete with that URL.
  completeOverrideUrl,

  /// sourceRegex or unmatched overrideUrl — wait for match or timeout.
  wait,
}

/// 后台 WebView 服务
/// 用于处理需要 JavaScript 渲染的书源请求
class WebViewService {
  static HeadlessInAppWebView? _headlessWebView;
  static Completer<String>? _completer;
  static bool _isInitialized = false;
  static int _requestGeneration = 0;

  WebViewService._();

  /// Pure success-condition helper for onLoadStop (unit-tested).
  ///
  /// - sourceRegex active → never complete with HTML on load stop (wait for resource)
  /// - overrideUrlRegex active → complete only when [loadedUrl] matches
  /// - neither → complete with HTML/JS result
  @visibleForTesting
  static WebViewLoadStopAction decideLoadStopAction({
    String? sourceRegex,
    String? overrideUrlRegex,
    String? loadedUrl,
  }) {
    final overridePattern = _tryCompileRegex(overrideUrlRegex);
    if (overridePattern != null) {
      final url = loadedUrl?.trim() ?? '';
      if (url.isNotEmpty && overridePattern.hasMatch(url)) {
        return WebViewLoadStopAction.completeOverrideUrl;
      }
      return WebViewLoadStopAction.wait;
    }
    if (_tryCompileRegex(sourceRegex) != null) {
      return WebViewLoadStopAction.wait;
    }
    return WebViewLoadStopAction.completeHtml;
  }

  @visibleForTesting
  static bool matchesSourceResource({
    required String? sourceRegex,
    required String resourceUrl,
  }) {
    final pattern = _tryCompileRegex(sourceRegex);
    if (pattern == null) return false;
    final url = resourceUrl.trim();
    return url.isNotEmpty && pattern.hasMatch(url);
  }

  @visibleForTesting
  static bool matchesOverrideUrl({
    required String? overrideUrlRegex,
    required String requestUrl,
  }) {
    final pattern = _tryCompileRegex(overrideUrlRegex);
    if (pattern == null) return false;
    final url = requestUrl.trim();
    return url.isNotEmpty && pattern.hasMatch(url);
  }

  static RegExp? _tryCompileRegex(String? raw) {
    final text = raw?.trim();
    if (text == null || text.isEmpty) return null;
    try {
      return RegExp(text);
    } catch (_) {
      return null;
    }
  }

  /// 初始化 WebView（应在 app 启动时调用）
  static Future<void> init() async {
    if (_isInitialized) return;

    // Web 平台不支持 HeadlessInAppWebView
    if (kIsWeb) {
      LogUtils.d('WebViewService: Web 平台不支持后台 WebView');
      return;
    }

    try {
      // Android 平台需要初始化
      if (defaultTargetPlatform == TargetPlatform.android) {
        await InAppWebViewController.setWebContentsDebuggingEnabled(kDebugMode);
      }
      _isInitialized = true;
      LogUtils.d('WebViewService 初始化成功');
    } catch (e) {
      LogUtils.e('WebViewService 初始化失败: $e');
    }
  }

  /// 使用 WebView 获取页面内容
  ///
  /// [url] 请求地址
  /// [headers] 请求头
  /// [webJs] 页面加载完成后执行的 JavaScript 代码
  /// [delayTime] 页面加载后的延迟时间（毫秒），用于等待 JS 渲染
  /// [timeout] 超时时间（毫秒）
  /// [sourceRegex] 源正则表达式（可选，用于匹配特定内容）
  /// [overrideUrlRegex] 跳转 URL 正则表达式（可选，用于匹配重定向后的地址）
  /// [sourceKey] 书源 key，用于将 webView cookie 同步到 sourceVariable
  static Future<String> fetch({
    required String url,
    Map<String, String>? headers,
    String? html,
    String? webJs,
    String? method,
    String? body,
    int delayTime = 1000,
    int timeout = 30000,
    String? sourceRegex,
    String? overrideUrlRegex,
    String? sourceKey,
  }) async {
    if (kIsWeb) {
      throw UnsupportedError('Web 平台不支持后台 WebView');
    }

    if (!_isInitialized) {
      await init();
    }

    // 确保之前的请求已完成
    if (_completer != null && !_completer!.isCompleted) {
      _completer!.completeError('请求被新请求取代');
    }
    _disposeWebView();

    final requestGeneration = ++_requestGeneration;
    _completer = Completer<String>();
    final requestHeaders = RequestHeaders.build(headers);
    final requestMethod = method?.trim().toUpperCase();
    final effectiveMethod =
        requestMethod == null || requestMethod.isEmpty ? null : requestMethod;

    RegExp? sourceRegexPattern;
    if (sourceRegex != null && sourceRegex.trim().isNotEmpty) {
      try {
        sourceRegexPattern = RegExp(sourceRegex.trim());
      } catch (_) {
        LogUtils.d('WebView sourceRegex 无效: $sourceRegex');
      }
    }
    RegExp? overrideUrlRegexPattern;
    if (overrideUrlRegex != null && overrideUrlRegex.trim().isNotEmpty) {
      try {
        overrideUrlRegexPattern = RegExp(overrideUrlRegex.trim());
      } catch (_) {
        LogUtils.d('WebView overrideUrlRegex 无效: $overrideUrlRegex');
      }
    }
    final initialHtml = html?.trim().isNotEmpty == true ? html : null;
    final baseUrl = url.trim().isNotEmpty ? url.trim() : 'about:blank';

    try {
      late final Timer timeoutTimer;
      Timer? initialDataFallbackTimer;
      var initialDataLoaded = false;

      bool isActiveRequest() {
        return requestGeneration == _requestGeneration &&
            _completer != null &&
            !_completer!.isCompleted;
      }

      Future<String?> readHtmlWhenReady(
        InAppWebViewController controller, {
        int maxWaitMs = 1500,
      }) async {
        final deadline = DateTime.now().add(Duration(milliseconds: maxWaitMs));
        while (DateTime.now().isBefore(deadline) && isActiveRequest()) {
          final result = await controller.evaluateJavascript(
            source:
                'document.documentElement && document.documentElement.outerHTML',
          );
          final text = _jsResultToString(result).trim();
          if (text.isNotEmpty &&
              text != 'null' &&
              text != 'undefined' &&
              text != '<html><head></head><body></body></html>') {
            return text;
          }
          await Future.delayed(const Duration(milliseconds: 100));
        }
        return null;
      }

      Future<String?> evaluateWebJsWhenReady(
        InAppWebViewController controller,
      ) async {
        final deadline = DateTime.now().add(Duration(milliseconds: timeout));
        while (DateTime.now().isBefore(deadline) && isActiveRequest()) {
          final jsResult = await controller.evaluateJavascript(
            source: _wrapJavaScript(webJs!),
          );
          final jsText = _jsResultToString(jsResult).trim();
          if (jsText.isNotEmpty && jsText != 'null' && jsText != 'undefined') {
            return jsText;
          }
          await Future.delayed(const Duration(milliseconds: 100));
        }
        return null;
      }

      Future<void> completeFromController(
        InAppWebViewController controller,
        String? loadedUrl,
      ) async {
        await Future.delayed(Duration(milliseconds: delayTime));

        if (!isActiveRequest()) return;

        try {
          final result = webJs != null && webJs.isNotEmpty
              ? await evaluateWebJsWhenReady(controller)
              : await readHtmlWhenReady(controller);

          final cookieUrl = loadedUrl?.trim().isNotEmpty == true
              ? loadedUrl!.trim()
              : baseUrl;
          await _syncCookiesToHttp(cookieUrl, sourceKey: sourceKey);

          timeoutTimer.cancel();
          initialDataFallbackTimer?.cancel();

          if (isActiveRequest()) {
            _completer!.complete(result ?? '');
          }
        } catch (e) {
          LogUtils.e('WebView 执行 JS 失败: $e');
          timeoutTimer.cancel();
          initialDataFallbackTimer?.cancel();
          if (isActiveRequest()) {
            _completer!.completeError('执行 JS 失败: $e');
          }
        } finally {
          _disposeWebView(requestGeneration);
        }
      }

      timeoutTimer = Timer(Duration(milliseconds: timeout), () {
        if (isActiveRequest()) {
          _completer!.completeError('WebView 请求超时');
          initialDataFallbackTimer?.cancel();
          _disposeWebView(requestGeneration);
        }
      });

      _headlessWebView = HeadlessInAppWebView(
        initialData: initialHtml == null
            ? null
            : InAppWebViewInitialData(
                data: initialHtml,
                baseUrl: WebUri(baseUrl),
                historyUrl: WebUri(baseUrl),
              ),
        initialUrlRequest: initialHtml != null
            ? null
            : URLRequest(
                url: WebUri(baseUrl),
                method: effectiveMethod,
                body:
                    body == null ? null : Uint8List.fromList(utf8.encode(body)),
                headers: requestHeaders,
              ),
        initialSettings: InAppWebViewSettings(
          javaScriptEnabled: true,
          domStorageEnabled: true,
          databaseEnabled: true,
          cacheEnabled: true,
          userAgent: RequestHeaders.getHeaderValue(
                requestHeaders,
                'User-Agent',
              ) ??
              RequestHeaders.defaultUserAgent,
          blockNetworkImage: sourceRegexPattern == null,
          mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
          useOnLoadResource: sourceRegexPattern != null,
          useShouldOverrideUrlLoading: overrideUrlRegexPattern != null,
        ),
        onWebViewCreated: (controller) {
          LogUtils.d('WebView 创建成功: $baseUrl');
          if (initialHtml != null &&
              sourceRegexPattern == null &&
              overrideUrlRegexPattern == null) {
            initialDataFallbackTimer = Timer(
              Duration(milliseconds: delayTime + 1200),
              () {
                if (!initialDataLoaded && isActiveRequest()) {
                  completeFromController(controller, baseUrl);
                }
              },
            );
          }
        },
        onLoadStart: (controller, loadedUrl) {
          LogUtils.d('WebView 开始加载: $loadedUrl');
        },
        shouldOverrideUrlLoading: overrideUrlRegexPattern != null
            ? (controller, navigationAction) async {
                final requestUrl =
                    navigationAction.request.url?.toString() ?? '';
                if (matchesOverrideUrl(
                      overrideUrlRegex: overrideUrlRegex,
                      requestUrl: requestUrl,
                    ) &&
                    isActiveRequest()) {
                  LogUtils.d('WebView overrideUrlRegex 匹配: $requestUrl');
                  timeoutTimer.cancel();
                  initialDataFallbackTimer?.cancel();
                  await _syncCookiesToHttp(requestUrl, sourceKey: sourceKey);
                  if (isActiveRequest()) {
                    _completer!.complete(requestUrl);
                  }
                  _disposeWebView(requestGeneration);
                  return NavigationActionPolicy.CANCEL;
                }
                return NavigationActionPolicy.ALLOW;
              }
            : null,
        onLoadResource: sourceRegexPattern != null
            ? (controller, resource) async {
                final resUrl = resource.url?.toString() ?? '';
                if (matchesSourceResource(
                      sourceRegex: sourceRegex,
                      resourceUrl: resUrl,
                    ) &&
                    isActiveRequest()) {
                  LogUtils.d('WebView sourceRegex 匹配: $resUrl');
                  timeoutTimer.cancel();
                  initialDataFallbackTimer?.cancel();
                  final cookieUrl = (await controller.getUrl())?.toString() ??
                      baseUrl;
                  await _syncCookiesToHttp(cookieUrl, sourceKey: sourceKey);
                  if (isActiveRequest()) {
                    _completer!.complete(resUrl);
                  }
                  _disposeWebView(requestGeneration);
                }
              }
            : null,
        onLoadStop: (controller, loadedUrl) async {
          LogUtils.d('WebView 加载完成: $loadedUrl');
          initialDataLoaded = true;

          final loadedUrlText = loadedUrl?.toString();
          final action = decideLoadStopAction(
            sourceRegex: sourceRegex,
            overrideUrlRegex: overrideUrlRegex,
            loadedUrl: loadedUrlText,
          );
          switch (action) {
            case WebViewLoadStopAction.completeOverrideUrl:
              if (isActiveRequest() &&
                  loadedUrlText != null &&
                  loadedUrlText.isNotEmpty) {
                timeoutTimer.cancel();
                initialDataFallbackTimer?.cancel();
                await _syncCookiesToHttp(loadedUrlText, sourceKey: sourceKey);
                if (isActiveRequest()) {
                  _completer!.complete(loadedUrlText);
                }
                _disposeWebView(requestGeneration);
              }
              return;
            case WebViewLoadStopAction.wait:
              // sourceRegex / unmatched override: wait for match or timeout.
              return;
            case WebViewLoadStopAction.completeHtml:
              await completeFromController(controller, loadedUrlText);
              return;
          }
        },
        onReceivedError: (controller, request, error) {
          final code = error.type.toNativeValue();
          final message = error.description;
          final requestUrl = request.url.toString();
          if (request.isForMainFrame != true) {
            LogUtils.d('WebView 子资源加载错误: $code - $message - $requestUrl');
            return;
          }
          LogUtils.e('WebView 主页面加载错误: $code - $message - $requestUrl');
          timeoutTimer.cancel();
          initialDataFallbackTimer?.cancel();
          if (isActiveRequest()) {
            _completer!.completeError('WebView 加载失败: $message');
          }
          _disposeWebView(requestGeneration);
        },
        onReceivedHttpError: (controller, request, errorResponse) {
          final statusCode = errorResponse.statusCode ?? -1;
          final description = errorResponse.reasonPhrase ?? 'HTTP 请求失败';
          final requestUrl = request.url.toString();
          if (request.isForMainFrame == true) {
            LogUtils.d(
                'WebView 主页面 HTTP 状态: $statusCode - $description - $requestUrl');
          } else {
            LogUtils.d(
                'WebView 子资源 HTTP 状态: $statusCode - $description - $requestUrl');
          }
        },
      );

      // 启动 WebView
      await _headlessWebView!.run();

      return await _completer!.future;
    } catch (e) {
      LogUtils.e('WebView 请求失败: $e');
      _disposeWebView(requestGeneration);
      rethrow;
    }
  }

  /// 释放 WebView 资源
  static void _disposeWebView([int? requestGeneration]) {
    if (requestGeneration != null && requestGeneration != _requestGeneration) {
      return;
    }
    try {
      final webView = _headlessWebView;
      _headlessWebView = null;
      if (webView != null) {
        unawaited(webView.dispose());
      }
    } catch (e) {
      LogUtils.e('释放 WebView 失败: $e');
    }
  }

  /// 清理所有资源
  static void dispose() {
    _disposeWebView();
    if (_completer != null && !_completer!.isCompleted) {
      _completer!.completeError('WebViewService 已销毁');
    }
    _completer = null;
  }

  static String _wrapJavaScript(String script) {
    return '''
(function() {
  var src = document.documentElement.outerHTML;
  var baseUrl = location.href;
  var __readerScript = ${jsonEncode(script)};
  var __readerOut;
  try {
    __readerOut = eval(__readerScript);
  } catch (__readerEvalError) {
    __readerOut = (function() {
$script
    })();
  }
  if (__readerOut === undefined || __readerOut === null) return '';
  if (typeof __readerOut === 'string') return __readerOut;
  return String(__readerOut);
})()
''';
  }

  static String _jsResultToString(Object? result) {
    if (result == null) return '';
    if (result is String) {
      final text = result.trim();
      if (text.length >= 2 &&
          ((text.startsWith('"') && text.endsWith('"')) ||
              (text.startsWith("'") && text.endsWith("'")))) {
        try {
          final decoded = jsonDecode(text);
          if (decoded is String) return decoded;
        } catch (_) {}
      }
      return result;
    }
    return result.toString();
  }

  static Future<void> syncCookiesToStore(
    String url, {
    String? sourceKey,
  }) {
    return _syncCookiesToHttp(url, sourceKey: sourceKey);
  }

  static Future<void> _syncCookiesToHttp(
    String url, {
    String? sourceKey,
  }) async {
    final uri = Uri.tryParse(url);
    if (uri == null || uri.host.isEmpty) {
      return;
    }
    try {
      final manager = CookieManager.instance();
      final cookies = await manager.getCookies(url: WebUri(uri.toString()));
      if (cookies.isEmpty) return;

      final ioCookies = <io.Cookie>[];
      for (final c in cookies) {
        final cookie = io.Cookie(c.name, c.value?.toString() ?? '');
        if ((c.domain ?? '').isNotEmpty) {
          cookie.domain = c.domain!;
        }
        if ((c.path ?? '').isNotEmpty) {
          cookie.path = c.path!;
        }
        cookie.secure = c.isSecure ?? false;
        cookie.httpOnly = c.isHttpOnly ?? false;
        final expiresDate = c.expiresDate;
        if (expiresDate != null && expiresDate > 0) {
          cookie.expires = DateTime.fromMillisecondsSinceEpoch(
            expiresDate,
            isUtc: true,
          );
        }
        ioCookies.add(cookie);
      }
      if (ioCookies.isNotEmpty) {
        await Http.instance.cookieJar.saveFromResponse(uri, ioCookies);
        if ((sourceKey ?? '').trim().isNotEmpty) {
          await SourceVariableStore.syncFromCookieJar(
              sourceKey!, uri.toString());
        }
      }
    } catch (e) {
      LogUtils.d('WebView cookie 同步失败: $e');
    }
  }
}
