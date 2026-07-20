import 'package:drift/drift.dart';

/// 一次连续的阅读区间。切章或退出阅读器会结束当前会话。
class ReadingSessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get bookSourceId => integer()();
  TextColumn get bookName => text()();
  TextColumn get chapterName => text().nullable()();
  IntColumn get chapterIndex => integer()();
  TextColumn get startLocatorJson => text()();
  TextColumn get endLocatorJson => text().nullable()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get endedAt => dateTime().nullable()();
  IntColumn get durationSeconds => integer().withDefault(const Constant(0))();
}
