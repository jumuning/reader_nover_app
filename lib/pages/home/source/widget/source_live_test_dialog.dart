import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:reader_nover/app/service/source/source_check_report.dart';

import '../state.dart';

class SourceLiveTestDialog extends StatelessWidget {
  const SourceLiveTestDialog({
    super.key,
    required this.stateListenable,
    required this.onCancel,
  });

  final ValueListenable<SourceLiveTestState> stateListenable;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<SourceLiveTestState>(
      valueListenable: stateListenable,
      builder: (context, state, _) {
        final theme = Theme.of(context);
        return AlertDialog(
          title: Text(
            state.sourceName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          content: SizedBox(
            width: 520,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _summaryText(state),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: _summaryColor(state, theme),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 360),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return _LiveTestStageTile(stage: state.stages[index]);
                    },
                    separatorBuilder: (_, __) => const Divider(height: 16),
                    itemCount: state.stages.length,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            if (state.isRunning)
              TextButton(
                onPressed: onCancel,
                child: const Text('取消'),
              ),
            FilledButton(
              onPressed: state.isRunning ? null : () => Get.back(),
              child: const Text('关闭'),
            ),
          ],
        );
      },
    );
  }

  String _summaryText(SourceLiveTestState state) {
    if (state.summary?.trim().isNotEmpty == true) {
      return state.summary!.trim();
    }
    if (state.isCancelled) return '已取消测试';
    if (state.isRunning) return '正在实跑书源规则';
    if (state.hasIssue) return '测试完成，有失败或告警阶段';
    return '测试完成';
  }

  Color _summaryColor(SourceLiveTestState state, ThemeData theme) {
    if (state.isCancelled) return Colors.orange.shade700;
    if (state.hasIssue) return theme.colorScheme.error;
    return theme.colorScheme.onSurface.withValues(alpha: 0.65);
  }
}

class _LiveTestStageTile extends StatelessWidget {
  const _LiveTestStageTile({required this.stage});

  final SourceLiveTestStageResult stage;

  @override
  Widget build(BuildContext context) {
    final color = _color();
    final icon = _icon();
    final elapsed =
        stage.elapsed == null ? '' : ' · ${_formatElapsed(stage.elapsed!)}';
    final message = '${_failurePrefix()}${stage.message}'.trim();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (stage.status == SourceLiveTestStageStatus.testing)
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          )
        else
          Icon(icon, color: color, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${stage.title}$elapsed',
                style: TextStyle(fontWeight: FontWeight.w600, color: color),
              ),
              if (stage.message.trim().isNotEmpty) ...[
                const SizedBox(height: 3),
                Text(message),
              ],
              if (stage.detail?.trim().isNotEmpty == true) ...[
                const SizedBox(height: 4),
                Text(
                  stage.detail!.trim(),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.62),
                      ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Color _color() {
    switch (stage.status) {
      case SourceLiveTestStageStatus.waiting:
        return Colors.grey;
      case SourceLiveTestStageStatus.testing:
        return Colors.blue;
      case SourceLiveTestStageStatus.success:
        return Colors.green;
      case SourceLiveTestStageStatus.warning:
        return Colors.orange;
      case SourceLiveTestStageStatus.error:
        return Colors.red;
    }
  }

  IconData _icon() {
    switch (stage.status) {
      case SourceLiveTestStageStatus.waiting:
        return Icons.schedule_rounded;
      case SourceLiveTestStageStatus.testing:
        return Icons.sync_rounded;
      case SourceLiveTestStageStatus.success:
        return Icons.check_circle_rounded;
      case SourceLiveTestStageStatus.warning:
        return Icons.info_rounded;
      case SourceLiveTestStageStatus.error:
        return Icons.error_rounded;
    }
  }

  String _formatElapsed(int elapsedMs) {
    if (elapsedMs < 1000) return '${elapsedMs}ms';
    return '${(elapsedMs / 1000).toStringAsFixed(1)}s';
  }

  String _failurePrefix() {
    final failureClass = stage.failureClass;
    if (failureClass == null) return '';
    return '[${SourceCheckReport.failureLabel(failureClass)}] ';
  }
}
