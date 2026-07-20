import 'package:shared_preferences/shared_preferences.dart';

class BookshelfUpdateScheduleStore {
  static const String _lastRunAtMillisKey =
      'bookshelf_auto_update_last_run_at_ms';

  const BookshelfUpdateScheduleStore();

  Future<DateTime?> loadLastRunAt() async {
    final prefs = await SharedPreferences.getInstance();
    final millis = prefs.getInt(_lastRunAtMillisKey);
    if (millis == null || millis <= 0) {
      return null;
    }
    return DateTime.fromMillisecondsSinceEpoch(millis);
  }

  Future<bool> shouldRun({
    required Duration minInterval,
    DateTime? now,
  }) async {
    final lastRunAt = await loadLastRunAt();
    if (lastRunAt == null) return true;
    final effectiveNow = now ?? DateTime.now();
    return effectiveNow.difference(lastRunAt) >= minInterval;
  }

  Future<void> markRunAt(DateTime runAt) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastRunAtMillisKey, runAt.millisecondsSinceEpoch);
  }
}
