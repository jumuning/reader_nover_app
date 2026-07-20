import 'package:flutter/material.dart';

import '../../app/service/reading/reading_stats.dart';
import '../../app/service/reading/reading_stats_service.dart';
import '../../app/l10n/generated/l10n.dart';
import '../../app/service/reading/reading_plan.dart';
import '../../app/service/reading/reading_plan_service.dart';

typedef ReadingStatsLoader = Future<ReadingStatsSnapshot> Function();
typedef ReadingPlanLoader = Future<ReadingPlanSnapshot> Function(
  ReadingStatsSnapshot stats,
);
typedef DailyGoalSetter = Future<void> Function(int minutes);

class ReadingStatsPage extends StatefulWidget {
  const ReadingStatsPage({
    super.key,
    this.loader,
    this.planLoader,
    this.dailyGoalSetter,
  });

  final ReadingStatsLoader? loader;
  final ReadingPlanLoader? planLoader;
  final DailyGoalSetter? dailyGoalSetter;

  @override
  State<ReadingStatsPage> createState() => _ReadingStatsPageState();
}

class _ReadingStatsPageState extends State<ReadingStatsPage> {
  late Future<ReadingStatsSnapshot> _snapshot;

  @override
  void initState() {
    super.initState();
    _snapshot = _load();
  }

  Future<ReadingStatsSnapshot> _load() {
    return widget.loader?.call() ?? ReadingStatsService().load();
  }

  Future<void> _refresh() async {
    final next = _load();
    setState(() => _snapshot = next);
    await next;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).readingStats),
        actions: [
          IconButton(
            tooltip: S.of(context).refresh,
            onPressed: _refresh,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: FutureBuilder<ReadingStatsSnapshot>(
        future: _snapshot,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _StatsError(onRetry: _refresh);
          }
          return RefreshIndicator(
            onRefresh: _refresh,
            child: _StatsContent(
              stats: snapshot.requireData,
              planLoader: widget.planLoader,
              dailyGoalSetter: widget.dailyGoalSetter,
            ),
          );
        },
      ),
    );
  }
}

class _StatsContent extends StatelessWidget {
  const _StatsContent({
    required this.stats,
    this.planLoader,
    this.dailyGoalSetter,
  });

  final ReadingStatsSnapshot stats;
  final ReadingPlanLoader? planLoader;
  final DailyGoalSetter? dailyGoalSetter;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final recentDays = List.generate(
      7,
      (index) => DateTime(now.year, now.month, now.day)
          .subtract(Duration(days: 6 - index)),
    );
    final dailyByDate = {
      for (final item in stats.daily) _dateKey(item.day): item
    };
    final recent = recentDays
        .map((day) => dailyByDate[_dateKey(day)]?.duration ?? Duration.zero)
        .toList(growable: false);

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      children: [
        _ReadingPlanPanel(
          stats: stats,
          loader: planLoader,
          goalSetter: dailyGoalSetter,
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 700 ? 4 : 2;
            return GridView.count(
              crossAxisCount: columns,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: columns == 4 ? 1.35 : 1.2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              children: [
                _MetricTile(
                  icon: Icons.schedule_rounded,
                  label: S.of(context).totalReadingTime,
                  value: _formatDuration(stats.totalDuration),
                ),
                _MetricTile(
                  icon: Icons.menu_book_rounded,
                  label: S.of(context).readingSessions,
                  value: S.of(context).timesCount(stats.sessionCount),
                ),
                _MetricTile(
                  icon: Icons.timelapse_rounded,
                  label: S.of(context).averageDuration,
                  value: _formatDuration(stats.averageSessionDuration),
                ),
                _MetricTile(
                  icon: Icons.local_fire_department_outlined,
                  label: S.of(context).readingStreak,
                  value: S.of(context).daysCount(stats.currentStreakDays),
                  detail: S.of(context).longestDays(stats.longestStreakDays),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 24),
        _SectionTitle(
            title: S.of(context).lastSevenDays, icon: Icons.bar_chart_rounded),
        const SizedBox(height: 12),
        _WeeklyBars(days: recentDays, durations: recent),
        const SizedBox(height: 28),
        _SectionTitle(
            title: S.of(context).statsByBook,
            icon: Icons.library_books_outlined),
        const SizedBox(height: 8),
        if (stats.books.isEmpty)
          const _EmptyStats()
        else
          ...stats.books.asMap().entries.map(
                (entry) => _BookStatsRow(
                  rank: entry.key + 1,
                  stats: entry.value,
                  maxDuration: stats.books.first.duration,
                ),
              ),
      ],
    );
  }
}

class _ReadingPlanPanel extends StatefulWidget {
  const _ReadingPlanPanel({
    required this.stats,
    this.loader,
    this.goalSetter,
  });

  final ReadingStatsSnapshot stats;
  final ReadingPlanLoader? loader;
  final DailyGoalSetter? goalSetter;

  @override
  State<_ReadingPlanPanel> createState() => _ReadingPlanPanelState();
}

class _ReadingPlanPanelState extends State<_ReadingPlanPanel> {
  late Future<ReadingPlanSnapshot> _plan = _load();

  Future<ReadingPlanSnapshot> _load() {
    return widget.loader?.call(widget.stats) ??
        ReadingPlanService().load(stats: widget.stats);
  }

  Future<void> _changeGoal(int currentMinutes) async {
    final selected = await showModalBottomSheet<int>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(S.of(context).dailyReadingGoal,
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [15, 30, 45, 60, 90].map((minutes) {
                  return ChoiceChip(
                    label: Text(S.of(context).minutesCount(minutes)),
                    selected: minutes == currentMinutes,
                    onSelected: (_) => Navigator.pop(context, minutes),
                  );
                }).toList(growable: false),
              ),
            ],
          ),
        ),
      ),
    );
    if (selected == null) return;
    await (widget.goalSetter?.call(selected) ??
        ReadingPlanService().setDailyGoalMinutes(selected));
    if (!mounted) return;
    setState(() => _plan = _load());
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ReadingPlanSnapshot>(
      future: _plan,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox(
            height: 116,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final plan = snapshot.requireData;
        final theme = Theme.of(context);
        final progress = plan.completionRate.clamp(0.0, 1.0);
        return Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.flag_outlined, color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(S.of(context).todayPlan,
                          style: theme.textTheme.titleMedium),
                    ),
                    IconButton(
                      tooltip: S.of(context).adjustGoal,
                      onPressed: () => _changeGoal(plan.dailyGoal.inMinutes),
                      icon: const Icon(Icons.tune_rounded),
                    ),
                  ],
                ),
                Text(
                  '${_formatDuration(plan.todayDuration)} / ${_formatDuration(plan.dailyGoal)}',
                  style: theme.textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 16,
                  runSpacing: 6,
                  children: [
                    Text(S.of(context).goalStreakDays(plan.goalStreakDays)),
                    Text(S.of(context).weekGoalDays(plan.weekGoalDays)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  plan.isTodayCompleted
                      ? S.of(context).todayGoalReached(
                          _formatDuration(plan.suggestedSession))
                      : S.of(context).todayGoalRemaining(
                          _formatDuration(plan.remainingToday),
                          _formatDuration(plan.suggestedSession)),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                if (plan.suggestedBookName != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    S.of(context).continueReadingBook(plan.suggestedBookName!),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.icon,
    required this.label,
    required this.value,
    this.detail,
  });

  final IconData icon;
  final String label;
  final String value;
  final String? detail;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, size: 22, color: theme.colorScheme.primary),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: theme.textTheme.titleLarge),
                Text(
                  detail == null ? label : '$label · $detail',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _WeeklyBars extends StatelessWidget {
  const _WeeklyBars({required this.days, required this.durations});

  final List<DateTime> days;
  final List<Duration> durations;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxSeconds = durations.fold<int>(0, (max, value) {
      return value.inSeconds > max ? value.inSeconds : max;
    });
    return SizedBox(
      height: 190,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(days.length, (index) {
          final seconds = durations[index].inSeconds;
          final ratio = maxSeconds == 0 ? 0.0 : seconds / maxSeconds;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    seconds == 0 ? '' : _formatCompact(durations[index]),
                    maxLines: 1,
                    style: theme.textTheme.labelSmall,
                  ),
                  const SizedBox(height: 5),
                  Container(
                    height: 112 * ratio + 4,
                    decoration: BoxDecoration(
                      color: seconds == 0
                          ? theme.colorScheme.surfaceContainerHighest
                          : theme.colorScheme.primary,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    '${days[index].month}/${days[index].day}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _BookStatsRow extends StatelessWidget {
  const _BookStatsRow({
    required this.rank,
    required this.stats,
    required this.maxDuration,
  });

  final int rank;
  final ReadingBookStats stats;
  final Duration maxDuration;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = maxDuration.inSeconds == 0
        ? 0.0
        : stats.duration.inSeconds / maxDuration.inSeconds;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        children: [
          SizedBox(
            width: 30,
            child: Text('$rank', style: theme.textTheme.titleMedium),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        stats.bookName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(_formatDuration(stats.duration)),
                  ],
                ),
                const SizedBox(height: 6),
                LinearProgressIndicator(
                  value: progress,
                  minHeight: 5,
                  borderRadius: BorderRadius.circular(3),
                ),
                const SizedBox(height: 4),
                Text(
                  S.of(context).sessionsCount(stats.sessionCount),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.icon});
  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 8),
        Text(title, style: Theme.of(context).textTheme.titleMedium),
      ],
    );
  }
}

class _EmptyStats extends StatelessWidget {
  const _EmptyStats();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 36),
      child: Column(
        children: [
          Icon(
            Icons.auto_stories_outlined,
            size: 38,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 10),
          Text(S.of(context).noReadingRecords),
        ],
      ),
    );
  }
}

class _StatsError extends StatelessWidget {
  const _StatsError({required this.onRetry});
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(S.of(context).readingStatsLoadFailed),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: Text(S.of(context).retry),
          ),
        ],
      ),
    );
  }
}

String _dateKey(DateTime value) => '${value.year}-${value.month}-${value.day}';

String _formatDuration(Duration duration) {
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);
  if (hours > 0) {
    return minutes == 0
        ? S.current.hoursCount(hours)
        : S.current.hoursMinutesCount(hours, minutes);
  }
  return S.current.minutesCount(duration.inMinutes);
}

String _formatCompact(Duration duration) {
  if (duration.inHours > 0) return '${duration.inHours}h';
  return '${duration.inMinutes}m';
}
