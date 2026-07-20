import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../../../../app/database/drift/app_database.dart';
import '../../../../app/database/models/models.dart' show BookInfo;
import '../../../../app/service/source/web_book_service.dart';
import '../../../../pages/home/source/controllers/source_login_controller.dart';
import '../../../../util/dialog/dialog_utils.dart';
import '../../../../util/log_utils.dart';
import '../state.dart';
import 'state.dart';

class StoreDetailLogic extends GetxController {
  StoreDetailLogic({
    required this.source,
    required this.kind,
  });

  final StoreDetailState state = StoreDetailState();
  final BookSource source;
  final ExploreKind kind;
  final SourceLoginController _sourceLoginController =
      const SourceLoginController();

  // 首次加载时预加载的最小数据量
  static const int _minInitialItems = 48;

  @override
  void onInit() {
    super.onInit();
    state.books.clear();
    state.currentPage = 1;
    state.hasMore = true;
    state.errorMessage = null;
    loadBooks();
  }

  /// 下拉/按钮刷新：清空后重新拉第一页。
  Future<void> refreshBooks() async {
    if (state.isLoading) return;
    state.books.clear();
    state.currentPage = 1;
    state.hasMore = true;
    state.errorMessage = null;
    state.loginRequired = false;
    update();
    await loadBooks();
  }

  /// 加载书籍，自动预加载多页直到达到最小数量。
  /// 逻辑与修改前保持一致；仅补充空列表重试时重置分页，避免 hasMore=false 后无法再次请求。
  Future<void> loadBooks({bool loadMore = false}) async {
    if (state.isLoading || (!loadMore && state.books.isNotEmpty)) return;

    // 空列表重新加载（含重试）：必须重置分页，否则 hasMore 已为 false 时 while 不执行
    if (!loadMore && state.books.isEmpty) {
      state.currentPage = 1;
      state.hasMore = true;
      state.errorMessage = null;
      state.loginRequired = false;
    }

    state.isLoading = true;
    state.errorMessage = null;
    state.loginRequired = false;
    update();

    try {
      int loadedCount = 0;
      while (loadedCount < _minInitialItems && state.hasMore) {
        final exploreUrl = kind.url;
        LogUtils.d(
          '书城发现请求: source=${source.bookSourceName}, '
          'kind=${kind.title}, page=${state.currentPage}, url=$exploreUrl',
        );

        final books = await WebSearchService.exploreBook(
          source,
          exploreUrl,
          page: state.currentPage,
          throwOnEmpty: false,
        );

        LogUtils.d(
          '书城发现结果: page=${state.currentPage}, count=${books.length}',
        );

        if (books.isEmpty) {
          state.hasMore = false;
          break;
        }

        final knownBooks = state.books.map(_bookIdentity).toSet();
        final newBooks = books
            .map(_toBookItem)
            .where((book) => knownBooks.add(_bookIdentity(book)))
            .toList(growable: false);
        if (newBooks.isEmpty) {
          state.hasMore = false;
          break;
        }

        state.books.addAll(newBooks);
        state.currentPage++;
        loadedCount += newBooks.length;
        update();
      }

      if (state.books.isEmpty && state.errorMessage == null) {
        LogUtils.w(
          '书城分类无数据: source=${source.bookSourceName}, '
          'kind=${kind.title}, url=${kind.url}',
        );
      }
    } on SourceLoginRequiredException catch (e) {
      state.errorMessage =
          _sourceLoginController.hasOpenableSourceLoginEntry(source)
              ? '需要登录后查看该分类，请点击重试并完成登录'
              : '需要登录，但书源未配置可用登录入口';
      state.loginRequired = true;
      _showLoadMoreErrorIfNeeded(loadMore);
      LogUtils.d('书城发现需要登录: ${source.bookSourceName}, $e');
    } on DioException catch (e) {
      // 无网络 / 超时等：必须走错误态，不能落到「暂无书籍」
      state.errorMessage = _resolveDioErrorMessage(e);
      state.loginRequired = false;
      _showLoadMoreErrorIfNeeded(loadMore);
      final requestUrl = e.requestOptions.uri.toString();
      final method = e.requestOptions.method;
      final statusCode = e.response?.statusCode;
      final responseSnippet = e.response?.data?.toString();
      LogUtils.e(
        '加载书籍失败: method=$method, status=$statusCode, url=$requestUrl, resp=${responseSnippet != null ? responseSnippet.substring(0, responseSnippet.length > 200 ? 200 : responseSnippet.length) : 'empty'}',
        error: e,
        stackTrace: e.stackTrace,
      );
    } on CheckException catch (e, stackTrace) {
      state.errorMessage = '${e.tag}：${e.message}';
      state.loginRequired = false;
      _showLoadMoreErrorIfNeeded(loadMore);
      LogUtils.e('加载书籍失败: ${e.tag} ${e.message}');
      LogUtils.e('加载书籍堆栈: $stackTrace');
    } catch (e, stackTrace) {
      // 部分网络栈会把断网包成非 DioException；尽量识别后提示检查网络
      final raw = e.toString().toLowerCase();
      final looksLikeNetwork = raw.contains('socket') ||
          raw.contains('network') ||
          raw.contains('connection') ||
          raw.contains('failed host lookup') ||
          raw.contains('connection refused') ||
          raw.contains('connection reset') ||
          raw.contains('timed out') ||
          raw.contains('timeout');
      state.errorMessage = looksLikeNetwork ? '网络连接失败，请检查网络后重试' : '加载失败，请稍后重试';
      _showLoadMoreErrorIfNeeded(loadMore);
      LogUtils.e('加载书籍失败: $e');
      LogUtils.e('加载书籍堆栈: $stackTrace');
    } finally {
      state.isLoading = false;
      if (loadMore) DialogUtils.dismiss();
      update();
    }
  }

  void _showLoadMoreErrorIfNeeded(bool loadMore) {
    if (!loadMore || state.books.isEmpty || state.errorMessage == null) {
      return;
    }
    Get.snackbar('加载失败', state.errorMessage!);
  }

  bool get canOpenLogin =>
      _sourceLoginController.hasOpenableSourceLoginEntry(source);

  /// 登录成功后清空列表并重新拉发现页。
  Future<void> loginAndRetry() async {
    if (!_sourceLoginController.hasOpenableSourceLoginEntry(source)) {
      DialogUtils.waring('该书源未配置可用登录入口');
      return;
    }
    final loggedIn = await _sourceLoginController.openSourceLogin(source);
    if (!loggedIn || isClosed) return;
    state.books.clear();
    state.currentPage = 1;
    state.hasMore = true;
    state.errorMessage = null;
    state.loginRequired = false;
    update();
    await loadBooks();
  }

  String _resolveDioErrorMessage(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return '请求超时，请稍后重试';
      case DioExceptionType.connectionError:
        return '网络连接失败，请检查网络';
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        return statusCode != null ? '服务响应异常：$statusCode' : '服务响应异常，请稍后重试';
      case DioExceptionType.cancel:
        return '请求已取消';
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
        return '加载失败，请稍后重试';
    }
  }

  BookItem _toBookItem(BookInfo info) {
    return BookItem(
      name: info.name,
      author: info.author,
      cover: info.cover,
      intro: info.intro,
      kind: info.kind,
      lastChapter: info.lastChapter,
      bookUrl: info.bookUrl ?? '',
      bookSourceId: info.bookSourceId,
    );
  }

  String _bookIdentity(BookItem book) {
    final bookUrl = book.bookUrl.trim();
    if (bookUrl.isNotEmpty) return bookUrl;
    return '${book.name.trim()}\u0000${book.author?.trim() ?? ''}';
  }
}
