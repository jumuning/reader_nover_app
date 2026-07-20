import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../logic.dart';
import '../state.dart';

/// 书架批量操作栏。
class BookshelfSelectionBar extends StatelessWidget {
  const BookshelfSelectionBar({
    super.key,
    required this.logic,
  });

  final BookLogic logic;

  BookState get state => logic.state;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final enabled = state.selectedIds.isNotEmpty;
    final selectedBooks = state.myBooks
        .where((b) => state.selectedIds.contains(b.id))
        .toList(growable: false);
    final allPinned =
        selectedBooks.isNotEmpty && selectedBooks.every((b) => b.customOrder > 0);

    return Material(
      elevation: 8,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      color: colorScheme.surfaceContainerHigh,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(6, 10, 6, 10),
        child: Row(
          children: [
            _Action(
              icon: allPinned
                  ? Icons.push_pin_outlined
                  : Icons.push_pin_rounded,
              label: allPinned ? '取消置顶' : '置顶',
              enabled: enabled,
              onTap: () {
                if (allPinned) {
                  logic.unpinSelected();
                } else {
                  logic.pinSelected();
                }
              },
            ),
            _Action(
              icon: Icons.delete_outline_rounded,
              label: '移出',
              enabled: enabled,
              isDestructive: true,
              onTap: () async {
                final confirmed = await Get.dialog<bool>(
                  AlertDialog(
                    title: const Text('移出书架'),
                    content: Text(
                      '确定将选中的 ${state.selectedIds.length} 本书移出书架吗？',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Get.back(result: false),
                        child: const Text('取消'),
                      ),
                      TextButton(
                        onPressed: () => Get.back(result: true),
                        child: Text(
                          '移出',
                          style: TextStyle(color: colorScheme.error),
                        ),
                      ),
                    ],
                  ),
                );
                if (confirmed == true) {
                  await logic.removeSelectedFromShelf();
                }
              },
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
