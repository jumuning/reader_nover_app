import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/database/drift/app_database.dart';
import '../../../app/routes/app_routes.dart';
import '../../../app/routes/route_args.dart';
import '../../common/app_empty_state.dart';
import '../logic.dart';
import 'logic.dart';
import 'state.dart';
import 'widget/book_grid_item.dart';
import 'widget/book_list_item.dart';
import 'widget/bookshelf_page_header.dart';
import 'widget/bookshelf_selection_bar.dart';

class BookPage extends StatelessWidget {
  const BookPage({
    super.key,
    required this.logic,
  });

  final BookLogic logic;

  BookState get state => logic.state;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BookLogic>(
      builder: (logic) {
        return Column(
          children: [
            BookshelfPageHeader(logic: logic),
            Expanded(
              child: RepaintBoundary(
                child: state.myBooks.isEmpty
                    ? _buildEmpty(context)
                    : _buildContent(context),
              ),
            ),
            if (state.isSelectionMode) BookshelfSelectionBar(logic: logic),
          ],
        );
      },
    );
  }

  Widget _buildContent(BuildContext context) {
    final books = state.displayBooks;
    final hasFilter = state.shelfQuery.trim().isNotEmpty ||
        state.typeFilter != BookshelfTypeFilter.all ||
        state.filterNewChaptersOnly;

    if (books.isEmpty) {
      return AppEmptyState(
        icon: hasFilter
            ? Icons.filter_alt_off_rounded
            : Icons.menu_book_outlined,
        title: hasFilter ? '没有匹配的书' : '书架还是空的',
        subtitle: hasFilter
            ? '试试调整筛选条件'
            : '搜索网络书籍、逛逛书城，或导入本地 txt',
        actions: [
          if (hasFilter)
            FilledButton.tonal(
              onPressed: () {
                logic.setShelfQuery('');
                logic.setTypeFilter(BookshelfTypeFilter.all);
                logic.setFilterNewChaptersOnly(false);
              },
              child: const Text('清除筛选'),
            )
          else ...[
            FilledButton.tonalIcon(
              onPressed: () {
                Get.toNamed(
                  AppRoutes.bookSearch,
                  arguments: BookSearchArgs(
                    onRefreshBookshelf: logic.refreshBooks,
                  ),
                );
              },
              icon: const Icon(Icons.search_rounded, size: 18),
              label: const Text('搜索'),
            ),
          ],
        ],
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await logic.refreshBooks();
        await logic.refreshReadProgress();
      },
      child: logic.currentLayout == BookshelfLayout.list
          ? _buildListView(books)
          : _buildGridView(books),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return AppEmptyState(
      icon: Icons.menu_book_outlined,
      title: '书架还是空的',
      subtitle: '搜索网络书籍、逛逛书城，或导入本地 txt',
      actions: [
        FilledButton.tonalIcon(
          onPressed: () {
            Get.toNamed(
              AppRoutes.bookSearch,
              arguments: BookSearchArgs(
                onRefreshBookshelf: logic.refreshBooks,
              ),
            );
          },
          icon: const Icon(Icons.search_rounded, size: 18),
          label: const Text('搜索'),
        ),
        OutlinedButton.icon(
          onPressed: () {
            if (Get.isRegistered<HomeLogic>()) {
              Get.find<HomeLogic>().changePageIndex(1);
            }
          },
          icon: const Icon(Icons.storefront_outlined, size: 18),
          label: const Text('书城'),
        ),
        OutlinedButton.icon(
          onPressed: logic.importLocalBook,
          icon: const Icon(Icons.upload_file_rounded, size: 18),
          label: const Text('导入'),
        ),
      ],
    );
  }

  Widget _buildListView(List<Book> books) {
    return ListView.builder(
      key: const PageStorageKey<String>('bookshelf-list'),
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.only(bottom: state.isSelectionMode ? 8 : 16),
      itemCount: books.length,
      itemBuilder: (context, index) {
        final book = books[index];
        final bookDetail = state.bookDetailCache[book.id];
        final bookInfo = state.bookInfoCache[book.id];

        if (bookDetail == null || bookInfo == null) {
          return const _BookshelfItemPlaceholder(isGrid: false);
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: BookListItem(
            logic: logic,
            bookDetail: bookDetail,
            bookInfo: bookInfo,
            bookId: book.id,
            book: book,
          ),
        );
      },
    );
  }

  Widget _buildGridView(List<Book> books) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 按宽度自适应列数与宽高比，减少标题裁切
        final width = constraints.maxWidth;
        final crossAxisCount = width < 360
            ? 3
            : width < 520
                ? 4
                : width < 720
                    ? 5
                    : 6;
        // 封面约 1.4 高宽比 + 下方两行文字
        final childAspectRatio = width < 360 ? 0.52 : 0.58;

        return GridView.builder(
          key: const PageStorageKey<String>('bookshelf-grid'),
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.only(
            top: 8,
            bottom: state.isSelectionMode ? 8 : 24,
          ),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: childAspectRatio,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: books.length,
          itemBuilder: (context, index) {
            final book = books[index];
            final bookDetail = state.bookDetailCache[book.id];
            final bookInfo = state.bookInfoCache[book.id];

            if (bookDetail == null || bookInfo == null) {
              return const _BookshelfItemPlaceholder(isGrid: true);
            }

            return BookGridItem(
              logic: logic,
              bookDetail: bookDetail,
              bookInfo: bookInfo,
              bookId: book.id,
              book: book,
            );
          },
        );
      },
    );
  }
}

class _BookshelfItemPlaceholder extends StatelessWidget {
  const _BookshelfItemPlaceholder({required this.isGrid});

  final bool isGrid;

  @override
  Widget build(BuildContext context) {
    final color =
        Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08);
    if (isGrid) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Container(height: 12, width: double.infinity, color: color),
          const SizedBox(height: 4),
          Container(height: 10, width: 48, color: color),
        ],
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 95,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height: 16, width: 140, color: color),
                const SizedBox(height: 10),
                Container(height: 12, width: 100, color: color),
                const SizedBox(height: 8),
                Container(height: 12, width: 160, color: color),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
