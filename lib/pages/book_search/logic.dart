import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import 'package:get/get.dart';
import '../../app/database/dao/book_source_dao.dart';
import '../../app/database/drift/app_database.dart' as db;
import '../../app/database/models/models.dart' show BookInfo;
import '../../app/service/source/source_check_policy.dart';
import '../../app/service/source/source_check_report.dart';
import '../../app/service/source/web_book_service.dart';
import '../home/source/controllers/source_login_controller.dart';
import '../../util/debouncer.dart';
import '../../util/log_utils.dart';
import 'state.dart';

class BookSearchLogic extends GetxController {
  BookSearchLogic({this.onRefreshBookshelf});

  final BookSearchState state = BookSearchState();
  final db.AppDatabase _db = db.AppDatabase.instance;
  late final BookSourceDao _bookSourceDao = BookSourceDao(database: _db);
  final SourceLoginController _sourceLoginController =
      const SourceLoginController();
  final VoidCallback? onRefreshBookshelf;

  /// 搜索防抖器
  final _searchDebouncer = Debouncer(delay: const Duration(milliseconds: 300));

  /// 搜索取消令牌列表
  final List<CancelToken> _searchCancelTokens = [];

  int _searchRunId = 0;

  @override
  void onReady() {
    super.onReady();
    init();
  }

  @override
  void onClose() {
    _searchDebouncer.dispose();
    _cancelAllSearches();
    super.onClose();
  }

  /// 取消所有搜索请求
  void _cancelAllSearches() {
    _searchRunId++;
    for (var token in _searchCancelTokens) {
      if (!token.isCancelled) {
        token.cancel('取消搜索');
      }
    }
    _searchCancelTokens.clear();
  }

  bool _isActiveSearch(int runId) => !isClosed && runId == _searchRunId;

  //构建搜索数据
  Future<void> init() async {
    // 加载启用的书源
    state.bookSources = await _bookSourceDao.listEnabledSearch();
    if (isClosed) return;

    // 加载搜索历史
    await loadSearchHistory();
  }

  /// 关键词搜索（带防抖）
  void searchWithDebounce(String keyword) {
    _searchDebouncer.run(() => search(keyword));
  }

  /// 关键词搜索 - 并发搜索所有启用的书源
  Future<void> search(String keyword) async {
    _cancelAllSearches();
    final runId = _searchRunId;
    final searchKeyword = keyword.trim();

    try {
      state.searchKeyword = searchKeyword;
      state.showHistory = false;
      state.isSearching = true;
      state.currentPage = 1;
      state.hasMore = true;
      state.bookInfoList.clear();
      state.sourceResults.clear();
      if (_isActiveSearch(runId)) {
        update();
      }

      await saveSearchHistory(state.searchKeyword);
      if (!_isActiveSearch(runId)) return;

      if (state.bookSources.isEmpty) {
        LogUtils.d("未找到启用的书源");
        state.isSearching = false;
        if (_isActiveSearch(runId)) {
          update();
        }
        return;
      }

      for (var source in state.bookSources) {
        state.sourceResults[source.id] = SourceSearchResult(
          source: source,
          books: [],
          isLoading: true,
        );
      }
      if (_isActiveSearch(runId)) {
        update();
      }

      final hasResults = await _searchSourcesPage(
        runId: runId,
        page: 1,
        append: false,
      );
      if (_isActiveSearch(runId)) {
        state.hasMore = hasResults;
      }
    } catch (e) {
      if (_isActiveSearch(runId)) {
        LogUtils.e("搜索出错: $e");
      }
    } finally {
      if (_isActiveSearch(runId)) {
        state.isSearching = false;
        update();
      }
    }
  }

  Future<void> loadMore() async {
    if (state.isSearching ||
        !state.hasMore ||
        state.searchKeyword.trim().isEmpty ||
        state.bookSources.isEmpty) {
      return;
    }

    final runId = _searchRunId;
    final nextPage = state.currentPage + 1;
    state.isSearching = true;
    for (final source in state.bookSources) {
      final previous = state.sourceResults[source.id];
      if (previous == null) continue;
      state.sourceResults[source.id] = previous.copyWith(
        isLoading: true,
        error: null,
        loginRequired: false,
        failureClass: null,
      );
    }
    update();

    try {
      final hasResults = await _searchSourcesPage(
        runId: runId,
        page: nextPage,
        append: true,
      );
      if (!_isActiveSearch(runId)) return;
      state.currentPage = nextPage;
      state.hasMore = hasResults;
    } finally {
      if (_isActiveSearch(runId)) {
        state.isSearching = false;
        update();
      }
    }
  }

  Future<bool> _searchSourcesPage({
    required int runId,
    required int page,
    required bool append,
  }) async {
    var hasResults = false;
    const concurrencyLimit = 5;
    for (int i = 0; i < state.bookSources.length; i += concurrencyLimit) {
      if (!_isActiveSearch(runId)) break;

      final batch = state.bookSources.skip(i).take(concurrencyLimit);
      final results = await Future.wait(
        batch.map(
          (source) => _searchSingleSource(
            source,
            runId,
            page: page,
            append: append,
          ),
        ),
      );
      hasResults = hasResults || results.any((hasItems) => hasItems);
      if (_isActiveSearch(runId)) {
        _rebuildBookInfoList();
        update();
      }
    }
    return hasResults;
  }

  /// 搜索单个书源
  Future<bool> _searchSingleSource(
    db.BookSource bookSource,
    int runId, {
    int page = 1,
    bool append = false,
  }) async {
    if (!_isActiveSearch(runId)) return false;

    CancelToken? cancelToken;
    try {
      cancelToken = CancelToken();
      _searchCancelTokens.add(cancelToken);

      final books = await WebSearchService.searchBook(
        bookSource,
        state.searchKeyword,
        cancelToken: cancelToken,
        page: page,
        throwOnEmpty: false,
      ).timeout(SourceCheckPolicy.requestTimeout(bookSource.respondTime));

      if (!_isActiveSearch(runId)) return false;

      final previousBooks =
          state.sourceResults[bookSource.id]?.books ?? const <BookInfo>[];
      final mergedBooks = append
          ? _mergeBooksByUrl(previousBooks, books)
          : List<BookInfo>.from(books);
      final hasNewBooks = append
          ? mergedBooks.length > previousBooks.length
          : mergedBooks.isNotEmpty;
      state.sourceResults[bookSource.id] =
          state.sourceResults[bookSource.id]!.copyWith(
        books: mergedBooks,
        isLoading: false,
        error: null,
        loginRequired: false,
        failureClass: null,
      );
      return hasNewBooks;
    } on SourceLoginRequiredException catch (e) {
      if (!_isActiveSearch(runId)) return false;

      LogUtils.d("搜索书源 ${bookSource.bookSourceName} 需要登录: $e");
      state.sourceResults[bookSource.id] =
          state.sourceResults[bookSource.id]!.copyWith(
        isLoading: false,
        error: _loginRequiredMessage(bookSource, e),
        loginRequired: true,
        failureClass: SourceCheckFailureClass.other,
      );
      return false;
    } on DioException catch (e) {
      if (e.type != DioExceptionType.cancel && _isActiveSearch(runId)) {
        final failureClass = SourceCheckReport.classifyFailure(e,
            stage: SourceCheckStage.search);
        LogUtils.e(
          "搜索书源 ${bookSource.bookSourceName} 出错"
          " [${SourceCheckReport.failureLabel(failureClass)}]: $e",
        );
        state.sourceResults[bookSource.id] =
            state.sourceResults[bookSource.id]!.copyWith(
          isLoading: false,
          error: SourceCheckReport.errorSummary(e),
          loginRequired: false,
          failureClass: failureClass,
        );
      }
      return false;
    } catch (e) {
      if (!_isActiveSearch(runId)) return false;

      cancelToken?.cancel('搜索超时或失败');
      final failureClass =
          SourceCheckReport.classifyFailure(e, stage: SourceCheckStage.search);
      LogUtils.e(
        "搜索书源 ${bookSource.bookSourceName} 出错"
        " [${SourceCheckReport.failureLabel(failureClass)}]: $e",
      );
      state.sourceResults[bookSource.id] =
          state.sourceResults[bookSource.id]!.copyWith(
        isLoading: false,
        error: SourceCheckReport.errorSummary(e),
        loginRequired: false,
        failureClass: failureClass,
      );
      return false;
    } finally {
      if (cancelToken != null) {
        _searchCancelTokens.remove(cancelToken);
      }
    }
  }

  List<BookInfo> _mergeBooksByUrl(
    List<BookInfo> previous,
    List<BookInfo> next,
  ) {
    final merged = <BookInfo>[];
    final identities = <String>{};
    for (final book in <BookInfo>[...previous, ...next]) {
      final bookUrl = book.bookUrl?.trim() ?? '';
      final identity = bookUrl.isNotEmpty
          ? bookUrl
          : '${book.name.trim()}\u0000${book.author?.trim() ?? ''}';
      if (identities.add(identity)) merged.add(book);
    }
    return merged;
  }

  /// 打开单个书源登录入口，成功后只重试当前关键词下的该书源一次。
  Future<void> loginAndRetrySource(db.BookSource source) async {
    final keyword = state.searchKeyword.trim();
    final runId = _searchRunId;
    if (keyword.isEmpty || isClosed) return;

    final result = state.sourceResults[source.id];
    if (result == null || !result.loginRequired || result.isLoading) return;

    final loggedIn = await _sourceLoginController.openSourceLogin(source);
    if (!loggedIn ||
        isClosed ||
        keyword != state.searchKeyword ||
        runId != _searchRunId) {
      return;
    }

    state.sourceResults[source.id] = result.copyWith(
      books: const [],
      isLoading: true,
      error: null,
      loginRequired: false,
    );
    _removeBooksFromSource(source.id);
    update();

    await _searchSingleSource(source, runId);
    if (_isActiveSearch(runId)) {
      _rebuildBookInfoList();
      update();
    }
  }

  bool hasOpenableSourceLoginEntry(db.BookSource source) {
    return _sourceLoginController.hasOpenableSourceLoginEntry(source);
  }

  void _removeBooksFromSource(int sourceId) {
    state.bookInfoList.removeWhere((book) => book.bookSourceId == sourceId);
  }

  void _rebuildBookInfoList() {
    state.bookInfoList = state.aggregatedBooks;
  }

  String _loginRequiredMessage(
    db.BookSource source,
    SourceLoginRequiredException error,
  ) {
    if (!_sourceLoginController.hasOpenableSourceLoginEntry(source)) {
      return '该书源需要登录，但未配置可用登录入口';
    }
    return '该书源需要登录后重试';
  }

  //判空处理
  String safeValue(List<String> list, int i, [String defaultValue = ""]) {
    return (list.length > i ? list[i] : defaultValue);
  }

  /// 加载搜索历史
  Future<void> loadSearchHistory() async {
    state.searchHistories = await (_db.select(_db.searchHistories)
          ..orderBy([(t) => OrderingTerm.desc(t.searchTime)]))
        .get();
    if (!isClosed) {
      update();
    }
  }

  /// 保存搜索历史
  Future<void> saveSearchHistory(String keyword) async {
    if (keyword.isEmpty) return;

    // 删除已存在的相同关键词
    await (_db.delete(_db.searchHistories)
          ..where((t) => t.keyword.equals(keyword)))
        .go();
    // 插入新记录
    await _db.into(_db.searchHistories).insert(
          db.SearchHistoriesCompanion.insert(
            keyword: keyword,
            searchTime: DateTime.now(),
          ),
        );
    await loadSearchHistory();
  }

  /// 清除搜索历史
  Future<void> clearSearchHistory() async {
    await _db.delete(_db.searchHistories).go();
    await loadSearchHistory();
  }
}
