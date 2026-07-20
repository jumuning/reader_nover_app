import 'dart:async';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:reader_nover/app/database/dao/book_source_dao.dart';
import 'package:reader_nover/app/routes/route_args.dart';
import 'package:reader_nover/app/service/book/models/source_book_info.dart';

import '../../app/database/drift/app_database.dart' as db;
import '../../app/service/source/source_check_policy.dart';
import '../../app/service/source/web_book_service.dart';
import '../../pages/home/source/controllers/source_login_controller.dart';
import '../../util/log_utils.dart';
import 'state.dart';

class BookChangeLogic extends GetxController {
  BookChangeLogic({required BookChangeArgs args})
      : state = BookChangeState(args: args);

  final BookChangeState state;
  final db.AppDatabase _db = db.AppDatabase.instance;
  late final BookSourceDao _bookSourceDao = BookSourceDao(database: _db);
  final SourceLoginController _sourceLoginController =
      const SourceLoginController();

  /// 换源搜索取消令牌列表
  final List<CancelToken> _cancelTokens = [];

  @override
  void onReady() {
    super.onReady();
    searchAvailableSources();
  }

  /// 搜索可用书源
  Future<void> searchAvailableSources() async {
    if (state.isSearching) return;

    _cancelAllSearches();
    state.isSearching = true;
    state.availableSources = [];
    state.loginRequiredSources = [];
    state.searchedCount = 0;
    update();

    try {
      final enabledSources = await _bookSourceDao.listEnabled();

      state.totalSourceCount = enabledSources.length;
      update();

      // 并发搜索，限制并发数为 5
      const concurrencyLimit = 5;
      for (var i = 0; i < enabledSources.length; i += concurrencyLimit) {
        if (!state.isSearching) break;

        final batch = enabledSources.skip(i).take(concurrencyLimit);
        final batchResults = await Future.wait(
          batch.map((source) => _searchSingleSource(source)),
        );

        for (final result in batchResults) {
          if (result != null) {
            state.availableSources.add(result);
          }
        }
        state.searchedCount =
            (i + concurrencyLimit).clamp(0, enabledSources.length);
        update();
      }
    } catch (e) {
      LogUtils.e('搜索可用书源失败: $e');
    } finally {
      state.isSearching = false;
      update();
    }
  }

  /// 搜索单个书源
  Future<SourceBookInfo?> _searchSingleSource(db.BookSource source) async {
    // 跳过当前书源
    if (source.id == state.currentBookSourceId) return null;

    CancelToken? cancelToken;
    try {
      cancelToken = CancelToken();
      _cancelTokens.add(cancelToken);

      final books = await WebSearchService.searchBook(
        source,
        state.bookName,
        cancelToken: cancelToken,
      ).timeout(SourceCheckPolicy.probeTimeout(source.respondTime));

      // 查找完全匹配的书籍
      for (final book in books) {
        if (book.name == state.bookName) {
          // 通过书籍详情接口获取最新章节（比抓取完整目录开销更小）
          String? lastChapter;
          try {
            final bookDetail = await WebBookDetailService.getBookInfo(
              source,
              book.bookUrl ?? '',
              cancelToken: cancelToken,
            ).timeout(SourceCheckPolicy.probeTimeout(source.respondTime));
            lastChapter = bookDetail.lastChapter;
          } on SourceLoginRequiredException {
            rethrow;
          } catch (_) {}

          return SourceBookInfo(
            bookSource: source,
            bookUrl: book.bookUrl ?? '',
            lastChapter: lastChapter,
          );
        }
      }
      return null;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) return null;
      LogUtils.e('搜索书源 ${source.bookSourceName} 失败: $e');
      return null;
    } on SourceLoginRequiredException catch (e) {
      LogUtils.d('搜索书源 ${source.bookSourceName} 需要登录: $e');
      if (!state.loginRequiredSources.any((s) => s.id == source.id)) {
        state.loginRequiredSources.add(source);
      }
      return null;
    } catch (e) {
      LogUtils.e('搜索书源 ${source.bookSourceName} 失败: $e');
      return null;
    }
  }

  bool hasOpenableSourceLoginEntry(db.BookSource source) {
    return _sourceLoginController.hasOpenableSourceLoginEntry(source);
  }

  /// 登录后仅重试该源一次（对齐搜索页 loginAndRetry）。
  Future<void> loginAndRetrySource(db.BookSource source) async {
    if (state.isSearching) return;
    if (!_sourceLoginController.hasOpenableSourceLoginEntry(source)) {
      return;
    }
    final loggedIn = await _sourceLoginController.openSourceLogin(source);
    if (!loggedIn || isClosed) return;

    state.loginRequiredSources.removeWhere((s) => s.id == source.id);
    update();

    final result = await _searchSingleSource(source);
    if (result != null) {
      state.availableSources.removeWhere(
        (item) => item.bookSource.id == source.id,
      );
      state.availableSources.add(result);
    }
    update();
  }

  /// 取消所有搜索
  void _cancelAllSearches() {
    for (var token in _cancelTokens) {
      token.cancel('取消搜索');
    }
    _cancelTokens.clear();
  }

  /// 停止搜索
  void stopSearch() {
    state.isSearching = false;
    _cancelAllSearches();
    update();
  }

  /// 选择书源并返回
  void selectSource(SourceBookInfo source) {
    Get.back(result: source);
  }

  @override
  void onClose() {
    _cancelAllSearches();
    super.onClose();
  }
}
