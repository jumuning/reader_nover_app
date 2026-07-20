import 'package:flutter/material.dart';

import '../state.dart';

/// 批量校验进度卡。入口「查看详情」仍跳转原校验详情页（暂不改详情内部）。
class SourceCheckProgressCard extends StatelessWidget {
  const SourceCheckProgressCard({
    super.key,
    required this.state,
    required this.onOpenResults,
    this.onStopChecking,
  });

  final SourceState state;
  final VoidCallback onOpenResults;
  final VoidCallback? onStopChecking;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final finished = state.checkFinished;
    final total = state.checkTotal;
    final successCount = state.checkResults.values
        .where((result) => result.state == CheckState.success)
        .length;
    final failCount = state.checkResults.values
        .where((result) => result.state == CheckState.failed)
        .length;
    final warningCount = state.checkResults.values
        .where((result) => result.state == CheckState.warning)
        .length;
    final checkingCount = state.checkResults.values
        .where((result) => result.state == CheckState.checking)
        .length;
    final isChecking = state.isChecking;
    final progress = total > 0 ? finished / total : 0.0;
    final percent = (progress * 100).toInt();
    final latestMessage = state.checkLatestMessage?.trim();

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 10, 12, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.55),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: 40,
                height: 40,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (isChecking)
                      CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 3,
                        backgroundColor:
                            colorScheme.onSurface.withValues(alpha: 0.1),
                        valueColor:
                            AlwaysStoppedAnimation<Color>(colorScheme.primary),
                      )
                    else
                      Icon(
                        failCount > 0 || warningCount > 0
                            ? Icons.assignment_late_rounded
                            : Icons.assignment_turned_in_rounded,
                        color: failCount > 0
                            ? colorScheme.error
                            : warningCount > 0
                                ? colorScheme.tertiary
                                : colorScheme.primary,
                        size: 28,
                      ),
                    if (isChecking)
                      Text(
                        '$percent%',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isChecking &&
                              state.checkCurrentName?.trim().isNotEmpty == true
                          ? '正在校验：${state.checkCurrentName}'
                          : isChecking
                              ? '正在校验书源'
                              : '最近一次校验结果',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '已完成 $finished / $total'
                      '${checkingCount > 0 ? ' · 并发 $checkingCount' : ''}',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurface.withValues(alpha: 0.58),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (successCount > 0)
                _StatBadge(
                  icon: Icons.check_circle_rounded,
                  count: successCount,
                  color: colorScheme.tertiary,
                ),
              if (failCount > 0)
                _StatBadge(
                  icon: Icons.error_rounded,
                  count: failCount,
                  color: colorScheme.error,
                ),
              if (warningCount > 0)
                _StatBadge(
                  icon: Icons.info_rounded,
                  count: warningCount,
                  color: colorScheme.tertiary,
                ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 5,
              backgroundColor: colorScheme.onSurface.withValues(alpha: 0.08),
              valueColor: AlwaysStoppedAnimation<Color>(
                isChecking ? colorScheme.primary : colorScheme.tertiary,
              ),
            ),
          ),
          if (latestMessage != null && latestMessage.isNotEmpty) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                latestMessage,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurface.withValues(alpha: 0.65),
                ),
              ),
            ),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onOpenResults,
                  icon: const Icon(Icons.list_alt_rounded, size: 18),
                  label: const Text('查看详情'),
                ),
              ),
              if (isChecking && onStopChecking != null) ...[
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.tonalIcon(
                    onPressed: onStopChecking,
                    icon: Icon(
                      Icons.stop_rounded,
                      size: 18,
                      color: colorScheme.error,
                    ),
                    label: Text(
                      '停止',
                      style: TextStyle(color: colorScheme.error),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  const _StatBadge({
    required this.icon,
    required this.count,
    required this.color,
  });

  final IconData icon;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 6),
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 3),
          Text(
            '$count',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
