class ReadingDayStats {
  const ReadingDayStats({
    required this.day,
    required this.duration,
    required this.sessionCount,
  });

  final DateTime day;
  final Duration duration;
  final int sessionCount;
}

class ReadingBookStats {
  const ReadingBookStats({
    required this.bookSourceId,
    required this.bookName,
    required this.duration,
    required this.sessionCount,
  });

  final int bookSourceId;
  final String bookName;
  final Duration duration;
  final int sessionCount;
}

class ReadingStatsSnapshot {
  const ReadingStatsSnapshot({
    required this.totalDuration,
    required this.sessionCount,
    required this.currentStreakDays,
    required this.longestStreakDays,
    required this.daily,
    required this.books,
  });

  final Duration totalDuration;
  final int sessionCount;
  final int currentStreakDays;
  final int longestStreakDays;
  final List<ReadingDayStats> daily;
  final List<ReadingBookStats> books;

  Duration get averageSessionDuration => sessionCount == 0
      ? Duration.zero
      : Duration(seconds: totalDuration.inSeconds ~/ sessionCount);
}
