import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reader_nover/app/constants/assets.dart';
import 'package:reader_nover/pages/common/decoded_network_image.dart';
import 'package:reader_nover/util/gap.dart';

import '../state.dart';

class BookDetailHeader extends StatelessWidget {
  const BookDetailHeader({
    super.key,
    required this.state,
    required this.statusBarHeight,
  });

  final BookDetailState state;
  final double statusBarHeight;

  @override
  Widget build(BuildContext context) {
    const double coverHeight = 160;
    const double coverWidth = 100;
    const double cardRadius = 16;
    final double headerHeight = statusBarHeight + coverHeight;
    final surfaceColor = context.theme.colorScheme.surface;
    final onSurface = context.theme.colorScheme.onSurface;

    return SizedBox(
      height: headerHeight,
      width: double.infinity,
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRect(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  DecodedCoverImage(
                    imageUrl: state.bookInfo.cover ?? Assets.defaultBook,
                    source: state.bookSource,
                    fit: BoxFit.cover,
                    errorWidget: Container(color: surfaceColor),
                  ),
                  BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: 24,
                      sigmaY: 24,
                    ),
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.15),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: statusBarHeight + 8,
            child: Stack(
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(56, 16, 16, 16),
                  decoration: BoxDecoration(
                    color: surfaceColor.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(cardRadius),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.18),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: coverWidth,
                        height: coverHeight - 32,
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.25),
                              blurRadius: 14,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: DecodedCoverImage(
                          imageUrl: state.bookInfo.cover ?? Assets.defaultBook,
                          source: state.bookSource,
                          fit: BoxFit.cover,
                          errorWidget: Image.asset(
                            Assets.defaultBook,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const Gap.h(value: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              state.bookInfo.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: context.textTheme.titleLarge?.copyWith(
                                color: onSurface,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Gap.vn(),
                            Text(
                              '作者：${_normalizeAuthor(state.bookInfo.author)}',
                              style: context.textTheme.labelSmall?.copyWith(
                                color: onSurface.withValues(alpha: 0.7),
                              ),
                            ),
                            const Gap.vn(),
                            Text(
                              '最新章节：${state.bookDetail.lastChapter}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: context.textTheme.labelSmall?.copyWith(
                                color: onSurface.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  child: Material(
                    color: surfaceColor.withValues(alpha: 0.7),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(cardRadius),
                      bottomRight: Radius.circular(cardRadius),
                    ),
                    child: InkWell(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(cardRadius),
                        bottomRight: Radius.circular(cardRadius),
                      ),
                      onTap: Get.back,
                      child: SizedBox(
                        width: 48,
                        height: 48,
                        child: Icon(
                          Icons.arrow_back_ios_new,
                          size: 18,
                          color: onSurface,
                        ),
                      ),
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

String _normalizeAuthor(String? author) {
  final normalized =
      author?.trim().replaceFirst(RegExp(r'^(?:作者\s*[：:]?\s*)+'), '');
  return normalized?.isNotEmpty == true ? normalized! : '未知';
}
