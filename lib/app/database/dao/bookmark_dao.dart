import 'package:drift/drift.dart' as drift;

import '../drift/app_database.dart' as db;

class BookmarkDao {
  const BookmarkDao({
    required db.AppDatabase database,
  }) : _database = database;

  final db.AppDatabase _database;

  Future<List<db.Bookmark>> listByBook({
    required int bookSourceId,
    required String bookName,
  }) {
    return (_database.select(_database.bookmarks)
          ..where((t) =>
              t.bookSourceId.equals(bookSourceId) & t.bookName.equals(bookName))
          ..orderBy([(t) => drift.OrderingTerm.asc(t.createTime)]))
        .get();
  }

  Future<int> add({
    required int bookSourceId,
    required String bookName,
    required String locatorJson,
    required String chapterName,
    required String bookText,
    String content = '',
    DateTime? createTime,
  }) {
    return _database.into(_database.bookmarks).insert(
          db.BookmarksCompanion.insert(
            bookSourceId: bookSourceId,
            bookName: bookName,
            locatorJson: locatorJson,
            chapterName: drift.Value(chapterName),
            bookText: drift.Value(bookText),
            content: drift.Value(content),
            createTime: createTime ?? DateTime.now(),
          ),
        );
  }

  Future<int> updateContent({
    required int bookmarkId,
    required String content,
  }) {
    return (_database.update(_database.bookmarks)
          ..where((t) => t.id.equals(bookmarkId)))
        .write(db.BookmarksCompanion(content: drift.Value(content)));
  }

  Future<int> updateById({
    required int bookmarkId,
    required db.BookmarksCompanion bookmark,
  }) {
    return (_database.update(_database.bookmarks)
          ..where((t) => t.id.equals(bookmarkId)))
        .write(bookmark);
  }

  Future<int> deleteById(int bookmarkId) {
    return (_database.delete(_database.bookmarks)
          ..where((t) => t.id.equals(bookmarkId)))
        .go();
  }

  Future<int> deleteByBook({
    required int bookSourceId,
    required String bookName,
  }) {
    return (_database.delete(_database.bookmarks)
          ..where((t) =>
              t.bookSourceId.equals(bookSourceId) &
              t.bookName.equals(bookName)))
        .go();
  }
}
