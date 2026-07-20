import 'package:drift/drift.dart' as drift;

import '../drift/app_database.dart' as db;

class BookSourceDao {
  const BookSourceDao({
    required db.AppDatabase database,
  }) : _database = database;

  final db.AppDatabase _database;

  Future<List<db.BookSource>> listAll() {
    return _database.select(_database.bookSources).get();
  }

  Future<bool> hasAny() async {
    final results =
        await (_database.select(_database.bookSources)..limit(1)).get();
    return results.isNotEmpty;
  }

  Future<List<db.BookSource>> listByIds(Iterable<int> ids) {
    final idList = ids.toSet().toList(growable: false);
    if (idList.isEmpty) return Future.value(const <db.BookSource>[]);
    return (_database.select(_database.bookSources)
          ..where((t) => t.id.isIn(idList)))
        .get();
  }

  Future<List<db.BookSource>> listEnabled() {
    return (_database.select(_database.bookSources)
          ..where((t) => t.enabled.equals(true))
          ..orderBy([(t) => drift.OrderingTerm.asc(t.customOrder)]))
        .get();
  }

  Future<List<db.BookSource>> listEnabledSearch() async {
    final sources = await listEnabled();
    return sources
        .where((source) => source.searchUrl?.trim().isNotEmpty == true)
        .toList(growable: false);
  }

  Future<List<db.BookSource>> listEnabledExplore() async {
    final sources = await (_database.select(_database.bookSources)
          ..where((t) =>
              (t.enabledExplore.equals(true) | t.enabledExplore.isNull()) &
              t.exploreUrl.isNotNull())
          ..orderBy([(t) => drift.OrderingTerm.asc(t.customOrder)]))
        .get();
    return sources
        .where((source) => source.exploreUrl?.trim().isNotEmpty == true)
        .toList(growable: false);
  }

  Future<db.BookSource?> findById(int sourceId) {
    return (_database.select(_database.bookSources)
          ..where((t) => t.id.equals(sourceId)))
        .getSingleOrNull();
  }

  Future<db.BookSource?> findByUrl(String sourceUrl) {
    return (_database.select(_database.bookSources)
          ..where((t) => t.bookSourceUrl.equals(sourceUrl)))
        .getSingleOrNull();
  }

  Future<int> nextAvailableId() async {
    final row = await _database
        .customSelect(
          'SELECT MAX(id) AS max_id FROM book_sources',
        )
        .getSingle();
    final maxId = row.read<int?>('max_id') ?? 0;
    return maxId + 1;
  }

  Future<List<db.BookSource>> findByIds(List<int> sourceIds) {
    if (sourceIds.isEmpty) return Future.value(const <db.BookSource>[]);
    return (_database.select(_database.bookSources)
          ..where((t) => t.id.isIn(sourceIds)))
        .get();
  }

  Future<int> updateEnabled({
    required int sourceId,
    required bool enabled,
  }) {
    return (_database.update(_database.bookSources)
          ..where((t) => t.id.equals(sourceId)))
        .write(db.BookSourcesCompanion(enabled: drift.Value(enabled)));
  }

  Future<int> updateEnabledByIds({
    required List<int> sourceIds,
    required bool enabled,
  }) {
    if (sourceIds.isEmpty) return Future.value(0);
    return (_database.update(_database.bookSources)
          ..where((t) => t.id.isIn(sourceIds)))
        .write(db.BookSourcesCompanion(enabled: drift.Value(enabled)));
  }

  Future<int> updateById({
    required int sourceId,
    required db.BookSourcesCompanion source,
  }) {
    return (_database.update(_database.bookSources)
          ..where((t) => t.id.equals(sourceId)))
        .write(source);
  }

  Future<void> upsert(db.BookSourcesCompanion source) {
    return _database.into(_database.bookSources).insertOnConflictUpdate(source);
  }

  Future<void> deleteWithRules(int sourceId) {
    return _database.transaction(() async {
      await (_database.delete(_database.bookSources)
            ..where((t) => t.id.equals(sourceId)))
          .go();
      await (_database.delete(_database.ruleBookInfos)
            ..where((t) => t.bookSourceId.equals(sourceId)))
          .go();
      await (_database.delete(_database.ruleContents)
            ..where((t) => t.bookSourceId.equals(sourceId)))
          .go();
      await (_database.delete(_database.ruleSearchs)
            ..where((t) => t.bookSourceId.equals(sourceId)))
          .go();
      await (_database.delete(_database.ruleTocs)
            ..where((t) => t.bookSourceId.equals(sourceId)))
          .go();
      await (_database.delete(_database.ruleExplores)
            ..where((t) => t.bookSourceId.equals(sourceId)))
          .go();
    });
  }
}
