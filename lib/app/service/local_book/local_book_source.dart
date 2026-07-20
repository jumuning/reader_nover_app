import 'package:drift/drift.dart' as drift;

import '../../database/dao/book_source_dao.dart';
import '../../database/drift/app_database.dart' as db;
import 'local_book_constants.dart';

class LocalBookSource {
  LocalBookSource({
    db.AppDatabase? database,
  }) : _database = database ?? db.AppDatabase.instance;

  final db.AppDatabase _database;
  late final BookSourceDao _bookSourceDao = BookSourceDao(database: _database);

  Future<db.BookSource> ensureExists() async {
    final existing = await _bookSourceDao.findById(LocalBookConstants.sourceId);
    if (existing != null) return existing;

    await _bookSourceDao.upsert(
      db.BookSourcesCompanion.insert(
        id: const drift.Value(LocalBookConstants.sourceId),
        bookSourceName: LocalBookConstants.sourceName,
        bookSourceUrl: LocalBookConstants.sourceUrl,
        bookSourceGroup: const drift.Value(LocalBookConstants.bookGroup),
        bookSourceComment: const drift.Value('本地导入书籍的保留书源'),
        enabled: const drift.Value(false),
        enabledExplore: const drift.Value(false),
        isEnabled: const drift.Value(false),
        bookSourceType: const drift.Value(0),
      ),
    );

    return (await _bookSourceDao.findById(LocalBookConstants.sourceId))!;
  }
}
