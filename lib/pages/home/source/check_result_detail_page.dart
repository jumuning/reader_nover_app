import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:reader_nover/app/database/drift/app_database.dart' as db;
import 'package:reader_nover/app/service/source/source_check_report.dart';

import 'logic.dart';
import 'state.dart';

class SourceCheckResultDetailPage extends StatefulWidget {
  const SourceCheckResultDetailPage({super.key});

  @override
  State<SourceCheckResultDetailPage> createState() =>
      _SourceCheckResultDetailPageState();
}

class _SourceCheckResultDetailPageState
    extends State<SourceCheckResultDetailPage> {
  SourceCheckFailureClass? _selectedFailureClass;
  bool _showUnclassifiedFailures = false;

  bool get _hasFailureClassFilter =>
      _selectedFailureClass != null || _showUnclassifiedFailures;

  void _clearFailureClassFilter() {
    if (!_hasFailureClassFilter) return;
    setState(() {
      _selectedFailureClass = null;
      _showUnclassifiedFailures = false;
    });
  }

  void _selectFailureClass(
    SourceCheckFailureClass? failureClass, {
    bool unclassified = false,
  }) {
    setState(() {
      _selectedFailureClass = failureClass;
      _showUnclassifiedFailures = unclassified;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SourceLogic>(
      builder: (logic) {
        final snapshot = _CheckResultSnapshot.fromState(logic.state);
        return Scaffold(
          appBar: AppBar(
            title: const Text('校验结果详情'),
          ),
          body: snapshot.results.isEmpty
              ? const _EmptyCheckResultView()
              : ListView(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
                  children: [
                    _SummarySection(snapshot: snapshot),
                    const SizedBox(height: 12),
                    _FailureClassSection(
                      snapshot: snapshot,
                      selectedFailureClass: _selectedFailureClass,
                      showUnclassifiedFailures: _showUnclassifiedFailures,
                      onClear: _clearFailureClassFilter,
                      onSelect: _selectFailureClass,
                    ),
                    const SizedBox(height: 12),
                    _StageSection(snapshot: snapshot),
                    const SizedBox(height: 12),
                    _ResultListSection(
                      snapshot: snapshot,
                      selectedFailureClass: _selectedFailureClass,
                      showUnclassifiedFailures: _showUnclassifiedFailures,
                    ),
                  ],
                ),
        );
      },
    );
  }
}

class _CheckResultSnapshot {
  const _CheckResultSnapshot({
    required this.isChecking,
    required this.total,
    required this.finished,
    required this.results,
    required this.sourcesById,
  });

  final bool isChecking;
  final int total;
  final int finished;
  final List<CheckResult> results;
  final Map<int, db.BookSource> sourcesById;

  factory _CheckResultSnapshot.fromState(SourceState state) {
    final results = state.checkResults.values.toList(growable: false)
      ..sort((a, b) {
        final stateCompare =
            _stateOrder(a.state).compareTo(_stateOrder(b.state));
        if (stateCompare != 0) return stateCompare;
        return a.sourceId.compareTo(b.sourceId);
      });
    return _CheckResultSnapshot(
      isChecking: state.isChecking,
      total: state.checkTotal,
      finished: state.checkFinished,
      results: results,
      sourcesById: {
        for (final source in state.allSources) source.id: source,
      },
    );
  }

  int get successCount =>
      results.where((result) => result.state == CheckState.success).length;

  int get warningCount =>
      results.where((result) => result.state == CheckState.warning).length;

  int get failedCount =>
      results.where((result) => result.state == CheckState.failed).length;

  int get issueCount => failedCount + warningCount;

  int get checkingCount =>
      results.where((result) => result.state == CheckState.checking).length;

  int get waitingCount =>
      results.where((result) => result.state == CheckState.waiting).length;

  double get progress => total > 0 ? finished / total : 0;

  List<_CountRow> get failureClassRows {
    final counts = <SourceCheckFailureClass?, int>{};
    for (final result in results) {
      if (result.state != CheckState.failed &&
          result.state != CheckState.warning) {
        continue;
      }
      final failureClass = _failureClassOf(result);
      counts[failureClass] = (counts[failureClass] ?? 0) + 1;
    }
    return _sortedFailureClassRows(counts);
  }

  List<_StageCountRow> get stageRows {
    final rows = <SourceCheckStage, _MutableStageCount>{};
    for (final result in results) {
      for (final report in result.stages) {
        final count = rows.putIfAbsent(report.stage, _MutableStageCount.new);
        if (report.ok) {
          count.success++;
        } else {
          count.failed++;
        }
      }
    }
    return rows.entries
        .map(
          (entry) => _StageCountRow(
            stage: entry.key,
            success: entry.value.success,
            failed: entry.value.failed,
          ),
        )
        .toList(growable: false)
      ..sort((a, b) => a.order.compareTo(b.order));
  }

  db.BookSource? sourceOf(CheckResult result) => sourcesById[result.sourceId];

  List<CheckResult> filteredResults({
    required SourceCheckFailureClass? failureClass,
    required bool showUnclassifiedFailures,
  }) {
    if (failureClass == null && !showUnclassifiedFailures) {
      return results;
    }
    return results.where((result) {
      if (!_isIssueResult(result)) return false;
      final resultFailureClass = _failureClassOf(result);
      if (showUnclassifiedFailures) {
        return resultFailureClass == null;
      }
      return resultFailureClass == failureClass;
    }).toList(growable: false);
  }

  List<_ResultGroupBlock> groupedResults(List<CheckResult> sourceResults) {
    final buckets = <_ResultGroup, List<CheckResult>>{
      for (final group in _ResultGroup.values) group: <CheckResult>[],
    };
    for (final result in sourceResults) {
      buckets[_resultGroupOf(result)]!.add(result);
    }
    return _ResultGroup.values
        .map((group) => _ResultGroupBlock(group, buckets[group]!))
        .where((block) => block.results.isNotEmpty)
        .toList(growable: false);
  }

  static int _stateOrder(CheckState state) {
    switch (state) {
      case CheckState.failed:
        return 0;
      case CheckState.warning:
        return 1;
      case CheckState.checking:
        return 2;
      case CheckState.waiting:
        return 3;
      case CheckState.success:
        return 4;
    }
  }
}

class _EmptyCheckResultView extends StatelessWidget {
  const _EmptyCheckResultView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.assignment_outlined,
            size: 64,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.28),
          ),
          const SizedBox(height: 12),
          Text(
            '暂无校验结果',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.62),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummarySection extends StatelessWidget {
  const _SummarySection({required this.snapshot});

  final _CheckResultSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progressText = snapshot.isChecking
        ? '进行中 ${snapshot.finished} / ${snapshot.total}'
        : '已完成 ${snapshot.finished} / ${snapshot.total}';
    return _SectionPanel(
      title: '结果摘要',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  progressText,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                '${(snapshot.progress * 100).toInt()}%',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: snapshot.progress,
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MetricChip(
                label: '正常',
                count: snapshot.successCount,
                color: Colors.green,
                icon: Icons.check_circle_rounded,
              ),
              _MetricChip(
                label: '失效',
                count: snapshot.failedCount,
                color: Colors.red,
                icon: Icons.error_rounded,
              ),
              _MetricChip(
                label: '复查',
                count: snapshot.warningCount,
                color: Colors.orange,
                icon: Icons.info_rounded,
              ),
              if (snapshot.checkingCount > 0)
                _MetricChip(
                  label: '校验中',
                  count: snapshot.checkingCount,
                  color: Colors.blue,
                  icon: Icons.sync_rounded,
                ),
              if (snapshot.waitingCount > 0)
                _MetricChip(
                  label: '等待',
                  count: snapshot.waitingCount,
                  color: Colors.grey,
                  icon: Icons.schedule_rounded,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FailureClassSection extends StatelessWidget {
  const _FailureClassSection({
    required this.snapshot,
    required this.selectedFailureClass,
    required this.showUnclassifiedFailures,
    required this.onClear,
    required this.onSelect,
  });

  final _CheckResultSnapshot snapshot;
  final SourceCheckFailureClass? selectedFailureClass;
  final bool showUnclassifiedFailures;
  final VoidCallback onClear;
  final void Function(
    SourceCheckFailureClass? failureClass, {
    bool unclassified,
  }) onSelect;

  @override
  Widget build(BuildContext context) {
    final rows = snapshot.failureClassRows;
    final hasFilter = selectedFailureClass != null || showUnclassifiedFailures;
    return _SectionPanel(
      title: '失败类型筛选',
      child: rows.isEmpty
          ? const _EmptySectionText(text: '没有失败或待复查结果')
          : Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _FailureFilterChip(
                  label: '全部',
                  count: snapshot.issueCount,
                  selected: !hasFilter,
                  onTap: onClear,
                ),
                for (final row in rows)
                  _FailureFilterChip(
                    label: row.label,
                    count: row.count,
                    selected: row.isUnclassified
                        ? showUnclassifiedFailures
                        : selectedFailureClass == row.failureClass,
                    onTap: () => onSelect(
                      row.failureClass,
                      unclassified: row.isUnclassified,
                    ),
                  ),
              ],
            ),
    );
  }
}

class _StageSection extends StatelessWidget {
  const _StageSection({required this.snapshot});

  final _CheckResultSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final rows = snapshot.stageRows;
    return _SectionPanel(
      title: '阶段聚合',
      child: rows.isEmpty
          ? const _EmptySectionText(text: '暂无阶段报告')
          : Column(
              children: [
                for (final row in rows)
                  _StageLine(
                    label: SourceCheckReport.stageLabel(row.stage),
                    success: row.success,
                    failed: row.failed,
                  ),
              ],
            ),
    );
  }
}

class _ResultListSection extends StatelessWidget {
  const _ResultListSection({
    required this.snapshot,
    required this.selectedFailureClass,
    required this.showUnclassifiedFailures,
  });

  final _CheckResultSnapshot snapshot;
  final SourceCheckFailureClass? selectedFailureClass;
  final bool showUnclassifiedFailures;

  @override
  Widget build(BuildContext context) {
    final filteredResults = snapshot.filteredResults(
      failureClass: selectedFailureClass,
      showUnclassifiedFailures: showUnclassifiedFailures,
    );
    final groups = snapshot.groupedResults(filteredResults);
    final title = filteredResults.length == snapshot.results.length
        ? '列表详情'
        : '列表详情 ${filteredResults.length} / ${snapshot.results.length}';
    return _SectionPanel(
      title: title,
      padding: EdgeInsets.zero,
      child: groups.isEmpty
          ? const Padding(
              padding: EdgeInsets.all(12),
              child: _EmptySectionText(text: '没有匹配的校验结果'),
            )
          : Column(
              children: [
                for (var groupIndex = 0;
                    groupIndex < groups.length;
                    groupIndex++) ...[
                  _ResultGroupHeader(block: groups[groupIndex]),
                  for (var resultIndex = 0;
                      resultIndex < groups[groupIndex].results.length;
                      resultIndex++) ...[
                    _ResultTile(
                      result: groups[groupIndex].results[resultIndex],
                      source: snapshot.sourceOf(
                        groups[groupIndex].results[resultIndex],
                      ),
                    ),
                    if (resultIndex != groups[groupIndex].results.length - 1)
                      const Divider(height: 1, indent: 16, endIndent: 16),
                  ],
                  if (groupIndex != groups.length - 1) const Divider(height: 1),
                ],
              ],
            ),
    );
  }
}

class _ResultGroupHeader extends StatelessWidget {
  const _ResultGroupHeader({required this.block});

  final _ResultGroupBlock block;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _resultGroupColor(block.group);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.42),
      child: Row(
        children: [
          Icon(_resultGroupIcon(block.group), size: 16, color: color),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              _resultGroupLabel(block.group),
              style: theme.textTheme.labelLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Text(
            '${block.results.length}',
            style: theme.textTheme.labelLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultTile extends StatelessWidget {
  const _ResultTile({
    required this.result,
    required this.source,
  });

  final CheckResult result;
  final db.BookSource? source;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _stateColor(result.state);
    final name = source?.bookSourceName.trim();
    final url = source?.bookSourceUrl.trim();
    final stageSummary = SourceCheckReport.summarizeStages(result.stages);
    final failureClass = _failureClassOf(result);
    final title = name?.isNotEmpty == true ? name! : '书源 #${result.sourceId}';
    final subtitle = _resultSummary(result, failureClass);

    return ExpansionTile(
      tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      leading: Icon(_stateIcon(result.state), color: color),
      title: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(color: color),
          ),
          if (url != null && url.isNotEmpty)
            Text(
              url,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
                fontSize: 11,
              ),
            ),
        ],
      ),
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: () => _copyResultDiagnostics(
              sourceTitle: title,
              result: result,
              failureClass: failureClass,
              stageSummary: stageSummary,
            ),
            icon: const Icon(Icons.copy_rounded, size: 16),
            label: const Text('复制诊断'),
          ),
        ),
        _DetailRow(
            label: '状态', value: _resultGroupLabel(_resultGroupOf(result))),
        if (failureClass != null)
          _DetailRow(
            label: '失败类型',
            value: SourceCheckReport.failureLabel(failureClass),
          ),
        if (stageSummary.isNotEmpty)
          _DetailRow(label: '阶段摘要', value: stageSummary),
        if (result.errorMsg?.trim().isNotEmpty == true)
          _DetailRow(label: '错误信息', value: result.errorMsg!.trim()),
        if ((result.errorTags ?? const <String>[]).isNotEmpty)
          _DetailRow(label: '结果标签', value: result.errorTags!.join('、')),
        if (result.elapsed != null)
          _DetailRow(label: '总耗时', value: _formatElapsed(result.elapsed!)),
        if (result.stages.isNotEmpty) ...[
          const SizedBox(height: 8),
          for (final stage in result.stages) _StageReportTile(report: stage),
        ],
      ],
    );
  }
}

Future<void> _copyResultDiagnostics({
  required String sourceTitle,
  required CheckResult result,
  required SourceCheckFailureClass? failureClass,
  required String stageSummary,
}) async {
  await Clipboard.setData(
    ClipboardData(
      text: _formatResultDiagnostics(
        sourceTitle: sourceTitle,
        result: result,
        failureClass: failureClass,
        stageSummary: stageSummary,
      ),
    ),
  );
  Get.snackbar(
    '已复制诊断',
    '书源校验诊断已复制到剪贴板',
    snackPosition: SnackPosition.TOP,
    duration: const Duration(seconds: 2),
  );
}

class _StageReportTile extends StatelessWidget {
  const _StageReportTile({required this.report});

  final SourceCheckStageReport report;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = report.ok ? Colors.green : Colors.red;
    final failure = report.failureClass == null
        ? ''
        : ' · ${SourceCheckReport.failureLabel(report.failureClass!)}';
    final elapsed = report.elapsedMs <= 0 ? '' : ' · ${report.elapsedMs}ms';
    final message = report.message?.trim();
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.18)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  report.ok
                      ? Icons.check_circle_outline_rounded
                      : Icons.error_outline_rounded,
                  size: 16,
                  color: color,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '${report.stageName}${report.ok ? ' 通过' : ' 失败'}$failure$elapsed',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            if (message != null && message.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                message,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.72),
                ),
              ),
            ],
            if (report.diagnostics.isNotEmpty) ...[
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final entry in report.diagnostics.entries)
                    _DiagnosticChip(entry: entry),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SectionPanel extends StatelessWidget {
  const _SectionPanel({
    required this.title,
    required this.child,
    this.padding = const EdgeInsets.all(12),
  });

  final String title;
  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Padding(
            padding: padding,
            child: child,
          ),
        ],
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({
    required this.label,
    required this.count,
    required this.color,
    required this.icon,
  });

  final String label;
  final int count;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 5),
          Text(
            '$label $count',
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _FailureFilterChip extends StatelessWidget {
  const _FailureFilterChip({
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
    final theme = Theme.of(context);
    final color =
        selected ? theme.colorScheme.primary : theme.colorScheme.outline;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: selected
              ? theme.colorScheme.primary.withValues(alpha: 0.1)
              : theme.colorScheme.onSurface.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected
                ? theme.colorScheme.primary.withValues(alpha: 0.36)
                : theme.colorScheme.outlineVariant,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: selected ? theme.colorScheme.primary : null,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '$count',
              style: theme.textTheme.labelMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StageLine extends StatelessWidget {
  const _StageLine({
    required this.label,
    required this.success,
    required this.failed,
  });

  final String label;
  final int success;
  final int failed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(
            '通过 $success',
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.green.shade700,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '失败 $failed',
            style: theme.textTheme.bodySmall?.copyWith(
              color: failed > 0 ? Colors.red.shade700 : Colors.grey,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _DiagnosticChip extends StatelessWidget {
  const _DiagnosticChip({required this.entry});

  final MapEntry<String, Object?> entry;

  @override
  Widget build(BuildContext context) {
    final value = entry.value;
    final text = value == null ? entry.key : '${entry.key}: $value';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall,
      ),
    );
  }
}

class _EmptySectionText extends StatelessWidget {
  const _EmptySectionText({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color:
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55),
          ),
    );
  }
}

class _CountRow {
  const _CountRow({
    required this.label,
    required this.count,
    required this.failureClass,
  });

  final String label;
  final int count;
  final SourceCheckFailureClass? failureClass;

  bool get isUnclassified => failureClass == null;
}

class _StageCountRow {
  const _StageCountRow({
    required this.stage,
    required this.success,
    required this.failed,
  });

  final SourceCheckStage stage;
  final int success;
  final int failed;

  int get order {
    switch (stage) {
      case SourceCheckStage.search:
        return 0;
      case SourceCheckStage.discovery:
        return 1;
      case SourceCheckStage.detail:
        return 2;
      case SourceCheckStage.toc:
        return 3;
      case SourceCheckStage.content:
        return 4;
    }
  }
}

class _MutableStageCount {
  int success = 0;
  int failed = 0;
}

enum _ResultGroup { normal, failed, review, other }

class _ResultGroupBlock {
  const _ResultGroupBlock(this.group, this.results);

  final _ResultGroup group;
  final List<CheckResult> results;
}

List<_CountRow> _sortedFailureClassRows(
  Map<SourceCheckFailureClass?, int> counts,
) {
  return counts.entries
      .map(
        (entry) => _CountRow(
          label: _failureClassLabel(entry.key),
          count: entry.value,
          failureClass: entry.key,
        ),
      )
      .toList(growable: false)
    ..sort((a, b) {
      final countCompare = b.count.compareTo(a.count);
      if (countCompare != 0) return countCompare;
      return a.label.compareTo(b.label);
    });
}

bool _isIssueResult(CheckResult result) {
  return result.state == CheckState.failed ||
      result.state == CheckState.warning;
}

SourceCheckFailureClass? _failureClassOf(CheckResult result) {
  if (result.failureClass != null) return result.failureClass;
  for (final stage in result.stages) {
    if (!stage.ok && stage.failureClass != null) {
      return stage.failureClass;
    }
  }
  return null;
}

_ResultGroup _resultGroupOf(CheckResult result) {
  switch (result.state) {
    case CheckState.success:
      return _ResultGroup.normal;
    case CheckState.failed:
      return _failureClassOf(result) == SourceCheckFailureClass.cancelled
          ? _ResultGroup.other
          : _ResultGroup.failed;
    case CheckState.warning:
      return _ResultGroup.review;
    case CheckState.waiting:
    case CheckState.checking:
      return _ResultGroup.other;
  }
}

String _resultGroupLabel(_ResultGroup group) {
  switch (group) {
    case _ResultGroup.normal:
      return '正常';
    case _ResultGroup.failed:
      return '失败';
    case _ResultGroup.review:
      return '待复查';
    case _ResultGroup.other:
      return '取消/其他';
  }
}

Color _resultGroupColor(_ResultGroup group) {
  switch (group) {
    case _ResultGroup.normal:
      return Colors.green.shade700;
    case _ResultGroup.failed:
      return Colors.red.shade700;
    case _ResultGroup.review:
      return Colors.orange.shade800;
    case _ResultGroup.other:
      return Colors.blueGrey.shade700;
  }
}

IconData _resultGroupIcon(_ResultGroup group) {
  switch (group) {
    case _ResultGroup.normal:
      return Icons.check_circle_rounded;
    case _ResultGroup.failed:
      return Icons.error_rounded;
    case _ResultGroup.review:
      return Icons.info_rounded;
    case _ResultGroup.other:
      return Icons.more_horiz_rounded;
  }
}

String _failureClassLabel(SourceCheckFailureClass? failureClass) {
  if (failureClass == null) return '未分类';
  return SourceCheckReport.failureLabel(failureClass);
}

String _resultSummary(
  CheckResult result,
  SourceCheckFailureClass? failureClass,
) {
  final elapsed =
      result.elapsed == null ? '' : ' ${_formatElapsed(result.elapsed!)}';
  final failure = failureClass == null
      ? ''
      : '[${SourceCheckReport.failureLabel(failureClass)}] ';
  switch (result.state) {
    case CheckState.waiting:
      return '等待校验';
    case CheckState.checking:
      return '正在校验';
    case CheckState.success:
      return '校验成功$elapsed';
    case CheckState.warning:
      return '$failure${result.errorTag?.trim().isNotEmpty == true ? result.errorTag!.trim() : '待复查'}$elapsed';
    case CheckState.failed:
      return '$failure${result.errorTag?.trim().isNotEmpty == true ? result.errorTag!.trim() : '校验失败'}$elapsed';
  }
}

String _formatResultDiagnostics({
  required String sourceTitle,
  required CheckResult result,
  required SourceCheckFailureClass? failureClass,
  required String stageSummary,
}) {
  final lines = <String>[
    '书源: $sourceTitle',
    '状态: ${_resultGroupLabel(_resultGroupOf(result))}',
  ];
  if (failureClass != null) {
    lines.add('失败类型: ${SourceCheckReport.failureLabel(failureClass)}');
  }
  if (result.errorTag?.trim().isNotEmpty == true) {
    lines.add('错误标签: ${result.errorTag!.trim()}');
  }
  if (result.errorMsg?.trim().isNotEmpty == true) {
    lines.add('错误信息: ${result.errorMsg!.trim()}');
  }
  if ((result.errorTags ?? const <String>[]).isNotEmpty) {
    lines.add('结果标签: ${result.errorTags!.join('、')}');
  }
  if (result.elapsed != null) {
    lines.add('总耗时: ${_formatElapsed(result.elapsed!)}');
  }
  if (stageSummary.isNotEmpty) {
    lines.add('阶段摘要: $stageSummary');
  }

  if (result.stages.isNotEmpty) {
    lines.add('');
    lines.add('阶段明细:');
    for (final stage in result.stages) {
      final status = stage.ok ? '通过' : '失败';
      final failure = stage.failureClass == null
          ? ''
          : ' / ${SourceCheckReport.failureLabel(stage.failureClass!)}';
      final elapsed = stage.elapsedMs <= 0 ? '' : ' / ${stage.elapsedMs}ms';
      final message = stage.message?.trim();
      lines.add('- ${stage.stageName}: $status$failure$elapsed');
      if (message != null && message.isNotEmpty) {
        lines.add('  信息: $message');
      }
      if (stage.diagnostics.isNotEmpty) {
        lines.add(
          '  诊断: ${stage.diagnostics.entries.map((entry) {
            final value = entry.value;
            return value == null ? entry.key : '${entry.key}=$value';
          }).join(', ')}',
        );
      }
    }
  }

  return lines.join('\n');
}

Color _stateColor(CheckState state) {
  switch (state) {
    case CheckState.waiting:
      return Colors.orange.shade700;
    case CheckState.checking:
      return Colors.blue.shade700;
    case CheckState.success:
      return Colors.green.shade700;
    case CheckState.warning:
      return Colors.orange.shade800;
    case CheckState.failed:
      return Colors.red.shade700;
  }
}

IconData _stateIcon(CheckState state) {
  switch (state) {
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

String _formatElapsed(int elapsedMs) {
  if (elapsedMs < 1000) return '${elapsedMs}ms';
  return '${(elapsedMs / 1000).toStringAsFixed(1)}s';
}
