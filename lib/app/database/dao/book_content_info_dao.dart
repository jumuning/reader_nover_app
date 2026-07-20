import 'package:drift/drift.dart' as drift;

import '../drift/app_database.dart' as db;

class CachedChapterIdentity {
  const CachedChapterIdentity({
    required this.chapterIndex,
    required this.chapterName,
  });

  final int? chapterIndex;
  final String? chapterName;
}

class BookContentInfoDao {
  const BookContentInfoDao({
    required db.AppDatabase database,
  }) : _database = database;

  final db.AppDatabase _database;

  Future<db.BookContentInfo?> findByChapter({
    required int bookSourceId,
    required String bookName,
    required String chapterName,
  }) {
    return (_database.select(_database.bookContentInfos)
          ..where((t) =>
              t.bookSourceId.equals(bookSourceId) &
              t.name.equals(bookName) &
              t.chapterName.equals(chapterName)))
        .getSingleOrNull();
  }

  Future<db.BookContentInfo?> findLatestByBook({
    required int bookSourceId,
    required String bookName,
  }) {
    return (_database.select(_database.bookContentInfos)
          ..where((t) =>
              t.bookSourceId.equals(bookSourceId) & t.name.equals(bookName))
          ..orderBy([(t) => drift.OrderingTerm.desc(t.chapterIndex)])
          ..limit(1))
        .getSingleOrNull();
  }

  Future<List<db.BookContentInfo>> listByBook({
    required int bookSourceId,
    required String bookName,
  }) {
    return (_database.select(_database.bookContentInfos)
          ..where((t) =>
              t.bookSourceId.equals(bookSourceId) & t.name.equals(bookName)))
        .get();
  }

  Future<List<CachedChapterIdentity>> listCachedChapterIdentitiesByBook({
    required int bookSourceId,
    required String bookName,
  }) async {
    final rows = await (_database.selectOnly(_database.bookContentInfos)
          ..addColumns([
            _database.bookContentInfos.chapterIndex,
            _database.bookContentInfos.chapterName,
          ])
          ..where(
            _database.bookContentInfos.bookSourceId.equals(bookSourceId) &
                _database.bookContentInfos.name.equals(bookName),
          ))
        .get();

    return rows
        .map(
          (row) => CachedChapterIdentity(
            chapterIndex: row.read(_database.bookContentInfos.chapterIndex),
            chapterName: row.read(_database.bookContentInfos.chapterName),
          ),
        )
        .toList(growable: false);
  }

  Future<List<db.BookContentInfo>> listForTtsRoleScan({
    required int bookSourceId,
    required String bookName,
    int limit = 40,
  }) {
    final safeLimit = limit <= 0 ? 1 : limit;
    return (_database.select(_database.bookContentInfos)
          ..where((t) =>
              t.bookSourceId.equals(bookSourceId) & t.name.equals(bookName))
          ..orderBy([
            (t) => drift.OrderingTerm.asc(t.chapterIndex),
            (t) => drift.OrderingTerm.asc(t.id),
          ])
          ..limit(safeLimit))
        .get();
  }

  Future<List<db.BookContentInfo>> listByBooks({
    required Set<int> bookSourceIds,
    required Set<String> bookNames,
  }) {
    if (bookSourceIds.isEmpty || bookNames.isEmpty) {
      return Future.value(const <db.BookContentInfo>[]);
    }
    return (_database.select(_database.bookContentInfos)
          ..where((t) =>
              t.bookSourceId.isIn(bookSourceIds) & t.name.isIn(bookNames))
          ..orderBy([
            (t) => drift.OrderingTerm.asc(t.bookSourceId),
            (t) => drift.OrderingTerm.asc(t.name),
            (t) => drift.OrderingTerm.desc(t.chapterIndex),
          ]))
        .get();
  }

  Future<int> deleteById(int id) {
    return (_database.delete(_database.bookContentInfos)
          ..where((t) => t.id.equals(id)))
        .go();
  }

  Future<int> deleteByBook({
    required int bookSourceId,
    required String bookName,
  }) {
    return (_database.delete(_database.bookContentInfos)
          ..where((t) =>
              t.bookSourceId.equals(bookSourceId) & t.name.equals(bookName)))
        .go();
  }

  Future<int> deleteByChapter({
    required int bookSourceId,
    required String bookName,
    required String chapterName,
    required int chapterIndex,
  }) {
    return (_database.delete(_database.bookContentInfos)
          ..where((t) =>
              t.bookSourceId.equals(bookSourceId) &
              t.name.equals(bookName) &
              t.chapterName.equals(chapterName) &
              t.chapterIndex.equals(chapterIndex)))
        .go();
  }

  Future<void> upsert({
    required int bookSourceId,
    required String bookName,
    required String chapterName,
    required int? chapterIndex,
    required String content,
  }) {
    return _database.into(_database.bookContentInfos).insertOnConflictUpdate(
          db.BookContentInfosCompanion.insert(
            bookSourceId: bookSourceId,
            name: drift.Value(bookName),
            chapterName: drift.Value(chapterName),
            chapterIndex: drift.Value(chapterIndex),
            bookContent: drift.Value(content),
          ),
        );
  }

  Future<void> bulkUpsert(List<db.BookContentInfosCompanion> contents) async {
    if (contents.isEmpty) return;
    await _database.batch((batch) {
      batch.insertAllOnConflictUpdate(_database.bookContentInfos, contents);
    });
  }

  Future<int> updateById({
    required int id,
    required db.BookContentInfosCompanion content,
  }) {
    return (_database.update(_database.bookContentInfos)
          ..where((t) => t.id.equals(id)))
        .write(content);
  }
}
