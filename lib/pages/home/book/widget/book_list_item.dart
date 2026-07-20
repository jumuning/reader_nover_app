import 'package:flutter/material.dart';
import 'package:reader_nover/util/color_utils.dart';

import '../../../../app/database/drift/app_database.dart';
import '../../../../app/database/models/models.dart';
import '../../../../app/service/local_book/local_book_constants.dart';
import '../../../../util/gap.dart';
import '../logic.dart';
import '../state.dart';
import 'book_list_item_cover.dart';
import 'bookshelf_item_helpers.dart';

class BookListItem extends StatelessWidget {
  const BookListItem({
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
    final latestChapterName = bookDetail.lastChapter;
    final updateResult = logic.state.updateResults[bookId];
    final colorScheme = Theme.of(context).colorScheme;
    final secondaryColor = ColorUtils.getContrastSecondaryTextColor(
      colorScheme.surface,
    );
    final isLocal =
        LocalBookConstants.isLocalBookSource(bookDetail.bookSourceId);
    final isPinned = book.customOrder > 0;
    final selectionMode = logic.state.isSelectionMode;
    final selected = logic.state.selectedIds.contains(bookId);

    return Material(
      color: selected
          ? colorScheme.primaryContainer.withValues(alpha: 0.35)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
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
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (selectionMode)
                Padding(
                  padding: const EdgeInsets.only(right: 8, top: 28),
                  child: Checkbox(
                    value: selected,
                    onChanged: (_) => logic.toggleSelection(bookId),
                  ),
                ),
              RepaintBoundary(
                child: GestureDetector(
                  onTap: selectionMode
                      ? () => logic.toggleSelection(bookId)
                      : () => openBookDetailPage(
                            logic: logic,
                            bookInfo: bookInfo,
                          ),
                  child: Stack(
                    children: [
                      BookListItemCover(
                        coverUrl: bookDetail.cover,
                        source: logic
                            .state.bookSourceCache[bookDetail.bookSourceId],
                        width: 70,
                        height: 95,
                      ),
                      if (isPinned)
                        Positioned(
                          top: 0,
                          left: 12,
                          child: Icon(
                            Icons.push_pin_rounded,
                            size: 16,
                            color: colorScheme.primary,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const Gap.hn(),
              Expanded(
                child: SizedBox(
                  height: 95,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              bookDetail.name ?? '',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isLocal) ...[
                            const SizedBox(width: 6),
                            _LocalTag(color: secondaryColor),
                          ],
                        ],
                      ),
                      Text(
                        bookDetail.author?.trim().isNotEmpty == true
                            ? bookDetail.author!
                            : '未知作者',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: secondaryColor,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      _MetaLine(
                        label: '在读',
                        value: readSnapshot.currentChapterName ?? '尚未阅读',
                        color: secondaryColor,
                      ),
                      _MetaLine(
                        label: '最新',
                        value: latestChapterName ?? '暂无更新',
                        color: secondaryColor,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _BookListUnreadBadge(
                    count: readSnapshot.unreadCount,
                    hasReadBefore: readSnapshot.hasReadBefore,
                  ),
                  if (updateResult != null &&
                      updateResult.status != BookUpdateStatus.idle) ...[
                    const SizedBox(height: 6),
                    _UpdateStatusChip(result: updateResult),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LocalTag extends StatelessWidget {
  const _LocalTag({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '本地',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _MetaLine extends StatelessWidget {
  const _MetaLine({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(3),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 10,
              height: 1.1,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: color,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _BookListUnreadBadge extends StatelessWidget {
  const _BookListUnreadBadge({
    required this.count,
    required this.hasReadBefore,
  });

  final int count;
  final bool hasReadBefore;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isHighlight = hasReadBefore && count > 0;
    final secondaryColor = ColorUtils.getContrastSecondaryTextColor(
      colorScheme.surface,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isHighlight
            ? colorScheme.error
            : secondaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$count',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: isHighlight ? colorScheme.onError : secondaryColor,
        ),
      ),
    );
  }
}

class _UpdateStatusChip extends StatelessWidget {
  const _UpdateStatusChip({required this.result});

  final BookUpdateResult result;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    late final String text;
    late final Color bg;
    late final Color fg;

    switch (result.status) {
      case BookUpdateStatus.waiting:
        text = '等待';
        bg = colorScheme.surfaceContainerHighest;
        fg = colorScheme.onSurfaceVariant;
        break;
      case BookUpdateStatus.updating:
        text = '更新中';
        bg = colorScheme.primaryContainer;
        fg = colorScheme.onPrimaryContainer;
        break;
      case BookUpdateStatus.success:
        if (result.newChapterCount > 0) {
          text = '+${result.newChapterCount}';
          bg = colorScheme.errorContainer;
          fg = colorScheme.onErrorContainer;
        } else {
          text = '无更新';
          bg = colorScheme.surfaceContainerHighest;
          fg = colorScheme.onSurfaceVariant;
        }
        break;
      case BookUpdateStatus.failed:
        text = '失败';
        bg = colorScheme.error.withValues(alpha: 0.12);
        fg = colorScheme.error;
        break;
      case BookUpdateStatus.idle:
        return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }
}
