import 'package:flutter/material.dart';
import 'package:reader_nover/util/color_utils.dart';

import '../../../../app/database/drift/app_database.dart';
import '../../../../app/database/models/models.dart';
import '../../../../app/service/local_book/local_book_constants.dart';
import '../logic.dart';
import '../state.dart';
import 'book_grid_item_cover.dart';
import 'bookshelf_item_helpers.dart';

class BookGridItem extends StatelessWidget {
  const BookGridItem({
    super.key,
    required this.logic,
    required this.bookDetail,
    required this.bookInfo,
    required this.bookId,
    required this.book,
  });

  final BookLogic logic;
  final BookDetail bookDetail;
  final BookInfo bookInfo;
  final int bookId;
  final Book book;

  @override
  Widget build(BuildContext context) {
    final readSnapshot = resolveBookshelfReadSnapshot(logic, bookDetail);
    final updateResult = logic.state.updateResults[bookId];
    final isLocal =
        LocalBookConstants.isLocalBookSource(bookDetail.bookSourceId);
    final isPinned = book.customOrder > 0;
    final selectionMode = logic.state.isSelectionMode;
    final selected = logic.state.selectedIds.contains(bookId);
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () async {
        if (selectionMode) {
          logic.toggleSelection(bookId);
          return;
        }
        await openBookReadPage(
          logic: logic,
          bookDetail: bookDetail,
          bookInfo: bookInfo,
          currentChapterIndex: readSnapshot.currentChapterIndex,
          currentPageIndex: readSnapshot.currentPageIndex,
        );
      },
      onLongPress: () {
        if (selectionMode) {
          logic.toggleSelection(bookId);
          return;
        }
        showBookshelfItemActions(
          context: context,
          logic: logic,
          bookDetail: bookDetail,
          bookInfo: bookInfo,
          book: book,
          readSnapshot: readSnapshot,
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: RepaintBoundary(
              child: DecoratedBox(
                decoration: selected
                    ? BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: colorScheme.primary,
                          width: 2,
                        ),
                      )
                    : const BoxDecoration(),
                child: Stack(
                  children: [
                    GestureDetector(
                      onTap: selectionMode
                          ? () => logic.toggleSelection(bookId)
                          : () => openBookDetailPage(
                                logic: logic,
                                bookInfo: bookInfo,
                              ),
                      child: BookGridItemCover(
                        coverUrl: bookDetail.cover,
                        source: logic
                            .state.bookSourceCache[bookDetail.bookSourceId],
                      ),
                    ),
                    if (selectionMode)
                      Positioned(
                        top: 4,
                        left: 4,
                        child: Container(
                          decoration: BoxDecoration(
                            color: colorScheme.surface.withValues(alpha: 0.9),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            selected
                                ? Icons.check_circle_rounded
                                : Icons.circle_outlined,
                            size: 20,
                            color: selected
                                ? colorScheme.primary
                                : colorScheme.onSurface.withValues(alpha: 0.55),
                          ),
                        ),
                      ),
                    if (readSnapshot.unreadCount > 0)
                      Positioned(
                        top: 4,
                        right: 4,
                        child: _BookGridUnreadBadge(
                          count: readSnapshot.unreadCount,
                          hasReadBefore: readSnapshot.hasReadBefore,
                        ),
                      ),
                    if (updateResult != null &&
                        (updateResult.status == BookUpdateStatus.updating ||
                            updateResult.status == BookUpdateStatus.waiting ||
                            updateResult.status == BookUpdateStatus.failed ||
                            (updateResult.status == BookUpdateStatus.success &&
                                updateResult.newChapterCount > 0)))
                      Positioned(
                        left: 4,
                        top: selectionMode ? 28 : 4,
                        child: _GridUpdateBadge(result: updateResult),
                      ),
                    if (isPinned)
                      Positioned(
                        right: 4,
                        bottom: isLocal ? 22 : 4,
                        child: Icon(
                          Icons.push_pin_rounded,
                          size: 14,
                          color: colorScheme.primary,
                        ),
                      ),
                    if (isLocal)
                      Positioned(
                        left: 4,
                        bottom: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.surface.withValues(alpha: 0.88),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '本地',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            bookDetail.name ?? '',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  height: 1.15,
                ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            bookDetail.author?.trim().isNotEmpty == true
                ? bookDetail.author!
                : '未知作者',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: ColorUtils.getContrastSecondaryTextColor(
                    Theme.of(context).colorScheme.surface,
                  ),
                  height: 1.1,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _BookGridUnreadBadge extends StatelessWidget {
  const _BookGridUnreadBadge({
    required this.count,
    required this.hasReadBefore,
  });

  final int count;
  final bool hasReadBefore;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isHighlight = hasReadBefore && count > 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isHighlight
            ? colorScheme.error
            : colorScheme.onSurface.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$count',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: isHighlight ? colorScheme.onError : colorScheme.surface,
        ),
      ),
    );
  }
}

class _GridUpdateBadge extends StatelessWidget {
  const _GridUpdateBadge({required this.result});

  final BookUpdateResult result;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    late final String text;
    late final Color bg;
    late final Color fg;

    switch (result.status) {
      case BookUpdateStatus.waiting:
        text = '…';
        bg = colorScheme.surface.withValues(alpha: 0.88);
        fg = colorScheme.onSurface;
        break;
      case BookUpdateStatus.updating:
        text = '更';
        bg = colorScheme.primary.withValues(alpha: 0.92);
        fg = colorScheme.onPrimary;
        break;
      case BookUpdateStatus.success:
        text = '+${result.newChapterCount}';
        bg = colorScheme.error.withValues(alpha: 0.92);
        fg = colorScheme.onError;
        break;
      case BookUpdateStatus.failed:
        text = '!';
        bg = colorScheme.error.withValues(alpha: 0.92);
        fg = colorScheme.onError;
        break;
      case BookUpdateStatus.idle:
        return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: fg,
        ),
      ),
    );
  }
}
