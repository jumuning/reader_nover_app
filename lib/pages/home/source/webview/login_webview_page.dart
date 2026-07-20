import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:reader_nover/app/net/webview_service.dart';
import 'package:reader_nover/util/log_utils.dart';

class SourceLoginWebViewPage extends StatefulWidget {
  final String title;
  final String url;
  final String sourceKey;
  final bool captureHtmlOnFinish;
  final String? initialHtml;
  /// When the current URL matches this regex, auto-finish (Legado sourceRegex).
  ///
  /// Matching is pure URL-level ([matchesSourceRegexUrl]); no DOM/slider.
  /// Hits on [onLoadStop] and SPA [onUpdateVisitedHistory]; finish always
  /// flushes cookies first via [WebViewService.syncCookiesToStore].
  final String? sourceRegex;

  const SourceLoginWebViewPage({
    super.key,
    required this.title,
    required this.url,
    required this.sourceKey,
    this.captureHtmlOnFinish = false,
    this.initialHtml,
    this.sourceRegex,
  });

  @override
  State<SourceLoginWebViewPage> createState() => _SourceLoginWebViewPageState();

  /// Pure URL match for Legado `sourceRegex` (auto-complete login WebView).
  /// Invalid patterns fall back to escaped literal substring match.
  @visibleForTesting
  static bool matchesSourceRegexUrl(String? sourceRegex, String url) {
    final re = compileSourceRegex(sourceRegex);
    if (re == null || url.isEmpty) return false;
    return re.hasMatch(url);
  }

  @visibleForTesting
  static RegExp? compileSourceRegex(String? raw) {
    final pattern = raw?.trim() ?? '';
    if (pattern.isEmpty) return null;
    try {
      return RegExp(pattern);
    } catch (_) {
      // Treat as literal substring match when regex is invalid.
      return RegExp(RegExp.escape(pattern));
    }
  }
}

class SourceLoginWebViewResult {
  const SourceLoginWebViewResult({
    required this.success,
    this.html,
  });

  final bool success;
  final String? html;

  static String jsResultToString(dynamic value) {
    if (value == null) return '';
    if (value is String) {
      final text = value.trim();
      if (text.length >= 2 &&
          ((text.startsWith('"') && text.endsWith('"')) ||
              (text.startsWith("'") && text.endsWith("'")))) {
        try {
          final decoded = jsonDecode(text);
          if (decoded is String) return decoded;
        } catch (_) {}
      }
      return value;
    }
    return value.toString();
  }
}

class _SourceLoginWebViewPageState extends State<SourceLoginWebViewPage> {
  InAppWebViewController? _controller;
  String _currentUrl = '';
  double _progress = 0;
  bool _syncing = false;
  bool _finishing = false;
  RegExp? _sourceRegex;

  @override
  void initState() {
    super.initState();
    _currentUrl = widget.url;
    _sourceRegex = SourceLoginWebViewPage.compileSourceRegex(widget.sourceRegex);
  }

  bool _urlMatchesSourceRegex(String url) {
    final re = _sourceRegex;
    if (re == null || url.isEmpty) return false;
    return re.hasMatch(url);
  }

  Future<void> _syncCookies([String? url]) async {
    if (_syncing) return;
    final targetUrl = (url ?? _currentUrl).trim();
    if (targetUrl.isEmpty) return;
    _syncing = true;
    try {
      await WebViewService.syncCookiesToStore(
        targetUrl,
        sourceKey: widget.sourceKey,
      );
    } catch (e) {
      LogUtils.d('登录页同步 cookie 失败: $e');
    } finally {
      _syncing = false;
    }
  }

  /// Completes login: **always** sync cookies before pop so
  /// `startBrowserAwait` / subsequent requests see the session.
  Future<void> _finishLogin({bool auto = false}) async {
    if (_finishing) return;
    _finishing = true;
    await _syncCookies();
    String? html;
    if (widget.captureHtmlOnFinish) {
      try {
        final result = await _controller?.evaluateJavascript(
          source: 'document.documentElement.outerHTML',
        );
        html = SourceLoginWebViewResult.jsResultToString(result);
        if (html.trim().isEmpty &&
            widget.initialHtml?.trim().isNotEmpty == true) {
          html = widget.initialHtml;
        }
      } catch (e) {
        LogUtils.d('登录页读取 HTML 失败: $e');
        if (widget.initialHtml?.trim().isNotEmpty == true) {
          html = widget.initialHtml;
        }
      }
    }
    if (!mounted) return;
    Navigator.of(context).pop(
      SourceLoginWebViewResult(
        success: true,
        html: html,
      ),
    );
  }

  Future<void> _maybeAutoFinish(String url) async {
    if (!_urlMatchesSourceRegex(url)) return;
    LogUtils.d('登录页 sourceRegex 命中，自动完成: $url');
    await _finishLogin(auto: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            tooltip: '刷新',
            icon: const Icon(Icons.refresh),
            onPressed: () => _controller?.reload(),
          ),
          IconButton(
            tooltip: '完成',
            icon: const Icon(Icons.check),
            onPressed: _finishLogin,
          ),
        ],
        bottom: _progress < 1
            ? PreferredSize(
                preferredSize: const Size.fromHeight(2),
                child: LinearProgressIndicator(
                  value: _progress <= 0 ? null : _progress,
                  minHeight: 2,
                ),
              )
            : null,
      ),
      body: InAppWebView(
        initialData: widget.initialHtml?.trim().isNotEmpty == true
            ? InAppWebViewInitialData(
                data: widget.initialHtml!,
                baseUrl: WebUri(widget.url),
                historyUrl: WebUri(widget.url),
              )
            : null,
        initialUrlRequest: widget.initialHtml?.trim().isNotEmpty == true
            ? null
            : URLRequest(url: WebUri(widget.url)),
        initialSettings: InAppWebViewSettings(
          javaScriptEnabled: true,
          domStorageEnabled: true,
          databaseEnabled: true,
          allowsBackForwardNavigationGestures: true,
        ),
        onWebViewCreated: (controller) {
          _controller = controller;
          if (widget.initialHtml?.trim().isNotEmpty == true) {
            controller
                .loadData(
              data: widget.initialHtml!,
              encoding: 'utf-8',
              baseUrl: WebUri(widget.url),
              historyUrl: WebUri(widget.url),
            )
                .catchError((e) {
              LogUtils.d('登录页 loadData 兜底失败: $e');
            });
          }
        },
        onLoadStop: (controller, url) async {
          final loadedUrl = url?.toString() ?? '';
          if (loadedUrl.isNotEmpty) {
            _currentUrl = loadedUrl;
          }
          await _syncCookies(loadedUrl);
          if (mounted) {
            setState(() {
              _progress = 1;
            });
          }
          await _maybeAutoFinish(loadedUrl);
        },
        onProgressChanged: (controller, progress) {
          if (!mounted) return;
          setState(() {
            _progress = (progress / 100).clamp(0, 1);
          });
        },
        onUpdateVisitedHistory: (controller, url, _) {
          final visitedUrl = url?.toString() ?? '';
          if (visitedUrl.isNotEmpty) {
            _currentUrl = visitedUrl;
            // SPA navigations may not fire onLoadStop; still try auto-finish.
            _maybeAutoFinish(visitedUrl);
          }
        },
      ),
    );
  }
}
