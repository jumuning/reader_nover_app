import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:reader_nover/app/database/drift/app_database.dart' as db;
import 'package:reader_nover/app/database/models/models.dart';
import 'package:reader_nover/rust/api/rule_engine.dart' hide BookInfo;
import 'package:reader_nover/rust/entities/rules.dart';
import 'package:reader_nover/util/http_cache_manager.dart';
import 'package:reader_nover/util/log_utils.dart';
import 'source_check_policy.dart';
import 'source_http.dart';
import 'source_image_decoder.dart';

/// 章节正文加载服务（含分页支持）。
class WebContentService {
  static final db.AppDatabase _db = db.AppDatabase.instance;

  WebContentService._();

  /// 执行正文 `payAction`（Legado 付费/登录动作），成功返回 true。
  static Future<bool> executePayAction(
    db.BookSource source,
    BookChapterInfo chapter, {
    CancelToken? cancelToken,
  }) async {
    final ruleContent = await (_db.select(_db.ruleContents)
          ..where((t) => t.bookSourceId.equals(source.id)))
        .getSingleOrNull();
    final script = ruleContent?.payAction?.trim() ?? '';
    if (script.isEmpty) return false;

    final sourceHeaders = await SourceHttp.buildSourceHeaders(source);
    final contentBookUrl = _resolveContentBookUrl(
      chapter: chapter,
      cachedVars: SourceHttp.getChapterRuleVariables(
        sourceId: source.id,
        chapterUrl: chapter.chapterUrl,
      ),
    );
    final engine = await SourceHttp.newRuleEngine(
      source,
      sourceHeaders: sourceHeaders,
      bookUrl: contentBookUrl,
    );
    await SourceHttp.syncVariablesToRuleEngine(
      engine,
      {
        ...?SourceHttp.getChapterRuleVariables(
          sourceId: source.id,
          chapterUrl: chapter.chapterUrl,
        ),
        if (contentBookUrl != null) 'bookUrl': contentBookUrl,
      },
    );
    await _syncChapterContextToRuleEngine(
      engine: engine,
      chapter: chapter,
      nextChapterUrl: null,
    );

    final wrapped = script.toLowerCase().startsWith('@js:') ||
            script.toLowerCase().startsWith('<js>')
        ? "$script; '__reader_pay_action_done'"
        : "@js:\n$script\n'__reader_pay_action_done'";

    await SourceHttp.runWithWebViewBridge(
      source: source,
      engine: engine,
      sourceHeaders: sourceHeaders,
      cancelToken: cancelToken,
      parse: () => engine.parseExploreKinds(exploreUrl: wrapped),
    );
    await SourceHttp.persistRuleEngineVariables(source, engine);
    return true;
  }

  // ── HTML 格式化正则（对齐 Legado HtmlFormatter / Rust content_formatter）──

  static final _nbspRe = RegExp(r'(&nbsp;)+', caseSensitive: false);
  static final _espRe = RegExp(r'&ensp;|&emsp;', caseSensitive: false);
  static final _thinspRe = RegExp(
    r'&thinsp;|&zwnj;|&zwj;|\u2009|\u200c|\u200d',
    caseSensitive: false,
  );
  static final _noPrintRe = RegExp(r'[\x00-\x08\x0b\x0c\x0e-\x1f]');
  /// 块级/换行标签 → 换行。`\b` 防止误伤 brew 等单词前缀。
  static final _wrapHtmlRe = RegExp(
    r'</?(?:p|br|hr|div|td|tr|li|ul|ol|blockquote|article|section|dd|dl|dt|h[1-6])\b[^>]*/?>',
    caseSensitive: false,
  );
  static final _commentRe = RegExp(r'<!--[\s\S]*?-->');
  static final _scriptRe = RegExp(
    r'<script\b[^>]*>[\s\S]*?</script>',
    caseSensitive: false,
  );
  static final _styleRe = RegExp(
    r'<style\b[^>]*>[\s\S]*?</style>',
    caseSensitive: false,
  );
  static final _noscriptRe = RegExp(
    r'<noscript\b[^>]*>[\s\S]*?</noscript>',
    caseSensitive: false,
  );
  /// 任意 HTML 标签（开/闭/自闭合）；回调中保留 img。
  static final _anyHtmlTagRe = RegExp(
    r'</?[a-zA-Z][^>]*/?>',
    caseSensitive: false,
  );
  static final _imgOpenRe = RegExp(r'^<img\b', caseSensitive: false);
  /// 全角书名号形态的 br（部分站点转义后出现）。
  static final _fullwidthBrRe = RegExp(
    r'＜\s*br\s*/?\s*＞',
    caseSensitive: false,
  );
  /// 反转义后仍可能残留的非 img 标签（轻量二次清洗）。
  static final _residualNonImgTagRe = RegExp(
    r'</?(?!img\b)[a-zA-Z][^>]*/?>',
    caseSensitive: false,
  );
  static final _imgSrcRe = RegExp(
    r'<img\s[^>]*?src\s*=\s*["\x27]([^"\x27]+)["\x27][^>]*>',
    caseSensitive: false,
  );
  static final _indent1Re = RegExp(r'\s*\n+\s*');
  static final _indent2Re = RegExp(r'^[\n\s]+');
  static final _trailingRe = RegExp(r'[\n\s]+$');

  // ── HTML 实体反转义正则 ──

  static final _numericEntityRe = RegExp(r'&#(\d+);');
  static final _hexEntityRe = RegExp(r'&#x([0-9a-fA-F]+);', caseSensitive: false);

  /// 获取正文内容。
  ///
  /// [skipNextPage] 为 true 时跳过分页加载，只获取首页内容（用于校验）
  /// [nextChapterUrl] 下一章 URL，注入规则引擎上下文供规则引用
  static Future<String> getContent(
    db.BookSource source,
    BookChapterInfo chapter, {
    CancelToken? cancelToken,
    bool skipNextPage = false,
    String? nextChapterUrl,
    bool forceRefresh = false,
    bool forCheck = false,
  }) async {
    final ruleContent = await (_db.select(_db.ruleContents)
          ..where((t) => t.bookSourceId.equals(source.id)))
        .getSingleOrNull();

    if (ruleContent?.content?.isEmpty != false) {
      return chapter.chapterUrl ?? '';
    }

    final cachedChapterVars = SourceHttp.getChapterRuleVariables(
      sourceId: source.id,
      chapterUrl: chapter.chapterUrl,
    );
    final request = await SourceHttp.prepareRequest(
      source: source,
      url: chapter.chapterUrl ?? '',
      baseUrl: _contentRequestBaseUrl(
        chapter: chapter,
        cachedVars: cachedChapterVars,
      ),
      chapter: chapter,
    );
    final sourceHeaders = request.sourceHeaders;
    final contentBookUrl = _resolveContentBookUrl(
      chapter: chapter,
      cachedVars: cachedChapterVars,
    );
    final engine = await SourceHttp.newRuleEngine(
      source,
      sourceHeaders: sourceHeaders,
      bookUrl: contentBookUrl,
    );
    await SourceHttp.syncVariablesToRuleEngine(
      engine,
      {
        ...?cachedChapterVars,
        if (contentBookUrl != null) 'bookUrl': contentBookUrl,
      },
    );
    await _syncChapterContextToRuleEngine(
      engine: engine,
      chapter: chapter,
      nextChapterUrl: nextChapterUrl,
    );
    await SourceHttp.syncUrlVariablesToRuleEngine(engine, request.urlResult);
    final cachePolicy = (forCheck || forceRefresh)
        ? const HttpCachePolicy(
            scene: HttpCacheScene.chapterContent,
            enableDeduplication: false,
          )
        : null;

    late final FetchedPage firstFetch;
    try {
      firstFetch = await SourceHttp.fetchPreparedPage(
        source: source,
        request: request,
        cancelToken: cancelToken,
        engine: engine,
        overrideWebJs: ruleContent?.webJs,
        sourceRegex: ruleContent?.sourceRegex,
        cacheScene: HttpCacheScene.chapterContent,
        cachePolicy: cachePolicy,
      );
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) rethrow;
      if (!_isJsOnlyContentRule(ruleContent?.content)) rethrow;
      firstFetch = FetchedPage(html: '', finalUrl: request.url);
    } catch (_) {
      if (!_isJsOnlyContentRule(ruleContent?.content)) rethrow;
      firstFetch = FetchedPage(html: '', finalUrl: request.url);
    }

    final extractionRule = ContentRule(
      content: ruleContent?.content,
    );

    final paginationRule = ContentRule(
      content: ruleContent?.content,
      nextContentUrl: ruleContent?.nextContentUrl,
    );

    // ── 第一步：仅用 content 规则提取首页 ──
    ChapterContent? result = await SourceHttp.runWithWebViewBridge(
      source: source,
      engine: engine,
      sourceHeaders: sourceHeaders,
      cancelToken: cancelToken,
      parse: () => engine.extractContent(
        html: firstFetch.html,
        rule: extractionRule,
        baseUrl: firstFetch.finalUrl,
      ),
    );

    if (result == null || result.content.trim().isEmpty) {
      for (final fallbackRule
          in _buildFallbackContentRules(ruleContent?.content ?? '')) {
        final fallbackResult = await SourceHttp.runWithWebViewBridge(
          source: source,
          engine: engine,
          sourceHeaders: sourceHeaders,
          cancelToken: cancelToken,
          parse: () => engine.extractContent(
            html: firstFetch.html,
            rule: ContentRule(content: fallbackRule),
            baseUrl: firstFetch.finalUrl,
          ),
        );
        if (fallbackResult != null &&
            fallbackResult.content.trim().isNotEmpty) {
          result = fallbackResult;
          break;
        }
      }
    }

    if (result == null || result.content.trim().isEmpty) {
      final fallbackResult = await _tryWtzwDartContentFallback(
        source: source,
        sourceHeaders: sourceHeaders,
        chapter: chapter,
        engine: engine,
        cachePolicy: cachePolicy,
        cancelToken: cancelToken,
      );
      if (fallbackResult != null && fallbackResult.content.trim().isNotEmpty) {
        result = fallbackResult;
      }
    }

    // P1-fix: formatKeepImg 保留 img 标签 + P2-fix: HTML 实体反转义
    if (result == null || result.content.trim().isEmpty) {
      final debugVars = await SourceHttp.snapshotRuleVariables(engine);
      final responseSummary = _jsonResponseSummary(firstFetch.html);
      final responseDiagnostics = _jsonResponseDiagnostics(firstFetch.html);
      final responseJsonPart =
          responseSummary.isNotEmpty ? 'responseJson=$responseSummary, ' : '';
      throw CheckException(
        '正文失效',
        '正文解析结果为空: '
            'bid=${debugVars['bid'] ?? ""}, '
            'bookId=${debugVars['bookId'] ?? ""}, '
            'hasHeaders=${(debugVars['headers'] ?? "").isNotEmpty}, '
            'chapterUrl=${chapter.chapterUrl ?? ""}, '
            'finalUrl=${firstFetch.finalUrl}, '
            'responseLength=${firstFetch.html.length}, '
            '$responseJsonPart'
            'response=${_shortDebugText(firstFetch.html)}',
        diagnostics: <String, Object?>{
          'response_length': firstFetch.html.length,
          ...responseDiagnostics,
        },
      );
    }

    if (forCheck) {
      return result.content;
    }

    String formattedContent =
        _formatAndUnescapeContent(result.content, firstFetch.finalUrl);

    // ── 第二步：多页内容加载 ──
    if (!skipNextPage) {
      final nextContentRule = ruleContent?.nextContentUrl?.trim() ?? '';
      if (nextContentRule.isNotEmpty) {
        final nextSeed = await SourceHttp.runWithWebViewBridge(
          source: source,
          engine: engine,
          sourceHeaders: sourceHeaders,
          cancelToken: cancelToken,
          parse: () => engine.extractContent(
            html: firstFetch.html,
            rule: ContentRule(
              content: '@js:result',
              nextContentUrl: nextContentRule,
            ),
            baseUrl: firstFetch.finalUrl,
          ),
        );
        final rawNextUrl = nextSeed?.nextUrl;

        if (rawNextUrl != null && rawNextUrl.isNotEmpty) {
          // P3-fix: 支持多 URL（换行分隔）
          final nextUrlList = rawNextUrl
              .split('\n')
              .map((u) => u.trim())
              .where((u) => u.isNotEmpty)
              .map((u) => resolveUrl(base: firstFetch.finalUrl, href: u))
              .where((u) => !_isNextChapterUrl(u, nextChapterUrl))
              .toList();

          if (nextUrlList.length <= 1) {
            formattedContent = await _loadPagesSerial(
              firstPageContent: formattedContent,
              nextUrlList: nextUrlList,
              engine: engine,
              contentRule: paginationRule,
              source: source,
              sourceHeaders: sourceHeaders,
              baseUrl: firstFetch.finalUrl,
              cancelToken: cancelToken,
              cachePolicy: cachePolicy,
              nextChapterUrl: nextChapterUrl,
            );
          } else {
            formattedContent = await _loadPagesConcurrent(
              firstPageContent: formattedContent,
              nextUrlList: nextUrlList,
              engine: engine,
              contentRule: paginationRule,
              source: source,
              sourceHeaders: sourceHeaders,
              cancelToken: cancelToken,
              cachePolicy: cachePolicy,
              nextChapterUrl: nextChapterUrl,
            );
          }
        }
      }
    }

    // ── 第三步：对合并后的完整内容统一应用 replaceRegex ──
    formattedContent = await _applyReplaceRegexWithEngine(
      engine: engine,
      content: formattedContent,
      replaceRegex: ruleContent?.replaceRegex,
      baseUrl: firstFetch.finalUrl,
    );

    // ── 第四步：正文图片 imageDecode（失败回退原 URL）──
    formattedContent = await _decodeContentImagesIfNeeded(
      source: source,
      html: formattedContent,
      imageDecodeJs: ruleContent?.imageDecode,
      cancelToken: cancelToken,
    );
    await SourceHttp.persistRuleEngineVariables(source, engine);

    return formattedContent;
  }

  /// 将 `<img src>` 拉取后经 imageDecode JS 解密，改写成 data URL。
  /// 最多处理 12 张，避免正文加载过久。
  static Future<String> _decodeContentImagesIfNeeded({
    required db.BookSource source,
    required String html,
    required String? imageDecodeJs,
    CancelToken? cancelToken,
  }) async {
    final script = imageDecodeJs?.trim() ?? '';
    if (script.isEmpty || html.isEmpty) return html;

    final srcPattern = RegExp(
      r'''<img\b[^>]*?\bsrc\s*=\s*["']([^"']+)["'][^>]*>''',
      caseSensitive: false,
    );
    final matches = srcPattern.allMatches(html).toList();
    if (matches.isEmpty) return html;

    var out = html;
    var count = 0;
    const maxImages = 12;
    for (final match in matches) {
      if (count >= maxImages) break;
      final src = match.group(1)?.trim() ?? '';
      if (src.isEmpty || src.startsWith('data:')) continue;
      try {
        final bytes = await SourceImageDecoder.loadContentImageBytes(
          source: source,
          imageUrl: src,
          imageDecodeJs: script,
          cancelToken: cancelToken,
        );
        if (bytes == null || bytes.isEmpty) continue;
        final mime = _guessImageMime(bytes);
        final dataUrl = 'data:$mime;base64,${base64Encode(bytes)}';
        out = out.replaceFirst(src, dataUrl);
        count++;
      } catch (e) {
        LogUtils.d('正文图片解密跳过 $src: $e');
      }
    }
    return out;
  }

  static String _guessImageMime(List<int> bytes) {
    if (bytes.length >= 3 &&
        bytes[0] == 0xFF &&
        bytes[1] == 0xD8 &&
        bytes[2] == 0xFF) {
      return 'image/jpeg';
    }
    if (bytes.length >= 8 &&
        bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47) {
      return 'image/png';
    }
    if (bytes.length >= 6 &&
        bytes[0] == 0x47 &&
        bytes[1] == 0x49 &&
        bytes[2] == 0x46) {
      return 'image/gif';
    }
    if (bytes.length >= 12 &&
        bytes[0] == 0x52 &&
        bytes[1] == 0x49 &&
        bytes[2] == 0x46 &&
        bytes[3] == 0x46) {
      return 'image/webp';
    }
    return 'image/jpeg';
  }

  static bool _isJsOnlyContentRule(String? rule) {
    final value = rule?.trimLeft() ?? '';
    if (value.isEmpty) return false;
    final lower = value.toLowerCase();
    return lower.startsWith('@js:') || lower.startsWith('<js>');
  }

  static String? _contentRequestBaseUrl({
    required BookChapterInfo chapter,
    required Map<String, String>? cachedVars,
  }) {
    for (final value in <String?>[
      cachedVars?['tocUrl'],
      cachedVars?['bookUrl'],
      chapter.baseUrl,
    ]) {
      final text = value?.trim();
      if (text != null && text.isNotEmpty) return text;
    }
    return null;
  }

  /// Prefer explicit bookUrl (chapter vars / cache); tocUrl only as fallback.
  static String? _resolveContentBookUrl({
    required BookChapterInfo chapter,
    required Map<String, String>? cachedVars,
  }) {
    for (final value in <String?>[
      chapter.variables['bookUrl'],
      cachedVars?['bookUrl'],
      chapter.variables['tocUrl'],
      cachedVars?['tocUrl'],
    ]) {
      final text = value?.trim();
      if (text != null && text.isNotEmpty) return text;
    }
    return null;
  }

  static Future<void> _syncChapterContextToRuleEngine({
    required RuleEngine engine,
    required BookChapterInfo chapter,
    required String? nextChapterUrl,
  }) async {
    final title = chapter.chapterName ?? '';
    final chapterUrl = chapter.chapterUrl ?? '';
    await engine.setChapterTitle(title: title);
    await engine.setChapterJson(json: jsonEncode(chapter.toJson()));

    final variables = <String, String>{
      ...chapter.variables,
      'chapter_title': title,
      'chapter_url': chapterUrl,
      'title': title,
      'url': chapterUrl,
      'isVolume': chapter.isVolume.toString(),
      'isVip': chapter.isVip.toString(),
      'isPay': chapter.isPay.toString(),
      if (chapter.updateTime?.trim().isNotEmpty == true)
        'updateTime': chapter.updateTime!.trim(),
      if (chapter.baseUrl?.trim().isNotEmpty == true)
        'baseUrl': chapter.baseUrl!.trim(),
      if (nextChapterUrl?.trim().isNotEmpty == true)
        'nextChapterUrl': nextChapterUrl!.trim(),
    };
    final index = chapter.chapterIndex;
    if (index != null) {
      variables['chapter_index'] = index.toString();
      variables['index'] = index.toString();
    }

    for (final entry in variables.entries) {
      final key = entry.key.trim();
      if (key.isEmpty) continue;
      await engine.setSourceVar(key: key, value: entry.value);
      await engine.setChapterVar(key: key, value: entry.value);
    }
  }

  static bool _isNextChapterUrl(String url, String? nextChapterUrl) {
    final expected = nextChapterUrl?.trim();
    if (expected == null || expected.isEmpty) return false;
    return SourceHttp.normalizeUrl(url) == SourceHttp.normalizeUrl(expected);
  }

  static Future<ChapterContent?> _tryWtzwDartContentFallback({
    required db.BookSource source,
    required Map<String, String> sourceHeaders,
    required BookChapterInfo chapter,
    required RuleEngine engine,
    required HttpCachePolicy? cachePolicy,
    required CancelToken? cancelToken,
  }) async {
    final chapterUrl = chapter.chapterUrl?.trim() ?? '';
    if (!source.bookSourceUrl.startsWith('https://api-bc.wtzw.com') ||
        !chapterUrl.startsWith('https://api-ks.wtzw.com/api/v1/chapter/')) {
      return null;
    }

    final cachedVars = SourceHttp.getChapterRuleVariables(
      sourceId: source.id,
      chapterUrl: chapterUrl,
    );
    await SourceHttp.syncVariablesToRuleEngine(engine, cachedVars);

    final recoveredBookUrl = await _findBookshelfBookUrl(
      sourceId: source.id,
      chapterUrl: chapterUrl,
    );
    final recoveredBookId = _recoverWtzwBookId(
      chapterUrl: chapterUrl,
      cachedVars: cachedVars,
      bookUrl: recoveredBookUrl,
    );
    if (recoveredBookId != null && recoveredBookId.isNotEmpty) {
      await engine.setSourceVar(key: 'bid', value: recoveredBookId);
    }
    final effectiveBookId = (await engine.getVariable(key: 'bid')).trim();
    if (effectiveBookId.isEmpty) {
      return null;
    }

    final headerOption = cachedVars?['headers']?.trim();
    if (headerOption == null || headerOption.isEmpty) {
      await engine.setSourceVar(
          key: 'headers', value: _wtzwDefaultHeaderOption);
    }

    final requestUrlResult = await engine.extractContent(
      html: '',
      rule: const ContentRule(content: _wtzwContentRequestRule),
      baseUrl: chapterUrl,
    );
    final requestRule = requestUrlResult?.content.trim() ?? '';
    if (requestRule.isEmpty || !requestRule.contains('/chapter/content?')) {
      return null;
    }

    final request = await SourceHttp.prepareRequest(
      source: source,
      url: requestRule,
      sourceHeaders: sourceHeaders,
      baseUrl: chapterUrl,
    );
    await SourceHttp.syncUrlVariablesToRuleEngine(engine, request.urlResult);
    final page = await SourceHttp.fetchHtml(
      url: request.url,
      urlResult: request.urlResult,
      fetchRequest: request.fetchRequest,
      sourceKey: source.bookSourceUrl,
      cancelToken: cancelToken,
      respondTime: source.respondTime,
      concurrentRate: source.concurrentRate,
      cacheScene: HttpCacheScene.chapterContent,
      cachePolicy: cachePolicy,
      syncCookieToSourceVariable: source.enabledCookieJar == true,
    );

    final decoded = await engine.extractContent(
      html: page.html,
      rule: const ContentRule(content: _wtzwContentDecodeRule),
      baseUrl: page.finalUrl,
    );
    if (decoded == null || decoded.content.trim().isEmpty) {
      throw CheckException(
        '正文失效',
        '万读正文接口已请求但解密结果为空: '
            'bid=$effectiveBookId, '
            'chapterUrl=$chapterUrl, '
            'contentUrl=${request.url}, '
            'response=${_shortDebugText(page.html)}',
      );
    }
    return decoded;
  }

  static const String _wtzwContentRequestRule = r'''@js:
sign_key='d3dGiJc651gSQ8w1'
headersJson=String(java.get("headers"))
if(!headersJson){
  headers={'app-version':'51110','platform':'android','reg':'0','AUTHORIZATION':'','application-id':'com.****.reader','net-env':'1','channel':'unknown','qm-params':''}
  headers['sign']=String(java.md5Encode(Object.keys(headers).sort().reduce((pre,n)=>pre+n+'='+headers[n],'')+sign_key))
  headersJson=JSON.stringify({"headers":headers})
}
params={'id':String(java.get('bid')),'chapterId':String(baseUrl.split("/").pop())}
var urlEncode = function (param, key, encode) {
  if(param==null) return '';
  var paramStr = '';
  var t = typeof (param);
  if (t == 'string' || t == 'number' || t == 'boolean') {
    paramStr += '&' + key + '=' + ((encode==null||encode) ? encodeURIComponent(param) : param);
  } else {
    for (var i in param) {
      var k = key == null ? i : key + (param instanceof Array ? '[' + i + ']' : '.' + i);
      paramStr += urlEncode(param[i], k, encode);
    }
  }
  return paramStr;
};
paramSign=String(java.md5Encode(Object.keys(params).sort().reduce((pre,n)=>pre+n+'='+params[n],'')+sign_key))
params['sign']=paramSign
"https://api-ks.wtzw.com/api/v1/chapter/content?"+urlEncode(params)+','+headersJson
''';

  static const String _wtzwDefaultHeaderOption =
      '{"headers":{"app-version":"51110","platform":"android","reg":"0","AUTHORIZATION":"","application-id":"com.****.reader","net-env":"1","channel":"unknown","qm-params":"","sign":"fc697243ab534ebaf51d2fa80f251cb4"}}';

  static const String _wtzwContentDecodeRule = r'''@js:
var javaImport = new JavaImporter();
javaImport.importPackage(
    Packages.java.lang,
    Packages.javax.crypto.spec,
    Packages.javax.crypto,
    Packages.java.util
);
with(javaImport) {
    function decode(content) {
        var ivEncData = Base64.getDecoder().decode(String(content));
        var key = SecretKeySpec(String("242ccb8230d709e1").getBytes(), "AES");
        var iv = IvParameterSpec(Arrays.copyOfRange(ivEncData, 0, 16));
        var chipher = Cipher.getInstance("AES/CBC/PKCS5Padding");
        chipher.init(2, key, iv);
        return String(chipher.doFinal(Arrays.copyOfRange(ivEncData, 16, ivEncData.length)));
    }
}
decode(JSON.parse(result).data.content)
''';

  static String? _recoverWtzwBookId({
    required String chapterUrl,
    required Map<String, String>? cachedVars,
    String? bookUrl,
  }) {
    final cachedBid = cachedVars?['bid']?.trim();
    if (cachedBid != null && cachedBid.isNotEmpty) return cachedBid;

    for (final rawUrl in <String?>[
      bookUrl,
      cachedVars?['bookUrl'],
      cachedVars?['tocUrl'],
    ]) {
      final id = _queryParam(rawUrl, 'id');
      if (id != null && id.isNotEmpty) return id;
    }

    final id = _queryParam(chapterUrl, 'id');
    if (id != null && id.isNotEmpty) return id;
    return null;
  }

  static Future<String?> _findBookshelfBookUrl({
    required int sourceId,
    required String chapterUrl,
  }) async {
    final normalizedChapterUrl = chapterUrl.trim();
    if (normalizedChapterUrl.isEmpty) return null;

    final storedChapter = await (_db.select(_db.bookChapters)
          ..where((table) =>
              table.bookSourceId.equals(sourceId) &
              table.chapterUrl.equals(normalizedChapterUrl))
          ..limit(1))
        .getSingleOrNull();
    if (storedChapter == null) return null;

    final book = await (_db.select(_db.books)
          ..where((table) => table.id.equals(storedChapter.bookId))
          ..limit(1))
        .getSingleOrNull();
    return book?.bookUrl?.trim();
  }

  static String? _queryParam(String? rawUrl, String key) {
    final url = rawUrl?.split(',').first.trim() ?? '';
    if (url.isEmpty) return null;
    final uri = Uri.tryParse(url);
    final value = uri?.queryParameters[key]?.trim();
    return value?.isNotEmpty == true ? value : null;
  }

  static String _shortDebugText(String text) {
    final normalized = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (normalized.length <= 240) return normalized;
    return normalized.substring(0, 240);
  }

  static String _jsonResponseSummary(String text) {
    try {
      final decoded = jsonDecode(text);
      if (decoded is! Map) return '';
      final parts = <String>[];
      for (final key in const ['errno', 'message', 'status', 'code']) {
        final value = decoded[key];
        if (value != null) parts.add('$key=$value');
      }
      final data = decoded['data'];
      if (data is Map) {
        for (final key in const ['errno', 'message', 'status', 'code']) {
          final value = data[key];
          if (value != null) parts.add('data.$key=$value');
        }
      }
      return parts.join(';');
    } catch (_) {
      return '';
    }
  }

  static Map<String, Object?> _jsonResponseDiagnostics(String text) {
    try {
      final decoded = jsonDecode(text);
      if (decoded is! Map) return const <String, Object?>{};
      final out = <String, Object?>{};
      final errno = decoded['errno'];
      final message = decoded['message'];
      if (errno is num || errno is String) out['response_errno'] = errno;
      if (message is String) out['response_message'] = message;

      final data = decoded['data'];
      if (data is Map) {
        final dataErrno = data['errno'];
        final dataMessage = data['message'];
        if (dataErrno is num || dataErrno is String) {
          out['response_data_errno'] = dataErrno;
        }
        if (dataMessage is String) {
          out['response_data_message'] = dataMessage;
        }
        final novel = data['novel'];
        out['response_has_data_novel'] = novel is Map;
        if (novel is Map) {
          final content = novel['content'];
          final contentText = content?.toString() ?? '';
          out['response_has_novel_content'] = contentText.trim().isNotEmpty;
          out['response_novel_content_length'] = contentText.length;
        }
      }
      return out;
    } catch (_) {
      return const <String, Object?>{};
    }
  }

  // ── P1-fix: 保留图片标签的 HTML 格式化 + 实体反转义后二次清洗 ──

  /// 正文最终清洗：formatKeepImg → unescapeHtml4 → 清理反转义后重新暴露的标签。
  ///
  /// 常见问题：`&lt;br&gt;` / `&#60;br&#62;` 在实体反转义后会变成字面 `<br>`，
  /// 若不再清洗会直接显示在阅读页。
  static String _formatAndUnescapeContent(String raw, String baseUrl) {
    if (raw.isEmpty) return '';
    var out = _formatKeepImg(raw, baseUrl);
    out = _unescapeHtml4(out);
    // 实体反转义可能重新暴露 <br>/<p> 等标签，再清洗一次。
    if (_residualNonImgTagRe.hasMatch(out) || _fullwidthBrRe.hasMatch(out)) {
      out = _formatKeepImg(out, baseUrl);
    }
    return out;
  }

  /// 保留 `<img>` 的 HTML → 纯文本格式化（对齐 Legado `HtmlFormatter.formatKeepImg`）。
  @visibleForTesting
  static String formatKeepImgForTesting(String raw, String baseUrl) =>
      _formatKeepImg(raw, baseUrl);

  /// 完整正文清洗（含反转义与残留标签二次清理），供单测与内部统一入口。
  @visibleForTesting
  static String formatAndUnescapeContentForTesting(
    String raw,
    String baseUrl,
  ) =>
      _formatAndUnescapeContent(raw, baseUrl);

  static String _formatKeepImg(String raw, String baseUrl) {
    if (raw.isEmpty) return '';

    String out = raw;
    out = out.replaceAll(_nbspRe, ' ');
    out = out.replaceAll(_espRe, ' ');
    out = out.replaceAll(_thinspRe, '');
    out = out.replaceAll(_noPrintRe, '');
    // 先剔除 script/style（含内部内容），避免其标签被换成换行残留脚本文本。
    out = out.replaceAll(_scriptRe, '');
    out = out.replaceAll(_styleRe, '');
    out = out.replaceAll(_noscriptRe, '');
    out = out.replaceAll(_commentRe, '');
    out = out.replaceAll(_fullwidthBrRe, '\n');
    out = out.replaceAll(_wrapHtmlRe, '\n');
    out = out.replaceAllMapped(_anyHtmlTagRe, (match) {
      final tag = match.group(0) ?? '';
      if (_imgOpenRe.hasMatch(tag)) return tag;
      return '';
    });

    out = out.replaceAllMapped(_imgSrcRe, (match) {
      final src = match.group(1) ?? '';
      if (src.isEmpty) return '';
      try {
        final resolved = resolveUrl(base: baseUrl, href: src);
        return '<img src="$resolved">';
      } catch (_) {
        return '<img src="$src">';
      }
    });

    out = out.replaceAll(_indent1Re, '\n\u3000\u3000');
    out = out.replaceAll(_indent2Re, '\u3000\u3000');
    out = out.replaceAll(_trailingRe, '');

    return out;
  }

  // ── P2-fix: HTML 实体反转义 ──

  static String _unescapeHtml4(String text) {
    if (!text.contains('&')) return text;
    // 先解 &amp;，避免 &amp;lt; 只解一层后留下 &lt; 无法继续变成 <。
    // 对双重实体做最多两轮，覆盖 &amp;lt;br&amp;gt; → <br>。
    var out = text;
    for (var i = 0; i < 2; i++) {
      final next = out
          .replaceAll('&amp;', '&')
          .replaceAll('&lt;', '<')
          .replaceAll('&gt;', '>')
          .replaceAll('&quot;', '"')
          .replaceAll('&apos;', "'")
          .replaceAllMapped(_numericEntityRe, (m) {
        final code = int.tryParse(m.group(1)!);
        return (code != null && code > 0 && code <= 0x10FFFF)
            ? String.fromCharCode(code)
            : m.group(0)!;
      }).replaceAllMapped(_hexEntityRe, (m) {
        final code = int.tryParse(m.group(1)!, radix: 16);
        return (code != null && code > 0 && code <= 0x10FFFF)
            ? String.fromCharCode(code)
            : m.group(0)!;
      });
      if (next == out) break;
      out = next;
    }
    return out;
  }

  static Future<String> _loadPagesSerial({
    required String firstPageContent,
    required List<String> nextUrlList,
    required RuleEngine engine,
    required ContentRule contentRule,
    required db.BookSource source,
    required Map<String, String>? sourceHeaders,
    required String baseUrl,
    CancelToken? cancelToken,
    HttpCachePolicy? cachePolicy,
    String? nextChapterUrl,
  }) async {
    final List<String> contentList = [firstPageContent];
    final Set<String> loadedUrls = {SourceHttp.normalizeUrl(baseUrl)};
    String? nextUrl = nextUrlList.isNotEmpty ? nextUrlList.first : null;

    const int maxPages = 50;
    int pageCount = 1;

    while (nextUrl != null && nextUrl.isNotEmpty && pageCount < maxPages) {
      final normalizedUrl = SourceHttp.normalizeUrl(nextUrl);

      if (loadedUrls.contains(normalizedUrl) ||
          _isNextChapterUrl(nextUrl, nextChapterUrl)) {
        break;
      }
      loadedUrls.add(normalizedUrl);
      pageCount++;

      try {
        final request = await SourceHttp.prepareRequest(
          source: source,
          url: nextUrl,
          sourceHeaders: sourceHeaders,
        );
        await SourceHttp.syncUrlVariablesToRuleEngine(
            engine, request.urlResult);
        final nextFetch = await SourceHttp.fetchPreparedPage(
          source: source,
          request: request,
          cancelToken: cancelToken,
          shouldRunLoginCheck: false,
          cacheScene: HttpCacheScene.chapterContent,
          cachePolicy: cachePolicy,
        ).timeout(SourceCheckPolicy.requestTimeout(source.respondTime));

        final nextResult = await SourceHttp.runWithWebViewBridge(
          source: source,
          engine: engine,
          sourceHeaders: sourceHeaders,
          cancelToken: cancelToken,
          parse: () => engine.extractContent(
            html: nextFetch.html,
            rule: contentRule,
            baseUrl: nextFetch.finalUrl,
          ),
        );

        if (nextResult != null && nextResult.content.isNotEmpty) {
          contentList.add(
            _formatAndUnescapeContent(
              nextResult.content,
              nextFetch.finalUrl,
            ),
          );
        }

        final nextNextUrl = nextResult?.nextUrl;
        if (nextNextUrl == null || nextNextUrl.isEmpty) break;

        final resolved =
            resolveUrl(base: nextFetch.finalUrl, href: nextNextUrl);
        if (SourceHttp.normalizeUrl(resolved) == normalizedUrl ||
            _isNextChapterUrl(resolved, nextChapterUrl)) {
          break;
        }
        nextUrl = resolved;
      } catch (e) {
        break;
      }
    }

    return contentList.join('\n');
  }

  static Future<String> _applyReplaceRegexWithEngine({
    required RuleEngine engine,
    required String content,
    String? replaceRegex,
    required String baseUrl,
  }) {
    return applyReplaceRegexOnceForTesting(
      content: content,
      replaceRegex: replaceRegex,
      baseUrl: baseUrl,
      apply: ({
        required String content,
        required String replaceRegex,
        required String baseUrl,
      }) async {
        final result = await engine.extractContent(
          html: content,
          rule: ContentRule(
            content: '@js:result',
            replaceRegex: replaceRegex,
          ),
          baseUrl: baseUrl,
        );
        return (result != null && result.content.trim().isNotEmpty)
            ? result.content
            : content;
      },
    );
  }

  /// 对已合并的正文统一应用 replaceRegex。
  @visibleForTesting
  static Future<String> applyReplaceRegexOnceForTesting({
    required String content,
    String? replaceRegex,
    required String baseUrl,
    required Future<String> Function({
      required String content,
      required String replaceRegex,
      required String baseUrl,
    }) apply,
  }) async {
    if (content.isEmpty) return content;
    if (replaceRegex == null || replaceRegex.trim().isEmpty) {
      return content;
    }
    return apply(
      content: content,
      replaceRegex: replaceRegex,
      baseUrl: baseUrl,
    );
  }

  static List<String> _buildFallbackContentRules(String currentRule) {
    final candidates = <String>[];
    final trimmed = currentRule.trim();

    if (trimmed.contains('@text')) {
      candidates.add(trimmed.replaceFirst('@text', '@html'));
    }

    candidates.addAll(const [
      '#chaptercontent@html',
      '#content@html',
      '.content@html',
      '.article@html',
      '.read-content@html',
      '.Readarea@html',
      'article@html',
      'body@text',
    ]);

    final unique = <String>{};
    final result = <String>[];
    for (final item in candidates) {
      final normalized = item.trim();
      if (normalized.isEmpty ||
          normalized == currentRule.trim() ||
          !unique.add(normalized)) {
        continue;
      }
      result.add(normalized);
    }
    return result;
  }

  static Future<String> _loadPagesConcurrent({
    required String firstPageContent,
    required List<String> nextUrlList,
    required RuleEngine engine,
    required ContentRule contentRule,
    required db.BookSource source,
    required Map<String, String>? sourceHeaders,
    CancelToken? cancelToken,
    HttpCachePolicy? cachePolicy,
    String? nextChapterUrl,
  }) async {
    final List<String> contentList = [firstPageContent];

    const int concurrencyLimit = 5;
    for (int i = 0; i < nextUrlList.length; i += concurrencyLimit) {
      final batch = nextUrlList
          .skip(i)
          .take(concurrencyLimit)
          .where((url) => !_isNextChapterUrl(url, nextChapterUrl))
          .toList(growable: false);
      if (batch.isEmpty) continue;
      final batchFutures = batch.map((url) => _loadSinglePage(
            url: url,
            engine: engine,
            contentRule: contentRule,
            source: source,
            sourceHeaders: sourceHeaders,
            cancelToken: cancelToken,
            cachePolicy: cachePolicy,
          ));
      final results = await Future.wait(batchFutures);
      for (final content in results) {
        if (content != null && content.isNotEmpty) {
          contentList.add(content);
        }
      }
    }

    return contentList.join('\n');
  }

  static Future<String?> _loadSinglePage({
    required String url,
    required RuleEngine engine,
    required ContentRule contentRule,
    required db.BookSource source,
    required Map<String, String>? sourceHeaders,
    CancelToken? cancelToken,
    HttpCachePolicy? cachePolicy,
  }) async {
    try {
      final request = await SourceHttp.prepareRequest(
        source: source,
        url: url,
        sourceHeaders: sourceHeaders,
      );
      await SourceHttp.syncUrlVariablesToRuleEngine(engine, request.urlResult);
      final fetchResult = await SourceHttp.fetchPreparedPage(
        source: source,
        request: request,
        cancelToken: cancelToken,
        shouldRunLoginCheck: false,
        cacheScene: HttpCacheScene.chapterContent,
        cachePolicy: cachePolicy,
      );
      final result = await SourceHttp.runWithWebViewBridge(
        source: source,
        engine: engine,
        sourceHeaders: sourceHeaders,
        cancelToken: cancelToken,
        parse: () => engine.extractContent(
          html: fetchResult.html,
          rule: contentRule,
          baseUrl: fetchResult.finalUrl,
        ),
      );
      if (result == null || result.content.isEmpty) return null;
      return _formatAndUnescapeContent(
        result.content,
        fetchResult.finalUrl,
      );
    } catch (e) {
      return null;
    }
  }
}
