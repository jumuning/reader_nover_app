import 'package:drift/drift.dart' as drift;

import '../drift/app_database.dart' as db;

class ReadingSessionDao {
  const ReadingSessionDao({required db.AppDatabase database})
      : _database = database;

  final db.AppDatabase _database;

  Future<int> insert(db.ReadingSessionsCompanion session) {
    return _database.into(_database.readingSessions).insert(session);
  }

  Future<int> finish({
    required int id,
    required DateTime endedAt,
    required int durationSeconds,
    required String endLocatorJson,
  }) {
    return (_database.update(_database.readingSessions)
          ..where((table) => table.id.equals(id)))
        .write(
      db.ReadingSessionsCompanion(
        endedAt: drift.Value(endedAt),
        durationSeconds: drift.Value(durationSeconds),
        endLocatorJson: drift.Value(endLocatorJson),
      ),
    );
  }

  Future<List<db.ReadingSession>> listCompleted({
    DateTime? from,
    DateTime? to,
  }) {
    final query = _database.select(_database.readingSessions)
      ..where((table) {
        var predicate = table.endedAt.isNotNull();
        if (from != null) {
          predicate = predicate & table.endedAt.isBiggerThanValue(from);
        }
        if (to != null) {
          predicate = predicate & table.startedAt.isSmallerThanValue(to);
        }
        return predicate;
      })
      ..orderBy([
        (table) => drift.OrderingTerm.asc(table.startedAt),
      ]);
    return query.get();
  }
}
