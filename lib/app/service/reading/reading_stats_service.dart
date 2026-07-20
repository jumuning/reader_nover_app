import '../../database/dao/reading_session_dao.dart';
import '../../database/drift/app_database.dart' as db;
import 'reading_stats.dart';

class ReadingStatsService {
  ReadingStatsService({
    db.AppDatabase? database,
    ReadingSessionDao? dao,
    DateTime Function()? now,
  })  : _dao = dao ??
            ReadingSessionDao(database: database ?? db.AppDatabase.instance),
        _now = now ?? DateTime.now;

  final ReadingSessionDao _dao;
  final DateTime Function() _now;

  Future<ReadingStatsSnapshot> load({DateTime? from, DateTime? to}) async {
    final sessions = await _dao.listCompleted(from: from, to: to);
    return aggregate(sessions, now: _now(), from: from, to: to);
  }

  static ReadingStatsSnapshot aggregate(
    Iterable<db.ReadingSession> sessions, {
    required DateTime now,
    DateTime? from,
    DateTime? to,
  }) {
    final byDay = <DateTime, _MutableDayStats>{};
    final byBook = <(int, String), _MutableBookStats>{};
    var totalSeconds = 0;
    var sessionCount = 0;
    final localFrom = from?.toLocal();
    final localTo = to?.toLocal();

    for (final session in sessions) {
      final recordedEnd = session.endedAt?.toLocal();
      if (recordedEnd == null) continue;
      final recordedStart = session.startedAt.toLocal();
      final start = localFrom != null && recordedStart.isBefore(localFrom)
          ? localFrom
          : recordedStart;
      final end = localTo != null && recordedEnd.isAfter(localTo)
          ? localTo
          : recordedEnd;
      if (!end.isAfter(start)) continue;

      sessionCount++;
      final seconds = end.difference(start).inSeconds;
      totalSeconds += seconds;
      final bookKey = (session.bookSourceId, session.bookName);
      final book = byBook.putIfAbsent(
        bookKey,
        () => _MutableBookStats(session.bookSourceId, session.bookName),
      );
      book.durationSeconds += seconds;
      book.sessionCount++;

      var cursor = start;
      final countedDays = <DateTime>{};
      while (cursor.isBefore(end)) {
        final day = DateTime(cursor.year, cursor.month, cursor.day);
        final nextDay = day.add(const Duration(days: 1));
        final segmentEnd = end.isBefore(nextDay) ? end : nextDay;
        final dayStats = byDay.putIfAbsent(day, _MutableDayStats.new);
        dayStats.durationSeconds += segmentEnd.difference(cursor).inSeconds;
        if (countedDays.add(day)) dayStats.sessionCount++;
        cursor = segmentEnd;
      }
    }

    final days = byDay.entries.toList()..sort((a, b) => a.key.compareTo(b.key));
    final books = byBook.values.toList()
      ..sort((a, b) => b.durationSeconds.compareTo(a.durationSeconds));
    final streaks = _calculateStreaks(byDay.keys, now);

    return ReadingStatsSnapshot(
      totalDuration: Duration(seconds: totalSeconds),
      sessionCount: sessionCount,
      currentStreakDays: streaks.$1,
      longestStreakDays: streaks.$2,
      daily: days
          .map((entry) => ReadingDayStats(
                day: entry.key,
                duration: Duration(seconds: entry.value.durationSeconds),
                sessionCount: entry.value.sessionCount,
              ))
          .toList(growable: false),
      books: books
          .map((book) => ReadingBookStats(
                bookSourceId: book.bookSourceId,
                bookName: book.bookName,
                duration: Duration(seconds: book.durationSeconds),
                sessionCount: book.sessionCount,
              ))
          .toList(growable: false),
    );
  }

  static (int, int) _calculateStreaks(Iterable<DateTime> values, DateTime now) {
    final days = values.toSet().toList()..sort();
    var longest = 0;
    var run = 0;
    DateTime? previous;
    for (final day in days) {
      run = previous != null && day.difference(previous).inDays == 1
          ? run + 1
          : 1;
      if (run > longest) longest = run;
      previous = day;
    }

    final today = DateTime(now.year, now.month, now.day);
    final activeDays = days.toSet();
    var cursor = activeDays.contains(today)
        ? today
        : today.subtract(const Duration(days: 1));
    var current = 0;
    while (activeDays.contains(cursor)) {
      current++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return (current, longest);
  }
}

class _MutableDayStats {
  int durationSeconds = 0;
  int sessionCount = 0;
}

class _MutableBookStats {
  _MutableBookStats(this.bookSourceId, this.bookName);
  final int bookSourceId;
  final String bookName;
  int durationSeconds = 0;
  int sessionCount = 0;
}
