import 'dart:async';

import 'package:dio/dio.dart';

import '../../database/drift/app_database.dart' as db;
import '../../database/models/models.dart';
import '../book/service_result.dart';
import 'source_check_policy.dart';
import 'source_check_report.dart';
import 'source_http.dart';
import 'source_login_service.dart';
import 'web_search_service.dart';
import 'web_book_detail_service.dart';
import 'web_content_service.dart';

enum SourceTestStatus { testing, success, warning, error }

class SourceTestReport {
  final String title;
  final SourceTestStatus status;
  final String message;
  final String? detail;
  final int? elapsed;
  final ServiceError? error;

  const SourceTestReport({
    required this.title,
    required this.status,
    required this.message,
    this.detail,
    this.elapsed,
    this.error,
  });
}

typedef SourceTestReporter = void Function(SourceTestReport report);
typedef SourceTestStageReporter = void Function(SourceCheckStageReport report);

/// 书源单测流程（搜索 -> 详情 -> 目录 -> 正文）。
class SourceTestService {
  static const String _defaultSearchWord = '我的';
  static const int _maxCandidateBooks = 3;

  static Future<List<SourceCheckStageReport>> run(
    db.BookSource source, {
    SourceTestReporter? onReport,
    SourceTestStageReporter? onStageReport,
    CancelToken? cancelToken,
    String searchWord = _defaultSearchWord,
  }) async {
    final stageReport = SourceCheckReportBuilder();
    List<BookInfo> searchBooks = const <BookInfo>[];
    String? bookUrl;
    BookDetailLoadContext? detailContext;
    BookDetail? detail;
    List<BookChapterInfo>? chapters;
    final effectiveSearchWord = await _resolveSearchWord(source, searchWord);

    if ((source.searchUrl ?? '').trim().isNotEmpty) {
      _emitReport(
        onReport,
        title: '搜索功能',
        status: SourceTestStatus.testing,
        message: '正在搜索「$effectiveSearchWord」...',
      );
      final sw = Stopwatch()..start();
      try {
        final books = await WebSearchService.searchBook(
          source,
          effectiveSearchWord,
          cancelToken: cancelToken,
        ).timeout(SourceCheckPolicy.requestTimeout(source.respondTime));
        sw.stop();
        if (books.isEmpty) {
          final error = ServiceError(
            code: ServiceErrorCodes.sourceTestSearchEmpty,
            userMessage: '搜索结果为空',
            context: <String, Object?>{
              'searchUrl': source.searchUrl,
              'keyword': effectiveSearchWord,
            },
          );
          _emitReport(
            onReport,
            title: '搜索功能',
            status: SourceTestStatus.warning,
            error: error,
            elapsed: sw.elapsedMilliseconds,
          );
          _emitStageReport(
            stageReport,
            onStageReport,
            stage: SourceCheckStage.search,
            ok: false,
            elapsedMs: sw.elapsedMilliseconds,
            error: CheckException('搜索失效', error.userMessage),
            message: error.userMessage,
            diagnostics: const <String, Object?>{'result_count': 0},
          );
        } else {
          searchBooks = books;
          final firstBook = books.first;
          bookUrl = firstBook.bookUrl?.trim();
          final validBookUrlCount = books
              .where((book) => (book.bookUrl ?? '').trim().isNotEmpty)
              .length;
          _emitReport(
            onReport,
            title: '搜索功能',
            status: SourceTestStatus.success,
            message: '找到 ${books.length} 本书',
            detail: _joinDetailLines([
              '首个: ${firstBook.name}（${firstBook.author ?? "未知"}）',
              'bookUrl: ${firstBook.bookUrl ?? "空"}',
            ]),
            elapsed: sw.elapsedMilliseconds,
          );
          _emitStageReport(
            stageReport,
            onStageReport,
            stage: SourceCheckStage.search,
            ok: true,
            elapsedMs: sw.elapsedMilliseconds,
            message: '找到 ${books.length} 本书',
            diagnostics: <String, Object?>{
              'result_count': books.length,
              'valid_book_url_count': validBookUrlCount,
            },
          );
        }
      } catch (error, stackTrace) {
        sw.stop();
        final serviceError = _buildStageError(
          code: ServiceErrorCodes.sourceTestSearchFailed,
          fallbackUserMessage: '搜索失败，请检查规则或网络后重试',
          error: error,
          stackTrace: stackTrace,
          context: <String, Object?>{
            'searchUrl': source.searchUrl,
            'keyword': effectiveSearchWord,
          },
        );
        _emitReport(
          onReport,
          title: '搜索功能',
          status: SourceTestStatus.error,
          detail: _joinDetailLines([
            'searchUrl: ${source.searchUrl ?? "空"}',
            'keyword: $effectiveSearchWord',
          ]),
          error: serviceError,
          elapsed: sw.elapsedMilliseconds,
        );
        _emitStageReport(
          stageReport,
          onStageReport,
          stage: SourceCheckStage.search,
          ok: false,
          elapsedMs: sw.elapsedMilliseconds,
          error: error,
          message: serviceError.userMessage,
        );
      }
    } else {
      _emitReport(
        onReport,
        title: '搜索功能',
        status: SourceTestStatus.warning,
        message: '未配置搜索地址，跳过',
      );
      _emitStageReport(
        stageReport,
        onStageReport,
        stage: SourceCheckStage.search,
        ok: false,
        elapsedMs: 0,
        error: CheckException('搜索失效', '未配置搜索地址'),
        message: '未配置搜索地址，跳过',
        diagnostics: const <String, Object?>{'configured': false},
      );
    }

    final candidateBooks = searchBooks
        .where((book) => (book.bookUrl ?? '').trim().isNotEmpty)
        .take(_maxCandidateBooks)
        .toList(growable: false);

    if (candidateBooks.isEmpty) {
      final currentBookUrl = bookUrl;
      if (currentBookUrl == null || currentBookUrl.isEmpty) {
        return stageReport.build();
      }

      final loaded = await _loadDetailAndTocForSingleBook(
        source: source,
        bookUrl: currentBookUrl,
        onReport: onReport,
        onStageReport: onStageReport,
        report: stageReport,
        cancelToken: cancelToken,
      );
      if (loaded == null) {
        return stageReport.build();
      }
      bookUrl = loaded.bookUrl;
      detailContext = loaded.detailContext;
      detail = loaded.detail;
      chapters = loaded.chapters;
    } else {
      _emitReport(
        onReport,
        title: '书籍详情',
        status: SourceTestStatus.testing,
        message: '正在获取详情...',
      );
      _emitReport(
        onReport,
        title: '目录规则',
        status: SourceTestStatus.testing,
        message: '正在获取目录...',
      );

      final detailSw = Stopwatch()..start();
      final tocSw = Stopwatch()..start();
      final candidateFailures = <String>[];
      Object? lastDetailError;
      StackTrace? lastDetailStackTrace;
      String? lastDetailBookUrl;
      Object? lastTocError;
      StackTrace? lastTocStackTrace;
      String? lastTocBookUrl;
      BookDetailLoadContext? lastTocDetailContext;
      BookDetail? lastTocDetail;

      for (var i = 0; i < candidateBooks.length; i++) {
        final candidate = candidateBooks[i];
        final candidateBookUrl = candidate.bookUrl!.trim();
        BookDetailLoadContext loadedDetailContext;
        BookDetail loadedDetail;

        try {
          loadedDetailContext =
              await WebBookDetailService.loadBookDetailContext(
            source,
            candidateBookUrl,
            cancelToken: cancelToken,
          ).timeout(SourceCheckPolicy.requestTimeout(source.respondTime));
          loadedDetail = loadedDetailContext.detail;
        } catch (error, stackTrace) {
          lastDetailError = error;
          lastDetailStackTrace = stackTrace;
          lastDetailBookUrl = candidateBookUrl;
          candidateFailures.add(
            '#${i + 1} ${candidate.name}: 详情失败: $error',
          );
          continue;
        }

        try {
          final loadedChapters = await WebBookDetailService.getChapterList(
            source,
            candidateBookUrl,
            tocUrl: loadedDetail.tocUrl,
            htmlData: loadedDetailContext.page.html,
            baseUrl: loadedDetailContext.page.finalUrl,
            cancelToken: cancelToken,
            stopWhenReadableChapterCount: 2,
          ).timeout(SourceCheckPolicy.requestTimeout(source.respondTime));

          if (loadedChapters.isEmpty) {
            throw CheckException('目录失效', '目录为空');
          }

          bookUrl = candidateBookUrl;
          detailContext = loadedDetailContext;
          detail = loadedDetail;
          chapters = loadedChapters;
          break;
        } catch (error, stackTrace) {
          lastTocError = error;
          lastTocStackTrace = stackTrace;
          lastTocBookUrl = candidateBookUrl;
          lastTocDetailContext = loadedDetailContext;
          lastTocDetail = loadedDetail;
          candidateFailures.add(
            '#${i + 1} ${candidate.name}: 目录失败: $error',
          );
        }
      }

      detailSw.stop();
      tocSw.stop();
      final loadedChapters = chapters;
      if (loadedChapters == null) {
        final failuresText = candidateFailures.take(5).join('\n');
        if (lastTocError != null) {
          _emitReport(
            onReport,
            title: '书籍详情',
            status: SourceTestStatus.success,
            message: '详情获取成功',
            detail: _buildBookDetailDebugInfo(
              context: lastTocDetailContext,
              detail: lastTocDetail,
              fallbackBookUrl: lastTocBookUrl ?? bookUrl ?? '',
            ),
            elapsed: detailSw.elapsedMilliseconds,
          );
          _emitStageReport(
            stageReport,
            onStageReport,
            stage: SourceCheckStage.detail,
            ok: true,
            elapsedMs: detailSw.elapsedMilliseconds,
            message: '详情获取成功',
            diagnostics:
                _detailDiagnostics(lastTocDetailContext, lastTocDetail),
          );
          _emitReport(
            onReport,
            title: '目录规则',
            status: SourceTestStatus.error,
            detail: mergeDebugDetails([
              _buildTocDebugInfo(
                chapters: loadedChapters,
                detail: lastTocDetail,
                detailContext: lastTocDetailContext,
                fallbackBookUrl: lastTocBookUrl ?? bookUrl ?? '',
              ),
              if (failuresText.isNotEmpty) '候选失败:\n$failuresText',
            ]),
            error: _buildStageError(
              code: ServiceErrorCodes.sourceTestTocFailed,
              fallbackUserMessage: '获取目录失败，请检查规则或网络后重试',
              error: lastTocError,
              stackTrace: lastTocStackTrace ?? StackTrace.current,
              context: <String, Object?>{
                'bookUrl': lastTocBookUrl,
                'tocUrl': lastTocDetail?.tocUrl,
              },
            ),
            elapsed: tocSw.elapsedMilliseconds,
          );
          _emitStageReport(
            stageReport,
            onStageReport,
            stage: SourceCheckStage.toc,
            ok: false,
            elapsedMs: tocSw.elapsedMilliseconds,
            error: lastTocError,
            message: '获取目录失败，请检查规则或网络后重试',
            diagnostics: <String, Object?>{
              'candidate_count': candidateBooks.length,
              'candidate_failure_count': candidateFailures.length,
              ..._tocDiagnostics(loadedChapters),
            },
          );
        } else if (lastDetailError != null) {
          _emitReport(
            onReport,
            title: '书籍详情',
            status: SourceTestStatus.error,
            detail: mergeDebugDetails([
              _buildBookDetailDebugInfo(
                context: detailContext,
                detail: detail,
                fallbackBookUrl: lastDetailBookUrl ?? bookUrl ?? '',
              ),
              if (failuresText.isNotEmpty) '候选失败:\n$failuresText',
            ]),
            error: _buildStageError(
              code: ServiceErrorCodes.sourceTestDetailFailed,
              fallbackUserMessage: '获取书籍详情失败，请检查规则或网络后重试',
              error: lastDetailError,
              stackTrace: lastDetailStackTrace ?? StackTrace.current,
              context: <String, Object?>{
                'bookUrl': lastDetailBookUrl,
                'sourceId': source.id,
              },
            ),
            elapsed: detailSw.elapsedMilliseconds,
          );
          _emitStageReport(
            stageReport,
            onStageReport,
            stage: SourceCheckStage.detail,
            ok: false,
            elapsedMs: detailSw.elapsedMilliseconds,
            error: lastDetailError,
            message: '获取书籍详情失败，请检查规则或网络后重试',
            diagnostics: <String, Object?>{
              'candidate_count': candidateBooks.length,
              'candidate_failure_count': candidateFailures.length,
            },
          );
        }
        return stageReport.build();
      }

      _emitReport(
        onReport,
        title: '书籍详情',
        status: SourceTestStatus.success,
        message: '详情获取成功',
        detail: _buildBookDetailDebugInfo(
          context: detailContext,
          detail: detail,
          fallbackBookUrl: bookUrl ?? '',
        ),
        elapsed: detailSw.elapsedMilliseconds,
      );
      _emitStageReport(
        stageReport,
        onStageReport,
        stage: SourceCheckStage.detail,
        ok: true,
        elapsedMs: detailSw.elapsedMilliseconds,
        message: '详情获取成功',
        diagnostics: <String, Object?>{
          'candidate_count': candidateBooks.length,
          ..._detailDiagnostics(detailContext, detail),
        },
      );
      _emitReport(
        onReport,
        title: '目录规则',
        status: SourceTestStatus.success,
        message:
            '本页 ${loadedChapters.length} 章，正文 ${WebBookDetailService.readableChapters(loadedChapters).length} 章',
        detail: _buildTocDebugInfo(
          chapters: loadedChapters,
          detail: detail,
          detailContext: detailContext,
          fallbackBookUrl: bookUrl ?? '',
        ),
        elapsed: tocSw.elapsedMilliseconds,
      );
      _emitStageReport(
        stageReport,
        onStageReport,
        stage: SourceCheckStage.toc,
        ok: true,
        elapsedMs: tocSw.elapsedMilliseconds,
        message:
            '本页 ${loadedChapters.length} 章，正文 ${WebBookDetailService.readableChapters(loadedChapters).length} 章',
        diagnostics: _tocDiagnostics(loadedChapters),
      );
    }

    final currentChapters = chapters;
    if (currentChapters == null || currentChapters.isEmpty) {
      return stageReport.build();
    }

    final readableChapters =
        WebBookDetailService.readableChapters(currentChapters).take(2).toList();
    if (readableChapters.isEmpty) {
      _emitReport(
        onReport,
        title: '正文规则',
        status: SourceTestStatus.warning,
        message: '没有可测试的正文章节，跳过',
      );
      _emitStageReport(
        stageReport,
        onStageReport,
        stage: SourceCheckStage.content,
        ok: false,
        elapsedMs: 0,
        error: CheckException('正文失效', '没有可测试的正文章节'),
        message: '没有可测试的正文章节，跳过',
        diagnostics: _tocDiagnostics(currentChapters),
      );
      return stageReport.build();
    }

    _emitReport(
      onReport,
      title: '正文规则',
      status: SourceTestStatus.testing,
      message: '正在获取正文...',
    );
    final sw = Stopwatch()..start();
    try {
      final firstChapter = readableChapters.first;
      final nextChapterUrl = readableChapters.length > 1
          ? readableChapters[1].chapterUrl?.trim()
          : readableChapters.first.chapterUrl?.trim();
      final content = await WebContentService.getContent(
        source,
        firstChapter,
        cancelToken: cancelToken,
        nextChapterUrl:
            nextChapterUrl?.isNotEmpty == true ? nextChapterUrl : null,
      ).timeout(SourceCheckPolicy.requestTimeout(source.respondTime));
      sw.stop();
      final preview =
          content.length > 100 ? '${content.substring(0, 100)}...' : content;
      _emitReport(
        onReport,
        title: '正文规则',
        status: SourceTestStatus.success,
        message: '正文获取成功（${content.length} 字）',
        detail: _joinDetailLines([
          '章节: ${firstChapter.chapterName ?? "空"}',
          'chapterUrl: ${firstChapter.chapterUrl ?? "空"}',
          if (nextChapterUrl != null) 'nextChapterUrl: $nextChapterUrl',
          '预览: $preview',
        ]),
        elapsed: sw.elapsedMilliseconds,
      );
      _emitStageReport(
        stageReport,
        onStageReport,
        stage: SourceCheckStage.content,
        ok: true,
        elapsedMs: sw.elapsedMilliseconds,
        message: '正文获取成功（${content.length} 字）',
        diagnostics: <String, Object?>{
          'content_length': content.length,
          'chapter_count': currentChapters.length,
          'readable_chapter_count': readableChapters.length,
          'has_next_chapter': nextChapterUrl?.isNotEmpty == true,
        },
      );
    } catch (error, stackTrace) {
      sw.stop();
      final firstChapter = readableChapters.first;
      final nextChapterUrl = readableChapters.length > 1
          ? readableChapters[1].chapterUrl?.trim()
          : readableChapters.first.chapterUrl?.trim();
      _emitReport(
        onReport,
        title: '正文规则',
        status: SourceTestStatus.error,
        detail: _joinDetailLines([
          '章节: ${firstChapter.chapterName ?? "空"}',
          'chapterUrl: ${firstChapter.chapterUrl ?? "空"}',
          if (nextChapterUrl != null) 'nextChapterUrl: $nextChapterUrl',
        ]),
        error: _buildStageError(
          code: ServiceErrorCodes.sourceTestContentFailed,
          fallbackUserMessage: '获取正文失败，请检查规则或网络后重试',
          error: error,
          stackTrace: stackTrace,
          context: <String, Object?>{
            'chapterName': firstChapter.chapterName,
            'chapterUrl': firstChapter.chapterUrl,
            'nextChapterUrl': nextChapterUrl,
          },
        ),
        elapsed: sw.elapsedMilliseconds,
      );
      _emitStageReport(
        stageReport,
        onStageReport,
        stage: SourceCheckStage.content,
        ok: false,
        elapsedMs: sw.elapsedMilliseconds,
        error: error,
        message: '获取正文失败，请检查规则或网络后重试',
        diagnostics: <String, Object?>{
          'chapter_count': currentChapters.length,
          'readable_chapter_count': readableChapters.length,
          'has_next_chapter': nextChapterUrl?.isNotEmpty == true,
        },
      );
    }
    return stageReport.build();
  }

  static Future<_LoadedDetailAndToc?> _loadDetailAndTocForSingleBook({
    required db.BookSource source,
    required String bookUrl,
    required SourceTestReporter? onReport,
    required SourceTestStageReporter? onStageReport,
    required SourceCheckReportBuilder report,
    required CancelToken? cancelToken,
  }) async {
    BookDetailLoadContext? detailContext;
    BookDetail? detail;
    List<BookChapterInfo>? chapters;

    _emitReport(
      onReport,
      title: '书籍详情',
      status: SourceTestStatus.testing,
      message: '正在获取详情...',
    );
    final detailSw = Stopwatch()..start();
    try {
      detailContext = await WebBookDetailService.loadBookDetailContext(
        source,
        bookUrl,
        cancelToken: cancelToken,
      ).timeout(SourceCheckPolicy.requestTimeout(source.respondTime));
      detail = detailContext.detail;
      detailSw.stop();
      _emitReport(
        onReport,
        title: '书籍详情',
        status: SourceTestStatus.success,
        message: '详情获取成功',
        detail: _buildBookDetailDebugInfo(
          context: detailContext,
          detail: detail,
          fallbackBookUrl: bookUrl,
        ),
        elapsed: detailSw.elapsedMilliseconds,
      );
      _emitStageReport(
        report,
        onStageReport,
        stage: SourceCheckStage.detail,
        ok: true,
        elapsedMs: detailSw.elapsedMilliseconds,
        message: '详情获取成功',
        diagnostics: _detailDiagnostics(detailContext, detail),
      );
    } catch (error, stackTrace) {
      detailSw.stop();
      _emitReport(
        onReport,
        title: '书籍详情',
        status: SourceTestStatus.error,
        detail: _buildBookDetailDebugInfo(
          context: detailContext,
          detail: detail,
          fallbackBookUrl: bookUrl,
        ),
        error: _buildStageError(
          code: ServiceErrorCodes.sourceTestDetailFailed,
          fallbackUserMessage: '获取书籍详情失败，请检查规则或网络后重试',
          error: error,
          stackTrace: stackTrace,
          context: <String, Object?>{
            'bookUrl': bookUrl,
            'sourceId': source.id,
          },
        ),
        elapsed: detailSw.elapsedMilliseconds,
      );
      _emitStageReport(
        report,
        onStageReport,
        stage: SourceCheckStage.detail,
        ok: false,
        elapsedMs: detailSw.elapsedMilliseconds,
        error: error,
        message: '获取书籍详情失败，请检查规则或网络后重试',
        diagnostics: _detailDiagnostics(detailContext, detail),
      );
      return null;
    }

    _emitReport(
      onReport,
      title: '目录规则',
      status: SourceTestStatus.testing,
      message: '正在获取目录...',
    );
    final tocSw = Stopwatch()..start();
    try {
      chapters = await WebBookDetailService.getChapterList(
        source,
        bookUrl,
        tocUrl: detail.tocUrl,
        htmlData: detailContext.page.html,
        baseUrl: detailContext.page.finalUrl,
        cancelToken: cancelToken,
        stopWhenReadableChapterCount: 2,
      ).timeout(SourceCheckPolicy.requestTimeout(source.respondTime));

      if (chapters.isEmpty) {
        throw CheckException('目录失效', '目录为空');
      }

      tocSw.stop();
      _emitReport(
        onReport,
        title: '目录规则',
        status: SourceTestStatus.success,
        message:
            '本页 ${chapters.length} 章，正文 ${WebBookDetailService.readableChapters(chapters).length} 章',
        detail: _buildTocDebugInfo(
          chapters: chapters,
          detail: detail,
          detailContext: detailContext,
          fallbackBookUrl: bookUrl,
        ),
        elapsed: tocSw.elapsedMilliseconds,
      );
      _emitStageReport(
        report,
        onStageReport,
        stage: SourceCheckStage.toc,
        ok: true,
        elapsedMs: tocSw.elapsedMilliseconds,
        message:
            '本页 ${chapters.length} 章，正文 ${WebBookDetailService.readableChapters(chapters).length} 章',
        diagnostics: _tocDiagnostics(chapters),
      );
    } catch (error, stackTrace) {
      tocSw.stop();
      _emitReport(
        onReport,
        title: '目录规则',
        status: SourceTestStatus.error,
        detail: _buildTocDebugInfo(
          chapters: chapters,
          detail: detail,
          detailContext: detailContext,
          fallbackBookUrl: bookUrl,
        ),
        error: _buildStageError(
          code: ServiceErrorCodes.sourceTestTocFailed,
          fallbackUserMessage: '获取目录失败，请检查规则或网络后重试',
          error: error,
          stackTrace: stackTrace,
          context: <String, Object?>{
            'bookUrl': bookUrl,
            'tocUrl': detail.tocUrl,
          },
        ),
        elapsed: tocSw.elapsedMilliseconds,
      );
      _emitStageReport(
        report,
        onStageReport,
        stage: SourceCheckStage.toc,
        ok: false,
        elapsedMs: tocSw.elapsedMilliseconds,
        error: error,
        message: '获取目录失败，请检查规则或网络后重试',
        diagnostics: _tocDiagnostics(chapters),
      );
      return null;
    }

    return _LoadedDetailAndToc(
      bookUrl: bookUrl,
      detailContext: detailContext,
      detail: detail,
      chapters: chapters,
    );
  }

  static Future<String> _resolveSearchWord(
    db.BookSource source,
    String searchWord,
  ) async {
    final provided = searchWord.trim();
    if (provided.isNotEmpty && provided != _defaultSearchWord) {
      return provided;
    }
    final ruleSearch = await (db.AppDatabase.instance.select(
      db.AppDatabase.instance.ruleSearchs,
    )..where((t) => t.bookSourceId.equals(source.id)))
        .getSingleOrNull();
    final checkKeyword = ruleSearch?.checkKeyWord?.trim();
    if (checkKeyword != null && checkKeyword.isNotEmpty) {
      return checkKeyword;
    }
    return provided.isEmpty ? _defaultSearchWord : provided;
  }

  static void _emitReport(
    SourceTestReporter? onReport, {
    required String title,
    required SourceTestStatus status,
    String? message,
    String? detail,
    int? elapsed,
    ServiceError? error,
  }) {
    onReport?.call(
      SourceTestReport(
        title: title,
        status: status,
        message: error?.userMessage ?? message ?? '',
        detail: mergeDebugDetails([detail, error?.formattedDebugDetail]),
        elapsed: elapsed,
        error: error,
      ),
    );
  }

  static void _emitStageReport(
    SourceCheckReportBuilder report,
    SourceTestStageReporter? onStageReport, {
    required SourceCheckStage stage,
    required bool ok,
    required int elapsedMs,
    String? message,
    Object? error,
    Map<String, Object?> diagnostics = const <String, Object?>{},
  }) {
    final stageReport = ok
        ? report.addSuccess(
            stage: stage,
            elapsedMs: elapsedMs,
            message: message,
            diagnostics: diagnostics,
          )
        : report.addFailure(
            stage: stage,
            error: error ??
                CheckException(
                    SourceCheckReport.stageLabel(stage), message ?? ''),
            elapsedMs: elapsedMs,
            message: message,
            diagnostics: diagnostics,
          );
    onStageReport?.call(stageReport);
  }

  static Map<String, Object?> _detailDiagnostics(
    BookDetailLoadContext? context,
    BookDetail? detail,
  ) {
    return <String, Object?>{
      'has_detail_html': context?.page.html.isNotEmpty,
      'detail_html_length': context?.page.html.length,
      'has_book_name': detail?.name?.trim().isNotEmpty,
      'has_author': detail?.author?.trim().isNotEmpty,
      'has_toc_url': detail?.tocUrl?.trim().isNotEmpty,
    };
  }

  static Map<String, Object?> _tocDiagnostics(List<BookChapterInfo>? chapters) {
    final readableCount = chapters == null
        ? 0
        : WebBookDetailService.readableChapters(chapters).length;
    return <String, Object?>{
      'chapter_count': chapters?.length ?? 0,
      'readable_chapter_count': readableCount,
    };
  }

  static ServiceError _buildStageError({
    required String code,
    required String fallbackUserMessage,
    required Object error,
    required StackTrace stackTrace,
    Map<String, Object?> context = const <String, Object?>{},
  }) {
    if (error is TimeoutException) {
      return ServiceError(
        code: '$code.timeout',
        userMessage: '请求超时，请稍后重试',
        debugMessage: 'source test stage timeout',
        context: context,
        cause: error,
        stackTrace: stackTrace,
      );
    }

    if (error is SourceLoginRequiredException) {
      return ServiceError(
        code: '$code.rule_failed',
        userMessage: error.message,
        debugMessage: 'tag: 登录校验',
        context: <String, Object?>{
          ...context,
          ...error.loginRequired.toJson(),
        },
        cause: error,
        stackTrace: stackTrace,
      );
    }

    if (error is CheckException) {
      return ServiceError(
        code: '$code.rule_failed',
        userMessage: error.message,
        debugMessage: 'tag: ${error.tag}',
        context: context,
        cause: error,
        stackTrace: stackTrace,
      );
    }

    return ServiceError(
      code: code,
      userMessage: fallbackUserMessage,
      debugMessage: error.toString(),
      context: context,
      cause: error,
      stackTrace: stackTrace,
    );
  }

  static String? _buildBookDetailDebugInfo({
    required BookDetailLoadContext? context,
    required BookDetail? detail,
    required String fallbackBookUrl,
  }) {
    return _joinDetailLines([
      '书名: ${detail?.name ?? "空"}',
      '作者: ${detail?.author ?? "空"}',
      if ((detail?.lastChapter?.trim().isNotEmpty ?? false))
        '最新章: ${detail!.lastChapter}',
      'bookUrl: ${detail?.bookUrl ?? fallbackBookUrl}',
      'finalUrl: ${context?.page.finalUrl ?? "空"}',
      if ((detail?.tocUrl?.trim().isNotEmpty ?? false))
        'tocUrl: ${detail!.tocUrl}',
    ]);
  }

  static String? _buildTocDebugInfo({
    required List<BookChapterInfo>? chapters,
    required BookDetail? detail,
    required BookDetailLoadContext? detailContext,
    required String fallbackBookUrl,
  }) {
    final firstChapter =
        (chapters != null && chapters.isNotEmpty) ? chapters.first : null;
    final lastChapter =
        (chapters != null && chapters.isNotEmpty) ? chapters.last : null;
    return _joinDetailLines([
      'bookUrl: ${detail?.bookUrl ?? fallbackBookUrl}',
      'detailUrl: ${detailContext?.page.finalUrl ?? "空"}',
      if ((detail?.tocUrl?.trim().isNotEmpty ?? false))
        'tocUrl: ${detail!.tocUrl}',
      if (firstChapter != null) '首章: ${firstChapter.chapterName ?? "空"}',
      if (firstChapter != null) '首章URL: ${firstChapter.chapterUrl ?? "空"}',
      if (lastChapter != null) '末章: ${lastChapter.chapterName ?? "空"}',
    ]);
  }

  static String? _joinDetailLines(Iterable<String?> lines) {
    final values = lines
        .map((line) => line?.trim())
        .where((line) => line != null && line.isNotEmpty)
        .cast<String>()
        .toList(growable: false);
    if (values.isEmpty) {
      return null;
    }
    return values.join('\n');
  }
}

class _LoadedDetailAndToc {
  final String bookUrl;
  final BookDetailLoadContext detailContext;
  final BookDetail detail;
  final List<BookChapterInfo> chapters;

  const _LoadedDetailAndToc({
    required this.bookUrl,
    required this.detailContext,
    required this.detail,
    required this.chapters,
  });
}
