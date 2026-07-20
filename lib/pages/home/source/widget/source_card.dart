import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:reader_nover/app/database/drift/app_database.dart' as db;
import 'package:reader_nover/app/service/source/source_check_report.dart';

import '../edit/view.dart';
import '../logic.dart';
import '../state.dart';

/// 书源卡片：点进编辑，长按批量，滑动编辑/启停。
class SourceCard extends StatelessWidget {
  const SourceCard({
    super.key,
    required this.logic,
    required this.bookSource,
    this.onLongPress,
  });

  final SourceLogic logic;
  final db.BookSource bookSource;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final state = logic.state;
    final enabled = bookSource.enabled;
    final isSelected = state.selectedIds.contains(bookSource.id);
    final checkResult = state.checkResults[bookSource.id];
    final colorScheme = Theme.of(context).colorScheme;

    if (state.isSelectionMode) {
      return _buildCard(
        context,
        enabled: enabled,
        isSelected: isSelected,
        checkResult: checkResult,
      );
    }

    return Dismissible(
      key: ValueKey(bookSource.id),
      background: _swipeBg(
        color: colorScheme.primary,
        icon: Icons.edit_rounded,
        alignment: Alignment.centerLeft,
        label: '编辑',
      ),
      secondaryBackground: _swipeBg(
        color: enabled ? colorScheme.tertiary : colorScheme.primary,
        icon: enabled ? Icons.visibility_off_rounded : Icons.visibility_rounded,
        alignment: Alignment.centerRight,
        label: enabled ? '禁用' : '启用',
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          _openEdit();
        } else {
          logic.toggleSource(bookSource, !enabled);
        }
        return false;
      },
      child: _buildCard(
        context,
        enabled: enabled,
        isSelected: isSelected,
        checkResult: checkResult,
      ),
    );
  }

  void _openEdit() {
    Get.to(
      () => BookSourceEditPage(
        source: bookSource,
        onOpenSourceLogin: logic.openSourceLogin,
      ),
    );
  }

  Widget _swipeBg({
    required Color color,
    required IconData icon,
    required Alignment alignment,
    required String label,
  }) {
    final isLeft = alignment == Alignment.centerLeft;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
      ),
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: isLeft
            ? [
                Icon(icon, color: Colors.white, size: 20),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ]
            : [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(width: 6),
                Icon(icon, color: Colors.white, size: 20),
              ],
      ),
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required bool enabled,
    required bool isSelected,
    required CheckResult? checkResult,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final accent = _accentColor(context, enabled, checkResult);
    final host = _hostOf(bookSource.bookSourceUrl);
    final hasLogin = (bookSource.loginUrl?.trim().isNotEmpty ?? false) ||
        (bookSource.loginUi?.trim().isNotEmpty ?? false);
    final groupText = bookSource.bookSourceGroup?.trim() ?? '';

    return Opacity(
      opacity: enabled ? 1 : 0.58,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primaryContainer.withValues(alpha: 0.35)
              : colorScheme.surfaceContainerHighest.withValues(alpha: 0.42),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? colorScheme.primary.withValues(alpha: 0.55)
                : colorScheme.outlineVariant.withValues(alpha: 0.45),
            width: isSelected ? 1.4 : 1,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () {
              if (logic.state.isSelectionMode) {
                logic.toggleSelection(bookSource.id);
              } else {
                _openEdit();
              }
            },
            onLongPress: onLongPress,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 8, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (logic.state.isSelectionMode)
                    Padding(
                      padding: const EdgeInsets.only(right: 8, top: 2),
                      child: Checkbox(
                        value: isSelected,
                        visualDensity: VisualDensity.compact,
                        onChanged: (_) =>
                            logic.toggleSelection(bookSource.id),
                      ),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.only(right: 10, top: 4),
                      child: _StatusDot(
                        color: accent,
                        checking: checkResult?.state == CheckState.checking,
                      ),
                    ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          bookSource.bookSourceName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          host.isNotEmpty ? host : bookSource.bookSourceUrl,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface.withValues(alpha: 0.45),
                            fontSize: 12,
                          ),
                        ),
                        if (checkResult != null) ...[
                          const SizedBox(height: 6),
                          _CheckLine(result: checkResult),
                        ],
                        if (groupText.isNotEmpty ||
                            (checkResult?.errorTag?.trim().isNotEmpty ==
                                    true &&
                                (checkResult?.state == CheckState.failed ||
                                    checkResult?.state ==
                                        CheckState.warning))) ...[
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: [
                              ..._groupTags(context, groupText),
                              if (checkResult != null &&
                                  (checkResult.state == CheckState.failed ||
                                      checkResult.state ==
                                          CheckState.warning) &&
                                  checkResult.errorTag?.trim().isNotEmpty ==
                                      true &&
                                  !_groupContains(
                                      groupText, checkResult.errorTag!))
                                _Tag(
                                  text: checkResult.errorTag!.trim(),
                                  isError:
                                      checkResult.state == CheckState.failed,
                                ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (!logic.state.isSelectionMode) ...[
                    if (hasLogin)
                      IconButton(
                        icon: const Icon(Icons.login_rounded, size: 18),
                        tooltip: '登录',
                        visualDensity: VisualDensity.compact,
                        onPressed: () => logic.openSourceLogin(bookSource),
                      ),
                    Transform.scale(
                      scale: 0.78,
                      child: Switch.adaptive(
                        value: enabled,
                        onChanged: (v) => logic.toggleSource(bookSource, v),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _accentColor(
    BuildContext context,
    bool enabled,
    CheckResult? checkResult,
  ) {
    final cs = Theme.of(context).colorScheme;
    if (checkResult != null) {
      switch (checkResult.state) {
        case CheckState.checking:
          return cs.primary;
        case CheckState.success:
          return cs.tertiary;
        case CheckState.warning:
          return cs.tertiary;
        case CheckState.failed:
          return cs.error;
        case CheckState.waiting:
          return cs.outline;
      }
    }
    return enabled ? cs.primary : cs.outline;
  }

  String _hostOf(String url) {
    try {
      final uri = Uri.tryParse(url);
      if (uri == null || uri.host.isEmpty) return '';
      return uri.host;
    } catch (_) {
      return '';
    }
  }

  List<Widget> _groupTags(BuildContext context, String group) {
    if (group.isEmpty) return const [];
    return group
        .split(RegExp(r'[,;，；]'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .take(3)
        .map((e) => _Tag(text: e))
        .toList();
  }

  bool _groupContains(String group, String tag) {
    return group
        .split(RegExp(r'[,;，；]'))
        .map((e) => e.trim())
        .contains(tag.trim());
  }
}

class _StatusDot extends StatelessWidget {
  const _StatusDot({
    required this.color,
    required this.checking,
  });

  final Color color;
  final bool checking;

  @override
  Widget build(BuildContext context) {
    if (checking) {
      return SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: Theme.of(context).colorScheme.primary,
        ),
      );
    }
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.35),
            blurRadius: 4,
          ),
        ],
      ),
    );
  }
}

class _CheckLine extends StatelessWidget {
  const _CheckLine({required this.result});

  final CheckResult result;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = _color(colorScheme);
    final text = _message();

    return Row(
      children: [
        Icon(_icon(), size: 13, color: color),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              height: 1.15,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Color _color(ColorScheme cs) {
    switch (result.state) {
      case CheckState.waiting:
        return cs.onSurfaceVariant;
      case CheckState.checking:
        return cs.primary;
      case CheckState.success:
        return cs.tertiary;
      case CheckState.warning:
        return cs.tertiary;
      case CheckState.failed:
        return cs.error;
    }
  }

  IconData _icon() {
    switch (result.state) {
      case CheckState.waiting:
        return Icons.schedule_rounded;
      case CheckState.checking:
        return Icons.sync_rounded;
      case CheckState.success:
        return Icons.check_circle_rounded;
      case CheckState.warning:
        return Icons.info_rounded;
      case CheckState.failed:
        return Icons.error_rounded;
    }
  }

  String _message() {
    final elapsed =
        result.elapsed == null ? '' : ' ${_formatElapsed(result.elapsed!)}';
    switch (result.state) {
      case CheckState.waiting:
        return '等待校验';
      case CheckState.checking:
        return '正在校验';
      case CheckState.success:
        return '校验成功$elapsed';
      case CheckState.warning:
        final reason = result.errorTag?.trim();
        final prefix = _failurePrefix();
        return '$prefix${reason?.isNotEmpty == true ? reason : '待复查'}$elapsed';
      case CheckState.failed:
        final reason = result.errorTag?.trim();
        final prefix = _failurePrefix();
        return '$prefix${reason?.isNotEmpty == true ? reason : '校验失败'}$elapsed';
    }
  }

  String _failurePrefix() {
    final failureClass = result.failureClass;
    if (failureClass == null) return '';
    return '[${SourceCheckReport.failureLabel(failureClass)}] ';
  }

  String _formatElapsed(int ms) {
    if (ms < 1000) return '${ms}ms';
    return '${(ms / 1000).toStringAsFixed(1)}s';
  }
}

class _Tag extends StatelessWidget {
  const _Tag({
    required this.text,
    this.isError = false,
  });

  final String text;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: isError
            ? cs.error.withValues(alpha: 0.1)
            : cs.onSurface.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: isError ? cs.error : cs.onSurface.withValues(alpha: 0.58),
        ),
      ),
    );
  }
}
