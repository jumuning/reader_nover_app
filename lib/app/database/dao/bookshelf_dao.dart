import 'package:drift/drift.dart' as drift;

import '../drift/app_database.dart' as db;

class BookshelfDao {
  const BookshelfDao({
    required db.AppDatabase database,
  }) : _database = database;

  final db.AppDatabase _database;

  Future<List<db.Book>> listBooks() {
    return (_database.select(_database.books)
          ..orderBy([(t) => drift.OrderingTerm.desc(t.id)]))
        .get();
  }

  /// 书架主列表按最近阅读优先返回，直接匹配 `books(last_read_time desc, id desc)` 索引。
  Future<List<db.Book>> listBooksForBookshelf() {
    return (_database.select(_database.books)
          ..orderBy([
            (t) => drift.OrderingTerm.desc(t.lastReadTime),
            (t) => drift.OrderingTerm.desc(t.id),
          ]))
        .get();
  }

  Future<List<db.Book>> listBooksByIds(Iterable<int> bookIds) {
    final ids = bookIds.toSet().toList(growable: false);
    if (ids.isEmpty) return Future.value(const <db.Book>[]);
    return (_database.select(_database.books)..where((t) => t.id.isIn(ids)))
        .get();
  }

  Future<db.Book?> findBook({
    required int bookSourceId,
    required String bookName,
  }) {
    return (_database.select(_database.books)
          ..where((t) =>
              t.bookSourceId.equals(bookSourceId) & t.name.equals(bookName))
          ..orderBy([(t) => drift.OrderingTerm.desc(t.id)])
          ..limit(1))
        .getSingleOrNull();
  }

  Future<List<db.Book>> listBooksBySourceAndName({
    required int bookSourceId,
    required String bookName,
  }) {
    return (_database.select(_database.books)
          ..where((t) =>
              t.bookSourceId.equals(bookSourceId) & t.name.equals(bookName)))
        .get();
  }

  Future<int> insertBook(db.BooksCompanion book) {
    return _database.into(_database.books).insert(book);
  }

  Future<int> updateBook({
    required int bookId,
    required db.BooksCompanion book,
  }) {
    return (_database.update(_database.books)
          ..where((t) => t.id.equals(bookId)))
        .write(book);
  }

  /// 更新置顶序：customOrder > 0 视为置顶，数值越大越靠前。
  Future<int> updateCustomOrder({
    required int bookId,
    required int customOrder,
  }) {
    return updateBook(
      bookId: bookId,
      book: db.BooksCompanion(
        customOrder: drift.Value(customOrder),
      ),
    );
  }

  Future<void> updateCustomOrders(Map<int, int> ordersByBookId) async {
    if (ordersByBookId.isEmpty) return;
    await _database.batch((batch) {
      for (final entry in ordersByBookId.entries) {
        batch.update(
          _database.books,
          db.BooksCompanion(customOrder: drift.Value(entry.value)),
          where: (table) => table.id.equals(entry.key),
        );
      }
    });
  }

  Future<int> maxCustomOrder() async {
    final rows = await (_database.select(_database.books)
          ..orderBy([(t) => drift.OrderingTerm.desc(t.customOrder)])
          ..limit(1))
        .get();
    if (rows.isEmpty) return 0;
    return rows.first.customOrder;
  }

  Future<int> updateReadSummaryBySourceAndName({
    required int bookSourceId,
    required String bookName,
    required int chapterIndex,
    required int pageIndex,
    required DateTime lastReadTime,
  }) {
    return (_database.update(_database.books)
          ..where((t) =>
              t.bookSourceId.equals(bookSourceId) & t.name.equals(bookName)))
        .write(
      db.BooksCompanion(
        durChapterIndex: drift.Value(chapterIndex),
        durChapterPos: drift.Value(pageIndex),
        lastReadTime: drift.Value(lastReadTime),
      ),
    );
  }

  Future<int> deleteBookById(int bookId) {
    return (_database.delete(_database.books)
          ..where((t) => t.id.equals(bookId)))
        .go();
  }

  Future<int> deleteBooksBySourceAndName({
    required int bookSourceId,
    required String bookName,
  }) {
    return (_database.delete(_database.books)
          ..where((t) =>
              t.bookSourceId.equals(bookSourceId) & t.name.equals(bookName)))
        .go();
  }

  Future<List<db.BookChapter>> listChaptersByBookId(int bookId) {
    return (_database.select(_database.bookChapters)
          ..where((t) => t.bookId.equals(bookId))
          ..orderBy([(t) => drift.OrderingTerm.asc(t.chapterIndex)]))
        .get();
  }

  Future<List<db.BookChapter>> listChaptersByBookIds(Iterable<int> bookIds) {
    final ids = bookIds.toSet().toList(growable: false);
    if (ids.isEmpty) return Future.value(const <db.BookChapter>[]);
    return (_database.select(_database.bookChapters)
          ..where((t) => t.bookId.isIn(ids))
          ..orderBy([
            (t) => drift.OrderingTerm.asc(t.bookId),
            (t) => drift.OrderingTerm.asc(t.chapterIndex),
          ]))
        .get();
  }

  Future<void> replaceChapters({
    required int bookId,
    required List<db.BookChaptersCompanion> chapters,
  }) async {
    await deleteChaptersByBookId(bookId);
    if (chapters.isEmpty) return;
    await _database.batch((batch) {
      batch.insertAll(_database.bookChapters, chapters);
    });
  }

  Future<void> insertChapters(List<db.BookChaptersCompanion> chapters) async {
    if (chapters.isEmpty) return;
    await _database.batch((batch) {
      batch.insertAll(_database.bookChapters, chapters);
    });
  }

  Future<int> deleteChaptersByBookId(int bookId) {
    return (_database.delete(_database.bookChapters)
          ..where((t) => t.bookId.equals(bookId)))
        .go();
  }
}
