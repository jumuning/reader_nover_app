import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reader_nover/util/book_help.dart';
import 'package:reader_nover/util/color_utils.dart';
import 'package:reader_nover/util/gap.dart';

import '../state.dart';

const _typeLabelPadding = EdgeInsets.symmetric(horizontal: 10, vertical: 5);
const _typeLabelRadius = BorderRadius.all(Radius.circular(16));

class BookDetailIntroSection extends StatelessWidget {
  const BookDetailIntroSection({
    super.key,
    required this.state,
    required this.onToggleExpanded,
    required this.onChangeSource,
  });

  final BookDetailState state;
  final VoidCallback onToggleExpanded;
  final VoidCallback onChangeSource;

  @override
  Widget build(BuildContext context) {
    final bgColor = context.theme.colorScheme.surface;
    final secondary = ColorUtils.getContrastSecondaryTextColor(bgColor);
    final introText = BookHelp.formatIntro(state.bookDetail.intro);
    final introDisplay = introText.isEmpty ? '暂无简介' : introText;

    return Container(
      color: bgColor,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ...(state.bookDetail.kind ?? [])
                        .map((value) => _BookDetailTypeLabel(label: value)),
                    if (state.bookDetail.wordCount != null)
                      _BookDetailTypeLabel(
                        label: '${state.bookDetail.wordCount}',
                      ),
                  ],
                ),
              ),
              if (state.bookSource != null)
                GestureDetector(
                  onTap: state.isLocalBook ? null : onChangeSource,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.link_rounded,
                        size: 16,
                        color: secondary.withValues(alpha: 0.6),
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: _BookDetailTypeLabel(
                          label: '源站：${state.bookSource!.bookSourceName}',
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const Gap.vn(),
          GestureDetector(
            onTap: onToggleExpanded,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  introDisplay,
                  maxLines: state.isIntroExpanded ? null : 3,
                  overflow: state.isIntroExpanded
                      ? TextOverflow.visible
                      : TextOverflow.ellipsis,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: secondary,
                  ),
                ),
                const Gap.vn(),
                Center(
                  child: Text(
                    state.isIntroExpanded ? '收起 ▲' : '展开 ▼',
                    style: context.textTheme.labelSmall?.copyWith(
                      color: secondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BookDetailTypeLabel extends StatelessWidget {
  const _BookDetailTypeLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final color = ColorUtils.readableRandomColorByStr(
      label,
      context.theme.colorScheme.surface,
    );
    return Container(
      padding: _typeLabelPadding,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: _typeLabelRadius,
      ),
      child: Text(
        label,
        style: context.textTheme.labelSmall?.copyWith(color: color),
      ),
    );
  }
}
