import 'package:flutter/material.dart';
import 'package:reader_nover/app/database/drift/app_database.dart' as db;
import 'package:reader_nover/pages/common/decoded_network_image.dart';

import '../state.dart';

/// 竖向封面卡片（紧凑）：封面 + 单行书名/作者。
class StoreDetailBookItem extends StatelessWidget {
  const StoreDetailBookItem({
    super.key,
    required this.book,
    required this.onTap,
    required this.source,
  });

  /// 与网格 [childAspectRatio] 计算共用，避免文字区撑爆导致 RenderFlex overflow。
  static const double textBlockHeight = 36;

  final BookItem book;
  final VoidCallback onTap;
  final db.BookSource source;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: book.cover != null && book.cover!.trim().isNotEmpty
                        ? SizedBox.expand(
                            child: _StoreCoverImage(
                              coverUrl: book.cover!,
                              source: source,
                            ),
                          )
                        : const _StoreDetailCoverPlaceholder(),
                  ),
                  if (book.inShelf)
                    Positioned(
                      top: 4,
                      left: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.tertiaryContainer
                              .withValues(alpha: 0.92),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '在架',
                          style: textTheme.labelSmall?.copyWith(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            height: 1.1,
                            color: colorScheme.onTertiaryContainer,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(
              height: textBlockHeight,
              child: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      book.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall?.copyWith(
                        fontSize: 12,
                        height: 1.15,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    if (book.author != null && book.author!.trim().isNotEmpty)
                      Text(
                        book.author!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.labelSmall?.copyWith(
                          fontSize: 10.5,
                          height: 1.15,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StoreCoverImage extends StatelessWidget {
  const _StoreCoverImage({
    required this.coverUrl,
    required this.source,
  });

  final String coverUrl;
  final db.BookSource source;

  @override
  Widget build(BuildContext context) {
    const placeholder = _StoreDetailCoverPlaceholder();
    return DecodedCoverImage(
      imageUrl: coverUrl,
      source: source,
      fit: BoxFit.cover,
      placeholder: placeholder,
      errorWidget: placeholder,
    );
  }
}

class _StoreDetailCoverPlaceholder extends StatelessWidget {
  const _StoreDetailCoverPlaceholder();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ColoredBox(
      color: colorScheme.surfaceContainerHighest,
      child: Center(
        child: Icon(
          Icons.auto_stories_outlined,
          size: 22,
          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
        ),
      ),
    );
  }
}
