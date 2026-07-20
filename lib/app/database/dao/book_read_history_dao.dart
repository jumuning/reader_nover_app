import 'package:drift/drift.dart' as drift;

import '../drift/app_database.dart' as db;

class BookReadHistoryDao {
  const BookReadHistoryDao({
    required db.AppDatabase database,
  }) : _database = database;

  final db.AppDatabase _database;

  Future<List<db.BookReadHistory>> listByBook({
    required int bookSourceId,
    required String bookName,
  }) {
    return (_database.select(_database.bookReadHistories)
          ..where((t) =>
              t.bookSourceId.equals(bookSourceId) &
              t.bookName.equals(bookName)))
        .get();
  }

  Future<int> insert(db.BookReadHistoriesCompanion history) {
    return _database.into(_database.bookReadHistories).insert(history);
  }

  Future<void> markChapterRead({
    required int bookSourceId,
    required String bookName,
    required String chapterName,
    required int chapterIndex,
  }) async {
    final existing = await (_database.select(_database.bookReadHistories)
          ..where((table) =>
              table.bookSourceId.equals(bookSourceId) &
              table.bookName.equals(bookName) &
              table.chapterIndex.equals(chapterIndex))
          ..limit(1))
        .getSingleOrNull();
    if (existing != null) return;
    await insert(
      db.BookReadHistoriesCompanion.insert(
        bookSourceId: bookSourceId,
        bookName: bookName,
        chapterName: drift.Value(chapterName),
        chapterIndex: chapterIndex,
      ),
    );
  }

  Future<int> updateById({
    required int id,
    required db.BookReadHistoriesCompanion history,
  }) {
    return (_database.update(_database.bookReadHistories)
          ..where((t) => t.id.equals(id)))
        .write(history);
  }

  Future<int> deleteByBook({
    required int bookSourceId,
    required String bookName,
  }) {
    return (_database.delete(_database.bookReadHistories)
          ..where((t) =>
              t.bookSourceId.equals(bookSourceId) &
              t.bookName.equals(bookName)))
        .go();
  }

  Future<int> deleteByBookChapter({
    required int bookSourceId,
    required String bookName,
    required int chapterIndex,
  }) {
    return (_database.delete(_database.bookReadHistories)
          ..where((t) =>
              t.bookSourceId.equals(bookSourceId) &
              t.bookName.equals(bookName) &
              t.chapterIndex.equals(chapterIndex)))
        .go();
  }
}
