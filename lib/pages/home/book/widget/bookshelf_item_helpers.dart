import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/database/drift/app_database.dart';
import '../../../../app/database/models/models.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../app/routes/route_args.dart';
import '../../../../app/service/local_book/local_book_constants.dart';
import '../../../../util/dialog/dialog_utils.dart';
import '../logic.dart';
import 'bookshelf_bottom_sheet.dart';

class BookshelfReadSnapshot {
  const BookshelfReadSnapshot({
    required this.hasReadBefore,
    required this.currentChapterIndex,
    required this.currentPageIndex,
    required this.unreadCount,
    required this.currentChapterName,
  });

  final bool hasReadBefore;
  final int currentChapterIndex;
  final int currentPageIndex;
  final int unreadCount;
  final String? currentChapterName;
}

class _ResolvedReadTarget {
  const _ResolvedReadTarget({
    required this.chapterIndex,
    required this.pageIndex,
    required this.chapter,
    required this.chapterListIndex,
    required this.usedChapterFallback,
  });

  final int chapterIndex;
  final int pageIndex;
  final BookChapterInfo? chapter;
  final int? chapterListIndex;
  final bool usedChapterFallback;
}

BookshelfReadSnapshot resolveBookshelfReadSnapshot(
  BookLogic logic,
  BookDetail bookDetail,
) {
  final bookName = bookDetail.name ?? '';
  final key = '${bookDetail.bookSourceId}_$bookName';
  final readProgress = logic.state.readProgressCache[key];
  final hasReadBefore = readProgress != null;
  final currentChapterIndex = readProgress ?? 0;
  final currentPageIndex = logic.state.readPageIndexCache[key] ?? 0;
  final bookId = logic.state.bookIdByKeyCache[key];
  final cachedTotalChapters =
      bookId != null ? logic.state.totalChapterCountCache[bookId] ?? 0 : 0;
  final chapters = bookDetail.chapters;
  final currentChapterName = logic.state.readChapterNameCache[key];

  if (chapters != null) {
    final totalChapters =
        chapters.isNotEmpty ? chapters.length : cachedTotalChapters;
    final resolvedTarget = _resolveReadTarget(
      chapters: chapters,
      requestedChapterIndex: currentChapterIndex,
      requestedPageIndex: currentPageIndex,
      fallbackToFirstChapter: hasReadBefore,
    );
    final unreadCount = !hasReadBefore
        ? totalChapters
        : _resolveUnreadCount(
            totalChapters: totalChapters,
            resolvedTarget: resolvedTarget,
          );

    return BookshelfReadSnapshot(
      hasReadBefore: hasReadBefore,
      currentChapterIndex: resolvedTarget.chapterIndex,
      currentPageIndex: resolvedTarget.pageIndex,
      unreadCount: unreadCount,
      currentChapterName:
          resolvedTarget.chapter?.chapterName ?? currentChapterName,
    );
  }

  final unreadCount = !hasReadBefore
      ? cachedTotalChapters
      : _resolveSummaryUnreadCount(
          totalChapters: cachedTotalChapters,
          currentChapterIndex: currentChapterIndex,
        );

  return BookshelfReadSnapshot(
    hasReadBefore: hasReadBefore,
    currentChapterIndex: currentChapterIndex,
    currentPageIndex: currentPageIndex,
    unreadCount: unreadCount,
    currentChapterName: currentChapterName ?? (hasReadBefore ? '继续阅读' : null),
  );
}

Future<void> openBookReadPage({
  required BookLogic logic,
  required BookDetail bookDetail,
  required BookInfo bookInfo,
  required int currentChapterIndex,
  required int currentPageIndex,
}) async {
  final needsLocalChapterParse =
      LocalBookConstants.isLocalBookSource(bookDetail.bookSourceId) &&
          (bookDetail.chapters?.isNotEmpty != true);
  if (needsLocalChapterParse) {
    unawaited(DialogUtils.loading());
    await Future<void>.delayed(Duration.zero);
  }
  final BookDetail readyBookDetail;
  try {
    readyBookDetail = await logic.ensureLocalBookChaptersReady(bookDetail);
  } finally {
    if (needsLocalChapterParse) {
      await DialogUtils.dismiss();
    }
  }
  final chapters = readyBookDetail.chapters ?? const <BookChapterInfo>[];
  final resolvedTarget = _resolveReadTarget(
    chapters: chapters,
    requestedChapterIndex: currentChapterIndex,
    requestedPageIndex: currentPageIndex,
    fallbackToFirstChapter: chapters.isNotEmpty,
  );
  final resolvedChapter = resolvedTarget.chapter;
  final chapterNameCacheKey = '${bookInfo.bookSourceId}_${bookInfo.name}';

  Get.toNamed(
    AppRoutes.bookRead,
    arguments: BookReadArgs(
      bookInfo: bookInfo,
      chapterName: resolvedChapter?.chapterName ??
          logic.state.readChapterNameCache[chapterNameCacheKey] ??
          '',
      chapterUrl: resolvedChapter?.chapterUrl ?? '',
      chapterIndex: resolvedTarget.chapterIndex,
      pageIndex: resolvedTarget.pageIndex,
      bookDetail: readyBookDetail,
      onRefreshBookshelf: logic.refreshBooks,
    ),
  )?.then((result) {
    if (result is BookReadExitResult) {
      logic.applyReturnedReadProgress(
        bookSourceId: bookInfo.bookSourceId,
        bookName: bookInfo.name,
        chapterIndex: result.chapterIndex,
        pageIndex: result.pageIndex,
      );
    } else if (result is int) {
      logic.applyReturnedReadProgress(
        bookSourceId: bookInfo.bookSourceId,
        bookName: bookInfo.name,
        chapterIndex: result,
        pageIndex: currentPageIndex,
      );
    }
    unawaited(logic.refreshReadProgress());
  });
}

_ResolvedReadTarget _resolveReadTarget({
  required List<BookChapterInfo> chapters,
  required int requestedChapterIndex,
  required int requestedPageIndex,
  required bool fallbackToFirstChapter,
}) {
  final matchedIndex = chapters.indexWhere(
    (chapter) => chapter.chapterIndex == requestedChapterIndex,
  );
  if (matchedIndex >= 0) {
    final matchedChapter = chapters[matchedIndex];
    return _ResolvedReadTarget(
      chapterIndex: matchedChapter.chapterIndex ?? requestedChapterIndex,
      pageIndex: requestedPageIndex,
      chapter: matchedChapter,
      chapterListIndex: matchedIndex,
      usedChapterFallback: false,
    );
  }

  if (fallbackToFirstChapter && chapters.isNotEmpty) {
    final firstChapter = chapters.first;
    return _ResolvedReadTarget(
      chapterIndex: firstChapter.chapterIndex ?? 0,
      pageIndex: 0,
      chapter: firstChapter,
      chapterListIndex: 0,
      usedChapterFallback: true,
    );
  }

  return _ResolvedReadTarget(
    chapterIndex: requestedChapterIndex,
    pageIndex: requestedPageIndex,
    chapter: null,
    chapterListIndex: null,
    usedChapterFallback: false,
  );
}

int _resolveUnreadCount({
  required int totalChapters,
  required _ResolvedReadTarget resolvedTarget,
}) {
  if (totalChapters <= 0) return 0;
  if (resolvedTarget.usedChapterFallback) {
    return totalChapters;
  }
  final chapterListIndex = resolvedTarget.chapterListIndex;
  if (chapterListIndex == null) {
    return totalChapters;
  }
  return (totalChapters - chapterListIndex - 1).clamp(0, totalChapters);
}

int _resolveSummaryUnreadCount({
  required int totalChapters,
  required int currentChapterIndex,
}) {
  if (totalChapters <= 0) return 0;
  final normalizedChapterIndex =
      currentChapterIndex < 0 ? 0 : currentChapterIndex;
  return (totalChapters - normalizedChapterIndex - 1).clamp(0, totalChapters);
}

void openBookDetailPage({
  required BookLogic logic,
  required BookInfo bookInfo,
}) {
  Get.toNamed(
    AppRoutes.bookDetail,
    arguments: BookDetailArgs(
      bookInfo: bookInfo,
      onRefreshBookshelf: logic.refreshBooks,
    ),
  )?.then((_) {
    logic.refreshReadProgress();
  });
}

/// 统一书架长按菜单：与「排序 / 最近阅读」弹层同款样式。
Future<void> showBookshelfItemActions({
  required BuildContext context,
  required BookLogic logic,
  required BookDetail bookDetail,
  required BookInfo bookInfo,
  required Book book,
  required BookshelfReadSnapshot readSnapshot,
}) async {
  final title = bookDetail.name?.trim().isNotEmpty == true
      ? bookDetail.name!
      : '未命名书籍';
  final author = bookDetail.author?.trim().isNotEmpty == true
      ? bookDetail.author!
      : '未知作者';
  final isLocal =
      LocalBookConstants.isLocalBookSource(bookDetail.bookSourceId);
  final isPinned = book.customOrder > 0;
  final subtitle = isLocal ? '$author · 本地书' : author;

  final action = await showBookshelfBottomSheet<_BookshelfAction>(
    child: BookshelfBottomSheetShell(
      title: title,
      subtitle: subtitle,
      icon: Icons.menu_book_rounded,
      children: [
        BookshelfSheetOption(
          icon: Icons.menu_book_rounded,
          label: readSnapshot.hasReadBefore ? '继续阅读' : '开始阅读',
          onTap: () => Get.back(result: _BookshelfAction.read),
        ),
        BookshelfSheetOption(
          icon: Icons.info_outline_rounded,
          label: '书籍详情',
          onTap: () => Get.back(result: _BookshelfAction.detail),
        ),
        BookshelfSheetOption(
          icon: isPinned ? Icons.push_pin_outlined : Icons.push_pin_rounded,
          label: isPinned ? '取消置顶' : '置顶',
          selected: isPinned,
          onTap: () => Get.back(result: _BookshelfAction.pin),
        ),
        BookshelfSheetOption(
          icon: Icons.checklist_rounded,
          label: '批量管理',
          onTap: () => Get.back(result: _BookshelfAction.batch),
        ),
        BookshelfSheetOption(
          icon: Icons.delete_outline_rounded,
          label: '移出书架',
          isDestructive: true,
          onTap: () => Get.back(result: _BookshelfAction.remove),
        ),
      ],
    ),
  );

  if (action == null) return;

  switch (action) {
    case _BookshelfAction.read:
      await openBookReadPage(
        logic: logic,
        bookDetail: bookDetail,
        bookInfo: bookInfo,
        currentChapterIndex: readSnapshot.currentChapterIndex,
        currentPageIndex: readSnapshot.currentPageIndex,
      );
      break;
    case _BookshelfAction.detail:
      openBookDetailPage(logic: logic, bookInfo: bookInfo);
      break;
    case _BookshelfAction.pin:
      await logic.setBookPinned(book, pinned: !isPinned);
      break;
    case _BookshelfAction.batch:
      logic.enterSelectionMode(initialBookId: book.id);
      break;
    case _BookshelfAction.remove:
      final confirmed = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('移出书架'),
          content: Text('确定将「$title」移出书架吗？'),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              child: Text(
                '移出',
                style: TextStyle(color: Get.theme.colorScheme.error),
              ),
            ),
          ],
        ),
      );
      if (confirmed == true) {
        await logic.removeBookFromShelf(
          bookSourceId: bookInfo.bookSourceId,
          bookName: bookInfo.name,
        );
      }
      break;
  }
}

enum _BookshelfAction {
  read,
  detail,
  pin,
  batch,
  remove,
}
