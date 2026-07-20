import 'package:flutter/material.dart';

import '../logic.dart';
import '../state.dart';

/// 批量选择模式下的底部操作栏。
class SourceSelectionBar extends StatelessWidget {
  const SourceSelectionBar({
    super.key,
    required this.logic,
    required this.state,
    required this.onShowSelectionAddGroupDialog,
    required this.onShowSelectionRemoveGroupDialog,
    required this.onShowDeleteDialog,
  });

  final SourceLogic logic;
  final SourceState state;
  final VoidCallback onShowSelectionAddGroupDialog;
  final VoidCallback onShowSelectionRemoveGroupDialog;
  final VoidCallback onShowDeleteDialog;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final enabled = state.selectedIds.isNotEmpty;

    return Material(
      elevation: 8,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      color: colorScheme.surfaceContainerHigh,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(6, 10, 6, 10),
        child: Row(
          children: [
            _Action(
              icon: Icons.toggle_on_outlined,
              label: '启用',
              enabled: enabled,
              onTap: logic.enableSelected,
            ),
            _Action(
              icon: Icons.toggle_off_outlined,
              label: '禁用',
              enabled: enabled,
              onTap: logic.disableSelected,
            ),
            _Action(
              icon: Icons.speed_rounded,
              label: '校验',
              enabled: enabled,
              onTap: logic.testSelectedSources,
            ),
            _Action(
              icon: Icons.folder_outlined,
              label: '分组',
              enabled: enabled,
              onTap: () {
                showModalBottomSheet<void>(
                  context: context,
                  showDragHandle: true,
                  builder: (ctx) {
                    return SafeArea(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            leading:
                                const Icon(Icons.create_new_folder_outlined),
                            title: const Text('加入分组'),
                            onTap: () {
                              Navigator.pop(ctx);
                              onShowSelectionAddGroupDialog();
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.folder_off_outlined),
                            title: const Text('移出分组'),
                            onTap: () {
                              Navigator.pop(ctx);
                              onShowSelectionRemoveGroupDialog();
                            },
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
            _Action(
              icon: Icons.delete_outline_rounded,
              label: '删除',
              enabled: enabled,
              isDestructive: true,
              onTap: onShowDeleteDialog,
            ),
          ],
        ),
      ),
    );
  }
}

class _Action extends StatelessWidget {
  const _Action({
    required this.icon,
    required this.label,
    required this.enabled,
    required this.onTap,
    this.isDestructive = false,
  });

  final IconData icon;
  final String label;
  final bool enabled;
  final VoidCallback onTap;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = !enabled
        ? colorScheme.onSurface.withValues(alpha: 0.28)
        : isDestructive
            ? colorScheme.error
            : colorScheme.onSurface;

    return Expanded(
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 22, color: color),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
