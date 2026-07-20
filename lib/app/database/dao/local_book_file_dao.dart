import 'package:drift/drift.dart' as drift;

import '../drift/app_database.dart' as db;

class LocalBookFileDao {
  const LocalBookFileDao({
    required db.AppDatabase database,
  }) : _database = database;

  final db.AppDatabase _database;

  Future<List<db.LocalBookFile>> listAll() {
    return _database.select(_database.localBookFiles).get();
  }

  Future<db.LocalBookFile?> findByBookId(int bookId) {
    return (_database.select(_database.localBookFiles)
          ..where((t) => t.bookId.equals(bookId)))
        .getSingleOrNull();
  }

  Future<List<db.LocalBookFile>> listByBookIds(Iterable<int> bookIds) {
    final ids = bookIds.toSet().toList(growable: false);
    if (ids.isEmpty) return Future.value(const <db.LocalBookFile>[]);
    return (_database.select(_database.localBookFiles)
          ..where((t) => t.bookId.isIn(ids)))
        .get();
  }

  Future<void> upsert(db.LocalBookFilesCompanion file) {
    return _database
        .into(_database.localBookFiles)
        .insertOnConflictUpdate(file);
  }

  Future<int> deleteByBookId(int bookId) {
    return (_database.delete(_database.localBookFiles)
          ..where((t) => t.bookId.equals(bookId)))
        .go();
  }

  Future<int> updateByBookId({
    required int bookId,
    required db.LocalBookFilesCompanion file,
  }) {
    return (_database.update(_database.localBookFiles)
          ..where((t) => t.bookId.equals(bookId)))
        .write(file);
  }

  Future<void> save({
    required int bookId,
    required String originalFileName,
    required String storedFilePath,
    required String format,
    required String? charset,
    required int fileSize,
    required String? fileHash,
    required DateTime importTime,
    required DateTime? sourceModifiedTime,
  }) {
    return upsert(
      db.LocalBookFilesCompanion.insert(
        bookId: drift.Value(bookId),
        originalFileName: originalFileName,
        storedFilePath: storedFilePath,
        format: format,
        charset: drift.Value(charset),
        fileSize: fileSize,
        fileHash: drift.Value(fileHash),
        importTime: importTime,
        sourceModifiedTime: drift.Value(sourceModifiedTime),
      ),
    );
  }
}
