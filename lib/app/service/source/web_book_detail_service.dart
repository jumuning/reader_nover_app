import 'package:dio/dio.dart';
import 'package:reader_nover/app/database/drift/app_database.dart' as db;
import 'package:reader_nover/app/database/models/models.dart';
import 'package:reader_nover/rust/api/rule_engine.dart' hide BookInfo;
import 'package:reader_nover/rust/entities/rules.dart';
import 'package:reader_nover/util/book_help.dart';
import 'package:reader_nover/util/http_cache_manager.dart';
import 'package:reader_nover/util/log_utils.dart';

import 'source_check_policy.dart';
import 'source_http.dart';

class BookDetailLoadContext {
  final FetchedPage page;
  final BookDetail detail;

  const BookDetailLoadContext({
    required this.page,
    required this.detail,
  });
}

/// 书籍详情 + 目录服务。
class WebBookDetailService {
  static final db.AppDatabase _db = db.AppDatabase.instance;

  WebBookDetailService._();

  /// 加载书籍页 HTML，并统一经过登录校验。
  static Future<FetchedPage> loadBookPage(
    db.BookSource source,
    String bookUrl, {
    CancelToken? cancelToken,
  }) async {
    final request = await SourceHttp.prepareRequest(
      source: source,
      url: bookUrl,
    );
    final engine = await SourceHttp.newRuleEngine(
      source,
      sourceHeaders: request.sourceHeaders,
      bookUrl: bookUrl,
    );
    await SourceHttp.syncVariablesToRuleEngine(
      engine,
      {
        ...?SourceHttp.getBookRuleVariables(
          sourceId: source.id,
          bookUrl: bookUrl,
        ),
        'bookUrl': bookUrl,
      },
    );
    await SourceHttp.syncUrlVariablesToRuleEngine(engine, request.urlResult);
    return SourceHttp.fetchPreparedPage(
      source: source,
      request: request,
      engine: engine,
      cancelToken: cancelToken,
      cacheScene: HttpCacheScene.bookDetail,
    );
  }

  /// 加载书籍页并解析详情，供后续目录复用 `htmlData/baseUrl/tocUrl`。
  static Future<BookDetailLoadContext> loadBookDetailContext(
    db.BookSource source,
    String bookUrl, {
    CancelToken? cancelToken,
  }) async {
    final page = await loadBookPage(
      source,
      bookUrl,
      cancelToken: cancelToken,
    );
    final detail = await getBookInfo(
      source,
      bookUrl,
      htmlData: page.html,
      baseUrl: page.finalUrl,
    );
    return BookDetailLoadContext(page: page, detail: detail);
  }

  /// 加载详情与目录，优先复用首个书籍页 HTML。
  static Future<BookDetail> loadBookDetailAndChapters(
    db.BookSource source,
    String bookUrl, {
    CancelToken? cancelToken,
  }) async {
    final context = await loadBookDetailContext(
      source,
      bookUrl,
      cancelToken: cancelToken,
    );
    final chapters = await getChapterList(
      source,
      bookUrl,
      cancelToken: cancelToken,
      tocUrl: context.detail.tocUrl,
      htmlData: context.page.html,
      baseUrl: context.page.finalUrl,
    );
    return context.detail.copyWith(chapters: chapters);
  }

  /// 获取书籍详情
  /// [htmlData] 如果已有 HTML 数据可以直接传入，避免重复请求
  static Future<BookDetail> getBookInfo(
    db.BookSource source,
    String bookUrl, {
    CancelToken? cancelToken,
    String? htmlData,
    String? baseUrl,
  }) async {
    final ruleBookInfo = await (_db.select(_db.ruleBookInfos)
          ..where((t) => t.bookSourceId.equals(source.id)))
        .getSingleOrNull();

    final request = await SourceHttp.prepareRequest(
      source: source,
      url: bookUrl,
    );

    final engine = await SourceHttp.newRuleEngine(
      source,
      sourceHeaders: request.sourceHeaders,
      bookUrl: bookUrl,
    );
    await SourceHttp.syncVariablesToRuleEngine(
      engine,
      {
        ...?SourceHttp.getBookRuleVariables(
          sourceId: source.id,
          bookUrl: bookUrl,
        ),
        'bookUrl': bookUrl,
      },
    );
    await SourceHttp.syncUrlVariablesToRuleEngine(engine, request.urlResult);

    final fallbackBaseUrl =
        (baseUrl?.trim().isNotEmpty == true) ? baseUrl!.trim() : request.url;

    String html;
    String resolvedBaseUrl;
    if (htmlData != null) {
      html = htmlData;
      resolvedBaseUrl = fallbackBaseUrl;
    } else {
      final fetchResult = await SourceHttp.fetchPreparedPage(
        source: source,
        request: request,
        engine: engine,
        cancelToken: cancelToken,
        cacheScene: HttpCacheScene.bookDetail,
      );
      html = fetchResult.html;
      resolvedBaseUrl = fetchResult.finalUrl;
    }
    final info = await SourceHttp.runWithWebViewBridge(
      source: source,
      engine: engine,
      sourceHeaders: request.sourceHeaders,
      cancelToken: cancelToken,
      parse: () => engine.extractBookInfo(
        html: html,
        rule: BookInfoRule(
          init: ruleBookInfo?.init,
          name: ruleBookInfo?.name,
          author: ruleBookInfo?.author,
          intro: ruleBookInfo?.intro,
          updateTime: ruleBookInfo?.updateTime,
          coverUrl: ruleBookInfo?.coverUrl,
          kind: ruleBookInfo?.kind,
          lastChapter: ruleBookInfo?.lastChapter,
          tocUrl: ruleBookInfo?.tocUrl,
          wordCount: ruleBookInfo?.wordCount,
          canReName: ruleBookInfo?.canReName,
          downloadUrls: ruleBookInfo?.downloadUrls,
        ),
        baseUrl: resolvedBaseUrl,
      ),
    );

    final name = info?.name ?? '';
    final author = info?.author ?? '';
    final coverUrl = info?.coverUrl ?? '';
    final intro = BookHelp.formatIntro(info?.intro);
    final lastChapter = info?.lastChapter ?? '';
    final kind = _splitKind(info?.kind);

    final bool coverIsFull = coverUrl.startsWith("http");
    final resolvedCover = coverIsFull
        ? coverUrl
        : (coverUrl.isNotEmpty
            ? resolveUrl(base: resolvedBaseUrl, href: coverUrl)
            : "");

    final cachedTocUrl = SourceHttp.getBookRuleVariables(
          sourceId: source.id,
          bookUrl: bookUrl,
        )?['tocUrl']
            ?.trim() ??
        '';
    final parsedTocUrl = info?.tocUrl?.trim() ?? '';
    final rawTocUrl = parsedTocUrl.isNotEmpty && parsedTocUrl != '@self'
        ? parsedTocUrl
        : cachedTocUrl;
    final resolvedTocUrl = rawTocUrl.isNotEmpty && rawTocUrl != '@self'
        ? (rawTocUrl.startsWith('http')
            ? rawTocUrl
            : resolveUrl(base: resolvedBaseUrl, href: rawTocUrl))
        : resolvedBaseUrl;
    final ruleVariables = await SourceHttp.snapshotRuleVariables(engine);
    SourceHttp.cacheBookRuleVariables(
      sourceId: source.id,
      bookUrl: bookUrl,
      tocUrl: resolvedTocUrl,
      variables: ruleVariables,
    );
    // Ensure book.putVariable written during info rules is persisted by bookUrl.
    await SourceHttp.persistRuleEngineVariables(source, engine);

    return BookDetail(
      bookSourceId: source.id,
      name: BookHelp.formatBookName(name),
      author: BookHelp.formatBookAuthor(author),
      cover: resolvedCover,
      intro: intro,
      kind: kind,
      lastChapter: lastChapter,
      wordCount: BookHelp.wordCountFormat(info?.wordCount),
      bookUrl: bookUrl,
      tocUrl: resolvedTocUrl,
      updateTime: info?.updateTime,
    );
  }

  static List<String> _splitKind(String? raw) {
    final value = raw?.trim();
    if (value == null || value.isEmpty) return const <String>[];
    return value
        .split(RegExp(r'[,，、/|;\n\r\t]+'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }

  /// 获取目录列表。
  ///
  /// [tocUrl] 独立的目录地址（来自 ruleBookInfo.tocUrl 解析结果），
  /// 当 tocUrl 与 bookUrl 不同时使用 tocUrl 作为请求地址。
  /// [htmlData] 如果已有 HTML 数据可以直接传入，避免重复请求
  static Future<List<BookChapterInfo>> getChapterList(
    db.BookSource source,
    String bookUrl, {
    CancelToken? cancelToken,
    String? tocUrl,
    String? htmlData,
    String? baseUrl,
    int? maxTocPages,
    int? maxChapters,
    int? stopWhenReadableChapterCount,
  }) async {
    final ruleToc = await (_db.select(_db.ruleTocs)
          ..where((t) => t.bookSourceId.equals(source.id)))
        .getSingleOrNull();

    // Headers first so preUpdateJs can use cookie/ajax before TOC request.
    final sourceHeaders = await SourceHttp.buildSourceHeaders(source);
    final engine = await SourceHttp.newRuleEngine(
      source,
      sourceHeaders: sourceHeaders,
      bookUrl: bookUrl,
    );
    await SourceHttp.syncVariablesToRuleEngine(
      engine,
      {
        ...?SourceHttp.getBookRuleVariables(
          sourceId: source.id,
          bookUrl: bookUrl,
          tocUrl: tocUrl,
        ),
        'bookUrl': bookUrl,
        if (tocUrl != null && tocUrl.trim().isNotEmpty) 'tocUrl': tocUrl.trim(),
      },
    );

    // Legado: run preUpdateJs BEFORE fetching TOC (may update tocUrl/book vars).
    var effectiveBookUrl = bookUrl;
    var effectiveTocUrl = tocUrl;
    final preUpdate = await _runPreUpdateJs(
      source: source,
      engine: engine,
      sourceHeaders: sourceHeaders,
      preUpdateJs: ruleToc?.preUpdateJs,
      bookUrl: bookUrl,
      tocUrl: tocUrl,
      cancelToken: cancelToken,
    );
    if (preUpdate.bookUrl != null && preUpdate.bookUrl!.trim().isNotEmpty) {
      effectiveBookUrl = preUpdate.bookUrl!.trim();
    }
    if (preUpdate.tocUrl != null && preUpdate.tocUrl!.trim().isNotEmpty) {
      effectiveTocUrl = preUpdate.tocUrl!.trim();
    }

    final effectiveUrl = (effectiveTocUrl?.isNotEmpty == true)
        ? effectiveTocUrl!
        : effectiveBookUrl;

    final initialRequest = await SourceHttp.prepareRequest(
      source: source,
      url: effectiveUrl,
      baseUrl: baseUrl,
      sourceHeaders: sourceHeaders,
    );
    final initialUrl = initialRequest.url;

    // 如果 tocUrl 与 bookUrl 不同，不复用已有的 htmlData
    final normalizedBookUrl = SourceHttp.normalizeUrl(effectiveBookUrl);
    final normalizedBaseUrl = (baseUrl?.trim().isNotEmpty == true)
        ? SourceHttp.normalizeUrl(baseUrl!.trim())
        : '';
    final normalizedTocUrl = (effectiveTocUrl?.trim().isNotEmpty == true)
        ? SourceHttp.normalizeUrl(effectiveTocUrl!.trim())
        : '';
    final bool tocUrlDiffers = normalizedTocUrl.isNotEmpty &&
        normalizedTocUrl != normalizedBookUrl &&
        (htmlData == null ||
            normalizedBaseUrl.isEmpty ||
            normalizedTocUrl != normalizedBaseUrl);
    if (tocUrlDiffers || preUpdate.invalidatedHtmlCache) {
      htmlData = null;
      baseUrl = null;
    }

    String currentUrl = initialUrl;
    await SourceHttp.syncUrlVariablesToRuleEngine(
      engine,
      initialRequest.urlResult,
    );
    if (htmlData == null) {
      final initialFetch = await SourceHttp.fetchPreparedPage(
        source: source,
        request: initialRequest,
        engine: engine,
        cancelToken: cancelToken,
        cacheScene: HttpCacheScene.chapterList,
      );
      htmlData = initialFetch.html;
      currentUrl = initialFetch.finalUrl;
    } else if (baseUrl?.trim().isNotEmpty == true) {
      currentUrl = baseUrl!.trim();
    }
    // HTML-time preUpdate already ran before fetch; keep rule field for Rust
    // extract compatibility but avoid double side-effects when possible by
    // clearing only when we already executed it on Dart side.
    final tocRule = TocRule(
      preUpdateJs: preUpdate.executed ? null : ruleToc?.preUpdateJs,
      chapterList: ruleToc?.chapterList,
      chapterName: ruleToc?.chapterName,
      chapterUrl: ruleToc?.chapterUrl,
      formatJs: ruleToc?.formatJs,
      isVolume: ruleToc?.isVolume,
      isVip: ruleToc?.isVip,
      isPay: ruleToc?.isPay,
      updateTime: ruleToc?.updateTime,
      nextTocUrl: ruleToc?.nextTocUrl,
    );
    final reverseChapterOrder = _isReverseChapterListRule(ruleToc?.chapterList);

    final allChapters = <_ChapterEntry>[];
    final chapterKeys = <String>{};
    final normalizedUrlCache = <String, String>{};
    String normalizeCached(String url) =>
        normalizedUrlCache.putIfAbsent(url, () => SourceHttp.normalizeUrl(url));
    final chapterKeyCache = <String, String>{};
    final visitedTocUrls = <String>{normalizeCached(currentUrl)};
    String currentHtml = htmlData;
    final int pageLimit =
        maxTocPages == null || maxTocPages <= 0 ? 20 : maxTocPages;
    final int? chapterLimit =
        maxChapters == null || maxChapters <= 0 ? null : maxChapters;
    final int? readableChapterLimit = stopWhenReadableChapterCount == null ||
            stopWhenReadableChapterCount <= 0 ||
            reverseChapterOrder ||
            (ruleToc?.formatJs?.trim().isNotEmpty ?? false)
        ? null
        : stopWhenReadableChapterCount;
    if (readableChapterLimit != null) {
      await engine.setSourceVar(
        key: '__reader_toc_parse_limit',
        value: readableChapterLimit.toString(),
      );
    }
    int pageCount = 0;
    int noNewChapterPages = 0;
    int readableChapterCount = 0;

    while (pageCount < pageLimit) {
      final currentNormalizedUrl = normalizeCached(currentUrl);
      final tocResult = await SourceHttp.runWithWebViewBridge(
        source: source,
        engine: engine,
        sourceHeaders: sourceHeaders,
        cancelToken: cancelToken,
        parse: () => engine.extractChapterList(
          html: currentHtml,
          rule: tocRule,
          baseUrl: currentUrl,
        ),
      );

      int pageNewChapterCount = 0;
      for (final chapter in tocResult.chapters) {
        final key = _buildChapterKey(
          currentUrl: currentUrl,
          currentNormalizedUrl: currentNormalizedUrl,
          chapter: chapter,
          normalizeUrl: normalizeCached,
          keyCache: chapterKeyCache,
        );
        if (chapterKeys.add(key)) {
          allChapters.add(_ChapterEntry(chapter: chapter, baseUrl: currentUrl));
          pageNewChapterCount++;
          if (readableChapterLimit != null &&
              _isReadableRawChapter(chapter, currentUrl)) {
            readableChapterCount++;
          }
          if (chapterLimit != null && allChapters.length >= chapterLimit) {
            break;
          }
          if (readableChapterLimit != null &&
              readableChapterCount >= readableChapterLimit) {
            break;
          }
        }
      }

      if (pageNewChapterCount == 0) {
        noNewChapterPages++;
      } else {
        noNewChapterPages = 0;
      }

      pageCount++;

      final rawNextUrl = tocResult.nextTocUrl;
      if ((readableChapterLimit != null &&
              readableChapterCount >= readableChapterLimit) ||
          (chapterLimit != null && allChapters.length >= chapterLimit) ||
          rawNextUrl == null ||
          rawNextUrl.isEmpty ||
          noNewChapterPages >= 2) {
        break;
      }

      // 支持多 URL（换行分隔），多个时并发请求
      final nextUrlList = rawNextUrl
          .split('\n')
          .map((u) => u.trim())
          .where((u) => u.isNotEmpty)
          .map((u) => resolveUrl(base: currentUrl, href: u))
          .toList();

      if (nextUrlList.length > 1) {
        // 并发加载全部下一页
        final futures = <Future<FetchedPage>>[];
        for (final nextUrl in nextUrlList) {
          final normalizedUrl = normalizeCached(nextUrl);
          if (normalizedUrl == currentNormalizedUrl ||
              !visitedTocUrls.add(normalizedUrl)) {
            continue;
          }
          final nextRequest = await SourceHttp.prepareRequest(
            source: source,
            url: nextUrl,
            sourceHeaders: sourceHeaders,
          );
          await SourceHttp.syncUrlVariablesToRuleEngine(
            engine,
            nextRequest.urlResult,
          );
          futures.add(SourceHttp.fetchHtml(
            url: nextRequest.url,
            urlResult: nextRequest.urlResult,
            fetchRequest: nextRequest.fetchRequest,
            sourceKey: source.bookSourceUrl,
            cancelToken: cancelToken,
            respondTime: source.respondTime,
            concurrentRate: source.concurrentRate,
            cacheScene: HttpCacheScene.chapterList,
            syncCookieToSourceVariable: source.enabledCookieJar == true,
          ).timeout(SourceCheckPolicy.requestTimeout(source.respondTime)));
        }
        if (futures.isEmpty) break;
        final pages = await Future.wait(futures);
        for (final page in pages) {
          final tocRes = await SourceHttp.runWithWebViewBridge(
            source: source,
            engine: engine,
            sourceHeaders: sourceHeaders,
            cancelToken: cancelToken,
            parse: () => engine.extractChapterList(
              html: page.html,
              rule: tocRule,
              baseUrl: page.finalUrl,
            ),
          );
          final pageNorm = normalizeCached(page.finalUrl);
          for (final chapter in tocRes.chapters) {
            final key = _buildChapterKey(
              currentUrl: page.finalUrl,
              currentNormalizedUrl: pageNorm,
              chapter: chapter,
              normalizeUrl: normalizeCached,
              keyCache: chapterKeyCache,
            );
            if (chapterKeys.add(key)) {
              allChapters.add(
                _ChapterEntry(chapter: chapter, baseUrl: page.finalUrl),
              );
              if (readableChapterLimit != null &&
                  _isReadableRawChapter(chapter, page.finalUrl)) {
                readableChapterCount++;
              }
              if (chapterLimit != null && allChapters.length >= chapterLimit) {
                break;
              }
              if (readableChapterLimit != null &&
                  readableChapterCount >= readableChapterLimit) {
                break;
              }
            }
          }
          if ((readableChapterLimit != null &&
                  readableChapterCount >= readableChapterLimit) ||
              (chapterLimit != null && allChapters.length >= chapterLimit)) {
            break;
          }
        }
        break;
      }

      // 单 URL 串行翻页
      final resolvedNextUrl = nextUrlList.first;
      final normalizedNextUrl = normalizeCached(resolvedNextUrl);
      if (normalizedNextUrl == currentNormalizedUrl ||
          !visitedTocUrls.add(normalizedNextUrl)) {
        break;
      }

      final nextRequest = await SourceHttp.prepareRequest(
        source: source,
        url: resolvedNextUrl,
        sourceHeaders: sourceHeaders,
      );
      await SourceHttp.syncUrlVariablesToRuleEngine(
        engine,
        nextRequest.urlResult,
      );
      final nextFetch = await SourceHttp.fetchHtml(
        url: nextRequest.url,
        urlResult: nextRequest.urlResult,
        fetchRequest: nextRequest.fetchRequest,
        sourceKey: source.bookSourceUrl,
        cancelToken: cancelToken,
        respondTime: source.respondTime,
        concurrentRate: source.concurrentRate,
        cacheScene: HttpCacheScene.chapterList,
        syncCookieToSourceVariable: source.enabledCookieJar == true,
      ).timeout(SourceCheckPolicy.requestTimeout(source.respondTime));
      currentHtml = nextFetch.html;
      currentUrl = nextFetch.finalUrl;
    }

    if (allChapters.isEmpty) {
      throw CheckException('目录失效', '目录解析结果为空');
    }

    var orderedEntries =
        reverseChapterOrder ? allChapters.reversed.toList() : allChapters;
    orderedEntries = await _formatFinalTocEntries(
      engine: engine,
      entries: orderedEntries,
      formatJs: ruleToc?.formatJs,
    );
    if (chapterLimit != null && orderedEntries.length > chapterLimit) {
      orderedEntries =
          orderedEntries.take(chapterLimit).toList(growable: false);
    }

    final ruleVariables = await SourceHttp.snapshotRuleVariables(engine);
    final sharedChapterVariables = SourceHttp.sharedChapterRuleVariables(
      variables: ruleVariables,
      bookUrl: bookUrl,
      tocUrl: tocUrl,
    );
    await SourceHttp.persistRuleEngineVariables(source, engine);

    return List<BookChapterInfo>.generate(
      orderedEntries.length,
      (i) {
        final entry = orderedEntries[i];
        final chapter = entry.chapter;
        final chapterUrl = _resolveChapterUrl(
          chapter: chapter,
          index: i,
          baseUrl: entry.baseUrl,
        );
        SourceHttp.cacheChapterRuleVariables(
          sourceId: source.id,
          chapterUrl: chapterUrl,
          variables: const <String, String>{},
          sharedVariables: sharedChapterVariables,
          itemVariables: chapter.variables,
          bookUrl: bookUrl,
          tocUrl: tocUrl,
        );
        return BookChapterInfo(
          bookSourceId: source.id,
          chapterIndex: i,
          chapterName: chapter.name,
          chapterUrl: chapterUrl,
          isVolume: chapter.isVolume,
          isVip: chapter.isVip,
          isPay: chapter.isPay,
          updateTime: chapter.updateTime,
          baseUrl: entry.baseUrl,
          variables: chapter.variables,
        );
      },
      growable: false,
    );
  }

  static Future<List<_ChapterEntry>> _formatFinalTocEntries({
    required RuleEngine engine,
    required List<_ChapterEntry> entries,
    required String? formatJs,
  }) async {
    final script = formatJs?.trim();
    if (script == null || script.isEmpty || entries.isEmpty) return entries;

    final formatted = await engine.formatTocChapters(
      chapters: entries.map((entry) => entry.chapter).toList(growable: false),
      formatJs: script,
      baseUrls: entries.map((entry) => entry.baseUrl).toList(growable: false),
    );
    if (formatted.length != entries.length) return entries;

    return List<_ChapterEntry>.generate(
      entries.length,
      (i) => _ChapterEntry(
        chapter: formatted[i],
        baseUrl: entries[i].baseUrl,
      ),
      growable: false,
    );
  }

  static String _buildChapterKey({
    required String currentUrl,
    required String currentNormalizedUrl,
    required Chapter chapter,
    required String Function(String url) normalizeUrl,
    required Map<String, String> keyCache,
  }) {
    final chapterUrl = chapter.url.trim();
    if (chapterUrl.isNotEmpty) {
      final cacheKey = '$currentNormalizedUrl|$chapterUrl';
      final cached = keyCache[cacheKey];
      if (cached != null) {
        return cached;
      }

      final resolved = (chapterUrl.startsWith('http://') ||
              chapterUrl.startsWith('https://'))
          ? chapterUrl
          : resolveUrl(base: currentUrl, href: chapterUrl);
      final key = 'u:${normalizeUrl(resolved)}';
      keyCache[cacheKey] = key;
      return key;
    }

    if (chapter.isVolume) {
      return 'v:${chapter.name.trim().toLowerCase()}@$currentNormalizedUrl';
    }
    return 'u:$currentNormalizedUrl';
  }

  static String _resolveChapterUrl({
    required Chapter chapter,
    required int index,
    required String baseUrl,
  }) {
    final url = chapter.url.trim();
    if (url.isNotEmpty) {
      final bool isFullUrl = url.startsWith('http://') ||
          url.startsWith('https://') ||
          url.startsWith('file://');
      return isFullUrl ? url : resolveUrl(base: baseUrl, href: url);
    }

    if (chapter.isVolume) {
      final title = chapter.name.trim();
      return title.isEmpty ? 'volume$index' : '$title$index';
    }
    return baseUrl;
  }

  static bool isReadableChapter(BookChapterInfo chapter) {
    if (chapter.isVolume) return false;

    final name = chapter.chapterName?.trim() ?? '';
    final url = chapter.chapterUrl?.trim() ?? '';
    if (name.isNotEmpty && url.startsWith(name)) return false;

    return url.isNotEmpty;
  }

  static bool _isReadableRawChapter(Chapter chapter, String baseUrl) {
    if (chapter.isVolume) return false;

    final name = chapter.name.trim();
    final resolvedUrl = _resolveChapterUrl(
      chapter: chapter,
      index: 0,
      baseUrl: baseUrl,
    ).trim();
    if (name.isNotEmpty && resolvedUrl.startsWith(name)) return false;

    return resolvedUrl.isNotEmpty;
  }

  static List<BookChapterInfo> readableChapters(
    List<BookChapterInfo> chapters,
  ) {
    return chapters.where(isReadableChapter).toList(growable: false);
  }

  static String? nextReadableChapterUrl(
    List<BookChapterInfo> readableChapters,
    int currentIndex,
  ) {
    final nextIndex = currentIndex + 1;
    if (nextIndex < 0 || nextIndex >= readableChapters.length) {
      return null;
    }
    final nextUrl = readableChapters[nextIndex].chapterUrl?.trim();
    return nextUrl?.isNotEmpty == true ? nextUrl : null;
  }

  static bool _isReverseChapterListRule(String? rule) {
    final value = rule?.trimLeft();
    return value?.startsWith('-') ?? false;
  }

  /// Legado `WebBook.runPreUpdateJs`: run before TOC HTTP request.
  static Future<_PreUpdateResult> _runPreUpdateJs({
    required db.BookSource source,
    required RuleEngine engine,
    required Map<String, String>? sourceHeaders,
    required String? preUpdateJs,
    required String bookUrl,
    String? tocUrl,
    CancelToken? cancelToken,
  }) async {
    final script = preUpdateJs?.trim() ?? '';
    if (script.isEmpty) {
      return const _PreUpdateResult(executed: false);
    }

    final beforeToc = tocUrl?.trim() ?? '';
    final beforeBook = bookUrl.trim();
    try {
      final wrapped = _wrapPreUpdateJs(script);
      await SourceHttp.runWithWebViewBridge(
        source: source,
        engine: engine,
        sourceHeaders: sourceHeaders,
        cancelToken: cancelToken,
        parse: () => engine.parseExploreKinds(exploreUrl: wrapped),
      );
      await SourceHttp.persistRuleEngineVariables(source, engine);
      final vars = await SourceHttp.snapshotRuleVariables(engine);
      final nextToc = _firstNonEmptyVar(vars, const [
        'tocUrl',
        'toc_url',
        'book.tocUrl',
      ]);
      final nextBook = _firstNonEmptyVar(vars, const [
        'bookUrl',
        'book_url',
        'book.bookUrl',
      ]);
      final refreshToc = _isTruthyFlag(vars['__reader_refresh_toc']);
      final regetBook = _isTruthyFlag(vars['__reader_reget_book']);
      final tocChanged = refreshToc ||
          (nextToc != null && nextToc.isNotEmpty && nextToc != beforeToc);
      final bookChanged = regetBook ||
          (nextBook != null && nextBook.isNotEmpty && nextBook != beforeBook);
      return _PreUpdateResult(
        executed: true,
        tocUrl: tocChanged
            ? (nextToc?.isNotEmpty == true ? nextToc : beforeToc)
            : null,
        bookUrl: bookChanged
            ? (nextBook?.isNotEmpty == true ? nextBook : beforeBook)
            : null,
        invalidatedHtmlCache:
            tocChanged || bookChanged || refreshToc || regetBook,
      );
    } catch (e, st) {
      LogUtils.e(
        'preUpdateJs 执行失败: ${source.bookSourceName}',
        error: e,
        stackTrace: st,
      );
      // Match Legado: log failure but continue TOC load.
      return const _PreUpdateResult(executed: true);
    }
  }

  static String _wrapPreUpdateJs(String script) {
    final trimmed = script.trim();
    final lower = trimmed.toLowerCase();
    if (lower.startsWith('@js:') || lower.startsWith('<js>')) {
      // Ensure the explore parser still yields a non-empty string token.
      if (lower.startsWith('@js:')) {
        return "$trimmed; '__reader_pre_update_done'";
      }
      return "$trimmed@js:'__reader_pre_update_done'";
    }
    return "@js:\n$trimmed\n'__reader_pre_update_done'";
  }

  static String? _firstNonEmptyVar(
    Map<String, String> vars,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = vars[key]?.trim();
      if (value != null && value.isNotEmpty) return value;
    }
    return null;
  }

  static bool _isTruthyFlag(String? raw) {
    final value = raw?.trim().toLowerCase() ?? '';
    return value == '1' || value == 'true' || value == 'yes';
  }
}

class _PreUpdateResult {
  const _PreUpdateResult({
    required this.executed,
    this.tocUrl,
    this.bookUrl,
    this.invalidatedHtmlCache = false,
  });

  final bool executed;
  final String? tocUrl;
  final String? bookUrl;
  final bool invalidatedHtmlCache;
}

class _ChapterEntry {
  final Chapter chapter;
  final String baseUrl;

  const _ChapterEntry({
    required this.chapter,
    required this.baseUrl,
  });
}
