import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 书架统一底部弹层外壳（与「排序 / 最近阅读」弹层同款）。
class BookshelfBottomSheetShell extends StatelessWidget {
  const BookshelfBottomSheetShell({
    super.key,
    required this.title,
    required this.icon,
    required this.children,
    this.subtitle,
  });

  final String title;
  final IconData icon;
  final String? subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    return Container(
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
              Icon(icon, size: 20, color: colorScheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (subtitle != null && subtitle!.trim().isNotEmpty)
                      Text(
                        subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.55),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

/// 统一选项行：圆角卡片 + 图标 + 文案（排序选中态同款）。
class BookshelfSheetOption extends StatelessWidget {
  const BookshelfSheetOption({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.selected = false,
    this.isDestructive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool selected;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final selectedColor = colorScheme.primary;
    final mutedColor = colorScheme.onSurface.withValues(alpha: 0.58);
    final danger = colorScheme.error;

    final Color fg;
    if (isDestructive) {
      fg = danger;
    } else if (selected) {
      fg = selectedColor;
    } else {
      fg = colorScheme.onSurface;
    }

    final Color iconColor;
    if (isDestructive) {
      iconColor = danger;
    } else if (selected) {
      iconColor = selectedColor;
    } else {
      iconColor = mutedColor;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: selected
            ? selectedColor.withValues(alpha: 0.10)
            : isDestructive
                ? danger.withValues(alpha: 0.06)
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
                    : isDestructive
                        ? danger.withValues(alpha: 0.22)
                        : colorScheme.outlineVariant.withValues(alpha: 0.34),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, size: 20, color: iconColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: fg,
                      fontWeight:
                          selected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
                if (selected)
                  Icon(
                    Icons.check_circle_rounded,
                    size: 20,
                    color: selectedColor,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 以与排序弹层相同的方式从底部弹出。
Future<T?> showBookshelfBottomSheet<T>({
  required Widget child,
}) {
  return Get.dialog<T>(
    Align(
      alignment: Alignment.bottomCenter,
      child: FractionallySizedBox(
        widthFactor: 1,
        child: child,
      ),
    ),
    barrierColor: Colors.black54,
    barrierDismissible: true,
    useSafeArea: false,
  );
}
