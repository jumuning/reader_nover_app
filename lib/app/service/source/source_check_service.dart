import 'dart:async';

import 'package:dio/dio.dart';

import 'package:reader_nover/app/database/drift/app_database.dart' as db;
import 'package:reader_nover/app/database/models/models.dart'
    show BookChapterInfo, BookInfo;
import 'package:reader_nover/app/service/source/source_check_policy.dart';
import 'package:reader_nover/app/service/source/source_check_report.dart';
import 'package:reader_nover/app/service/source/source_http.dart';
import 'package:reader_nover/app/service/source/source_login_service.dart';
import 'package:reader_nover/app/service/source/web_book_detail_service.dart';
import 'package:reader_nover/app/service/source/web_content_service.dart';
import 'package:reader_nover/app/service/source/web_search_service.dart';
import 'package:reader_nover/util/log_utils.dart';

typedef SourceCheckSourceResolver = Future<db.BookSource?> Function(
  int sourceId,
);

typedef SourceCheckSourceStarted = void Function({
  required int sourceId,
  required String sourceName,
});

typedef SourceCheckSourceFinished = FutureOr<void> Function({
  required int sourceId,
  required SourceCheckExecutionResult result,
  required String message,
});

class SourceCheckRunConfig {
  const SourceCheckRunConfig({
    required this.timeout,
    required this.fastMode,
    required this.checkSearch,
    required this.checkDiscovery,
    required this.checkInfo,
    required this.checkCategory,
    required this.checkContent,
  });

  final Duration timeout;
  final bool fastMode;
  final bool checkSearch;
  final bool checkDiscovery;
  final bool checkInfo;
  final bool checkCategory;
  final bool checkContent;
}

enum SourceCheckExecutionState { success, warning, failed }

class SourceCheckExecutionResult {
  const SourceCheckExecutionResult({
    required this.sourceId,
    required this.state,
    this.errorTag,
    this.errorTags,
    this.resolvedGroups,
    this.errorMsg,
    this.elapsed,
    this.stages = const <SourceCheckStageReport>[],
    this.failureClass,
  });

  final int sourceId;
  final SourceCheckExecutionState state;
  final String? errorTag;
  final List<String>? errorTags;
  final List<String>? resolvedGroups;
  final String? errorMsg;
  final int? elapsed;
  final List<SourceCheckStageReport> stages;
  final SourceCheckFailureClass? failureClass;
}

class SourceCheckService {
  const SourceCheckService();

  Future<void> runBatch({
    required List<int> ids,
    required String searchWord,
    required int concurrencyLimit,
    required SourceCheckRunConfig config,
    required CancelToken cancelToken,
    required SourceCheckSourceResolver resolveSource,
    required Map<int, String> sourceCheckKeywords,
    required bool Function() isActive,
    SourceCheckSourceStarted? onSourceStarted,
    required SourceCheckSourceFinished onSourceFinished,
  }) {
    return _SourceCheckBatchRunner(
      ids: ids,
      searchWord: searchWord,
      concurrencyLimit: concurrencyLimit,
      config: config,
      cancelToken: cancelToken,
      resolveSource: resolveSource,
      sourceCheckKeywords: sourceCheckKeywords,
      isActive: isActive,
      onSourceStarted: onSourceStarted,
      onSourceFinished: onSourceFinished,
    ).run();
  }
}

class _SourceCheckBatchRunner {
  _SourceCheckBatchRunner({
    required this.ids,
    required this.searchWord,
    required this.concurrencyLimit,
    required this.config,
    required this.cancelToken,
    required this.resolveSource,
    required this.sourceCheckKeywords,
    required this.isActive,
    required this.onSourceStarted,
    required this.onSourceFinished,
  });

  final List<int> ids;
  final String searchWord;
  final int concurrencyLimit;
  final SourceCheckRunConfig config;
  final CancelToken cancelToken;
  final SourceCheckSourceResolver resolveSource;
  final Map<int, String> sourceCheckKeywords;
  final bool Function() isActive;
  final SourceCheckSourceStarted? onSourceStarted;
  final SourceCheckSourceFinished onSourceFinished;

  Future<void> run() async {
    var nextIndex = 0;

    Future<void> worker() async {
      while (isActive()) {
        final currentIndex = nextIndex;
        if (currentIndex >= ids.length) return;
        nextIndex++;
        await _checkSingleSource(ids[currentIndex]);
      }
    }

    final workerCount = concurrencyLimit.clamp(1, ids.length).toInt();
    await Future.wait(List.generate(workerCount, (_) => worker()));
  }

  Future<void> _checkSingleSource(int sourceId) async {
    if (!isActive()) return;

    final source = await resolveSource(sourceId);
    if (source == null) {
      await _finish(
        sourceId,
        result: SourceCheckExecutionResult(
          sourceId: sourceId,
          state: SourceCheckExecutionState.failed,
          errorTag: '书源不存在',
          errorTags: const ['书源不存在'],
        ),
        message: '书源不存在',
      );
      return;
    }

    onSourceStarted?.call(
      sourceId: sourceId,
      sourceName: source.bookSourceName,
    );

    final stopwatch = Stopwatch()..start();
    final effectiveSearchWord = await _resolveSearchWord(source, searchWord);
    final groups = _parseGroups(source.bookSourceGroup);
    _removeInvalidGroups(groups);
    final bookCheckCache = <String, _BookCheckOutcome>{};
    final report = SourceCheckReportBuilder();
    var searchBookPassed = false;

    try {
      await Future(() async {
        if (!isActive()) throw _SourceCheckCancelledException();

        if (config.checkSearch) {
          searchBookPassed = await _checkSearchBranch(
            source: source,
            searchWord: effectiveSearchWord,
            groups: groups,
            bookCheckCache: bookCheckCache,
            report: report,
          );
          if (!isActive()) throw _SourceCheckCancelledException();
        }

        if (config.checkDiscovery) {
          await _checkDiscoveryBranch(
            source: source,
            groups: groups,
            bookCheckCache: bookCheckCache,
            skipBookCheck: config.fastMode && searchBookPassed,
            report: report,
          );
          if (!isActive()) throw _SourceCheckCancelledException();
        }

        final checkTags =
            groups.where(SourceCheckPolicy.isCheckTag).toList(growable: false);
        final fatalTags = checkTags
            .where(SourceCheckPolicy.isFatalCheckTag)
            .toList(growable: false);
        if (fatalTags.isNotEmpty) {
          throw _InvalidGroupsException(
            fatalTags: fatalTags,
            checkTags: checkTags,
            resolvedGroups: groups.toList(growable: false),
          );
        }
      }).timeout(config.timeout);

      stopwatch.stop();
      final checkTags =
          groups.where(SourceCheckPolicy.isCheckTag).toList(growable: false);
      await _finish(
        sourceId,
        result: SourceCheckExecutionResult(
          sourceId: sourceId,
          state: SourceCheckExecutionState.success,
          errorTags: checkTags.isEmpty ? null : checkTags,
          resolvedGroups: groups.toList(growable: false),
          elapsed: stopwatch.elapsedMilliseconds,
          stages: report.build(),
        ),
        message:
            '${source.bookSourceName}: 校验成功 ${_formatElapsed(stopwatch.elapsedMilliseconds)}',
      );
    } on _SourceCheckCancelledException {
      stopwatch.stop();
      return;
    } on TimeoutException {
      stopwatch.stop();
      groups.add(SourceCheckTags.timeout);
      await _finish(
        sourceId,
        result: SourceCheckExecutionResult(
          sourceId: sourceId,
          state: SourceCheckExecutionState.failed,
          errorTag: SourceCheckTags.timeout,
          errorTags: const [SourceCheckTags.timeout],
          resolvedGroups: groups.toList(growable: false),
          errorMsg: '超过${config.timeout.inSeconds}秒未响应',
          elapsed: stopwatch.elapsedMilliseconds,
          stages: report.build(),
          failureClass: SourceCheckFailureClass.timeout,
        ),
        message:
            '${source.bookSourceName}: 校验超时 ${_formatElapsed(stopwatch.elapsedMilliseconds)}',
      );
    } on _InvalidGroupsException catch (e) {
      stopwatch.stop();
      await _finish(
        sourceId,
        result: SourceCheckExecutionResult(
          sourceId: sourceId,
          state: SourceCheckExecutionState.failed,
          errorTag: e.fatalTags.first,
          errorTags: e.checkTags,
          resolvedGroups: e.resolvedGroups,
          errorMsg: e.fatalTags.join('、'),
          elapsed: stopwatch.elapsedMilliseconds,
          stages: report.build(),
          failureClass: _failureClassFromReport(report),
        ),
        message:
            '${source.bookSourceName}: ${e.fatalTags.join('、')} ${_formatElapsed(stopwatch.elapsedMilliseconds)}',
      );
    } on SourceLoginRequiredException catch (e) {
      stopwatch.stop();
      await _finish(
        sourceId,
        result: SourceCheckExecutionResult(
          sourceId: sourceId,
          state: SourceCheckExecutionState.failed,
          errorTag: '登录校验',
          errorTags: const ['登录校验'],
          resolvedGroups: groups.toList(growable: false),
          errorMsg: e.message,
          elapsed: stopwatch.elapsedMilliseconds,
          stages: report.build(),
          failureClass: _failureClassFromReport(report) ??
              SourceCheckReport.classifyFailure(e),
        ),
        message:
            '${source.bookSourceName}: 登录校验 ${_formatElapsed(stopwatch.elapsedMilliseconds)}',
      );
    } on CheckException catch (e) {
      stopwatch.stop();
      if (SourceCheckPolicy.isInvalidGroup(e.tag)) {
        groups.add(e.tag);
      }
      await _finish(
        sourceId,
        result: SourceCheckExecutionResult(
          sourceId: sourceId,
          state: SourceCheckExecutionState.failed,
          errorTag: e.tag,
          errorTags: SourceCheckPolicy.isInvalidGroup(e.tag) ? [e.tag] : null,
          resolvedGroups: groups.toList(growable: false),
          errorMsg: e.message,
          elapsed: stopwatch.elapsedMilliseconds,
          stages: report.build(),
          failureClass: _failureClassFromReport(report) ??
              SourceCheckReport.classifyFailure(e),
        ),
        message:
            '${source.bookSourceName}: ${e.tag} ${_formatElapsed(stopwatch.elapsedMilliseconds)}',
      );
    } catch (e) {
      stopwatch.stop();
      if (e is DioException && e.type == DioExceptionType.cancel) {
        return;
      }
      if (SourceCheckPolicy.isTransientNetworkFailure(e)) {
        await _finish(
          sourceId,
          result: SourceCheckExecutionResult(
            sourceId: sourceId,
            state: SourceCheckExecutionState.warning,
            errorTag: SourceCheckTags.transientNetwork,
            errorMsg: '网络请求异常，建议稍后复查: $e',
            elapsed: stopwatch.elapsedMilliseconds,
            stages: report.build(),
            failureClass: SourceCheckFailureClass.network,
          ),
          message:
              '${source.bookSourceName}: ${SourceCheckTags.transientNetwork} ${_formatElapsed(stopwatch.elapsedMilliseconds)}',
        );
        return;
      }
      final errorTag = _isLikelyJsError(e) ? 'js失效' : '网站失效';
      groups.add(errorTag);
      await _finish(
        sourceId,
        result: SourceCheckExecutionResult(
          sourceId: sourceId,
          state: SourceCheckExecutionState.failed,
          errorTag: errorTag,
          errorTags: [errorTag],
          resolvedGroups: groups.toList(growable: false),
          errorMsg: '$e',
          elapsed: stopwatch.elapsedMilliseconds,
          stages: report.build(),
          failureClass: _failureClassFromReport(report) ??
              SourceCheckReport.classifyFailure(e),
        ),
        message:
            '${source.bookSourceName}: $errorTag ${_formatElapsed(stopwatch.elapsedMilliseconds)}',
      );
    }
  }

  Future<bool> _checkSearchBranch({
    required db.BookSource source,
    required String searchWord,
    required Set<String> groups,
    required Map<String, _BookCheckOutcome> bookCheckCache,
    required SourceCheckReportBuilder report,
  }) async {
    final searchUrl = source.searchUrl?.trim() ?? '';
    if (searchUrl.isEmpty) {
      groups.add(SourceCheckTags.searchUrlEmpty);
      report.addFailure(
        stage: SourceCheckStage.search,
        error: CheckException(
          SourceCheckTags.searchUrlEmpty,
          '未配置搜索地址',
        ),
      );
      return false;
    }

    groups.remove(SourceCheckTags.searchUrlEmpty);
    List<BookInfo> books;
    try {
      books = await report.record<List<BookInfo>>(
        stage: SourceCheckStage.search,
        action: () async {
          final result = await _withTransientNetworkRetry<List<BookInfo>>(
            sourceName: source.bookSourceName,
            stage: '搜索',
            action: () => WebSearchService.searchBook(
              source,
              searchWord,
              cancelToken: cancelToken,
            ).timeout(
              SourceCheckPolicy.requestTimeout(source.respondTime),
            ),
          );
          if (result.isEmpty) {
            throw CheckException('搜索失效', '搜索结果为空');
          }
          return result;
        },
        successMessage: (books) => '找到 ${books.length} 本书',
        successDiagnostics: (books) => <String, Object?>{
          'result_count': books.length,
          'first_has_book_url':
              (books.firstOrNull?.bookUrl ?? '').trim().isNotEmpty,
        },
      );
    } on CheckException catch (e) {
      if (e.tag == '搜索失效') {
        groups.add('搜索失效');
        return false;
      }
      rethrow;
    } on TimeoutException {
      groups.add('搜索失效');
      return false;
    }

    if (books.isEmpty) {
      groups.add('搜索失效');
      return false;
    }

    groups.remove('搜索失效');
    final candidate = books.first;
    return _checkBook(
      source: source,
      book: candidate,
      groups: groups,
      isSearchBook: true,
      bookCheckCache: bookCheckCache,
      report: report,
    );
  }

  Future<String> _resolveSearchWord(
    db.BookSource source,
    String fallbackSearchWord,
  ) async {
    final importedKeyword = sourceCheckKeywords[source.id]?.trim();
    if (importedKeyword != null && importedKeyword.isNotEmpty) {
      return importedKeyword;
    }

    final normalizedFallback =
        SourceCheckPolicy.normalizeKeyword(fallbackSearchWord);
    if (normalizedFallback != SourceCheckPolicy.defaultKeyword) {
      return normalizedFallback;
    }

    final database = db.AppDatabase.instance;
    final ruleSearch = await (database.select(database.ruleSearchs)
          ..where((t) => t.bookSourceId.equals(source.id)))
        .getSingleOrNull();
    final checkKeyword = ruleSearch?.checkKeyWord?.trim();
    if (checkKeyword != null && checkKeyword.isNotEmpty) {
      return checkKeyword;
    }
    return normalizedFallback;
  }

  Future<void> _checkDiscoveryBranch({
    required db.BookSource source,
    required Set<String> groups,
    required Map<String, _BookCheckOutcome> bookCheckCache,
    required bool skipBookCheck,
    required SourceCheckReportBuilder report,
  }) async {
    final exploreUrl = source.exploreUrl?.trim() ?? '';
    if (SourceCheckPolicy.shouldSkipDiscovery(exploreUrl)) {
      report.addSkipped(SourceCheckStage.discovery, '未配置发现地址，跳过');
      return;
    }

    final exploreUrls = await _resolveExploreCandidateUrls(source);
    if (exploreUrls.isEmpty) {
      groups.add(SourceCheckTags.discoveryRuleEmpty);
      report.addFailure(
        stage: SourceCheckStage.discovery,
        error: CheckException(
          SourceCheckTags.discoveryRuleEmpty,
          '发现规则未解析出候选地址',
        ),
      );
      return;
    }

    groups.remove(SourceCheckTags.discoveryRuleEmpty);

    List<BookInfo> books = const [];
    Object? lastFailure;
    Object? transientFailure;
    var sawNonTransientFailureOrEmpty = false;
    for (final exploreItemUrl in exploreUrls) {
      try {
        books = await report.record<List<BookInfo>>(
          stage: SourceCheckStage.discovery,
          action: () async {
            final result = await _withTransientNetworkRetry<List<BookInfo>>(
              sourceName: source.bookSourceName,
              stage: '发现',
              action: () => WebSearchService.exploreBook(
                source,
                exploreItemUrl,
                cancelToken: cancelToken,
                throwOnEmpty: false,
              ).timeout(
                SourceCheckPolicy.requestTimeout(source.respondTime),
              ),
            );
            if (result.isEmpty) {
              throw CheckException('发现失效', '发现结果为空');
            }
            return result;
          },
          successMessage: (books) => '找到 ${books.length} 本书',
          successDiagnostics: (books) => <String, Object?>{
            'result_count': books.length,
            'first_has_book_url':
                (books.firstOrNull?.bookUrl ?? '').trim().isNotEmpty,
          },
        );
      } on CheckException catch (e) {
        if (e.tag == '发现失效') {
          lastFailure = e;
          sawNonTransientFailureOrEmpty = true;
          continue;
        }
        rethrow;
      } on SourceLoginRequiredException {
        rethrow;
      } catch (e) {
        lastFailure = e;
        if (SourceCheckPolicy.isTransientNetworkFailure(e)) {
          transientFailure = e;
        } else {
          sawNonTransientFailureOrEmpty = true;
        }
        continue;
      }

      if (books.isNotEmpty) {
        break;
      }
      sawNonTransientFailureOrEmpty = true;
    }

    if (books.isEmpty) {
      if (transientFailure != null && !sawNonTransientFailureOrEmpty) {
        throw transientFailure;
      }
      groups.add('发现失效');
      if (lastFailure != null) {
        LogUtils.w(
          '书源 ${source.bookSourceName} 发现候选均未解析出结果: $lastFailure',
        );
      }
      return;
    }

    groups.remove('发现失效');
    final candidate = books.first;
    if ((candidate.bookUrl ?? '').trim().isEmpty) {
      groups.add('发现失效');
      report.addFailure(
        stage: SourceCheckStage.discovery,
        error: CheckException('发现失效', '发现结果缺少书籍链接'),
      );
      return;
    }

    if (skipBookCheck) {
      _removeStageTags(groups, '发现');
      report.addSkipped(SourceCheckStage.detail, '快速模式复用搜索详情结果');
      report.addSkipped(SourceCheckStage.toc, '快速模式复用搜索目录结果');
      if (config.checkContent) {
        report.addSkipped(SourceCheckStage.content, '快速模式复用搜索正文结果');
      }
      return;
    }

    await _checkBook(
      source: source,
      book: candidate,
      groups: groups,
      isSearchBook: false,
      bookCheckCache: bookCheckCache,
      report: report,
    );
  }

  Future<bool> _checkBook({
    required db.BookSource source,
    required BookInfo book,
    required Set<String> groups,
    required bool isSearchBook,
    required Map<String, _BookCheckOutcome> bookCheckCache,
    required SourceCheckReportBuilder report,
  }) async {
    if (SourceCheckPolicy.shouldSkipDetail(config.checkInfo)) {
      report.addSkipped(SourceCheckStage.detail, '未启用详情校验');
      return true;
    }

    final prefix = isSearchBook ? '搜索' : '发现';
    final bookUrl = book.bookUrl?.trim() ?? '';
    if (bookUrl.isEmpty) {
      report.addFailure(
        stage: SourceCheckStage.detail,
        error: CheckException('网站失效', '书籍链接为空'),
      );
      throw CheckException('网站失效', '$prefix结果缺少书籍链接');
    }

    final cacheKeys = _bookCheckCacheKeys(book);
    _BookCheckOutcome? outcome;
    for (final key in cacheKeys) {
      outcome = bookCheckCache[key];
      if (outcome != null) break;
    }

    try {
      if (outcome != null) {
        report.addSkipped(SourceCheckStage.detail, '复用已校验书籍结果');
        report.addSkipped(SourceCheckStage.toc, '复用已校验书籍结果');
        if (config.checkContent) {
          report.addSkipped(SourceCheckStage.content, '复用已校验书籍结果');
        }
      }
      outcome ??= await _checkBookCore(
        source: source,
        book: book,
        report: report,
      );
      final allCacheKeys = <String>{
        ...cacheKeys,
        ..._bookCheckCacheKeys(
          book.copyWith(tocUrl: outcome.resolvedTocUrl),
        ),
      };
      for (final key in allCacheKeys) {
        bookCheckCache[key] = outcome;
      }

      if (outcome.failureTag == null) {
        _removeStageTags(groups, prefix);
        return true;
      }

      switch (outcome.failureTag) {
        case '目录失效':
          groups.add('$prefix目录失效');
          return false;
        case '正文失效':
          groups.add('$prefix正文失效');
          return false;
        default:
          throw CheckException(
            outcome.failureTag!,
            outcome.failureMessage ?? outcome.failureTag!,
          );
      }
    } on CheckException catch (e) {
      switch (e.tag) {
        case '目录失效':
          groups.add('$prefix目录失效');
          return false;
        case '正文失效':
          groups.add('$prefix正文失效');
          return false;
        default:
          rethrow;
      }
    }
  }

  Future<_BookCheckOutcome> _checkBookCore({
    required db.BookSource source,
    required BookInfo book,
    required SourceCheckReportBuilder report,
  }) async {
    final bookUrl = book.bookUrl!.trim();
    BookDetailLoadContext? detailContext;
    String? tocUrl = book.tocUrl?.trim();

    try {
      if (tocUrl == null || tocUrl.isEmpty) {
        detailContext = await report.record<BookDetailLoadContext>(
          stage: SourceCheckStage.detail,
          action: () => _withTransientNetworkRetry<BookDetailLoadContext>(
            sourceName: source.bookSourceName,
            stage: '详情',
            action: () => WebBookDetailService.loadBookDetailContext(
              source,
              bookUrl,
              cancelToken: cancelToken,
            ).timeout(
              SourceCheckPolicy.requestTimeout(source.respondTime),
            ),
          ),
          successMessage: (context) {
            final name = context.detail.name?.trim() ?? '';
            return name.isEmpty ? '详情获取成功' : '详情: $name';
          },
        );
        tocUrl = detailContext.detail.tocUrl?.trim();
      } else {
        report.addSkipped(SourceCheckStage.detail, '搜索结果已包含目录地址');
        final cachedVars = SourceHttp.getBookRuleVariables(
          sourceId: source.id,
          bookUrl: bookUrl,
          tocUrl: tocUrl,
        );
        if (cachedVars == null) {
          SourceHttp.cacheBookRuleVariables(
            sourceId: source.id,
            bookUrl: bookUrl,
            tocUrl: tocUrl,
            variables: const <String, String>{},
          );
        }
      }

      if (SourceCheckPolicy.shouldSkipCategory(
        checkCategory: config.checkCategory,
        bookSourceType: source.bookSourceType,
      )) {
        report.addSkipped(SourceCheckStage.toc, '未启用目录校验或文件类书源');
        return _BookCheckOutcome.success(resolvedTocUrl: tocUrl);
      }

      final chapters = await report.record<List<BookChapterInfo>>(
        stage: SourceCheckStage.toc,
        action: () async {
          final loaded =
              await _withTransientNetworkRetry<List<BookChapterInfo>>(
            sourceName: source.bookSourceName,
            stage: '目录',
            action: () => WebBookDetailService.getChapterList(
              source,
              bookUrl,
              tocUrl: tocUrl,
              htmlData: detailContext?.page.html,
              baseUrl: detailContext?.page.finalUrl,
              cancelToken: cancelToken,
              maxTocPages: 1,
              stopWhenReadableChapterCount: 2,
            ).timeout(
              SourceCheckPolicy.requestTimeout(source.respondTime),
            ),
          );
          if (loaded.isEmpty) {
            throw CheckException('目录失效', '目录为空');
          }
          final readable = WebBookDetailService.readableChapters(loaded)
              .take(2)
              .toList(growable: false);
          if (readable.isEmpty) {
            throw CheckException('目录失效', '目录没有可测试的正文章节');
          }
          return loaded;
        },
        successMessage: (chapters) => '章节 ${chapters.length}',
        successDiagnostics: (chapters) => <String, Object?>{
          'chapter_count': chapters.length,
          'readable_chapter_count':
              WebBookDetailService.readableChapters(chapters).length,
        },
      );

      final readableChapters =
          WebBookDetailService.readableChapters(chapters).take(2).toList();

      if (config.checkContent) {
        final testChapter = readableChapters.first;
        final nextChapterUrl = readableChapters.length > 1
            ? readableChapters[1].chapterUrl?.trim()
            : readableChapters.first.chapterUrl?.trim();
        try {
          await report.record<String>(
            stage: SourceCheckStage.content,
            action: () async {
              final content = await _withTransientNetworkRetry<String>(
                sourceName: source.bookSourceName,
                stage: '正文',
                action: () => WebContentService.getContent(
                  source,
                  testChapter,
                  cancelToken: cancelToken,
                  skipNextPage: true,
                  forCheck: true,
                  nextChapterUrl: nextChapterUrl?.isNotEmpty == true
                      ? nextChapterUrl
                      : null,
                ).timeout(
                  SourceCheckPolicy.requestTimeout(source.respondTime),
                ),
              );
              if (content.trim().isEmpty) {
                throw CheckException('正文失效', '正文为空');
              }
              return content;
            },
            successMessage: (content) => '正文 ${content.trim().length} 字',
            successDiagnostics: (content) => <String, Object?>{
              'content_length': content.length,
              'trimmed_content_length': content.trim().length,
              'looks_html_like':
                  RegExp(r'</?[a-z][\s\S]*>', caseSensitive: false)
                      .hasMatch(content),
            },
          );
        } on TimeoutException {
          throw CheckException('正文失效', '正文请求超时');
        }
      } else {
        report.addSkipped(SourceCheckStage.content, '未启用正文校验');
      }

      return _BookCheckOutcome.success(resolvedTocUrl: tocUrl);
    } on TimeoutException {
      final fallbackTag = SourceCheckPolicy.shouldSkipCategory(
        checkCategory: config.checkCategory,
        bookSourceType: source.bookSourceType,
      )
          ? '网站失效'
          : '目录失效';
      return _BookCheckOutcome.failure(
        failureTag: fallbackTag,
        failureMessage: '$fallbackTag: 阶段请求超时',
        resolvedTocUrl: tocUrl,
      );
    } on CheckException catch (e) {
      switch (e.tag) {
        case '目录失效':
        case '正文失效':
          return _BookCheckOutcome.failure(
            failureTag: e.tag,
            failureMessage: e.message,
            resolvedTocUrl: tocUrl,
          );
        default:
          rethrow;
      }
    }
  }

  void _removeStageTags(Set<String> groups, String prefix) {
    groups.remove('$prefix失效');
    groups.remove('$prefix目录失效');
    groups.remove('$prefix正文失效');
  }

  List<String> _bookCheckCacheKeys(BookInfo book) {
    final keys = <String>[];
    final bookUrl = book.bookUrl?.trim();
    if (bookUrl != null && bookUrl.isNotEmpty) {
      keys.add('book:${SourceHttp.normalizeUrl(bookUrl)}');
    }
    final tocUrl = book.tocUrl?.trim();
    if (tocUrl != null && tocUrl.isNotEmpty) {
      keys.add('toc:${SourceHttp.normalizeUrl(tocUrl)}');
    }
    return keys;
  }

  Future<List<String>> _resolveExploreCandidateUrls(
      db.BookSource source) async {
    final rawExploreUrl = source.exploreUrl?.trim() ?? '';
    if (rawExploreUrl.isEmpty) {
      return const [];
    }

    final sourceHeaders = await SourceHttp.buildSourceHeaders(source);
    final engine = await SourceHttp.newRuleEngine(
      source,
      sourceHeaders: sourceHeaders,
    );
    final kinds = await SourceHttp.runWithWebViewBridge(
      source: source,
      engine: engine,
      sourceHeaders: sourceHeaders,
      parse: () => engine.parseExploreKinds(exploreUrl: rawExploreUrl),
    );

    final urls = <String>[];
    for (final item in kinds) {
      final rawUrl = (item.url ?? '').trim();
      if (rawUrl.isEmpty) continue;
      if (!urls.contains(rawUrl)) {
        urls.add(rawUrl);
      }
      if (urls.length >= SourceCheckPolicy.maxDiscoveryCandidates) {
        break;
      }
    }
    return urls;
  }

  Future<T> _withTransientNetworkRetry<T>({
    required String sourceName,
    required String stage,
    required Future<T> Function() action,
  }) async {
    Object? lastError;
    for (var attempt = 0;
        attempt <= SourceCheckPolicy.transientNetworkRetryCount;
        attempt++) {
      try {
        return await action();
      } on SourceLoginRequiredException {
        rethrow;
      } catch (e) {
        if (e is DioException && e.type == DioExceptionType.cancel) {
          rethrow;
        }
        if (!SourceCheckPolicy.isTransientNetworkFailure(e) ||
            attempt >= SourceCheckPolicy.transientNetworkRetryCount) {
          rethrow;
        }
        lastError = e;
        LogUtils.w(
          '书源 $sourceName $stage 网络异常，准备重试(${attempt + 1}/${SourceCheckPolicy.transientNetworkRetryCount}): $e',
        );
        await Future.delayed(SourceCheckPolicy.transientNetworkRetryDelay);
        if (!isActive()) {
          throw _SourceCheckCancelledException();
        }
      }
    }

    throw lastError ?? StateError('$stage 请求失败');
  }

  bool _isLikelyJsError(Object error) {
    final message = error.toString().toLowerCase();
    return message.contains('scriptexception') ||
        message.contains('wrappedexception') ||
        message.contains('javascript');
  }

  String _formatElapsed(int elapsedMs) {
    if (elapsedMs < 1000) return '${elapsedMs}ms';
    return '${(elapsedMs / 1000).toStringAsFixed(1)}s';
  }

  SourceCheckFailureClass? _failureClassFromReport(
    SourceCheckReportBuilder report,
  ) {
    for (final stage in report.build().reversed) {
      if (!stage.ok && stage.failureClass != null) {
        return stage.failureClass;
      }
    }
    return null;
  }

  Future<void> _finish(
    int sourceId, {
    required SourceCheckExecutionResult result,
    required String message,
  }) async {
    if (!isActive()) return;
    await onSourceFinished(
      sourceId: sourceId,
      result: result,
      message: message,
    );
  }

  Set<String> _parseGroups(String? group) {
    if (group == null || group.trim().isEmpty) {
      return <String>{};
    }
    return group
        .split(RegExp(r'[;,，]'))
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toSet();
  }

  void _removeInvalidGroups(Set<String> groups) {
    groups.removeWhere(SourceCheckPolicy.isInvalidGroup);
  }
}

class _SourceCheckCancelledException implements Exception {}

class _InvalidGroupsException implements Exception {
  _InvalidGroupsException({
    required this.fatalTags,
    required this.checkTags,
    required this.resolvedGroups,
  });

  final List<String> fatalTags;
  final List<String> checkTags;
  final List<String> resolvedGroups;
}

class _BookCheckOutcome {
  const _BookCheckOutcome({
    required this.failureTag,
    required this.failureMessage,
    required this.resolvedTocUrl,
  });

  const _BookCheckOutcome.success({String? resolvedTocUrl})
      : this(
          failureTag: null,
          failureMessage: null,
          resolvedTocUrl: resolvedTocUrl,
        );

  const _BookCheckOutcome.failure({
    required String failureTag,
    required String failureMessage,
    String? resolvedTocUrl,
  }) : this(
          failureTag: failureTag,
          failureMessage: failureMessage,
          resolvedTocUrl: resolvedTocUrl,
        );

  final String? failureTag;
  final String? failureMessage;
  final String? resolvedTocUrl;
}
