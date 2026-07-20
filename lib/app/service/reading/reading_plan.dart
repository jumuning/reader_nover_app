class ReadingPlanSnapshot {
  const ReadingPlanSnapshot({
    required this.dailyGoal,
    required this.todayDuration,
    required this.completionRate,
    required this.goalStreakDays,
    required this.weekGoalDays,
    required this.suggestedSession,
    this.suggestedBookName,
  });

  final Duration dailyGoal;
  final Duration todayDuration;
  final double completionRate;
  final int goalStreakDays;
  final int weekGoalDays;
  final Duration suggestedSession;
  final String? suggestedBookName;

  bool get isTodayCompleted => completionRate >= 1;
  Duration get remainingToday {
    final remaining = dailyGoal - todayDuration;
    return remaining.isNegative ? Duration.zero : remaining;
  }
}
