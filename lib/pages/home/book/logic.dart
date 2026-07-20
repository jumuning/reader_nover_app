import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:drift/drift.dart' as drift;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show TextButton, Text;
import 'package:get/get.dart';
import 'package:reader_nover/app/database/dao/book_content_info_dao.dart';
import 'package:reader_nover/app/database/dao/book_read_progress_dao.dart';
import 'package:reader_nover/app/database/dao/book_source_dao.dart';
import 'package:reader_nover/app/database/dao/bookshelf_dao.dart';
import 'package:reader_nover/app/l10n/generated/l10n.dart';
import 'package:reader_nover/app/service/book/bookshelf_service.dart';
import 'package:reader_nover/app/service/local_book/local_book_chapter_service.dart';
import 'package:reader_nover/app/service/local_book/local_book_import_service.dart';
import 'package:reader_nover/app/service/local_book/local_book_repository.dart';
import 'package:reader_nover/app/service/local_book/local_text_book_parser.dart';
import 'package:reader_nover/app/service/source/web_book_service.dart';
import 'package:reader_nover/util/dialog/dialog_utils.dart';
import 'package:reader_nover/util/log_utils.dart';
import 'package:reader_nover/util/performance_log_helper.dart';
import '../../../app/database/drift/app_database.dart';
import '../../../app/database/models/models.dart' hide BookSource;
import 'bookshelf_sort_store.dart';
import 'state.dart';
import 'update_schedule_store.dart';

class BookLogic extends GetxController {
  BookLogic({
    required VoidCallback onToggleBookshelfLayout,
    required BookshelfLayout Function() currentLayoutProvider,
  })  : _onToggleBookshelfLayout = onToggleBookshelfLayout,
        _currentLayoutProvider = currentLayoutProvider;

  final BookState state = BookState();
  final AppDatabase _db = AppDatabase.instance;
  late final BookshelfDao _bookshelfDao = BookshelfDao(database: _db);
  late final BookContentInfoDao _contentInfoDao =
      BookContentInfoDao(database: _db);
  late final BookSourceDao _bookSourceDao = BookSourceDao(database: _db);
  late final BookReadProgressDao _readProgressDao =
      BookReadProgressDao(database: _db);
  late final LocalBookImportService _localBookImportService =
      LocalBookImportService(database: _db);
  late final LocalBookChapterService _localBookChapterService =
      LocalBookChapterService(database: _db);
  late final BookshelfService _bookshelfService =
      BookshelfService(database: _db);
  final VoidCallback _onToggleBookshelfLayout;
  final BookshelfLayout Function() _currentLayoutProvider;

  /// 更新任务取消令牌
  CancelToken? _updateCancelToken;

  /// 并发控制数量
  static const int _maxConcurrency = 3;
  static const Duration _fastCheckTimeout = Duration(seconds: 12);
  static const Duration _autoUpdateInitialDelay = Duration(seconds: 2);
  static const Duration _autoUpdateMinInterval = Duration(hours: 6);
  static const Duration _importLoadingDismissTimeout = Duration(seconds: 2);

  /// 更新期间缓存书源，避免每本书都查一次数据库
  final Map<int, BookSource> _updateSourceCache = {};
  final BookshelfSortStore _sortStore = const BookshelfSortStore();
  final BookshelfUpdateScheduleStore _updateScheduleStore =
      const BookshelfUpdateScheduleStore();
  Timer? _autoUpdateTimer;

  /// 单本书目录懒加载任务，避免重复查询同一本书的章节表
  final Map<int, Future<BookDetail>> _bookDetailHydrationTasks = {};

  @override
  void onReady() {
    super.onReady();
    _initBookshelf();
  }

  /// 初始化书架：仅加载首页所需摘要数据，整库更新改为手动触发
  Future<void> _initBookshelf() async {
    state.sortMode = BookshelfSortModeX.fromName(
      await _sortStore.loadSortModeName(),
    );
    await refreshBooks();
    unawaited(_scheduleAutoUpdateIfDue());
  }

  @override
  void onClose() {
    _autoUpdateTimer?.cancel();
    _autoUpdateTimer = null;
    cancelUpdate();
    super.onClose();
  }

  /// 切换布局（委托给 SettingLogic）
  void toggleLayout() {
    _onToggleBookshelfLayout();
    update();
  }

  /// 获取当前布局
  BookshelfLayout get currentLayout => _currentLayoutProvider();

  Future<void> importLocalBook() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['txt', 'epub'],
      allowMultiple: false,
    );
    if (result == null || result.files.isEmpty) return;

    final path = result.files.single.path;
    if (path == null || path.trim().isEmpty) {
      Get.snackbar(S.current.importFailed, S.current.importPathUnavailable);
      return;
    }

    unawaited(DialogUtils.loading());
    await Future<void>.delayed(Duration.zero);

    LocalBookImportResult? importResult;
    try {
      importResult = await _localBookImportService.importFile(path);
    } on LocalBookParseException catch (e) {
      LogUtils.e('导入本地书籍失败: ${e.message}');
      Get.snackbar(
        S.current.importFailed,
        e.message,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e, stackTrace) {
      LogUtils.e('导入本地书籍异常: $e', stackTrace: stackTrace);
      Get.snackbar(
        S.current.importFailed,
        S.current.importRetryLater,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      await _dismissImportLoading();
    }

    if (importResult != null) {
      await _appendImportedLocalBook(importResult);
      Get.snackbar(
        S.current.importSucceeded,
        S.current.bookAddedToShelf(importResult.bookInfo.name),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _dismissImportLoading() async {
    try {
      await DialogUtils.dismiss().timeout(_importLoadingDismissTimeout);
    } on TimeoutException {
      LogUtils.w('关闭本地书籍导入 loading 超时，继续刷新书架');
    } catch (e, stackTrace) {
      LogUtils.w(
        '关闭本地书籍导入 loading 失败: $e',
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> _appendImportedLocalBook(
      LocalBookImportResult importResult) async {
    try {
      final books = await _bookshelfDao.listBooksByIds([importResult.bookId]);
      if (books.isEmpty) return;

      final book = books.first;
      final bookInfo = importResult.bookInfo;
      final bookDetail = importResult.bookDetail;
      final key = _bookKey(bookInfo.bookSourceId, bookInfo.name);

      state.myBooks = [
        book,
        ...state.myBooks.where((item) => item.id != book.id),
      ];
      state.bookDetailCache[book.id] = bookDetail;
      state.bookInfoCache[book.id] = bookInfo;
      state.bookIdByKeyCache[key] = book.id;
      state.totalChapterCountCache[book.id] =
          bookDetail.chapters?.length ?? book.totalChapterNum;
      state.readProgressCache.remove(key);
      state.readPageIndexCache.remove(key);
      state.readChapterNameCache.remove(key);
      _sortBooks();
      update();
    } catch (e, stackTrace) {
      LogUtils.e(
        '刷新导入本地书籍到书架失败: $e',
        stackTrace: stackTrace,
      );
    }
  }

  Future<BookDetail> ensureLocalBookChaptersReady(BookDetail bookDetail) async {
    final readyDetail =
        await _localBookChapterService.ensureChapters(bookDetail);
    final bookName = readyDetail.name;
    if (bookName == null || readyDetail.chapters == null) {
      return readyDetail;
    }
    final key = _bookKey(readyDetail.bookSourceId, bookName);
    final bookId = state.bookIdByKeyCache[key];
    if (bookId != null) {
      state.bookDetailCache[bookId] = readyDetail;
      state.totalChapterCountCache[bookId] = readyDetail.chapters!.length;
      update();
    }
    return readyDetail;
  }

  Future<void> changeSortMode(BookshelfSortMode mode) async {
    if (state.sortMode == mode) return;
    state.sortMode = mode;
    _sortBooks();
    update();
    await _sortStore.saveSortModeName(mode.name);
  }

  // ==================== 书架更新机制 ====================

  /// 更新所有书籍目录（入口方法）
  Future<void> updateAllBooks() async {
    await _runUpdateAllBooks(
      recordRunAtEnd: true,
      trigger: 'manual',
    );
  }

  Future<void> _runUpdateAllBooks({
    required bool recordRunAtEnd,
    required String trigger,
  }) async {
    final perf = PerformanceLogHelper.start(
      'bookshelf.updateAllBooks',
      fields: <String, Object?>{
        'trigger': trigger,
      },
    );
    if (state.isUpdating) {
      perf.complete(
        fields: const <String, Object?>{
          'status': 'skipped',
          'reason': 'already_updating',
        },
      );
      return;
    }
    _autoUpdateTimer?.cancel();
    _autoUpdateTimer = null;

    // 筛选可更新的书籍（非本地书籍）
    final booksToUpdate = state.myBooks.where((book) {
      final detail = state.bookDetailCache[book.id];
      return detail != null && detail.bookUrl != null;
    }).toList();

    if (booksToUpdate.isEmpty) {
      LogUtils.d('没有需要更新的书籍');
      if (recordRunAtEnd) {
        await _updateScheduleStore.markRunAt(DateTime.now());
      }
      perf.complete(
        fields: <String, Object?>{
          'status': 'skipped',
          'reason': 'no_updatable_books',
          'totalBooks': state.myBooks.length,
        },
      );
      return;
    }

    // 初始化更新状态
    state.isUpdating = true;
    state.totalUpdateCount = booksToUpdate.length;
    state.updatedCount = 0;
    state.updateProgress = 0.0;
    state.filterNewChaptersOnly = false;
    state.updateResults.clear();
    _updateCancelToken = CancelToken();

    // 初始化每本书的状态为等待中
    for (final book in booksToUpdate) {
      state.updateResults[book.id] = BookUpdateResult(
        bookId: book.id,
        status: BookUpdateStatus.waiting,
      );
    }
    update();

    try {
      // 预热书源缓存，减少更新时数据库查询
      await _warmUpSourceCache(booksToUpdate);

      // 使用信号量控制并发
      await _processUpdateQueue(booksToUpdate);

      // 刷新书架数据（保留 updateResults 供角标与筛选）
      final cancelled = _updateCancelToken?.isCancelled == true;
      final keptResults = Map<int, BookUpdateResult>.from(state.updateResults);

      await refreshBooks();

      // refreshBooks 不清理 updateResults；显式写回并结束更新态
      state.updateResults
        ..clear()
        ..addAll(keptResults);
      state.isUpdating = false;
      state.updateProgress = 1.0;
      _updateCancelToken = null;
      _updateSourceCache.clear();

      // 仅 Snackbar 提示一次，不再叠结果条
      if (!cancelled && trigger == 'manual') {
        final summary = getUpdateSummary();
        if (state.newChapterBookCount > 0) {
          Get.snackbar(
            '更新完成',
            summary,
            duration: const Duration(seconds: 4),
            mainButton: TextButton(
              onPressed: () {
                setFilterNewChaptersOnly(true);
                if (Get.isSnackbarOpen) Get.closeCurrentSnackbar();
              },
              child: const Text('只看有新章'),
            ),
          );
        } else {
          Get.snackbar(
            '更新完成',
            summary,
            duration: const Duration(seconds: 3),
          );
        }
      }

      if (recordRunAtEnd) {
        await _updateScheduleStore.markRunAt(DateTime.now());
      }
      update();
      perf.complete(
        fields: <String, Object?>{
          'status': cancelled ? 'cancelled' : 'success',
          'candidateCount': booksToUpdate.length,
          'updatedCount': state.updatedCount,
          'failedCount': state.updateResults.values
              .where((r) => r.status == BookUpdateStatus.failed)
              .length,
          'newChapterTotal': state.updateResults.values.fold<int>(
            0,
            (sum, result) => sum + result.newChapterCount,
          ),
        },
      );
    } catch (e) {
      state.isUpdating = false;
      _updateCancelToken = null;
      _updateSourceCache.clear();
      update();
      perf.complete(
        fields: <String, Object?>{
          'status': 'failed',
          'candidateCount': booksToUpdate.length,
          'updatedCount': state.updatedCount,
          'error': e.toString(),
        },
      );
      rethrow;
    }
  }

  void setFilterNewChaptersOnly(bool value) {
    state.filterNewChaptersOnly = value;
    update();
  }

  void setShelfQuery(String query) {
    state.shelfQuery = query;
    update();
  }

  void setTypeFilter(BookshelfTypeFilter filter) {
    if (state.typeFilter == filter) return;
    state.typeFilter = filter;
    update();
  }

  // ==================== 批量选择 ====================

  void enterSelectionMode({int? initialBookId}) {
    state.isSelectionMode = true;
    state.selectedIds.clear();
    if (initialBookId != null) {
      state.selectedIds.add(initialBookId);
    }
    update();
  }

  void exitSelectionMode() {
    state.clearSelection();
    update();
  }

  void toggleSelection(int bookId) {
    if (state.selectedIds.contains(bookId)) {
      state.selectedIds.remove(bookId);
    } else {
      state.selectedIds.add(bookId);
    }
    if (state.selectedIds.isEmpty) {
      state.isSelectionMode = false;
    }
    update();
  }

  void selectAllVisible() {
    for (final book in state.displayBooks) {
      state.selectedIds.add(book.id);
    }
    state.isSelectionMode = true;
    update();
  }

  void clearSelectionKeepMode() {
    state.selectedIds.clear();
    update();
  }

  /// 置顶 / 取消置顶（customOrder > 0 为置顶）
  Future<void> setBookPinned(Book book, {required bool pinned}) async {
    try {
      final order = pinned ? (await _bookshelfDao.maxCustomOrder()) + 1 : 0;
      await _bookshelfDao.updateCustomOrder(
        bookId: book.id,
        customOrder: order,
      );
      // 本地列表即时更新
      final index = state.myBooks.indexWhere((b) => b.id == book.id);
      if (index >= 0) {
        final old = state.myBooks[index];
        state.myBooks[index] = old.copyWith(customOrder: order);
        _sortBooks();
      }
      update();
    } catch (e) {
      LogUtils.e('更新置顶失败: $e');
      Get.snackbar('操作失败', '置顶状态更新失败');
    }
  }

  Future<void> pinSelected() async {
    final ids = state.selectedIds.toList(growable: false);
    if (ids.isEmpty) return;
    try {
      var next = await _bookshelfDao.maxCustomOrder();
      final orders = <int, int>{};
      for (final id in ids) {
        next += 1;
        orders[id] = next;
        final index = state.myBooks.indexWhere((b) => b.id == id);
        if (index >= 0) {
          final old = state.myBooks[index];
          state.myBooks[index] = old.copyWith(customOrder: next);
        }
      }
      await _bookshelfDao.updateCustomOrders(orders);
      _sortBooks();
      exitSelectionMode();
      Get.snackbar('已置顶', '已置顶 ${ids.length} 本书');
    } catch (e) {
      LogUtils.e('批量置顶失败: $e');
      Get.snackbar('操作失败', '批量置顶失败');
    }
  }

  Future<void> unpinSelected() async {
    final ids = state.selectedIds.toList(growable: false);
    if (ids.isEmpty) return;
    try {
      await _bookshelfDao.updateCustomOrders({for (final id in ids) id: 0});
      for (final id in ids) {
        final index = state.myBooks.indexWhere((b) => b.id == id);
        if (index >= 0) {
          final old = state.myBooks[index];
          state.myBooks[index] = old.copyWith(customOrder: 0);
        }
      }
      _sortBooks();
      exitSelectionMode();
      Get.snackbar('已取消置顶', '已处理 ${ids.length} 本书');
    } catch (e) {
      LogUtils.e('批量取消置顶失败: $e');
      Get.snackbar('操作失败', '取消置顶失败');
    }
  }

  Future<void> removeSelectedFromShelf() async {
    final ids = state.selectedIds.toList(growable: false);
    if (ids.isEmpty) return;

    final books =
        state.myBooks.where((b) => ids.contains(b.id)).toList(growable: false);
    if (books.isEmpty) return;

    try {
      await _bookshelfService.removeManyFromBookshelf(books);
      exitSelectionMode();
      await refreshBooks();
      Get.snackbar('已移出书架', '已移除 ${books.length} 本书');
    } catch (e) {
      LogUtils.e('批量移出书架失败: $e');
      Get.snackbar('移出失败', '请稍后重试');
    }
  }

  /// 从书架移除一本书
  Future<void> removeBookFromShelf({
    required int bookSourceId,
    required String bookName,
  }) async {
    try {
      await _bookshelfService.removeFromBookshelf(
        bookSourceId: bookSourceId,
        bookName: bookName,
      );
      await refreshBooks();
      Get.snackbar('已移出书架', bookName);
    } catch (e) {
      LogUtils.e('移出书架失败: $e');
      Get.snackbar('移出失败', '请稍后重试');
    }
  }

  /// 队列调度：控制并发更新，使用节流减少 UI 重建
  Future<void> _processUpdateQueue(List<Book> books) async {
    final semaphore = _Semaphore(_maxConcurrency);
    final futures = <Future<void>>[];
    final stopwatch = Stopwatch()..start();
    int lastUpdateMs = 0;
    const throttleMs = 300;

    for (final book in books) {
      if (_updateCancelToken?.isCancelled == true) break;

      final future = semaphore.acquire().then((_) async {
        try {
          if (_updateCancelToken?.isCancelled != true) {
            await _updateSingleBook(book);
          }
        } finally {
          state.updatedCount++;
          state.updateProgress = state.updatedCount / state.totalUpdateCount;
          // 节流：每 300ms 最多刷新一次 UI
          final nowMs = stopwatch.elapsedMilliseconds;
          if (nowMs - lastUpdateMs >= throttleMs) {
            lastUpdateMs = nowMs;
            update();
          }
          semaphore.release();
        }
      });
      futures.add(future);
    }

    await Future.wait(futures);
    update();
  }

  /// 更新单本书目录（核心逻辑）
  Future<void> _updateSingleBook(Book book) async {
    final bookId = book.id;
    final summaryDetail = state.bookDetailCache[bookId];

    if (summaryDetail == null || summaryDetail.bookUrl == null) {
      state.updateResults[bookId] = BookUpdateResult(
        bookId: bookId,
        status: BookUpdateStatus.failed,
        errorMessage: '书籍信息不完整',
      );
      return;
    }

    final detail = await ensureBookDetailReady(summaryDetail);

    state.updateResults[bookId] = BookUpdateResult(
      bookId: bookId,
      status: BookUpdateStatus.updating,
    );

    try {
      final source = await _resolveBookSource(detail.bookSourceId);
      if (source == null) throw Exception('书源不存在');

      final String? fastLatestChapter;
      try {
        fastLatestChapter = await _fastCheckLatestChapter(source, detail);
      } on SourceLoginRequiredException {
        state.updateResults[bookId] = BookUpdateResult(
          bookId: bookId,
          status: BookUpdateStatus.failed,
          errorMessage: '需要登录后才能检查更新',
        );
        return;
      }

      // 快速检查失败（返回 null）时，跳过全量抓取，视为无更新
      if (fastLatestChapter == null) {
        state.updateResults[bookId] = BookUpdateResult(
          bookId: bookId,
          status: BookUpdateStatus.success,
          newChapterCount: 0,
        );
        return;
      }

      final currentLastChapter = detail.lastChapter?.trim() ?? '';
      if (_isSameChapterTitle(fastLatestChapter, currentLastChapter)) {
        state.updateResults[bookId] = BookUpdateResult(
          bookId: bookId,
          status: BookUpdateStatus.success,
          newChapterCount: 0,
        );
        return;
      }

      await _fetchAndSaveNewChapters(
        bookId: bookId,
        detail: detail,
        source: source,
        fastLatestChapter: fastLatestChapter,
      );
    } on SourceLoginRequiredException {
      state.updateResults[bookId] = BookUpdateResult(
        bookId: bookId,
        status: BookUpdateStatus.failed,
        errorMessage: '需要登录后才能检查更新',
      );
    } catch (e) {
      LogUtils.e('更新书籍目录失败 [${detail.name}]: $e');
      state.updateResults[bookId] = BookUpdateResult(
        bookId: bookId,
        status: BookUpdateStatus.failed,
        errorMessage: e.toString(),
      );
    }
    // 注意：isUpdating / cancelToken 由整批更新结束统一收口，避免并发更新被提前打断
  }

  /// 从缓存或数据库解析书源
  Future<BookSource?> _resolveBookSource(int bookSourceId) async {
    BookSource? source = _updateSourceCache[bookSourceId];
    source ??= await _bookSourceDao.findById(bookSourceId);
    if (source != null) _updateSourceCache[bookSourceId] = source;
    return source;
  }

  /// 第一阶段：快速检查最新章节标题。
  /// 返回 null 表示应回退全量目录；抛出登录异常时由上层单独处理。
  Future<String?> _fastCheckLatestChapter(
    BookSource source,
    BookDetail detail,
  ) async {
    try {
      final latestInfo = await WebBookDetailService.getBookInfo(
        source,
        detail.bookUrl!,
        cancelToken: _updateCancelToken,
      ).timeout(_fastCheckTimeout);
      return latestInfo.lastChapter?.trim();
    } on SourceLoginRequiredException {
      rethrow;
    } catch (e) {
      LogUtils.d('快速检查最新章节失败，回退目录抓取 [${detail.name}]: $e');
      return null;
    }
  }

  /// 第二阶段：抓取完整目录并保存到数据库
  Future<void> _fetchAndSaveNewChapters({
    required int bookId,
    required BookDetail detail,
    required BookSource source,
    required String? fastLatestChapter,
  }) async {
    final newChapters = await WebBookDetailService.getChapterList(
      source,
      detail.bookUrl!,
      tocUrl: detail.tocUrl,
      cancelToken: _updateCancelToken,
    );

    final oldChapters = detail.chapters ?? [];
    final newChapterCount = newChapters.length - oldChapters.length;
    final fallbackLastChapter = newChapters.isNotEmpty
        ? newChapters.last.chapterName
        : detail.lastChapter;
    final resolvedLastChapter =
        (fastLatestChapter != null && fastLatestChapter.isNotEmpty)
            ? fastLatestChapter
            : fallbackLastChapter;

    if (newChapterCount > 0) {
      final updatedDetail = BookDetail(
        bookSourceId: detail.bookSourceId,
        name: detail.name,
        author: detail.author,
        cover: detail.cover,
        intro: detail.intro,
        kind: detail.kind,
        lastChapter: resolvedLastChapter,
        wordCount: detail.wordCount,
        bookUrl: detail.bookUrl,
        chapters: newChapters,
      );

      await _persistChapters(
        bookId: bookId,
        detail: detail,
        oldChapters: oldChapters,
        newChapters: newChapters,
        resolvedLastChapter: resolvedLastChapter,
      );

      state.bookDetailCache[bookId] = updatedDetail;
      state.updateResults[bookId] = BookUpdateResult(
        bookId: bookId,
        status: BookUpdateStatus.success,
        newChapterCount: newChapterCount,
      );
    } else {
      // 无新增章节：同步修正 lastChapter（应对同章数但标题变化）
      if (resolvedLastChapter != null &&
          resolvedLastChapter.isNotEmpty &&
          resolvedLastChapter != detail.lastChapter) {
        await _bookshelfDao.updateBook(
          bookId: bookId,
          book: BooksCompanion(
            lastChapter: drift.Value(resolvedLastChapter),
          ),
        );
        state.bookDetailCache[bookId] = detail.copyWith(
          lastChapter: resolvedLastChapter,
        );
      }

      state.updateResults[bookId] = BookUpdateResult(
        bookId: bookId,
        status: BookUpdateStatus.success,
        newChapterCount: 0,
      );
    }
  }

  /// 将 BookChapterInfo 列表转为 drift Companion 列表
  List<BookChaptersCompanion> _toChapterCompanions(
    List<BookChapterInfo> chapters, {
    required int bookId,
    required int bookSourceId,
  }) {
    return chapters
        .map((ch) => BookChaptersCompanion.insert(
              bookId: bookId,
              bookSourceId: bookSourceId,
              chapterIndex: ch.chapterIndex ?? 0,
              chapterName: ch.chapterName ?? '',
              chapterUrl: ch.chapterUrl ?? '',
            ))
        .toList();
  }

  /// 持久化章节数据（优先增量追加，失败时回退全量替换）
  Future<void> _persistChapters({
    required int bookId,
    required BookDetail detail,
    required List<BookChapterInfo> oldChapters,
    required List<BookChapterInfo> newChapters,
    required String? resolvedLastChapter,
  }) async {
    final appendStartIndex = _findAppendStartIndex(oldChapters, newChapters);
    await _bookshelfDao.updateBook(
      bookId: bookId,
      book: BooksCompanion(
        lastChapter: drift.Value(resolvedLastChapter),
        totalChapterNum: drift.Value(newChapters.length),
      ),
    );

    if (appendStartIndex == oldChapters.length) {
      final appendChapters = newChapters.skip(appendStartIndex).toList();
      if (appendChapters.isNotEmpty) {
        await _bookshelfDao.insertChapters(
          _toChapterCompanions(
            appendChapters,
            bookId: bookId,
            bookSourceId: detail.bookSourceId,
          ),
        );
      }
    } else {
      await _bookshelfDao.replaceChapters(
        bookId: bookId,
        chapters: _toChapterCompanions(
          newChapters,
          bookId: bookId,
          bookSourceId: detail.bookSourceId,
        ),
      );
    }
  }

  Future<void> _warmUpSourceCache(List<Book> books) async {
    final sourceIds = books
        .map((book) => state.bookDetailCache[book.id]?.bookSourceId)
        .whereType<int>()
        .toSet()
        .toList();
    if (sourceIds.isEmpty) return;

    final sources = await _bookSourceDao.listByIds(sourceIds);
    for (final source in sources) {
      _updateSourceCache[source.id] = source;
    }
  }

  int _findAppendStartIndex(
    List<BookChapterInfo> oldChapters,
    List<BookChapterInfo> newChapters,
  ) {
    final maxCompare = oldChapters.length < newChapters.length
        ? oldChapters.length
        : newChapters.length;
    for (int i = 0; i < maxCompare; i++) {
      if (!_isSameChapter(oldChapters[i], newChapters[i])) {
        return i;
      }
    }
    return maxCompare;
  }

  bool _isSameChapter(BookChapterInfo a, BookChapterInfo b) {
    final aUrl = (a.chapterUrl ?? '').trim();
    final bUrl = (b.chapterUrl ?? '').trim();
    if (aUrl.isNotEmpty || bUrl.isNotEmpty) {
      return aUrl == bUrl;
    }
    final aName = (a.chapterName ?? '').trim();
    final bName = (b.chapterName ?? '').trim();
    return aName == bName;
  }

  bool _isSameChapterTitle(String? a, String? b) {
    final aTrim = (a ?? '').trim();
    final bTrim = (b ?? '').trim();
    if (aTrim.isEmpty || bTrim.isEmpty) return false;
    return aTrim == bTrim;
  }

  /// 取消更新
  void cancelUpdate() {
    _updateCancelToken?.cancel('用户取消');
    _updateCancelToken = null;
    state.clearUpdateState();
    update();
  }

  /// 获取更新结果摘要
  String getUpdateSummary() {
    final successCount = state.updateResults.values
        .where((r) => r.status == BookUpdateStatus.success)
        .length;
    final failedCount = state.updateResults.values
        .where((r) => r.status == BookUpdateStatus.failed)
        .length;
    final totalNewChapters = state.updateResults.values
        .fold<int>(0, (sum, r) => sum + r.newChapterCount);

    if (totalNewChapters > 0) {
      return '更新完成：$successCount 本成功，新增 $totalNewChapters 章';
    } else if (failedCount > 0) {
      return '更新完成：$successCount 本成功，$failedCount 本失败';
    } else {
      return '更新完成：暂无新章节';
    }
  }

  /// 仅刷新阅读进度缓存（从阅读页返回时调用）
  Future<void> refreshReadProgress() async {
    final latestBooks = await _bookshelfDao.listBooksByIds(
      state.myBooks.map((book) => book.id),
    );
    final latestBookById = <int, Book>{
      for (final book in latestBooks) book.id: book
    };

    state.myBooks = state.myBooks
        .map((book) => latestBookById[book.id] ?? book)
        .toList(growable: false);

    for (final book in state.myBooks) {
      final detail = state.bookDetailCache[book.id];
      final bookName = detail?.name;
      if (detail == null || bookName == null || bookName.trim().isEmpty) {
        continue;
      }
      final key = _bookKey(detail.bookSourceId, bookName);
      final chapterIndex = _resolveBookSummaryChapterIndex(book);
      final pageIndex = book.lastReadTime != null ? book.durChapterPos : 0;
      final chapterName = _resolveChapterNameFromDetail(detail, chapterIndex);
      _cacheResolvedReadProgress(
        key: key,
        chapterIndex: chapterIndex,
        pageIndex: pageIndex,
        chapterName: chapterName,
      );
    }
    _sortBooks();
    update();
  }

  void applyReturnedReadProgress({
    required int bookSourceId,
    required String bookName,
    required int chapterIndex,
    required int pageIndex,
  }) {
    final key = _bookKey(bookSourceId, bookName);
    state.readProgressCache[key] = chapterIndex;
    state.readPageIndexCache[key] = pageIndex;
    final bookId = state.bookIdByKeyCache[key];
    final chapterName = _resolveChapterNameFromDetail(
      bookId != null ? state.bookDetailCache[bookId] : null,
      chapterIndex,
    );
    if (chapterName != null) {
      state.readChapterNameCache[key] = chapterName;
    }
    if (bookId != null) {
      state.myBooks = state.myBooks.map((book) {
        if (book.id != bookId) return book;
        return book.copyWith(
          durChapterIndex: chapterIndex,
          durChapterPos: pageIndex,
          lastReadTime: drift.Value(DateTime.now()),
        );
      }).toList(growable: false);
      _sortBooks();
    }
    update();
  }

  Future<BookDetail> ensureBookDetailReady(BookDetail bookDetail) async {
    if (bookDetail.chapters != null) return bookDetail;

    final bookName = _normalizeText(bookDetail.name);
    if (bookName == null) return bookDetail;

    var bookId = state.bookIdByKeyCache[_bookKey(
      bookDetail.bookSourceId,
      bookName,
    )];
    if (bookId == null) {
      final matchedBook = await _bookshelfDao.findBook(
        bookSourceId: bookDetail.bookSourceId,
        bookName: bookName,
      );
      bookId = matchedBook?.id;
      if (bookId != null) {
        state.bookIdByKeyCache[_bookKey(bookDetail.bookSourceId, bookName)] =
            bookId;
      }
    }
    if (bookId == null) return bookDetail;

    final cachedDetail = state.bookDetailCache[bookId];
    if (cachedDetail?.chapters != null) {
      return cachedDetail!;
    }

    final inflightTask = _bookDetailHydrationTasks[bookId];
    if (inflightTask != null) {
      return inflightTask;
    }

    final task = _hydrateBookDetail(
      bookId: bookId,
      fallbackDetail: cachedDetail ?? bookDetail,
    );
    _bookDetailHydrationTasks[bookId] = task;
    return task;
  }

  // 刷新书架
  Future<void> refreshBooks() async {
    final perf = PerformanceLogHelper.start('bookshelf.refreshBooks');
    try {
      // 从 Books 表加载书籍，优先使用 SQL 排序与索引。
      state.myBooks = await _bookshelfDao.listBooksForBookshelf();
      final sourceIds = state.myBooks
          .map((book) => book.bookSourceId)
          .where((id) => id > 0)
          .toSet();
      final sources = await _bookSourceDao.listByIds(sourceIds);
      final booksNeedingProgressFallback = state.myBooks
          .where((book) => !_hasBookReadSummary(book))
          .toList(growable: false);
      final readSnapshot = booksNeedingProgressFallback.isEmpty
          ? (
              latestProgressByKey: <String, BookReadProgressesData>{},
              fallbackChapterIndexByKey: <String, int>{},
              resolvedChapterNameByKey: <String, String>{},
            )
          : await _loadReadSnapshotByBooks(booksNeedingProgressFallback);

      // 清除旧缓存并仅预解析首页所需摘要数据
      state.clearCache();
      state.bookSourceCache.addEntries(
        sources.map((source) => MapEntry(source.id, source)),
      );
      await _preParseBooksFromNewTables(
        state.myBooks,
        latestProgressByKey: readSnapshot.latestProgressByKey,
        fallbackChapterIndexByKey: readSnapshot.fallbackChapterIndexByKey,
        resolvedChapterNameByKey: readSnapshot.resolvedChapterNameByKey,
      );
      _sortBooks();
      update();
      perf.complete(
        fields: <String, Object?>{
          'status': 'success',
          'bookCount': state.myBooks.length,
          'progressFallbackCount': booksNeedingProgressFallback.length,
        },
      );
    } catch (e) {
      perf.complete(
        fields: <String, Object?>{
          'status': 'failed',
          'error': e.toString(),
        },
      );
      rethrow;
    }
  }

  /// 从新表结构预解析书籍数据
  Future<void> _preParseBooksFromNewTables(
    List<Book> bookRecords, {
    required Map<String, BookReadProgressesData> latestProgressByKey,
    required Map<String, int> fallbackChapterIndexByKey,
    required Map<String, String> resolvedChapterNameByKey,
  }) async {
    if (bookRecords.isEmpty) return;

    for (final book in bookRecords) {
      final kind = book.kind;
      final detail = BookDetail(
        bookSourceId: book.bookSourceId,
        name: book.name,
        author: book.author,
        cover: book.cover,
        intro: book.intro,
        kind: kind != null ? List<String>.from(jsonDecode(kind)) : null,
        lastChapter: book.lastChapter,
        wordCount: book.wordCount,
        bookUrl: book.bookUrl,
        isAscending: book.isAscending,
      );

      state.bookDetailCache[book.id] = detail;
      final key = _bookKey(detail.bookSourceId, detail.name!);
      state.bookIdByKeyCache[key] = book.id;
      state.totalChapterCountCache[book.id] = book.totalChapterNum;
      state.bookInfoCache[book.id] = BookInfo(
        bookSourceId: detail.bookSourceId,
        name: detail.name!,
        author: detail.author,
        cover: detail.cover,
        intro: detail.intro,
        kind: detail.kind?.join(','),
        lastChapter: detail.lastChapter,
        wordCount: detail.wordCount,
        bookUrl: detail.bookUrl,
      );

      // 预加载阅读进度（使用批量查询快照）
      final chapterIndex = _resolveBookSummaryChapterIndex(
        book,
        fallbackChapterIndex: fallbackChapterIndexByKey[key],
      );
      final pageIndex = _resolveBookSummaryPageIndex(
        book,
        fallbackPageIndex: 0,
      );
      _cacheResolvedReadProgress(
        key: key,
        chapterIndex: chapterIndex,
        pageIndex: pageIndex,
        chapterName: _firstNonEmpty([
          _resolveChapterNameFromDetail(detail, chapterIndex),
          resolvedChapterNameByKey[key],
        ]),
      );
    }
  }

  void _sortBooks() {
    state.myBooks.sort(_compareBooksForCurrentSort);
  }

  int _compareBooksForCurrentSort(Book a, Book b) {
    // 置顶优先（customOrder 越大越靠前）
    final pinA = a.customOrder > 0;
    final pinB = b.customOrder > 0;
    if (pinA != pinB) return pinA ? -1 : 1;
    if (pinA && pinB) {
      final byPin = b.customOrder.compareTo(a.customOrder);
      if (byPin != 0) return byPin;
    }

    switch (state.sortMode) {
      case BookshelfSortMode.recentRead:
        return _compareRecentRead(a, b);
      case BookshelfSortMode.latestAdded:
        return b.id.compareTo(a.id);
      case BookshelfSortMode.title:
        return _compareTextThenNewest(
          _sortKey(a.name),
          _sortKey(b.name),
          a,
          b,
        );
      case BookshelfSortMode.author:
        return _compareTextThenNewest(
          _sortKey(a.author, fallback: a.name),
          _sortKey(b.author, fallback: b.name),
          a,
          b,
        );
    }
  }

  int _compareRecentRead(Book a, Book b) {
    final timeA = a.lastReadTime;
    final timeB = b.lastReadTime;

    if (timeA != null && timeB != null) {
      final byTime = timeB.compareTo(timeA);
      if (byTime != 0) return byTime;
      return b.id.compareTo(a.id);
    }
    if (timeA != null) return -1;
    if (timeB != null) return 1;
    return b.id.compareTo(a.id);
  }

  int _compareTextThenNewest(
    String aKey,
    String bKey,
    Book a,
    Book b,
  ) {
    final byText = aKey.compareTo(bKey);
    if (byText != 0) return byText;
    return b.id.compareTo(a.id);
  }

  String _sortKey(String? value, {String? fallback}) {
    final normalized = value?.trim();
    if (normalized != null && normalized.isNotEmpty) {
      return normalized.toLowerCase();
    }
    return (fallback ?? '').trim().toLowerCase();
  }

  Future<void> _scheduleAutoUpdateIfDue() async {
    _autoUpdateTimer?.cancel();
    _autoUpdateTimer = null;

    final hasUpdatableBooks = state.myBooks.any((book) {
      final detail = state.bookDetailCache[book.id];
      return detail?.bookUrl?.trim().isNotEmpty == true;
    });
    if (!hasUpdatableBooks) return;

    final shouldRun = await _updateScheduleStore.shouldRun(
      minInterval: _autoUpdateMinInterval,
    );
    if (!shouldRun) {
      return;
    }

    _autoUpdateTimer = Timer(_autoUpdateInitialDelay, () {
      _autoUpdateTimer = null;
      unawaited(_runUpdateAllBooks(
        recordRunAtEnd: true,
        trigger: 'auto',
      ));
    });
  }

  String _bookKey(int bookSourceId, String bookName) =>
      '${bookSourceId}_$bookName';

  Future<
      ({
        Map<String, BookReadProgressesData> latestProgressByKey,
        Map<String, int> fallbackChapterIndexByKey,
        Map<String, String> resolvedChapterNameByKey
      })> _loadReadSnapshotByBooks(List<Book> books) {
    final sourceIds = books.map((book) => book.bookSourceId).toSet();
    final names = books
        .map((book) => book.name)
        .where((name) => name.trim().isNotEmpty)
        .toSet();
    return _loadReadSnapshot(sourceIds: sourceIds, bookNames: names);
  }

  Future<
      ({
        Map<String, BookReadProgressesData> latestProgressByKey,
        Map<String, int> fallbackChapterIndexByKey,
        Map<String, String> resolvedChapterNameByKey
      })> _loadReadSnapshot({
    required Set<int> sourceIds,
    required Set<String> bookNames,
  }) async {
    if (sourceIds.isEmpty || bookNames.isEmpty) {
      return (
        latestProgressByKey: <String, BookReadProgressesData>{},
        fallbackChapterIndexByKey: <String, int>{},
        resolvedChapterNameByKey: <String, String>{},
      );
    }

    final progressRows = await _readProgressDao.listByBooks(
      bookSourceIds: sourceIds,
      bookNames: bookNames,
    );
    final latestProgressByKey = <String, BookReadProgressesData>{};
    final resolvedChapterNameByKey = <String, String>{};
    for (final progress in progressRows) {
      final key = _bookKey(progress.bookSourceId, progress.bookName);
      latestProgressByKey.putIfAbsent(key, () => progress);
      final chapterName = _normalizeText(progress.chapterName);
      if (chapterName != null) {
        resolvedChapterNameByKey.putIfAbsent(key, () => chapterName);
      }
    }

    final contentRows = await _contentInfoDao.listByBooks(
      bookSourceIds: sourceIds.toSet(),
      bookNames: bookNames.toSet(),
    );
    final fallbackChapterIndexByKey = <String, int>{};
    for (final content in contentRows) {
      final bookName = content.name;
      final chapterIndex = content.chapterIndex;
      if (bookName == null || bookName.trim().isEmpty || chapterIndex == null) {
        continue;
      }
      final key = _bookKey(content.bookSourceId, bookName);
      fallbackChapterIndexByKey.putIfAbsent(key, () => chapterIndex);
      final chapterName = _normalizeText(content.chapterName);
      if (chapterName != null) {
        resolvedChapterNameByKey.putIfAbsent(key, () => chapterName);
      }
    }

    return (
      latestProgressByKey: latestProgressByKey,
      fallbackChapterIndexByKey: fallbackChapterIndexByKey,
      resolvedChapterNameByKey: resolvedChapterNameByKey,
    );
  }

  Future<BookDetail> _hydrateBookDetail({
    required int bookId,
    required BookDetail fallbackDetail,
  }) async {
    try {
      final chapters = await _loadBookChapters(bookId);
      final hydratedDetail = fallbackDetail.copyWith(chapters: chapters);
      state.bookDetailCache[bookId] = hydratedDetail;
      state.totalChapterCountCache[bookId] = chapters.length;
      return hydratedDetail;
    } catch (e) {
      LogUtils.e('加载书架书籍目录失败 [${fallbackDetail.name}]: $e');
      return state.bookDetailCache[bookId] ?? fallbackDetail;
    } finally {
      _bookDetailHydrationTasks.remove(bookId);
    }
  }

  Future<List<BookChapterInfo>> _loadBookChapters(int bookId) async {
    final chapterRecords = await _bookshelfDao.listChaptersByBookId(bookId);
    return chapterRecords
        .map((ch) => BookChapterInfo(
              bookSourceId: ch.bookSourceId,
              chapterIndex: ch.chapterIndex,
              chapterName: ch.chapterName,
              chapterUrl: ch.chapterUrl,
            ))
        .toList(growable: false);
  }

  void _cacheResolvedReadProgress({
    required String key,
    required int? chapterIndex,
    required int pageIndex,
    String? chapterName,
  }) {
    if (chapterIndex == null) {
      state.readProgressCache.remove(key);
      state.readPageIndexCache.remove(key);
      state.readChapterNameCache.remove(key);
      return;
    }

    state.readProgressCache[key] = chapterIndex;
    state.readPageIndexCache[key] = pageIndex;
    final normalizedChapterName = _normalizeText(chapterName);
    if (normalizedChapterName != null) {
      state.readChapterNameCache[key] = normalizedChapterName;
    } else {
      state.readChapterNameCache.remove(key);
    }
  }

  String? _resolveChapterNameFromDetail(BookDetail? detail, int? chapterIndex) {
    if (detail == null || chapterIndex == null) return null;
    final chapters = detail.chapters;
    if (chapters == null || chapters.isEmpty) return null;

    for (final chapter in chapters) {
      if (chapter.chapterIndex == chapterIndex) {
        return _normalizeText(chapter.chapterName);
      }
    }

    if (chapterIndex >= 0 && chapterIndex < chapters.length) {
      return _normalizeText(chapters[chapterIndex].chapterName);
    }
    return null;
  }

  String? _firstNonEmpty(Iterable<String?> values) {
    for (final value in values) {
      final normalized = _normalizeText(value);
      if (normalized != null) {
        return normalized;
      }
    }
    return null;
  }

  String? _normalizeText(String? value) {
    final normalized = value?.trim();
    if (normalized == null || normalized.isEmpty) {
      return null;
    }
    return normalized;
  }

  bool _hasBookReadSummary(Book book) {
    return book.lastReadTime != null;
  }

  int? _resolveBookSummaryChapterIndex(
    Book book, {
    int? fallbackChapterIndex,
  }) {
    if (_hasBookReadSummary(book)) {
      return book.durChapterIndex;
    }
    return fallbackChapterIndex;
  }

  int _resolveBookSummaryPageIndex(
    Book book, {
    required int fallbackPageIndex,
  }) {
    if (_hasBookReadSummary(book)) {
      return book.durChapterPos;
    }
    return fallbackPageIndex;
  }

  // 获取书籍的阅读进度（章节索引和页码）
  Future<({int? chapterIndex, int pageIndex})> getReadProgress(
      int bookSourceId, String bookName) async {
    final logContext = 'bookSourceId=$bookSourceId, bookName=$bookName';
    try {
      // 优先从阅读进度表获取，按更新时间倒序取最新的一条
      final progress = await _readProgressDao.findByBook(
        bookSourceId: bookSourceId,
        bookName: bookName,
      );

      if (progress != null) {
        LogUtils.d(
          '读取阅读进度命中: $logContext, '
          'chapterIndex=${progress.chapterIndex}',
        );
        return (chapterIndex: progress.chapterIndex, pageIndex: 0);
      }

      // 兼容旧数据：如果没有阅读进度记录，从缓存章节表获取最大章节索引
      final result = await _contentInfoDao.findLatestByBook(
        bookSourceId: bookSourceId,
        bookName: bookName,
      );

      if (result != null) {
        LogUtils.d(
          '读取阅读进度回退正文缓存: $logContext, '
          'chapterIndex=${result.chapterIndex}, pageIndex=0',
        );
      } else {
        LogUtils.d('读取阅读进度为空: $logContext');
      }

      return (chapterIndex: result?.chapterIndex, pageIndex: 0);
    } catch (e) {
      LogUtils.e('获取阅读进度失败: $logContext, error=$e');
      return (chapterIndex: null, pageIndex: 0);
    }
  }

  /// 获取缓存的阅读进度（章节索引）
  int getCachedReadProgress(int bookSourceId, String bookName) {
    return state.readProgressCache['${bookSourceId}_$bookName'] ?? 0;
  }

  /// 获取缓存的阅读页码
  int getCachedReadPageIndex(int bookSourceId, String bookName) {
    return state.readPageIndexCache['${bookSourceId}_$bookName'] ?? 0;
  }
}

/// 简单的信号量实现，用于控制并发数
class _Semaphore {
  final int maxCount;
  int _currentCount = 0;
  final List<Completer<void>> _waitQueue = [];

  _Semaphore(this.maxCount);

  Future<void> acquire() async {
    if (_currentCount < maxCount) {
      _currentCount++;
      return;
    }
    final completer = Completer<void>();
    _waitQueue.add(completer);
    await completer.future;
  }

  void release() {
    if (_waitQueue.isNotEmpty) {
      final completer = _waitQueue.removeAt(0);
      completer.complete();
    } else {
      _currentCount--;
    }
  }
}
