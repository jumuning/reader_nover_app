import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reader_nover/app/service/book/models/source_book_info.dart';

import 'package:reader_nover/app/database/dao/book_source_dao.dart';
import 'package:reader_nover/app/database/dao/bookshelf_dao.dart';
import 'package:reader_nover/app/database/drift/app_database.dart' as db;
import 'package:reader_nover/app/database/models/models.dart';
import 'package:reader_nover/app/routes/route_args.dart';
import 'package:reader_nover/app/routes/app_routes.dart';
import 'package:reader_nover/app/service/book/book_change_service.dart';
import 'package:reader_nover/app/service/book/bookshelf_service.dart';
import 'package:reader_nover/app/service/book/service_result.dart';
import 'package:reader_nover/app/service/local_book/local_book_constants.dart';
import 'package:reader_nover/pages/home/source/controllers/source_login_controller.dart';
import 'package:reader_nover/util/dialog/dialog_utils.dart';
import 'package:reader_nover/util/log_utils.dart';
import '../state.dart';

class BookReadLibraryController {
  BookReadLibraryController({
    required this.state,
    required db.AppDatabase database,
    required BookChangeService bookChangeService,
    required BookshelfService bookshelfService,
    required this.onUpdate,
    required this.onRefreshBookshelf,
    required this.onToggleAppBarVisibility,
    required this.onReloadCurrentChapter,
    required this.onSyncBookmarkStatus,
  })  : _database = database,
        _bookChangeService = bookChangeService,
        _bookshelfService = bookshelfService;

  final BookReadState state;
  final db.AppDatabase _database;
  late final BookSourceDao _bookSourceDao = BookSourceDao(database: _database);
  late final BookshelfDao _bookshelfDao = BookshelfDao(database: _database);
  final BookChangeService _bookChangeService;
  final BookshelfService _bookshelfService;
  final VoidCallback onUpdate;
  final VoidCallback? onRefreshBookshelf;
  final VoidCallback onToggleAppBarVisibility;
  final Future<void> Function() onReloadCurrentChapter;
  final VoidCallback onSyncBookmarkStatus;
  final SourceLoginController _sourceLoginController =
      const SourceLoginController();

  Future<void> checkBookshelfStatus() async {
    try {
      state.isInBookshelf = await _isBookInShelf();
      onUpdate();
    } catch (e) {
      LogUtils.e('检查书架状态失败: $e');
    }
  }

  Future<void> showSourceDialog() async {
    if (LocalBookConstants.isLocalBookSource(state.bookInfo.bookSourceId)) {
      Get.snackbar(
        '提示',
        '本地书籍不支持换源',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (state.isAppBarVisible) {
      onToggleAppBarVisibility();
    }

    final currentSource = await _bookSourceDao.findById(
      state.bookInfo.bookSourceId,
    );

    final result = await Get.toNamed(
      AppRoutes.bookChange,
      arguments: BookChangeArgs(
        bookName: state.bookInfo.name,
        bookSourceId: state.bookInfo.bookSourceId,
        sourceName: currentSource?.bookSourceName ?? '未知',
        sourceUrl: currentSource?.bookSourceUrl ?? '',
        bookUrl: state.bookInfo.bookUrl ?? '',
      ),
    );

    if (result != null && result is SourceBookInfo) {
      await _handleChangeSourceResult(result);
    }
  }

  Future<void> toggleBookshelf() async {
    try {
      DialogUtils.loading();
      final wasInBookshelf = state.isInBookshelf;
      if (state.isInBookshelf) {
        await _removeFromBookshelf();
      } else {
        await _addToBookshelf();
      }
      await DialogUtils.dismiss();
      Get.snackbar(
        wasInBookshelf ? '已移出书架' : '已加入书架',
        wasInBookshelf
            ? '《${state.bookInfo.name}》已从书架移除'
            : '《${state.bookInfo.name}》已加入书架',
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      await DialogUtils.dismiss();
      LogUtils.e('书架操作失败: $e');
      Get.snackbar(
        '操作失败',
        '书架操作失败，请重试',
        duration: const Duration(seconds: 2),
      );
    }
  }

  Future<bool> _isBookInShelf() async {
    try {
      final result = await _bookshelfDao.findBook(
        bookSourceId: state.bookInfo.bookSourceId,
        bookName: state.bookInfo.name,
      );
      return result != null;
    } catch (_) {
      return false;
    }
  }

  Future<void> _handleChangeSourceResult(SourceBookInfo sourceInfo) async {
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
      await showLoading();
      var changeResult = await _changeSourceOnce(sourceInfo);
      if (changeResult.isFailure) {
        final error = changeResult.error!;
        final loggedIn = await _openLoginForChangeSourceIfNeeded(
          error,
          dismissLoading: dismissLoading,
        );
        if (loggedIn) {
          await showLoading();
          changeResult = await _changeSourceOnce(sourceInfo);
        }
      }

      if (changeResult.isFailure) {
        final error = changeResult.error!;
        await dismissLoading();
        LogUtils.e('换源失败: ${error.formatForLog()}');
        Get.snackbar('错误', error.userMessage);
        return;
      }
      final data = changeResult.requireData();

      state.bookInfo = data.bookInfo;
      state.bookDetail = data.bookDetail;
      state.isAscending = data.bookDetail.isAscending;
      state.currentChapterIndex = data.newChapterIndex;
      state.currentChapter = data.newChapterName;
      state.currentChapterUrl = data.newChapterUrl;
      onSyncBookmarkStatus();
      onUpdate();

      await dismissLoading();
      await onReloadCurrentChapter();
      await checkBookshelfStatus();
      _refreshBookshelf();

      LogUtils.d('换源成功: ${sourceInfo.bookSource.bookSourceName}');
    } catch (e) {
      await dismissLoading();
      LogUtils.e('换源失败: $e');
      Get.snackbar('错误', '换源失败: $e');
    }
  }

  Future<ServiceResult<ChangeSourceResult>> _changeSourceOnce(
    SourceBookInfo sourceInfo,
  ) {
    return _bookChangeService.changeSource(
      sourceInfo: sourceInfo,
      bookInfo: state.bookInfo,
      bookDetail: state.bookDetail,
      currentChapterName: state.currentChapter,
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

  Future<void> _addToBookshelf() async {
    final source = await _bookSourceDao.findById(state.bookInfo.bookSourceId);
    if (source == null) {
      throw StateError('当前书源不存在，无法加入书架');
    }

    await _bookshelfService.addToBookshelf(
      source: source,
      bookInfo: state.bookInfo,
      bookDetail: state.bookDetail,
      chapterInfo: state.bookDetail.chapters ?? const <BookChapterInfo>[],
      currentReadChapterIndex: state.currentChapterIndex,
      currentReadPageIndex: state.currentPage,
    );

    state.isInBookshelf = true;
    _refreshBookshelf();
    LogUtils.d('书籍已加入书架');
    onUpdate();
  }

  Future<void> _removeFromBookshelf() async {
    await _bookshelfService.removeFromBookshelf(
      bookSourceId: state.bookInfo.bookSourceId,
      bookName: state.bookInfo.name,
    );

    state.isInBookshelf = false;
    _refreshBookshelf();
    LogUtils.d('书籍已从书架移除');
    onUpdate();
  }

  void _refreshBookshelf() {
    onRefreshBookshelf?.call();
  }
}
