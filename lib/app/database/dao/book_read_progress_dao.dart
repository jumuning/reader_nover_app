import 'package:drift/drift.dart' as drift;

import '../drift/app_database.dart' as db;

class BookReadProgressDao {
  const BookReadProgressDao({
    required db.AppDatabase database,
  }) : _database = database;

  final db.AppDatabase _database;

  Future<db.BookReadProgressesData?> findByBook({
    required int bookSourceId,
    required String bookName,
  }) {
    return (_database.select(_database.bookReadProgresses)
          ..where((t) =>
              t.bookSourceId.equals(bookSourceId) & t.bookName.equals(bookName))
          ..orderBy([
            (t) => drift.OrderingTerm.desc(t.id),
            (t) => drift.OrderingTerm.desc(t.updateTime),
          ])
          ..limit(1))
        .getSingleOrNull();
  }

  Future<List<db.BookReadProgressesData>> listByBooks({
    required Set<int> bookSourceIds,
    required Set<String> bookNames,
  }) {
    if (bookSourceIds.isEmpty || bookNames.isEmpty) {
      return Future.value(const <db.BookReadProgressesData>[]);
    }
    return (_database.select(_database.bookReadProgresses)
          ..where((t) =>
              t.bookSourceId.isIn(bookSourceIds) & t.bookName.isIn(bookNames))
          ..orderBy([
            (t) => drift.OrderingTerm.desc(t.id),
            (t) => drift.OrderingTerm.desc(t.updateTime),
          ]))
        .get();
  }

  Future<void> save({
    required int bookSourceId,
    required String bookName,
    required String? chapterName,
    required int chapterIndex,
    required String locatorJson,
    DateTime? updateTime,
  }) {
    return _database.transaction(() async {
      await deleteByBook(
        bookSourceId: bookSourceId,
        bookName: bookName,
      );
      await _database.into(_database.bookReadProgresses).insert(
            db.BookReadProgressesCompanion.insert(
              bookSourceId: bookSourceId,
              bookName: bookName,
              chapterName: drift.Value(chapterName),
              chapterIndex: chapterIndex,
              locatorJson: locatorJson,
              updateTime: updateTime ?? DateTime.now(),
            ),
          );
    });
  }

  Future<int> deleteByBook({
    required int bookSourceId,
    required String bookName,
  }) {
    return (_database.delete(_database.bookReadProgresses)
          ..where((t) =>
              t.bookSourceId.equals(bookSourceId) &
              t.bookName.equals(bookName)))
        .go();
  }
}
