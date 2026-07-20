import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:reader_nover/app/database/drift/app_database.dart' as db;
import 'package:reader_nover/app/database/models/models.dart';
import 'package:reader_nover/rust/api/rule_engine.dart' hide BookInfo;
import 'package:reader_nover/rust/entities/rules.dart';
import 'package:reader_nover/util/analyze_url_utils.dart';
import 'package:reader_nover/util/book_help.dart';
import 'package:reader_nover/util/http_cache_manager.dart';
import 'package:reader_nover/util/log_utils.dart';

import 'source_http.dart';

/// 搜索 + 发现服务。
class WebSearchService {
  static final db.AppDatabase _db = db.AppDatabase.instance;

  WebSearchService._();

  /// 搜索书籍。
  static Future<List<BookInfo>> searchBook(
    db.BookSource source,
    String keyword, {
    CancelToken? cancelToken,
    int page = 1,
    bool throwOnEmpty = true,
  }) async {
    if (source.searchUrl == null || source.searchUrl!.isEmpty) {
      throw CheckException('搜索失效', '未配置搜索地址');
    }

    final request = await SourceHttp.prepareRequest(
      source: source,
      url: source.searchUrl!,
      key: keyword,
      page: page < 1 ? 1 : page,
    );

    if (AnalyzeUrlUtils.hasError(request.urlResult)) {
      throw CheckException(
          '搜索失效', 'URL解析失败: ${AnalyzeUrlUtils.getError(request.urlResult)}');
    }

    final engine = await SourceHttp.newRuleEngine(
      source,
      sourceHeaders: request.sourceHeaders,
    );
    await SourceHttp.syncUrlVariablesToRuleEngine(engine, request.urlResult);

    final String finalUrl = request.url;
    if (finalUrl.isEmpty) {
      throw CheckException('搜索失效', 'URL 解析为空');
    }

    // Store keyword in engine variables so checkKeyWord rule can reference it as {{key}}
    await engine.putVariable(key: 'key', value: keyword);
    try {
      final fetchResult = await SourceHttp.fetchPreparedPage(
        source: source,
        request: request,
        cancelToken: cancelToken,
        engine: engine,
        cacheScene: HttpCacheScene.search,
      );

      if (_matchesBookUrlPattern(source.bookUrlPattern, fetchResult.finalUrl)) {
        final detailItem = await _extractSingleBookFromInfoHtml(
          source: source,
          engine: engine,
          sourceHeaders: request.sourceHeaders,
          html: fetchResult.html,
          finalUrl: fetchResult.finalUrl,
        );
        if (detailItem != null) {
          return [detailItem];
        }
      }

      final ruleSearch = await (_db.select(_db.ruleSearchs)
            ..where((t) => t.bookSourceId.equals(source.id)))
          .getSingleOrNull();

      final books = await SourceHttp.runWithWebViewBridge(
        source: source,
        engine: engine,
        sourceHeaders: request.sourceHeaders,
        cancelToken: cancelToken,
        parse: () => engine.extractBookList(
          html: fetchResult.html,
          rule: SearchRule(
            bookList: ruleSearch?.bookList,
            bookUrl: ruleSearch?.bookUrl,
            tocUrl: ruleSearch?.tocUrl,
            name: ruleSearch?.name,
            author: ruleSearch?.author,
            coverUrl: ruleSearch?.coverUrl,
            intro: ruleSearch?.intro,
            kind: ruleSearch?.kind,
            lastChapter: ruleSearch?.lastChapter,
            updateTime: ruleSearch?.updateTime,
            wordCount: ruleSearch?.wordCount,
            checkKeyWord: ruleSearch?.checkKeyWord,
          ),
          baseUrl: fetchResult.finalUrl,
        ),
      );

      if (books.isEmpty) {
        final detailItem = await _extractSingleBookFromInfoHtml(
          source: source,
          engine: engine,
          sourceHeaders: request.sourceHeaders,
          html: fetchResult.html,
          finalUrl: fetchResult.finalUrl,
        );
        if (detailItem != null) {
          return [detailItem];
        }
      }

      if (books.isEmpty) {
        if (throwOnEmpty) {
          throw CheckException('搜索失效', '搜索结果为空');
        }
        return const <BookInfo>[];
      }

      final ruleVariables = await SourceHttp.snapshotRuleVariables(engine);
      return books.map((b) {
        SourceHttp.cacheBookRuleVariables(
          sourceId: source.id,
          bookUrl: b.bookUrl,
          tocUrl: b.tocUrl,
          variables: ruleVariables,
          itemVariables: _bookItemRuleVariables(b),
        );
        return BookInfo(
          bookSourceId: source.id,
          name: BookHelp.formatBookName(b.name),
          author: BookHelp.formatBookAuthor(b.author),
          cover: b.coverUrl ?? '',
          intro: BookHelp.formatIntro(b.intro),
          kind: b.kind,
          lastChapter: b.lastChapter,
          wordCount: BookHelp.wordCountFormat(b.wordCount),
          bookUrl: b.bookUrl,
          tocUrl: b.tocUrl,
        );
      }).toList();
    } finally {
      await SourceHttp.persistRuleEngineVariables(source, engine);
    }
  }

  /// 发现书籍。
  /// 当 `ruleExplore.bookList` 为空时回退到 `ruleSearch`
  static Future<List<BookInfo>> exploreBook(
    db.BookSource source,
    String exploreUrl, {
    CancelToken? cancelToken,
    int page = 1,
    bool throwOnEmpty = true,
  }) async {
    if (exploreUrl.trim().isEmpty) {
      throw CheckException('发现失效', '未配置发现地址');
    }

    final ruleExplore = await (_db.select(_db.ruleExplores)
          ..where((t) => t.bookSourceId.equals(source.id)))
        .getSingleOrNull();
    final ruleSearch = await (_db.select(_db.ruleSearchs)
          ..where((t) => t.bookSourceId.equals(source.id)))
        .getSingleOrNull();
    final effectiveRule = _buildEffectiveExploreRule(
      ruleExplore: ruleExplore,
      ruleSearch: ruleSearch,
    );

    final request = await SourceHttp.prepareRequest(
      source: source,
      url: exploreUrl,
      page: page,
    );
    if (AnalyzeUrlUtils.hasError(request.urlResult)) {
      throw CheckException(
          '发现失效', 'URL解析失败: ${AnalyzeUrlUtils.getError(request.urlResult)}');
    }

    final engine = await SourceHttp.newRuleEngine(
      source,
      sourceHeaders: request.sourceHeaders,
    );
    await SourceHttp.syncUrlVariablesToRuleEngine(engine, request.urlResult);
    try {
      final fetchResult = await _fetchExplorePageAllowingJsSelfRequest(
        source: source,
        request: request,
        cancelToken: cancelToken,
        engine: engine,
        bookListRule: effectiveRule.bookList,
      );
      final parsedBooks = await SourceHttp.runWithWebViewBridge(
        source: source,
        engine: engine,
        sourceHeaders: request.sourceHeaders,
        cancelToken: cancelToken,
        parse: () => engine.extractExploreList(
          html: fetchResult.html,
          rule: effectiveRule,
          // Prefer request URL so placeholder params (gender=…&category_id=…)
          // remain available to bookList JS even if the site redirects.
          baseUrl: fetchResult.finalUrl.isNotEmpty
              ? fetchResult.finalUrl
              : request.url,
        ),
      );

      final ruleVariables = await SourceHttp.snapshotRuleVariables(engine);
      final books = <BookInfo>[];
      for (final item in parsedBooks) {
        final resolvedUrl =
            resolveUrl(base: fetchResult.finalUrl, href: item.bookUrl);
        if (resolvedUrl.isEmpty) continue;

        final rawCover = item.coverUrl ?? '';
        SourceHttp.cacheBookRuleVariables(
          sourceId: source.id,
          bookUrl: resolvedUrl,
          variables: ruleVariables,
          itemVariables: _bookItemRuleVariables(item),
        );
        books.add(
          BookInfo(
            bookSourceId: source.id,
            name: BookHelp.formatBookName(item.name),
            author: BookHelp.formatBookAuthor(item.author),
            cover: rawCover.isNotEmpty
                ? resolveUrl(base: fetchResult.finalUrl, href: rawCover)
                : '',
            intro: BookHelp.formatIntro(item.intro),
            kind: item.kind,
            lastChapter: item.lastChapter,
            wordCount: BookHelp.wordCountFormat(item.wordCount),
            bookUrl: resolvedUrl,
          ),
        );
      }

      if (books.isEmpty && (source.bookUrlPattern?.trim().isEmpty ?? true)) {
        final detailItem = await _extractSingleBookFromInfoHtml(
          source: source,
          engine: engine,
          sourceHeaders: request.sourceHeaders,
          html: fetchResult.html,
          finalUrl: fetchResult.finalUrl,
        );
        if (detailItem != null) {
          books.add(detailItem);
        }
      }

      if (books.isEmpty && throwOnEmpty) {
        throw CheckException('发现失效', '发现结果为空');
      }
      return books;
    } finally {
      await SourceHttp.persistRuleEngineVariables(source, engine);
    }
  }

  static Map<String, String> _bookItemRuleVariables(BookItem item) {
    return <String, String>{
      'name': item.name,
      if ((item.author ?? '').trim().isNotEmpty) 'author': item.author!,
      if ((item.coverUrl ?? '').trim().isNotEmpty) 'image_url': item.coverUrl!,
      if ((item.coverUrl ?? '').trim().isNotEmpty) 'cover': item.coverUrl!,
      if ((item.intro ?? '').trim().isNotEmpty) 'desc_info': item.intro!,
      if ((item.intro ?? '').trim().isNotEmpty) 'intro': item.intro!,
      if ((item.kind ?? '').trim().isNotEmpty) 'category_name': item.kind!,
      if ((item.kind ?? '').trim().isNotEmpty) 'kind': item.kind!,
      if ((item.lastChapter ?? '').trim().isNotEmpty)
        'newest_chapter_name': item.lastChapter!,
      if ((item.wordCount ?? '').trim().isNotEmpty)
        'word_count': item.wordCount!,
      if ((item.wordCount ?? '').trim().isNotEmpty)
        'wordCount': item.wordCount!,
      if ((item.tocUrl ?? '').trim().isNotEmpty) 'tocUrl': item.tocUrl!,
    };
  }

  static ExploreRule _buildEffectiveExploreRule({
    required db.RuleExplore? ruleExplore,
    required db.RuleSearch? ruleSearch,
  }) {
    final exploreBookList = ruleExplore?.bookList?.trim() ?? '';
    if (exploreBookList.isNotEmpty) {
      return ExploreRule(
        bookList: ruleExplore?.bookList,
        name: ruleExplore?.name,
        author: ruleExplore?.author,
        bookUrl: ruleExplore?.bookUrl,
        coverUrl: ruleExplore?.coverUrl,
        intro: ruleExplore?.intro,
        kind: ruleExplore?.kind,
        lastChapter: ruleExplore?.lastChapter,
        wordCount: ruleExplore?.wordCount,
      );
    }
    return ExploreRule(
      bookList: ruleSearch?.bookList,
      name: ruleSearch?.name,
      author: ruleSearch?.author,
      bookUrl: ruleSearch?.bookUrl,
      coverUrl: ruleSearch?.coverUrl,
      intro: ruleSearch?.intro,
      kind: ruleSearch?.kind,
      lastChapter: ruleSearch?.lastChapter,
      wordCount: ruleSearch?.wordCount,
    );
  }

  /// 发现页抓取：HTTP 失败时，若 bookList 为可自请求的 JS 规则则继续解析。
  ///
  /// 对齐 Legado：部分书源 exploreUrl 仅是参数载体（如 baidu.com），真实接口在
  /// bookList 的 `java.ajax` 中发起；占位站 404/断网不应阻断列表规则。
  static Future<FetchedPage> _fetchExplorePageAllowingJsSelfRequest({
    required db.BookSource source,
    required PreparedSourceRequest request,
    required RuleEngine engine,
    CancelToken? cancelToken,
    String? bookListRule,
  }) async {
    try {
      return await SourceHttp.fetchPreparedPage(
        source: source,
        request: request,
        cancelToken: cancelToken,
        engine: engine,
        cacheScene: HttpCacheScene.explore,
      );
    } on DioException catch (e) {
      if (!_bookListCanSelfFetch(bookListRule)) rethrow;
      LogUtils.w(
        '发现页 HTTP 失败，bookList 为 JS 自请求规则，用空 body 继续: '
        '${e.message}, url=${request.url}',
      );
      return FetchedPage(
        html: e.response?.data?.toString() ?? '',
        finalUrl: request.url,
      );
    }
  }

  /// bookList 是否为纯 JS 且会自行 `java.ajax/connect/get/post` 拉数据。
  @visibleForTesting
  static bool bookListCanSelfFetchForTesting(String? bookList) =>
      _bookListCanSelfFetch(bookList);

  static bool _bookListCanSelfFetch(String? bookList) {
    final raw = bookList?.trim() ?? '';
    if (raw.isEmpty) return false;
    final lower = raw.toLowerCase();
    final isJs = lower.startsWith('<js>') ||
        lower.startsWith('@js:') ||
        lower.startsWith('js:') ||
        lower.startsWith('@js\n') ||
        lower.contains('<js>');
    if (!isJs) return false;
    return lower.contains('java.ajax') ||
        lower.contains('java.connect') ||
        lower.contains('java.get(') ||
        lower.contains('java.post(') ||
        lower.contains('java.ajaxall');
  }

  static bool _matchesBookUrlPattern(String? pattern, String url) {
    if (pattern == null || pattern.trim().isEmpty) return false;
    try {
      return RegExp(pattern).hasMatch(url);
    } catch (_) {
      return false;
    }
  }

  static Future<BookInfo?> _extractSingleBookFromInfoHtml({
    required db.BookSource source,
    required RuleEngine engine,
    required Map<String, String> sourceHeaders,
    required String html,
    required String finalUrl,
  }) async {
    final ruleBookInfo = await (_db.select(_db.ruleBookInfos)
          ..where((t) => t.bookSourceId.equals(source.id)))
        .getSingleOrNull();
    if (ruleBookInfo == null) return null;

    final info = await SourceHttp.runWithWebViewBridge(
      source: source,
      engine: engine,
      sourceHeaders: sourceHeaders,
      parse: () => engine.extractBookInfo(
        html: html,
        rule: BookInfoRule(
          init: ruleBookInfo.init,
          name: ruleBookInfo.name,
          author: ruleBookInfo.author,
          intro: ruleBookInfo.intro,
          updateTime: ruleBookInfo.updateTime,
          coverUrl: ruleBookInfo.coverUrl,
          kind: ruleBookInfo.kind,
          lastChapter: ruleBookInfo.lastChapter,
          tocUrl: ruleBookInfo.tocUrl,
          wordCount: ruleBookInfo.wordCount,
          canReName: ruleBookInfo.canReName,
          downloadUrls: ruleBookInfo.downloadUrls,
        ),
        baseUrl: finalUrl,
      ),
    );

    final name = info?.name.trim() ?? '';
    if (name.isEmpty) return null;

    final rawCover = info?.coverUrl ?? '';
    final coverUrl =
        rawCover.isNotEmpty ? resolveUrl(base: finalUrl, href: rawCover) : '';
    final rawTocUrl = info?.tocUrl ?? '';
    final tocUrl = rawTocUrl.isNotEmpty
        ? resolveUrl(base: finalUrl, href: rawTocUrl)
        : null;

    final book = BookInfo(
      bookSourceId: source.id,
      name: BookHelp.formatBookName(name),
      author: BookHelp.formatBookAuthor(info?.author),
      cover: coverUrl,
      intro: BookHelp.formatIntro(info?.intro),
      kind: info?.kind,
      lastChapter: info?.lastChapter,
      wordCount: BookHelp.wordCountFormat(info?.wordCount),
      bookUrl: finalUrl,
      tocUrl: tocUrl,
    );
    SourceHttp.cacheBookRuleVariables(
      sourceId: source.id,
      bookUrl: book.bookUrl,
      tocUrl: book.tocUrl,
      variables: await SourceHttp.snapshotRuleVariables(engine),
    );
    return book;
  }
}
