import 'package:flutter/material.dart';

import '../logic.dart';
import '../state.dart';

/// 书源页顶栏：标题 + 添加 + 更多；批量模式仅关闭与全选。
class SourcePageAppBar extends StatelessWidget implements PreferredSizeWidget {
  const SourcePageAppBar({
    super.key,
    required this.logic,
    required this.state,
    required this.onShowSortDialog,
    required this.onShowCheckConfigDialog,
    required this.onShowGroupManageDialog,
  });

  final SourceLogic logic;
  final SourceState state;
  final VoidCallback onShowSortDialog;
  final VoidCallback onShowCheckConfigDialog;
  final VoidCallback onShowGroupManageDialog;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: false,
      titleSpacing: 16,
      title: AnimatedSwitcher(
        duration: const Duration(milliseconds: 180),
        child: state.isSelectionMode
            ? Text(
                '已选 ${state.selectedIds.length}',
                key: const ValueKey('selection'),
                style: const TextStyle(fontWeight: FontWeight.w600),
              )
            : const Text(
                '书源',
                key: ValueKey('normal'),
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
      ),
      leading: state.isSelectionMode
          ? IconButton(
              icon: const Icon(Icons.close_rounded),
              tooltip: '退出批量',
              onPressed: logic.toggleSelectionMode,
            )
          : null,
      actions: state.isSelectionMode
          ? _buildSelectionActions(context)
          : _buildNormalActions(context),
    );
  }

  List<Widget> _buildNormalActions(BuildContext context) {
    final searching = state.isSearchBarVisible ||
        state.searchKeyword.trim().isNotEmpty ||
        (state.groupFilter?.trim().isNotEmpty ?? false);
    return [
      IconButton(
        icon: Icon(
          searching ? Icons.search_off_rounded : Icons.search_rounded,
        ),
        tooltip: searching ? '关闭搜索' : '搜索书源',
        onPressed: logic.toggleSearchBar,
      ),
      IconButton(
        icon: const Icon(Icons.add_circle_outline_rounded),
        tooltip: '添加书源',
        onPressed: logic.urlImport,
      ),
      PopupMenuButton<String>(
        tooltip: '更多',
        icon: const Icon(Icons.more_vert_rounded),
        onSelected: (value) {
          switch (value) {
            case 'sort':
              onShowSortDialog();
              break;
            case 'qr_import':
              logic.scanQrCodeImport();
              break;
            case 'url_import':
              logic.urlImport();
              break;
            case 'select_mode':
              logic.toggleSelectionMode();
              break;
            case 'check_config':
              onShowCheckConfigDialog();
              break;
            case 'group_manage':
              onShowGroupManageDialog();
              break;
            case 'refresh':
              logic.refreshSources();
              break;
            default:
              logic.handleMenuAction(value);
          }
        },
        itemBuilder: (context) {
          final muted = Theme.of(context).colorScheme.onSurfaceVariant;
          return [
            PopupMenuItem(
              enabled: false,
              height: 32,
              child: Text(
                '校验',
                style: TextStyle(fontSize: 12, color: muted),
              ),
            ),
            const PopupMenuItem(
              value: 'check_config',
              child: ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.tune_rounded, size: 20),
                title: Text('校验设置'),
              ),
            ),
            const PopupMenuItem(
              value: 'export_check_diagnostics',
              child: ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.bug_report_outlined, size: 20),
                title: Text('导出校验诊断'),
              ),
            ),
            const PopupMenuDivider(),
            PopupMenuItem(
              enabled: false,
              height: 32,
              child: Text(
                '导入导出',
                style: TextStyle(fontSize: 12, color: muted),
              ),
            ),
            const PopupMenuItem(
              value: 'url_import',
              child: ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.link_rounded, size: 20),
                title: Text('网址导入'),
              ),
            ),
            const PopupMenuItem(
              value: 'qr_import',
              child: ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.qr_code_scanner_rounded, size: 20),
                title: Text('扫码导入'),
              ),
            ),
            const PopupMenuItem(
              value: 'import',
              child: ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.file_upload_outlined, size: 20),
                title: Text('导入书源'),
              ),
            ),
            const PopupMenuItem(
              value: 'export',
              child: ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.file_download_outlined, size: 20),
                title: Text('导出书源'),
              ),
            ),
            const PopupMenuDivider(),
            PopupMenuItem(
              enabled: false,
              height: 32,
              child: Text(
                '管理',
                style: TextStyle(fontSize: 12, color: muted),
              ),
            ),
            const PopupMenuItem(
              value: 'group_manage',
              child: ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.folder_outlined, size: 20),
                title: Text('分组管理'),
              ),
            ),
            const PopupMenuItem(
              value: 'select_mode',
              child: ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.checklist_rounded, size: 20),
                title: Text('批量管理'),
              ),
            ),
            const PopupMenuItem(
              value: 'sort',
              child: ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.sort_rounded, size: 20),
                title: Text('排序'),
              ),
            ),
            const PopupMenuItem(
              value: 'refresh',
              child: ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.refresh_rounded, size: 20),
                title: Text('刷新'),
              ),
            ),
          ];
        },
      ),
    ];
  }

  List<Widget> _buildSelectionActions(BuildContext context) {
    final hasSelection = state.selectedIds.isNotEmpty;
    final isAllSelected = state.showSources.isNotEmpty &&
        state.selectedIds.length == state.showSources.length;
    return [
      TextButton(
        onPressed: () {
          if (isAllSelected) {
            logic.clearSelection();
          } else {
            logic.selectAll();
          }
        },
        child: Text(isAllSelected ? '取消全选' : '全选'),
      ),
      IconButton(
        icon: const Icon(Icons.speed_rounded),
        tooltip: '校验所选',
        onPressed: hasSelection ? logic.testSelectedSources : null,
      ),
    ];
  }
}

/// 全部 / 启用 / 禁用 分段筛选。
class SourceFilterSegment extends StatelessWidget {
  const SourceFilterSegment({
    super.key,
    required this.state,
    required this.onChanged,
  });

  final SourceState state;
  final ValueChanged<ShowType> onChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Row(
            children: [
              _Segment(
                label: '全部',
                count: state.allSources.length,
                selected: state.showType == ShowType.all,
                onTap: () => onChanged(ShowType.all),
              ),
              _Segment(
                label: '启用',
                count: state.enabledSources.length,
                selected: state.showType == ShowType.enabled,
                onTap: () => onChanged(ShowType.enabled),
              ),
              _Segment(
                label: '禁用',
                count: state.disabledSources.length,
                selected: state.showType == ShowType.disabled,
                onTap: () => onChanged(ShowType.disabled),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Expanded(
      child: Material(
        color: selected ? colorScheme.surface : Colors.transparent,
        elevation: selected ? 1 : 0,
        shadowColor: Colors.black.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(9),
        child: InkWell(
          borderRadius: BorderRadius.circular(9),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected
                        ? colorScheme.primary
                        : colorScheme.onSurface.withValues(alpha: 0.62),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: selected
                        ? colorScheme.primary.withValues(alpha: 0.85)
                        : colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
