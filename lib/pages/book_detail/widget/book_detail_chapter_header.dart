import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reader_nover/util/color_utils.dart';

import '../state.dart';

class BookDetailChapterHeader extends StatelessWidget {
  const BookDetailChapterHeader({
    super.key,
    required this.state,
    required this.onSortChapters,
  });

  final BookDetailState state;
  final VoidCallback onSortChapters;

  @override
  Widget build(BuildContext context) {
    final bgColor = context.theme.colorScheme.surface;
    final text = ColorUtils.getContrastTextColor(bgColor);
    final secondary = ColorUtils.getContrastSecondaryTextColor(bgColor);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                '章节列表',
                style: context.textTheme.titleMedium?.copyWith(
                  color: text,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              if (state.cachedChapterIndices.isNotEmpty)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.green.withValues(alpha: 0.3),
                      width: 0.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.cloud_done,
                        size: 13,
                        color: Colors.green.shade700,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${state.cachedChapterIndices.length}/${state.chapterInfo.length}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          Row(
            children: [
              Text(
                state.isAscending ? '正序' : '倒序',
                style: context.textTheme.labelSmall?.copyWith(color: secondary),
              ),
              IconButton(
                icon: Transform.rotate(
                  angle: state.isAscending ? 0 : 3.14,
                  child: Icon(Icons.sort, color: secondary),
                ),
                onPressed: onSortChapters,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
