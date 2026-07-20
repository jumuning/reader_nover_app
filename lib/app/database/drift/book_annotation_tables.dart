import 'package:drift/drift.dart';

class BookAnnotations extends Table {
  TextColumn get id => text()();
  IntColumn get bookSourceId => integer()();
  TextColumn get bookName => text()();
  IntColumn get chapterIndex => integer()();
  TextColumn get chapterName => text().withDefault(const Constant(''))();
  TextColumn get locatorJson => text()();
  TextColumn get type => text()();
  TextColumn get excerpt => text().withDefault(const Constant(''))();
  TextColumn get note => text().withDefault(const Constant(''))();
  IntColumn get colorValue => integer().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
        {bookSourceId, bookName, chapterIndex, locatorJson, type},
      ];
}
