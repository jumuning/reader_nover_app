import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../app/database/models/models.dart' show BookInfo;
import '../../../../../app/routes/app_routes.dart';
import '../../../../../app/routes/route_args.dart';
import '../logic.dart';
import '../state.dart';
import 'store_detail_book_item.dart';

/// 竖封面网格：手机端偏紧凑（约 3 列），封面 3:4 + 单行书名/作者。
class StoreDetailBookGrid extends StatelessWidget {
  const StoreDetailBookGrid({
    super.key,
    required this.logic,
  });

  final StoreDetailLogic logic;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
      sliver: SliverLayoutBuilder(
        builder: (context, constraints) {
          final maxWidth = constraints.crossAxisExtent;
          // 手机约 360 宽 → 3 列；再宽再增列。目标卡片宽 ~96–108。
          final crossAxisCount = (maxWidth / 100).floor().clamp(3, 6);
          const crossAxisSpacing = 8.0;
          const mainAxisSpacing = 10.0;
          final itemWidth =
              (maxWidth - crossAxisSpacing * (crossAxisCount - 1)) /
                  crossAxisCount;
          // 封面略扁于 3:4，整体更小；文字区与 [StoreDetailBookItem.textBlockHeight] 一致。
          final coverHeight = itemWidth * 1.28;
          final itemHeight =
              coverHeight + StoreDetailBookItem.textBlockHeight;
          final childAspectRatio = itemWidth / itemHeight;

          return SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: crossAxisSpacing,
              mainAxisSpacing: mainAxisSpacing,
              childAspectRatio: childAspectRatio,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final book = logic.state.books[index];
                return StoreDetailBookItem(
                  book: book,
                  source: logic.source,
                  onTap: () => _openBookDetail(book),
                );
              },
              childCount: logic.state.books.length,
            ),
          );
        },
      ),
    );
  }

  void _openBookDetail(BookItem book) {
    final bookInfo = BookInfo(
      bookSourceId: book.bookSourceId,
      name: book.name,
      author: book.author,
      cover: book.cover,
      intro: book.intro,
      kind: book.kind,
      lastChapter: book.lastChapter,
      bookUrl: book.bookUrl,
    );
    Get.toNamed(
      AppRoutes.bookDetail,
      arguments: BookDetailArgs(bookInfo: bookInfo),
    );
  }
}
