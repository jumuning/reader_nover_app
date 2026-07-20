import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../logic.dart';
import '../state.dart';

void showSourceDeleteConfirmDialog({
  required SourceLogic logic,
  required int count,
}) {
  Get.dialog(
    AlertDialog(
      title: const Text('确认删除'),
      content: Text('确定删除选中的 $count 个书源吗？此操作不可恢复。'),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('取消')),
        TextButton(
          onPressed: () {
            Get.back();
            logic.deleteSelected();
            logic.toggleSelectionMode();
          },
          child: const Text('删除', style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );
}

void showSourceSortDialog({
  required SourceLogic logic,
  required SortType selectedType,
}) {
  Get.dialog(
    Align(
      alignment: Alignment.bottomCenter,
      child: FractionallySizedBox(
        widthFactor: 1,
        child: _SourceSortSheet(
          logic: logic,
          selectedType: selectedType,
        ),
      ),
    ),
    barrierColor: Colors.black54,
    barrierDismissible: true,
    useSafeArea: false,
  );
}

void showSourceGroupManageDialog(
  SourceLogic logic,
) {
  Get.dialog(
    Align(
      alignment: Alignment.bottomCenter,
      child: FractionallySizedBox(
        widthFactor: 1,
        child: _SourceGroupManageSheet(logic: logic),
      ),
    ),
    barrierColor: Colors.black54,
    barrierDismissible: true,
    useSafeArea: false,
  );
}

void showSourceSelectionGroupDialog(
  SourceLogic logic, {
  required bool isAdd,
}) {
  final controller = TextEditingController();
  final groups = logic.getGroupInfos().where((item) => !item.isUngrouped);

  Get.dialog(
    AlertDialog(
      title: Text(isAdd ? '加入分组' : '移出分组'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: '分组名称',
              prefixIcon: Icon(Icons.folder_outlined),
            ),
            onSubmitted: (_) => _submitSelectionGroupDialog(
              logic: logic,
              controller: controller,
              isAdd: isAdd,
            ),
          ),
          if (groups.isNotEmpty) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final group in groups)
                    ActionChip(
                      label: Text(group.name),
                      onPressed: () {
                        controller.text = group.name;
                        controller.selection = TextSelection.collapsed(
                          offset: controller.text.length,
                        );
                      },
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: () => _submitSelectionGroupDialog(
            logic: logic,
            controller: controller,
            isAdd: isAdd,
          ),
          child: Text(isAdd ? '加入' : '移出'),
        ),
      ],
    ),
  );
}

Future<void> _submitSelectionGroupDialog({
  required SourceLogic logic,
  required TextEditingController controller,
  required bool isAdd,
}) async {
  final group = controller.text.trim();
  if (group.isEmpty) return;
  Get.back();
  if (isAdd) {
    await logic.addSelectedToGroup(group);
  } else {
    await logic.removeSelectedFromGroup(group);
  }
}

void _showRenameGroupDialog({
  required SourceLogic logic,
  required String oldGroup,
}) {
  final isCreate = oldGroup.isEmpty;
  final controller = TextEditingController(text: oldGroup);

  Get.dialog(
    AlertDialog(
      title: Text(isCreate ? '新建分组' : '重命名分组'),
      content: TextField(
        controller: controller,
        autofocus: true,
        decoration: const InputDecoration(
          labelText: '分组名称',
          prefixIcon: Icon(Icons.folder_outlined),
        ),
        onSubmitted: (_) => _submitRenameGroupDialog(
          logic: logic,
          oldGroup: oldGroup,
          controller: controller,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: () => _submitRenameGroupDialog(
            logic: logic,
            oldGroup: oldGroup,
            controller: controller,
          ),
          child: Text(isCreate ? '新建' : '保存'),
        ),
      ],
    ),
  );
}

Future<void> _submitRenameGroupDialog({
  required SourceLogic logic,
  required String oldGroup,
  required TextEditingController controller,
}) async {
  final group = controller.text.trim();
  if (group.isEmpty) return;
  Get.back();
  if (oldGroup.isEmpty) {
    await logic.addUngroupedToGroup(group);
  } else {
    await logic.renameGroup(oldGroup, group);
  }
}

void _showDeleteGroupDialog({
  required SourceLogic logic,
  required String group,
  required int count,
}) {
  Get.dialog(
    AlertDialog(
      title: const Text('移除分组'),
      content: Text('将从 $count 个书源中移除“$group”分组，书源本身不会删除。'),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: const Text('取消'),
        ),
        TextButton(
          onPressed: () async {
            Get.back();
            await logic.deleteGroup(group);
          },
          child: const Text('移除', style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );
}

class _SourceSortSheet extends StatelessWidget {
  const _SourceSortSheet({
    required this.logic,
    required this.selectedType,
  });

  final SourceLogic logic;
  final SortType selectedType;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    return Material(
      color: Colors.transparent,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(16, 10, 16, 16 + bottomPadding),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 18,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.onSurface.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Icon(Icons.sort_rounded, size: 20, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  '排序方式',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            for (final type in SortType.values)
              _SourceSortOption(
                label: _labelOf(type),
                selected: selectedType == type,
                onTap: () {
                  logic.changeSortType(type);
                  Get.back();
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _SourceGroupManageSheet extends StatelessWidget {
  const _SourceGroupManageSheet({
    required this.logic,
  });

  final SourceLogic logic;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bottomPadding = MediaQuery.paddingOf(context).bottom;
    final groups = logic.getGroupInfos();

    return Material(
      color: Colors.transparent,
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.78,
        ),
        padding: EdgeInsets.fromLTRB(16, 10, 16, 16 + bottomPadding),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 18,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.onSurface.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Icon(
                  Icons.folder_outlined,
                  size: 20,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  '分组管理',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => _showRenameGroupDialog(
                    logic: logic,
                    oldGroup: '',
                  ),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('归入未分组'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: groups.length + 1,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, index) {
                  if (index == 0) {
                    return _SourceAllGroupsTile(logic: logic);
                  }
                  final group = groups[index - 1];
                  return _SourceGroupTile(
                    logic: logic,
                    group: group,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SourceAllGroupsTile extends StatelessWidget {
  const _SourceAllGroupsTile({
    required this.logic,
  });

  final SourceLogic logic;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final selected = logic.state.groupFilter == null;

    return Material(
      color: selected
          ? colorScheme.primary.withValues(alpha: 0.10)
          : colorScheme.surfaceContainerHighest.withValues(alpha: 0.34),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          logic.filterByGroup(null);
          Get.back();
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Icon(
                Icons.all_inbox_outlined,
                size: 20,
                color: selected
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '全部书源',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: selected ? colorScheme.primary : null,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: colorScheme.onSurface.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${logic.state.allSources.length}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SourceGroupTile extends StatelessWidget {
  const _SourceGroupTile({
    required this.logic,
    required this.group,
  });

  final SourceLogic logic;
  final SourceGroupInfo group;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final selected = logic.state.groupFilter == group.name;

    return Material(
      color: selected
          ? colorScheme.primary.withValues(alpha: 0.10)
          : colorScheme.surfaceContainerHighest.withValues(alpha: 0.34),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          logic.filterByGroup(group.name);
          Get.back();
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Icon(
                group.isUngrouped
                    ? Icons.folder_off_outlined
                    : Icons.folder_outlined,
                size: 20,
                color: selected
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  group.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: selected ? colorScheme.primary : null,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: colorScheme.onSurface.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${group.count}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              if (!group.isUngrouped)
                PopupMenuButton<String>(
                  tooltip: '分组操作',
                  onSelected: (value) {
                    switch (value) {
                      case 'rename':
                        _showRenameGroupDialog(
                          logic: logic,
                          oldGroup: group.name,
                        );
                        break;
                      case 'delete':
                        _showDeleteGroupDialog(
                          logic: logic,
                          group: group.name,
                          count: group.count,
                        );
                        break;
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'rename', child: Text('重命名')),
                    PopupMenuItem(value: 'delete', child: Text('移除分组')),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SourceSortOption extends StatelessWidget {
  const _SourceSortOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final selectedColor = colorScheme.primary;
    final mutedColor = colorScheme.onSurface.withValues(alpha: 0.58);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: selected
            ? selectedColor.withValues(alpha: 0.10)
            : colorScheme.surfaceContainerHighest.withValues(alpha: 0.34),
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: selected
                    ? selectedColor.withValues(alpha: 0.34)
                    : colorScheme.outlineVariant.withValues(alpha: 0.34),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  selected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  size: 20,
                  color: selected ? selectedColor : mutedColor,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: selected ? selectedColor : colorScheme.onSurface,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                    ),
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

String _labelOf(SortType type) {
  switch (type) {
    case SortType.defaultSort:
      return '默认排序';
    case SortType.name:
      return '按名称';
    case SortType.url:
      return '按地址';
    case SortType.weight:
      return '按权重';
    case SortType.updateTime:
      return '按更新时间';
  }
}
