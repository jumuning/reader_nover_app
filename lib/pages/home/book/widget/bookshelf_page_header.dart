import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../app/routes/route_args.dart';
import '../logic.dart';
import '../state.dart';
import 'bookshelf_bottom_sheet.dart';

class BookshelfPageHeader extends StatefulWidget {
  const BookshelfPageHeader({
    super.key,
    required this.logic,
  });

  final BookLogic logic;

  @override
  State<BookshelfPageHeader> createState() => _BookshelfPageHeaderState();
}

class _BookshelfPageHeaderState extends State<BookshelfPageHeader> {
  late final TextEditingController _searchController;
  bool _showSearch = false;

  BookLogic get logic => widget.logic;
  BookState get state => logic.state;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: state.shelfQuery);
    _showSearch = state.shelfQuery.trim().isNotEmpty;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // 外部状态驱动搜索框显隐（如清空筛选）
    if (state.shelfQuery.isEmpty &&
        _searchController.text.isNotEmpty &&
        !_showSearch) {
      _searchController.clear();
    }

    if (state.isSelectionMode) {
      return _buildSelectionHeader(context);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  const Text(
                    '书架',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (state.isUpdating) ...[
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        value: state.updateProgress > 0
                            ? state.updateProgress
                            : null,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      state.totalUpdateCount > 0
                          ? '${state.updatedCount}/${state.totalUpdateCount}'
                          : '更新中',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurface.withValues(alpha: 0.55),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                logic.currentLayout == BookshelfLayout.list
                    ? Icons.grid_view_rounded
                    : Icons.view_list_rounded,
                size: 20,
              ),
              onPressed: logic.toggleLayout,
              tooltip: logic.currentLayout == BookshelfLayout.list
                  ? '切换网格视图'
                  : '切换列表视图',
            ),
            IconButton(
              icon: Icon(
                _showSearch
                    ? Icons.search_off_rounded
                    : Icons.filter_list_rounded,
                size: 20,
              ),
              tooltip: _showSearch ? '收起筛选' : '架内筛选',
              onPressed: () {
                setState(() {
                  _showSearch = !_showSearch;
                  if (!_showSearch) {
                    _searchController.clear();
                    logic.setShelfQuery('');
                  }
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.search_rounded, size: 20),
              tooltip: '搜索网络书籍',
              onPressed: () {
                Get.toNamed(
                  AppRoutes.bookSearch,
                  arguments: BookSearchArgs(
                    onRefreshBookshelf: logic.refreshBooks,
                  ),
                );
              },
            ),
            PopupMenuButton<String>(
              tooltip: '更多',
              icon: const Icon(Icons.more_vert_rounded, size: 20),
              onSelected: (value) async {
                switch (value) {
                  case 'update':
                    if (state.isUpdating) {
                      logic.cancelUpdate();
                    } else {
                      logic.updateAllBooks();
                    }
                    break;
                  case 'import':
                    logic.importLocalBook();
                    break;
                  case 'sort':
                    await _showSortSheet(context);
                    break;
                  case 'batch':
                    logic.enterSelectionMode();
                    break;
                }
              },
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: 'update',
                  child: ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      state.isUpdating
                          ? Icons.stop_rounded
                          : Icons.sync_rounded,
                      size: 20,
                    ),
                    title: Text(state.isUpdating ? '取消更新' : '更新目录'),
                  ),
                ),
                const PopupMenuItem(
                  value: 'import',
                  child: ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.upload_file_rounded, size: 20),
                    title: Text('导入本地书籍'),
                  ),
                ),
                PopupMenuItem(
                  value: 'sort',
                  child: ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.sort_rounded, size: 20),
                    title: Text('排序：${state.sortMode.label}'),
                  ),
                ),
                const PopupMenuItem(
                  value: 'batch',
                  child: ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.checklist_rounded, size: 20),
                    title: Text('批量管理'),
                  ),
                ),
              ],
            ),
          ],
        ),
        if (_showSearch) ...[
          const SizedBox(height: 8),
          TextField(
            controller: _searchController,
            onChanged: (v) {
              logic.setShelfQuery(v);
              setState(() {});
            },
            decoration: InputDecoration(
              hintText: '在书架中筛选书名 / 作者',
              isDense: true,
              filled: true,
              fillColor:
                  colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
              prefixIcon: const Icon(Icons.filter_list_rounded, size: 18),
              suffixIcon: _searchController.text.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        logic.setShelfQuery('');
                        setState(() {});
                      },
                    ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
          const SizedBox(height: 8),
          _TypeFilterChips(
            current: state.typeFilter,
            onChanged: logic.setTypeFilter,
          ),
        ],
      ],
    );
  }

  Widget _buildSelectionHeader(BuildContext context) {
    final selected = state.selectedIds.length;
    final visible = state.displayBooks.length;
    final allSelected = visible > 0 && selected == visible;

    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.close_rounded),
          tooltip: '退出批量',
          onPressed: logic.exitSelectionMode,
        ),
        Expanded(
          child: Text(
            '已选 $selected',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        TextButton(
          onPressed: () {
            if (allSelected) {
              logic.clearSelectionKeepMode();
            } else {
              logic.selectAllVisible();
            }
          },
          child: Text(allSelected ? '取消全选' : '全选'),
        ),
      ],
    );
  }

  Future<void> _showSortSheet(BuildContext context) async {
    final selected = await showBookshelfBottomSheet<BookshelfSortMode>(
      child: BookshelfBottomSheetShell(
        title: '排序方式',
        icon: Icons.sort_rounded,
        children: BookshelfSortMode.values
            .map(
              (mode) => BookshelfSheetOption(
                icon: mode.icon,
                label: mode.label,
                selected: mode == logic.state.sortMode,
                onTap: () => Get.back(result: mode),
              ),
            )
            .toList(),
      ),
    );
    if (selected != null && selected != logic.state.sortMode) {
      logic.changeSortMode(selected);
    }
  }
}

class _TypeFilterChips extends StatelessWidget {
  const _TypeFilterChips({
    required this.current,
    required this.onChanged,
  });

  final BookshelfTypeFilter current;
  final ValueChanged<BookshelfTypeFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: BookshelfTypeFilter.values.map((filter) {
        final selected = filter == current;
        return ChoiceChip(
          label: Text(filter.label),
          selected: selected,
          onSelected: (_) => onChanged(filter),
          visualDensity: VisualDensity.compact,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        );
      }).toList(),
    );
  }
}

extension on BookshelfSortMode {
  IconData get icon {
    switch (this) {
      case BookshelfSortMode.recentRead:
        return Icons.history_rounded;
      case BookshelfSortMode.latestAdded:
        return Icons.library_add_check_rounded;
      case BookshelfSortMode.title:
        return Icons.drive_file_rename_outline_rounded;
      case BookshelfSortMode.author:
        return Icons.person_outline_rounded;
    }
  }
}
