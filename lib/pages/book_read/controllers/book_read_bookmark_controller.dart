import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:reader_nover/app/database/dao/bookmark_dao.dart';
import 'package:reader_nover/app/database/drift/app_database.dart' as db;
import 'package:reader_nover/util/log_utils.dart';
import 'package:reader_nover/app/service/book/reader_locator.dart';

import '../state.dart';

class BookReadBookmarkController {
  BookReadBookmarkController({
    required this.state,
    required db.AppDatabase database,
    required this.onUpdate,
    required this.onJumpToLocator,
  }) : _database = database;

  final BookReadState state;
  final db.AppDatabase _database;
  late final BookmarkDao _bookmarkDao = BookmarkDao(database: _database);
  final VoidCallback onUpdate;
  final Future<void> Function(ReaderLocator locator) onJumpToLocator;

  Future<void> loadBookmarks() async {
    try {
      final results = await _bookmarkDao.listByBook(
        bookSourceId: state.bookInfo.bookSourceId,
        bookName: state.bookInfo.name,
      );
      _applyBookmarkList(results);
    } catch (e) {
      LogUtils.e('加载书签失败: $e');
    }
  }

  void syncCurrentChapterBookmarkFlag() {
    state.isCurrentChapterBookmarked = state.bookmarkList.any(
      (bookmark) =>
          _decodeLocator(bookmark)?.chapterIndex == state.currentChapterIndex,
    );
  }

  Future<void> toggleBookmark() async {
    final previousBookmarks = List<db.Bookmark>.from(state.bookmarkList);
    try {
      if (state.isCurrentChapterBookmarked) {
        final removed = state.bookmarkList
            .where((bookmark) =>
                _decodeLocator(bookmark)?.chapterIndex ==
                state.currentChapterIndex)
            .toList(growable: false);
        final nextBookmarks = List<db.Bookmark>.from(state.bookmarkList)
          ..removeWhere(removed.contains);
        _applyBookmarkList(nextBookmarks);
        for (final bookmark in removed) {
          await _bookmarkDao.deleteById(bookmark.id);
        }
        Get.snackbar(
          '书签',
          '已删除书签',
          backgroundColor: Colors.black.withValues(alpha: 0.75),
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 1),
        );
      } else {
        final now = DateTime.now();
        final bookText = _buildCurrentPageSnippet();
        final locator = _currentLocator();
        final bookmarkId = await _bookmarkDao.add(
          bookSourceId: state.bookInfo.bookSourceId,
          bookName: state.bookInfo.name,
          locatorJson: locator.encode(),
          chapterName: state.currentChapter,
          bookText: bookText,
          createTime: now,
        );
        final nextBookmarks = List<db.Bookmark>.from(state.bookmarkList)
          ..add(
            db.Bookmark(
              id: bookmarkId,
              bookSourceId: state.bookInfo.bookSourceId,
              bookName: state.bookInfo.name,
              locatorJson: locator.encode(),
              chapterName: state.currentChapter,
              bookText: bookText,
              content: '',
              createTime: now,
            ),
          )
          ..sort((a, b) => _locatorIndex(a).compareTo(_locatorIndex(b)));
        _applyBookmarkList(nextBookmarks);
        Get.snackbar(
          '书签',
          '已添加书签',
          backgroundColor: Colors.black.withValues(alpha: 0.75),
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 1),
        );
      }
    } catch (e) {
      _applyBookmarkList(previousBookmarks);
      LogUtils.e('切换书签失败: $e');
    }
  }

  Future<void> updateBookmark(db.Bookmark bookmark, String content) async {
    final normalizedContent = content.trim();
    if (bookmark.content == normalizedContent) {
      return;
    }

    final previousBookmarks = List<db.Bookmark>.from(state.bookmarkList);
    final updatedBookmarks = state.bookmarkList
        .map(
          (item) => item.id == bookmark.id
              ? item.copyWith(content: normalizedContent)
              : item,
        )
        .toList(growable: false);
    _applyBookmarkList(updatedBookmarks);

    try {
      await _bookmarkDao.updateContent(
        bookmarkId: bookmark.id,
        content: normalizedContent,
      );
      Get.snackbar(
        '书签',
        '已保存备注',
        backgroundColor: Colors.black.withValues(alpha: 0.75),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 1),
      );
    } catch (e) {
      _applyBookmarkList(previousBookmarks);
      LogUtils.e('更新书签失败: $e');
    }
  }

  Future<void> deleteBookmark(db.Bookmark bookmark) async {
    final previousBookmarks = List<db.Bookmark>.from(state.bookmarkList);
    final nextBookmarks = List<db.Bookmark>.from(state.bookmarkList)
      ..removeWhere((item) => item.id == bookmark.id);
    _applyBookmarkList(nextBookmarks);

    try {
      await _bookmarkDao.deleteById(bookmark.id);
      Get.snackbar(
        '书签',
        '已删除书签',
        backgroundColor: Colors.black.withValues(alpha: 0.75),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 1),
      );
    } catch (e) {
      _applyBookmarkList(previousBookmarks);
      LogUtils.e('删除书签失败: $e');
    }
  }

  Future<void> jumpToBookmark(db.Bookmark bookmark) async {
    final locator = _decodeLocator(bookmark);
    if (locator != null) await onJumpToLocator(locator);
  }

  void _applyBookmarkList(List<db.Bookmark> bookmarks) {
    state.bookmarkList = bookmarks;
    syncCurrentChapterBookmarkFlag();
    onUpdate();
  }

  String _buildCurrentPageSnippet() {
    if (state.bookContentList.isEmpty ||
        state.currentPage >= state.bookContentList.length) {
      return '';
    }

    var bookText = state.bookContentList[state.currentPage];
    if (bookText.length > 100) {
      bookText = '${bookText.substring(0, 100)}...';
    }
    return bookText;
  }

  ReaderLocator _currentLocator() {
    final page = state.currentPage.clamp(0, state.bookContentList.length);
    final offset = state.bookContentList
        .take(page)
        .fold<int>(0, (total, text) => total + text.length);
    return const ReaderLocatorService().create(
      chapterIndex: state.currentChapterIndex,
      chapterName: state.currentChapter,
      chapterText: state.bookContent,
      offsetUtf16: offset,
    );
  }

  ReaderLocator? _decodeLocator(db.Bookmark bookmark) {
    try {
      return ReaderLocator.decode(bookmark.locatorJson);
    } on FormatException catch (error) {
      LogUtils.e('书签定位数据无效: $error');
      return null;
    }
  }

  int _locatorIndex(db.Bookmark bookmark) =>
      _decodeLocator(bookmark)?.chapterIndex ?? 0;
}
