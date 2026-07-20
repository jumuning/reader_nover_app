import 'package:shared_preferences/shared_preferences.dart';

abstract interface class ReadingPlanStore {
  Future<int?> loadDailyGoalMinutes();
  Future<void> saveDailyGoalMinutes(int minutes);
}

class SharedPreferencesReadingPlanStore implements ReadingPlanStore {
  static const String dailyGoalMinutesKey = 'reading_plan.daily_goal_minutes';

  @override
  Future<int?> loadDailyGoalMinutes() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getInt(dailyGoalMinutesKey);
  }

  @override
  Future<void> saveDailyGoalMinutes(int minutes) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setInt(dailyGoalMinutesKey, minutes);
  }
}
