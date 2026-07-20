import 'reading_plan.dart';
import 'reading_plan_store.dart';
import 'reading_stats.dart';
import 'reading_stats_service.dart';

class ReadingPlanService {
  ReadingPlanService({
    ReadingStatsService? statsService,
    ReadingPlanStore? store,
    DateTime Function()? now,
  })  : _statsService = statsService,
        _store = store ?? SharedPreferencesReadingPlanStore(),
        _now = now ?? DateTime.now;

  static const int defaultDailyGoalMinutes = 30;
  static const int minimumDailyGoalMinutes = 5;
  static const int maximumDailyGoalMinutes = 180;

  final ReadingStatsService? _statsService;
  final ReadingPlanStore _store;
  final DateTime Function() _now;

  Future<ReadingPlanSnapshot> load({ReadingStatsSnapshot? stats}) async {
    final goalMinutes =
        await _store.loadDailyGoalMinutes() ?? defaultDailyGoalMinutes;
    final resolvedStats =
        stats ?? await (_statsService ?? ReadingStatsService()).load();
    return calculate(
      stats: resolvedStats,
      dailyGoal: Duration(minutes: goalMinutes),
      now: _now(),
    );
  }

  Future<void> setDailyGoalMinutes(int minutes) {
    return _store.saveDailyGoalMinutes(
      minutes.clamp(minimumDailyGoalMinutes, maximumDailyGoalMinutes),
    );
  }

  static ReadingPlanSnapshot calculate({
    required ReadingStatsSnapshot stats,
    required Duration dailyGoal,
    required DateTime now,
  }) {
    final today = DateTime(now.year, now.month, now.day);
    final durations = <DateTime, Duration>{
      for (final day in stats.daily)
        DateTime(day.day.year, day.day.month, day.day.day): day.duration,
    };
    final todayDuration = durations[today] ?? Duration.zero;
    final goalSeconds = dailyGoal.inSeconds;
    final rate = goalSeconds <= 0 ? 0.0 : todayDuration.inSeconds / goalSeconds;

    final monday = today.subtract(Duration(days: today.weekday - 1));
    var weekGoalDays = 0;
    for (var offset = 0; offset <= today.weekday - 1; offset++) {
      final day = monday.add(Duration(days: offset));
      if ((durations[day] ?? Duration.zero) >= dailyGoal) weekGoalDays++;
    }

    var streak = 0;
    var cursor = todayDuration >= dailyGoal
        ? today
        : today.subtract(const Duration(days: 1));
    while ((durations[cursor] ?? Duration.zero) >= dailyGoal) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }

    final remaining = dailyGoal - todayDuration;
    final basis = remaining.isNegative || remaining == Duration.zero
        ? stats.averageSessionDuration
        : remaining;
    final suggestedMinutes = basis.inMinutes.clamp(5, 45).toInt();

    return ReadingPlanSnapshot(
      dailyGoal: dailyGoal,
      todayDuration: todayDuration,
      completionRate: rate,
      goalStreakDays: streak,
      weekGoalDays: weekGoalDays,
      suggestedSession: Duration(minutes: suggestedMinutes),
      suggestedBookName: stats.books.firstOrNull?.bookName,
    );
  }
}
