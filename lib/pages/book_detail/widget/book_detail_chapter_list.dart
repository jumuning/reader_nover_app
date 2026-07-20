import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:reader_nover/app/database/models/models.dart';
import 'package:reader_nover/util/gap.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../state.dart';

class BookDetailChapterList extends StatelessWidget {
  const BookDetailChapterList({
    super.key,
    required this.state,
    required this.onRetry,
    required this.onChapterTap,
  });

  final BookDetailState state;
  final VoidCallback onRetry;
  final Future<void> Function(BookChapterInfo chapter) onChapterTap;

  @override
  Widget build(BuildContext context) {
    if (state.isChapterLoadError) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 48,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.3),
            ),
            const Gap.vn(),
            Text(
              '章节加载失败',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.5),
                  ),
            ),
            const Gap.vn(),
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('重试'),
            ),
          ],
        ),
      );
    }

    if (state.displayedChapters.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final theme = Theme.of(context);
    state.updateChapterListColors(theme.colorScheme.surface);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: ScrollablePositionedList.builder(
        key: ValueKey(state.isAscending),
        itemScrollController: state.itemScrollController,
        itemPositionsListener: state.itemPositionsListener,
        initialScrollIndex: _getInitialScrollIndex(state),
        itemCount: state.displayedChapters.length,
        itemBuilder: (context, index) {
          final chapter = state.displayedChapters[index];
          final isCurrent =
              chapter.chapterIndex == state.currentReadChapterIndex;
          final isRead =
              state.readChapterIndices.contains(chapter.chapterIndex);
          final isCached =
              state.cachedChapterIndices.contains(chapter.chapterIndex);

          return InkWell(
            onTap: () {
              HapticFeedback.selectionClick();
              onChapterTap(chapter);
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: isCurrent ? Colors.blue.withValues(alpha: 0.08) : null,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isCurrent
                          ? Colors.blue.withValues(alpha: 0.15)
                          : (isCached
                              ? Colors.green.withValues(alpha: 0.12)
                              : Colors.transparent),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      isCurrent
                          ? Icons.my_location_sharp
                          : (isCached
                              ? Icons.cloud_done
                              : Icons.cloud_download),
                      size: 18,
                      color: isCurrent
                          ? Colors.blue
                          : (isCached
                              ? Colors.green.shade700
                              : (isRead
                                  ? state.chapterListSecondaryTextColor
                                      .withValues(alpha: 0.7)
                                  : state.chapterListSecondaryTextColor)),
                    ),
                  ),
                  const Gap.h(value: 12),
                  Expanded(
                    child: Text(
                      chapter.chapterName ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight:
                            isCurrent ? FontWeight.w600 : FontWeight.normal,
                        color: isCurrent
                            ? Colors.blue
                            : (isCached
                                ? state.chapterListTextColor
                                : (isRead
                                    ? state.chapterListSecondaryTextColor
                                    : state.chapterListTextColor)),
                      ),
                    ),
                  ),
                  if (isCurrent)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        '上次',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

int _getInitialScrollIndex(BookDetailState state) {
  if (!state.isAscending) return 0;
  if (state.currentReadChapterIndex == null) return 0;
  final index = state.displayedChapters.indexWhere(
    (chapter) => chapter.chapterIndex == state.currentReadChapterIndex,
  );
  return index < 0 ? 0 : index;
}
