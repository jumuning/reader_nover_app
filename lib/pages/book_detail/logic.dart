import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:drift/drift.dart' as drift;
import 'package:reader_nover/app/database/dao/book_content_info_dao.dart';
import 'package:reader_nover/app/database/dao/book_read_progress_dao.dart';
import 'package:reader_nover/app/database/dao/book_source_dao.dart';
import 'package:reader_nover/app/database/dao/bookshelf_dao.dart';
import 'package:reader_nover/app/database/models/models.dart';
import 'package:reader_nover/app/service/book/bookshelf_service.dart';
import 'package:reader_nover/app/service/book/models/source_book_info.dart';
import 'package:reader_nover/app/service/book/service_result.dart';
import 'package:reader_nover/app/service/source/source_check_policy.dart';
import 'package:reader_nover/app/service/source/web_book_service.dart';
import 'package:reader_nover/pages/home/source/controllers/source_login_controller.dart';
import 'package:reader_nover/pages/home/source/controllers/source_login_retry.dart';
import 'package:reader_nover/util/book_help.dart';
import 'package:reader_nover/util/color_utils.dart';
import 'package:reader_nover/util/log_utils.dart';
import '../../app/constants/app_pattern.dart';
import '../../app/database/drift/app_database.dart' as db;
import '../../app/routes/route_args.dart';
import '../../app/routes/app_routes.dart';
import '../../app/service/book/read_chapter_service.dart';
import '../../app/service/local_book/local_book_constants.dart';
import '../../rust/api/rule_engine.dart' hide BookInfo;
import '../../util/dialog/dialog_utils.dart';
import '../../app/service/book/book_change_service.dart';
import 'state.dart';
import 'deferred_chapter_load.dart';

class BookDetailLogic extends GetxController {
  static const int _initialReadableChapterCount = 30;

  BookDetailLogic({
    required BookDetailArgs args,
  })  : state = BookDetailState(args: args),
        _onRefreshBookshelf = args.onRefreshBookshelf;

  final BookDetailState state;
  final VoidCallback? _onRefreshBookshelf;
  final db.AppDatabase _db = db.AppDatabase.instance;
  late final BookshelfDao _bookshelfDao = BookshelfDao(database: _db);
  late final BookSourceDao _bookSourceDao = BookSourceDao(database: _db);
  late final BookContentInfoDao _contentInfoDao =
      BookContentInfoDao(database: _db);
  late final BookReadProgressDao _readProgressDao =
      BookReadProgressDao(database: _db);
  late final BookChangeService _bookChangeService =
      BookChangeService(database: _db);
  late final BookshelfService _bookshelfService =
      BookshelfService(database: _db);
  late final ReadChapterService _readChapterService =
      ReadChapterService(database: _db);
  final SourceLoginController _sourceLoginController =
      const SourceLoginController();
  String? _chapterListSeedHtml;
  String? _chapterListSeedBaseUrl;
  bool _isCompleteChapterListLoaded = false;
  CancelToken? _completeChapterListCancelToken;
  late final DeferredChapterLoad _deferredChapterLoad = DeferredChapterLoad(
    delay: const Duration(milliseconds: 800),
    load: _loadCompleteChapterList,
  );

  @override
  void onReady() {
    super.onReady();
    _initPositionListener();
    _initData();
  }

  /// 初始化滚动位置监听器（只执行一次）
  void _initPositionListener() {
    state.itemPositionsListener.itemPositions.addListener(_onPositionChanged);
  }

  /// 滚动位置变化回调
  void _onPositionChanged() {
    final positions = state.itemPositionsListener.itemPositions.value;
    if (positions.isNotEmpty && state.isHasMore) {
      final maxIndex =
          positions.map((p) => p.index).reduce((a, b) => a > b ? a : b);
      // 当滚动到接近底部时加载更多
      if (maxIndex >= state.displayedChapters.length - 5) {
        loadMoreChapters();
      }
    }
  }

  @override
  void onClose() {
    _cancelCompleteChapterListLoad();
    // 移除监听器，防止内存泄漏
    state.itemPositionsListener.itemPositions
        .removeListener(_onPositionChanged);
    super.onClose();
  }

  Future<void> _initData() async {
    try {
      // 封面取色可能触发远程图片下载，不应阻塞详情和目录请求。
      unawaited(_calculateCoverTextColor().then((_) {
        if (!isClosed) update();
      }));

      // _loadReadProgress 依赖 chapterInfo 做章节名称匹配。
      final results = await Future.wait([
        _bookSourceDao.findById(state.bookInfo.bookSourceId),
        _findCurrentBookInShelf(),
      ]);

      state.bookSource = results[0] as db.BookSource?;
      final db.Book? currentBook = results[1] as db.Book?;

      if (currentBook != null) {
        // 书籍在书架中，从新表结构加载数据
        final chapterRecords =
            await _bookshelfDao.listChaptersByBookId(currentBook.id);

        final chapters = chapterRecords
            .map((ch) => BookChapterInfo(
                  bookSourceId: ch.bookSourceId,
                  chapterIndex: ch.chapterIndex,
                  chapterName: ch.chapterName,
                  chapterUrl: ch.chapterUrl,
                ))
            .toList();

        final bookDetail = BookDetail(
          bookSourceId: currentBook.bookSourceId,
          name: currentBook.name,
          author: currentBook.author,
          cover: currentBook.cover,
          intro: BookHelp.formatIntro(
            currentBook.intro?.isNotEmpty == true
                ? currentBook.intro
                : state.bookInfo.intro,
          ),
          kind: currentBook.kind != null
              ? List<String>.from(jsonDecode(currentBook.kind!))
              : null,
          lastChapter: currentBook.lastChapter,
          wordCount: currentBook.wordCount ?? state.bookInfo.wordCount,
          bookUrl: currentBook.bookUrl,
          isAscending: currentBook.isAscending,
          chapters: chapters,
        );

        state.bookDetail = bookDetail;
        state.chapterInfo = chapters;
        state.isAscending = currentBook.isAscending;
        state.isInBookshelf = true;

        // 章节已就绪后再加载阅读进度（依赖 chapterInfo 做名称匹配）
        await _loadReadProgress();

        if (state.chapterInfo.isNotEmpty) {
          state.isChapterLoaded = true;
          _loadInitialChapters();
        }
        update();

        await loadReadChapters();

        if (!state.isChapterLoaded) {
          loadChapterList();
        }

        scrollToCurrentReadingChapter();
      } else {
        // 书籍不在书架中，先加载详情首屏，再后台加载完整目录。
        try {
          await _fetchBookDetailOnly();
          update();
          unawaited(loadChapterList());
        } catch (error) {
          LogUtils.e('数据加载失败: $error');
          state.isChapterLoadError = true;
          update();
        }
      }
    } catch (e) {
      LogUtils.e('初始化数据失败: $e');
    }
  }

  Future<void> _fetchBookDetailOnly() async {
    return _retryAfterSourceLoginIfNeeded(
      actionName: '详情加载',
      action: _fetchBookDetailOnlyOnce,
    );
  }

  Future<void> _fetchBookDetailOnlyOnce() async {
    final source = state.bookSource;
    final bookUrl = state.bookInfo.bookUrl ?? '';
    if (source == null || bookUrl.isEmpty) {
      throw Exception('书源或书籍地址为空');
    }

    final context = await WebBookDetailService.loadBookDetailContext(
      source,
      bookUrl,
    ).timeout(SourceCheckPolicy.requestTimeout(source.respondTime));

    state.bookDetail = _mergeLoadedDetailWithListInfo(
      context.detail,
      bookUrl: bookUrl,
    );
    state.isAscending = state.bookDetail.isAscending;
    _chapterListSeedHtml = context.page.html;
    _chapterListSeedBaseUrl = context.page.finalUrl;
  }

  Future<void> _fetchChapterListOnly({
    int? stopWhenReadableChapterCount,
    bool cacheResult = true,
    CancelToken? cancelToken,
  }) async {
    return _retryAfterSourceLoginIfNeeded(
      actionName: '目录加载',
      beforeRetry: _clearChapterListSeed,
      action: () => _fetchChapterListOnlyOnce(
        stopWhenReadableChapterCount: stopWhenReadableChapterCount,
        cacheResult: cacheResult,
        cancelToken: cancelToken,
      ),
    );
  }

  Future<void> _fetchChapterListOnlyOnce({
    int? stopWhenReadableChapterCount,
    bool cacheResult = true,
    CancelToken? cancelToken,
  }) async {
    final source = state.bookSource;
    final bookUrl = state.bookInfo.bookUrl ?? '';
    if (source == null || bookUrl.isEmpty) {
      throw Exception('书源或书籍地址为空');
    }

    if ((state.bookDetail.tocUrl?.trim().isNotEmpty != true) &&
        _chapterListSeedHtml == null) {
      await _fetchBookDetailOnlyOnce();
    }

    // getChapterList may fetch and parse multiple TOC pages. Each network
    // request already applies the source timeout, so a timeout around the
    // whole operation would incorrectly cap the complete pagination flow.
    final chapters = await WebBookDetailService.getChapterList(
      source,
      bookUrl,
      cancelToken: cancelToken,
      tocUrl: state.bookDetail.tocUrl,
      htmlData: _chapterListSeedHtml,
      baseUrl: _chapterListSeedBaseUrl,
      stopWhenReadableChapterCount: stopWhenReadableChapterCount,
    );
    if (isClosed) return;

    state.chapterInfo = chapters;
    _syncBookDetailChapterOrder();
    await _loadReadProgress();
    _loadInitialChapters();
    state.isChapterLoaded = true;
    if (stopWhenReadableChapterCount == null) {
      _chapterListSeedHtml = null;
      _chapterListSeedBaseUrl = null;
      _isCompleteChapterListLoaded = true;
    }
    if (cacheResult) {
      await _cacheChapterList();
    }
  }

  Future<void> _retryAfterSourceLoginIfNeeded({
    required String actionName,
    required Future<void> Function() action,
    VoidCallback? beforeRetry,
  }) {
    return runWithSourceLoginRetry<void>(
      action: action,
      beforeRetry: beforeRetry,
      openLogin: (error) => _openSourceLoginForDetailIfNeeded(
        error,
        actionName: actionName,
      ),
    );
  }

  Future<bool> _openSourceLoginForDetailIfNeeded(
    SourceLoginRequiredException error, {
    required String actionName,
  }) async {
    final source = await _sourceForLoginRequired(error);
    if (source == null) {
      LogUtils.d('$actionName登录重试未找到书源: $error');
      return false;
    }

    if (!_sourceLoginController.hasOpenableSourceLoginEntry(source)) {
      LogUtils.d('$actionName登录重试无可用登录入口: sourceId=${source.id}');
      return false;
    }

    return _sourceLoginController.openSourceLogin(source);
  }

  Future<db.BookSource?> _sourceForLoginRequired(
    SourceLoginRequiredException error,
  ) async {
    final sourceId = error.sourceId ?? state.bookSource?.id;
    if (sourceId != null) {
      final source = await _bookSourceDao.findById(sourceId);
      if (source != null) return source;
    }

    final sourceKey = error.sourceKey;
    final currentSource = state.bookSource;
    if (sourceKey != null &&
        currentSource != null &&
        currentSource.bookSourceUrl == sourceKey) {
      return currentSource;
    }

    return currentSource;
  }

  void _clearChapterListSeed() {
    _chapterListSeedHtml = null;
    _chapterListSeedBaseUrl = null;
  }

  BookDetail _mergeLoadedDetailWithListInfo(
    BookDetail loadedDetail, {
    required String bookUrl,
  }) {
    String? preferNonBlank(String? primary, String? fallback) {
      final value = primary?.trim();
      if (value != null && value.isNotEmpty) return primary;
      final fallbackValue = fallback?.trim();
      if (fallbackValue != null && fallbackValue.isNotEmpty) return fallback;
      return primary ?? fallback;
    }

    final loadedKind = _normalizeKindList(loadedDetail.kind);
    final fallbackKind = _splitKind(state.bookInfo.kind);

    return loadedDetail.copyWith(
      name: preferNonBlank(loadedDetail.name, state.bookInfo.name),
      author: preferNonBlank(loadedDetail.author, state.bookInfo.author),
      cover: preferNonBlank(loadedDetail.cover, state.bookInfo.cover),
      intro: BookHelp.formatIntro(
        preferNonBlank(loadedDetail.intro, state.bookInfo.intro),
      ),
      kind: loadedKind.isNotEmpty ? loadedKind : fallbackKind,
      lastChapter:
          preferNonBlank(loadedDetail.lastChapter, state.bookInfo.lastChapter),
      wordCount:
          preferNonBlank(loadedDetail.wordCount, state.bookInfo.wordCount),
      bookUrl: bookUrl,
    );
  }

  List<String> _normalizeKindList(List<String>? raw) {
    if (raw == null || raw.isEmpty) return const <String>[];
    return raw.expand(_splitKind).where((s) => s.isNotEmpty).toList();
  }

  List<String> _splitKind(String? raw) {
    final value = raw?.trim();
    if (value == null || value.isEmpty) return const <String>[];
    return value
        .split(RegExp(r'[,，、/|;\n\r\t]+'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }

  // 加载章节列表（供外部调用）
  Future<void> loadChapterList() async {
    _deferredChapterLoad.cancel();
    if (state.isChapterLoading || state.isChapterLoaded) return;

    state.isChapterLoading = true;
    state.isChapterLoadError = false;
    update();

    try {
      await _fetchChapterListOnly(
        stopWhenReadableChapterCount: _initialReadableChapterCount,
        cacheResult: false,
      );
      await loadReadChapters();
      scrollToCurrentReadingChapter();
      _scheduleCompleteChapterListLoad();
    } catch (e) {
      LogUtils.e('章节列表加载失败: $e');
      state.isChapterLoadError = true;
    } finally {
      state.isChapterLoading = false;
      update();
    }
  }

  void _scheduleCompleteChapterListLoad() {
    if (!state.isChapterLoaded || _isCompleteChapterListLoaded || isClosed) {
      return;
    }
    _deferredChapterLoad.schedule();
  }

  Future<void> _loadCompleteChapterList() async {
    if (_isCompleteChapterListLoaded || isClosed) return;
    final cancelToken = CancelToken();
    _completeChapterListCancelToken = cancelToken;
    try {
      await _fetchChapterListOnly(cancelToken: cancelToken);
      if (isClosed) return;
      await loadReadChapters();
      scrollToCurrentReadingChapter();
      update();
    } catch (e) {
      // 首批目录已经可用，完整目录失败不应把页面切回错误状态。
      if (!cancelToken.isCancelled) {
        LogUtils.e('后台加载完整章节列表失败: $e');
      }
    } finally {
      if (identical(_completeChapterListCancelToken, cancelToken)) {
        _completeChapterListCancelToken = null;
      }
    }
  }

  void _cancelCompleteChapterListLoad() {
    _deferredChapterLoad.cancel();
    final cancelToken = _completeChapterListCancelToken;
    if (cancelToken != null && !cancelToken.isCancelled) {
      cancelToken.cancel('进入阅读，暂停完整目录加载');
    }
    _completeChapterListCancelToken = null;
  }

  // 缓存章节列表到数据库
  Future<void> _cacheChapterList() async {
    try {
      // 更新 bookDetail 中的 chapters，并保留当前排序偏好
      _syncBookDetailChapterOrder();

      // 查找是否已在书架中
      final existingBook = await _findCurrentBookInShelf();

      if (existingBook != null) {
        // 已在书架中，在事务中原子更新元数据 + 章节
        await _db.transaction(() async {
          await _bookshelfDao.updateBook(
            bookId: existingBook.id,
            book: db.BooksCompanion(
              lastChapter: drift.Value(state.bookDetail.lastChapter),
              wordCount: drift.Value(
                state.bookDetail.wordCount ?? state.bookInfo.wordCount,
              ),
              totalChapterNum: drift.Value(state.chapterInfo.length),
            ),
          );

          await _bookshelfDao.replaceChapters(
            bookId: existingBook.id,
            chapters: state.chapterInfo
                .map((ch) => db.BookChaptersCompanion.insert(
                      bookId: existingBook.id,
                      bookSourceId: state.bookInfo.bookSourceId,
                      chapterIndex: ch.chapterIndex ?? 0,
                      chapterName: ch.chapterName ?? '',
                      chapterUrl: ch.chapterUrl ?? '',
                    ))
                .toList(),
          );
        });
        LogUtils.d('章节列表已缓存到书架');
      }
    } catch (e) {
      LogUtils.e('缓存章节列表失败: $e');
    }
  }

  Future<db.Book?> _findCurrentBookInShelf() async {
    try {
      return await _bookshelfDao.findBook(
        bookSourceId: state.bookInfo.bookSourceId,
        bookName: state.bookInfo.name,
      );
    } catch (e) {
      return null;
    }
  }

  // 计算封面图片对应的文字颜色
  Future<void> _calculateCoverTextColor() async {
    try {
      final dominantColor =
          await ColorUtils.getDominantColorFromUrl(state.bookInfo.cover);
      if (dominantColor != null) {
        state.coverTextColor = ColorUtils.getContrastTextColor(dominantColor);
        state.coverSecondaryTextColor =
            ColorUtils.getContrastSecondaryTextColor(dominantColor);
      }
    } catch (e) {
      LogUtils.e('计算封面文字颜色失败: $e');
    }
  }

  /// 加载已阅读章节索引
  Future<void> loadReadChapters() async {
    state.readChapterIndices = await _readChapterService.loadReadChapterIndices(
      bookSourceId: state.bookInfo.bookSourceId,
      bookName: state.bookInfo.name,
      chapters: state.chapterInfo,
    );
    await loadCachedChapters();
    update();
  }

  /// 加载已缓存章节索引
  Future<void> loadCachedChapters() async {
    state.cachedChapterIndices =
        await _readChapterService.loadCachedChapterIndices(
      bookSourceId: state.bookInfo.bookSourceId,
      bookName: state.bookInfo.name,
      chapters: state.chapterInfo,
    );
  }

  List<BookChapterInfo> _getOrderedChapterInfo() {
    if (state.isAscending) {
      return state.chapterInfo;
    }
    return state.chapterInfo.reversed.toList(growable: false);
  }

  // 内部方法：加载初始章节，不触发 update
  void _loadInitialChapters() {
    if (state.chapterInfo.isEmpty) return;
    final orderedChapters = _getOrderedChapterInfo();

    int itemsToAdd = state.chapterPageSize;
    if (state.isAscending && state.currentReadChapterIndex != null) {
      // 找到当前阅读章节在列表中的位置
      final readingIndex = orderedChapters.indexWhere(
        (c) => c.chapterIndex == state.currentReadChapterIndex,
      );
      if (readingIndex >= 0) {
        // 确保加载足够多的章节以显示当前阅读位置
        itemsToAdd = (readingIndex + 5)
            .clamp(state.chapterPageSize, orderedChapters.length);
      }
    }

    itemsToAdd = itemsToAdd.clamp(0, orderedChapters.length);
    state.displayedChapters = orderedChapters.sublist(0, itemsToAdd);
    state.isHasMore = itemsToAdd < orderedChapters.length;
  }

  /// 滚动到当前阅读章节
  void scrollToCurrentReadingChapter() {
    if (!state.isAscending) return;
    if (state.currentReadChapterIndex == null) return;
    if (state.displayedChapters.isEmpty) return;

    // 找到当前阅读章节在显示列表中的位置
    final index = state.displayedChapters.indexWhere(
      (c) => c.chapterIndex == state.currentReadChapterIndex,
    );

    if (index < 0) return;

    // 等待 UI 渲染完毕后再滚动
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (state.itemScrollController.isAttached) {
        state.itemScrollController.jumpTo(index: index);
      }
    });
  }

  // 添加加载更多方法
  void loadMoreChapters() {
    if (!state.isHasMore) return;
    final orderedChapters = _getOrderedChapterInfo();
    final currentLength = state.displayedChapters.length;
    final remainingItems = orderedChapters.length - currentLength;

    if (remainingItems <= 0) {
      state.isHasMore = false;
      update();
      return;
    }

    final itemsToAdd = remainingItems < state.chapterPageSize
        ? remainingItems
        : state.chapterPageSize;

    // 使用 addAll 批量添加，避免多次列表操作
    state.displayedChapters = [
      ...state.displayedChapters,
      ...orderedChapters.sublist(currentLength, currentLength + itemsToAdd),
    ];
    state.isHasMore = currentLength + itemsToAdd < orderedChapters.length;

    update();
  }

  // 添加书籍到书架（UI 入口，带 busy 守卫）
  Future<void> addToBookShelf() async {
    if (state.isBottomBarBusy) return;
    state.isBottomBarBusy = true;
    update();
    try {
      await _doAddToBookShelf();
    } finally {
      state.isBottomBarBusy = false;
      update();
    }
  }

  // 从书架移除书籍（UI 入口，带 busy 守卫）
  Future<void> removeFromBookShelf() async {
    if (state.isBottomBarBusy) return;
    state.isBottomBarBusy = true;
    update();
    try {
      await _doRemoveFromBookShelf();
    } finally {
      state.isBottomBarBusy = false;
      update();
    }
  }

  Future<void> _doAddToBookShelf() async {
    try {
      final source = state.bookSource;
      if (source == null) return;

      final result = await _bookshelfService.addToBookshelf(
        source: source,
        bookInfo: state.bookInfo,
        bookDetail: state.bookDetail,
        chapterInfo: state.chapterInfo,
        currentReadChapterIndex: state.currentReadChapterIndex,
        currentReadPageIndex: state.currentReadPageIndex,
      );

      state.isInBookshelf = result.isInBookshelf;
      state.currentReadChapterIndex = result.currentReadChapterIndex;
      state.currentReadPageIndex = result.currentReadPageIndex;
      _onRefreshBookshelf?.call();
      LogUtils.d('书籍已加入书架');
    } catch (e) {
      LogUtils.e('加入书架失败: $e');
    }
  }

  Future<void> _doRemoveFromBookShelf() async {
    try {
      final source = state.bookSource;
      if (source == null) return;

      await _bookshelfService.removeFromBookshelf(
        bookSourceId: source.id,
        bookName: state.bookInfo.name,
      );

      state.isInBookshelf = false;
      _onRefreshBookshelf?.call();
      LogUtils.d('书籍已移出书架');
    } catch (e) {
      LogUtils.e('移出书架失败: $e');
    }
  }

  //章节排序
  Future<void> sortChapters() async {
    try {
      DialogUtils.loading();
      state.isAscending = !state.isAscending;

      _syncBookDetailChapterOrder();

      // 在书架中时异步保存排序状态（不阻塞 UI）
      _findCurrentBookInShelf().then((existingBook) {
        if (existingBook != null) {
          _bookshelfDao.updateBook(
            bookId: existingBook.id,
            book: db.BooksCompanion(
              isAscending: drift.Value(state.isAscending),
            ),
          );
        }
      });

      state.displayedChapters = [];
      state.isHasMore = true;
      _loadInitialChapters();

      update();
    } finally {
      await DialogUtils.dismiss();
    }
  }

  // 加载当前阅读进度
  Future<void> _loadReadProgress() async {
    try {
      // 优先从阅读进度表获取
      final progress = await _readProgressDao.findByBook(
        bookSourceId: state.bookInfo.bookSourceId,
        bookName: state.bookInfo.name,
      );

      if (progress != null) {
        // 优先使用章节名称匹配（换源后章节索引可能不准确）
        if (progress.chapterName != null && state.chapterInfo.isNotEmpty) {
          try {
            final matchedChapter =
                _findSimilarChapter(progress.chapterName!, state.chapterInfo);
            state.currentReadChapterIndex = matchedChapter.chapterIndex;
          } catch (e) {
            // 如果章节名称匹配失败，使用索引（但要验证索引有效性）
            if (state.chapterInfo
                .any((c) => c.chapterIndex == progress.chapterIndex)) {
              state.currentReadChapterIndex = progress.chapterIndex;
            } else {
              state.currentReadChapterIndex = 0;
            }
          }
        } else if (state.chapterInfo.isNotEmpty) {
          // 没有章节名称，验证索引有效性
          if (state.chapterInfo
              .any((c) => c.chapterIndex == progress.chapterIndex)) {
            state.currentReadChapterIndex = progress.chapterIndex;
          } else {
            state.currentReadChapterIndex = 0;
          }
        } else {
          // 章节列表还未加载，暂时使用数据库中的索引
          state.currentReadChapterIndex = progress.chapterIndex;
        }
        state.currentReadPageIndex = 0;
        return;
      }

      // 兼容旧数据：如果没有阅读进度记录，从缓存章节表获取最大章节索引
      final result = await _contentInfoDao.findLatestByBook(
        bookSourceId: state.bookInfo.bookSourceId,
        bookName: state.bookInfo.name,
      );

      if (result != null && result.chapterIndex != null) {
        state.currentReadChapterIndex = result.chapterIndex;
      }
    } catch (e) {
      LogUtils.e('加载阅读进度失败: $e');
    }
  }

  // 刷新阅读进度（从阅读页返回时调用）
  Future<void> refreshReadProgress() async {
    await _loadReadProgress();
    update();
    // 延迟滚动，确保UI已更新
    scrollToCurrentReadingChapter();
  }

  // 直接更新阅读进度（从阅读页返回时接收的章节索引）
  void updateReadProgress({
    required int chapterIndex,
    int? pageIndex,
  }) {
    state.currentReadChapterIndex = chapterIndex;
    if (pageIndex != null) {
      state.currentReadPageIndex = pageIndex;
    }
    update();
    // 延迟滚动，确保UI已更新
    scrollToCurrentReadingChapter();
  }

  String parseUrl({
    required String bookSourceUrl,
    required String parseSearchUrl,
  }) {
    if (AppPattern.httpReg.hasMatch(bookSourceUrl) &&
        AppPattern.httpReg.hasMatch(parseSearchUrl)) {
      return parseSearchUrl;
    }
    if (bookSourceUrl.endsWith('/')) {
      bookSourceUrl = bookSourceUrl.substring(0, bookSourceUrl.length - 1);
    }
    if (parseSearchUrl.startsWith('/')) {
      parseSearchUrl = parseSearchUrl.substring(1);
    }
    return '$bookSourceUrl/$parseSearchUrl';
  }

  Future<void> startOrContinueRead() async {
    if (state.isBottomBarBusy) return;
    state.isBottomBarBusy = true;
    _cancelCompleteChapterListLoad();
    update();

    try {
      if (!state.isInBookshelf) {
        await _doAddToBookShelf();
      }

      final readIndex = state.currentReadChapterIndex ?? 0;

      final BookChapterInfo? chapter = state.chapterInfo.isNotEmpty
          ? state.chapterInfo.firstWhere(
              (c) => c.chapterIndex == readIndex,
              orElse: () => state.chapterInfo[0],
            )
          : null;

      if (chapter == null) return;

      final result = await Get.toNamed(
        AppRoutes.bookRead,
        arguments: BookReadArgs(
          bookInfo: state.bookInfo,
          chapterName: chapter.chapterName ?? '',
          chapterUrl: chapter.chapterUrl ?? '',
          chapterIndex: chapter.chapterIndex ?? 0,
          pageIndex: state.currentReadPageIndex,
          bookDetail: _buildReadingBookDetail(),
          onRefreshBookshelf: _onRefreshBookshelf,
        ),
      );

      if (result is BookReadExitResult) {
        updateReadProgress(
          chapterIndex: result.chapterIndex,
          pageIndex: result.pageIndex,
        );
      } else if (result is int) {
        updateReadProgress(chapterIndex: result);
      }
      await refreshReadProgress();
      loadReadChapters();
    } finally {
      state.isBottomBarBusy = false;
      update();
      _scheduleCompleteChapterListLoad();
    }
  }

  /// 点击章节跳转阅读
  Future<void> onChapterTap(BookChapterInfo chapter) async {
    _cancelCompleteChapterListLoad();
    // 只有点击当前阅读章节时才恢复页码，其他章节从第一页开始
    final pageIndex = chapter.chapterIndex == state.currentReadChapterIndex
        ? state.currentReadPageIndex
        : 0;

    final result = await Get.toNamed(
      AppRoutes.bookRead,
      arguments: BookReadArgs(
        bookInfo: state.bookInfo,
        chapterName: chapter.chapterName ?? '',
        chapterUrl: chapter.chapterUrl ?? '',
        chapterIndex: chapter.chapterIndex ?? 0,
        pageIndex: pageIndex,
        bookDetail: _buildReadingBookDetail(),
        onRefreshBookshelf: _onRefreshBookshelf,
      ),
    );

    // 从阅读页返回后更新阅读进度
    if (result is BookReadExitResult) {
      updateReadProgress(
        chapterIndex: result.chapterIndex,
        pageIndex: result.pageIndex,
      );
    } else if (result is int) {
      updateReadProgress(chapterIndex: result);
    }
    await refreshReadProgress();
    // 刷新已阅读章节
    loadReadChapters();
    _scheduleCompleteChapterListLoad();
  }

  /// 切换书源
  Future<void> changeSource(SourceBookInfo sourceInfo) async {
    if (LocalBookConstants.isLocalBookSource(state.bookInfo.bookSourceId)) {
      Get.snackbar(
        '提示',
        '本地书籍不支持换源',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    var isLoading = false;
    Future<void> showLoading() async {
      await DialogUtils.loading();
      isLoading = true;
    }

    Future<void> dismissLoading() async {
      if (!isLoading) return;
      await DialogUtils.dismiss();
      isLoading = false;
    }

    try {
      final currentChapterName = state.chapterInfo.isEmpty
          ? ''
          : state.chapterInfo
                  .firstWhere(
                    (c) => c.chapterIndex == state.currentReadChapterIndex,
                    orElse: () => state.chapterInfo.first,
                  )
                  .chapterName ??
              '';

      await showLoading();
      var changeResult = await _changeSourceOnce(
        sourceInfo: sourceInfo,
        currentChapterName: currentChapterName,
      );
      if (changeResult.isFailure) {
        final error = changeResult.error!;
        final loggedIn = await _openLoginForChangeSourceIfNeeded(
          error,
          dismissLoading: dismissLoading,
        );
        if (loggedIn) {
          await showLoading();
          changeResult = await _changeSourceOnce(
            sourceInfo: sourceInfo,
            currentChapterName: currentChapterName,
          );
        }
      }

      if (changeResult.isFailure) {
        final error = changeResult.error!;
        LogUtils.e('换源失败: ${error.formatForLog()}');
        Get.snackbar('错误', error.userMessage);
        return;
      }
      final data = changeResult.requireData();

      state.bookSource = sourceInfo.bookSource;
      state.bookInfo = data.bookInfo;
      state.bookDetail = data.bookDetail;
      state.chapterInfo = data.bookDetail.chapters ?? [];
      state.isAscending = state.bookDetail.isAscending;
      _syncBookDetailChapterOrder();
      state.currentReadChapterIndex = data.newChapterIndex;
      state.currentReadPageIndex = 0;

      state.isChapterLoading = false;
      state.isChapterLoadError = false;
      state.isChapterLoaded = state.chapterInfo.isNotEmpty;
      state.displayedChapters = [];
      state.isHasMore = true;
      _loadInitialChapters();

      await loadReadChapters();
      if (state.isInBookshelf) {
        _onRefreshBookshelf?.call();
      }

      update();
      scrollToCurrentReadingChapter();

      LogUtils.d('换源成功: ${sourceInfo.bookSource.bookSourceName}');
    } catch (e) {
      LogUtils.e('换源失败: $e');
    } finally {
      await dismissLoading();
    }
  }

  Future<ServiceResult<ChangeSourceResult>> _changeSourceOnce({
    required SourceBookInfo sourceInfo,
    required String currentChapterName,
  }) {
    return _bookChangeService.changeSource(
      sourceInfo: sourceInfo,
      bookInfo: state.bookInfo,
      bookDetail: state.bookDetail.copyWith(chapters: state.chapterInfo),
      currentChapterName: currentChapterName,
      isInBookshelf: state.isInBookshelf,
    );
  }

  Future<bool> _openLoginForChangeSourceIfNeeded(
    ServiceError error, {
    required Future<void> Function() dismissLoading,
  }) async {
    if (error.code !=
        '${ServiceErrorCodes.changeSourceFailed}.login_required') {
      return false;
    }

    final sourceId = _sourceIdFromChangeSourceLoginError(error);
    if (sourceId == null) {
      LogUtils.d('换源登录重试缺少目标书源: ${error.formatForLog()}');
      return false;
    }

    final source = await _bookSourceDao.findById(sourceId);
    if (source == null) {
      LogUtils.d('换源登录重试未找到书源: sourceId=$sourceId');
      return false;
    }

    if (!_sourceLoginController.hasOpenableSourceLoginEntry(source)) {
      LogUtils.d('换源登录重试无可用登录入口: sourceId=$sourceId');
      return false;
    }

    await dismissLoading();
    return _sourceLoginController.openSourceLogin(source);
  }

  int? _sourceIdFromChangeSourceLoginError(ServiceError error) {
    return _intFromObject(error.context['toBookSourceId']) ??
        _intFromObject(error.context['sourceId']);
  }

  int? _intFromObject(Object? value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value.trim());
    return null;
  }

  /// 跳转到换源页面
  Future<void> goToChangeSource() async {
    if (LocalBookConstants.isLocalBookSource(state.bookInfo.bookSourceId)) {
      Get.snackbar(
        '提示',
        '本地书籍不支持换源',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (state.bookSource == null) return;

    final result = await Get.toNamed(
      AppRoutes.bookChange,
      arguments: BookChangeArgs(
        bookName: state.bookInfo.name,
        bookSourceId: state.bookSource!.id,
        sourceName: state.bookSource!.bookSourceName,
        sourceUrl: state.bookSource!.bookSourceUrl,
        bookUrl: state.bookInfo.bookUrl ?? '',
      ),
    );

    // 如果选择了新书源，执行换源
    if (result != null && result is SourceBookInfo) {
      await changeSource(result);
    }
  }

  /// 根据章节名称相似度查找最匹配的章节
  BookChapterInfo _findSimilarChapter(
      String targetName, List<BookChapterInfo> chapters) {
    if (chapters.isEmpty) throw StateError('章节列表为空');

    final chapterNames = chapters.map((c) => c.chapterName ?? '').toList();
    final matchedIndex = findMatchingChapter(
      target: targetName,
      chapterNames: chapterNames,
    );

    LogUtils.d('章节匹配: $targetName -> ${chapters[matchedIndex].chapterName}');
    return chapters[matchedIndex];
  }

  BookDetail _buildReadingBookDetail() {
    return state.bookDetail.copyWith(
      chapters: List<BookChapterInfo>.from(state.chapterInfo),
      isAscending: state.isAscending,
    );
  }

  void _syncBookDetailChapterOrder() {
    state.bookDetail = _buildReadingBookDetail();
  }
}
