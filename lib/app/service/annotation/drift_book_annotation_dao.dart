import 'package:drift/drift.dart' as drift;

import '../../database/drift/app_database.dart' as db;
import 'book_annotation.dart';
import 'book_annotation_dao.dart';

class DriftBookAnnotationDao implements BookAnnotationDao {
  DriftBookAnnotationDao({db.AppDatabase? database})
      : _database = database ?? db.AppDatabase.instance;

  final db.AppDatabase _database;

  @override
  Future<void> upsert(BookAnnotation annotation) async {
    await _database.into(_database.bookAnnotations).insertOnConflictUpdate(
          db.BookAnnotationsCompanion.insert(
            id: annotation.id,
            bookSourceId: annotation.bookSourceId,
            bookName: annotation.bookName,
            chapterIndex: annotation.chapterIndex,
            chapterName: drift.Value(annotation.chapterName),
            locatorJson: annotation.locatorJson,
            type: annotation.type.name,
            excerpt: drift.Value(annotation.excerpt),
            note: drift.Value(annotation.note),
            colorValue: drift.Value(annotation.colorValue),
            createdAt: annotation.createdAt,
            updatedAt: annotation.updatedAt,
          ),
        );
  }

  @override
  Future<BookAnnotation?> findById(String id) async {
    final row = await (_database.select(_database.bookAnnotations)
          ..where((table) => table.id.equals(id)))
        .getSingleOrNull();
    return row == null ? null : _fromRow(row);
  }

  @override
  Future<List<BookAnnotation>> list(BookAnnotationQuery query) async {
    final statement = _database.select(_database.bookAnnotations)
      ..where((table) {
        drift.Expression<bool> predicate = const drift.Constant(true);
        if (query.bookSourceId != null) {
          predicate =
              predicate & table.bookSourceId.equals(query.bookSourceId!);
        }
        if (query.bookName != null) {
          predicate = predicate & table.bookName.equals(query.bookName!);
        }
        if (query.chapterIndex != null) {
          predicate =
              predicate & table.chapterIndex.equals(query.chapterIndex!);
        }
        if (query.type != null) {
          predicate = predicate & table.type.equals(query.type!.name);
        }
        final keyword = query.keyword?.trim();
        if (keyword != null && keyword.isNotEmpty) {
          final pattern = '%${_escapeLike(keyword)}%';
          predicate = predicate &
              (table.excerpt.like(pattern, escapeChar: r'\') |
                  table.note.like(pattern, escapeChar: r'\'));
        }
        return predicate;
      })
      ..orderBy([
        (table) => drift.OrderingTerm.asc(table.chapterIndex),
        (table) => drift.OrderingTerm.asc(table.createdAt),
      ]);
    final rows = await statement.get();
    return rows.map(_fromRow).toList(growable: false);
  }

  @override
  Future<bool> deleteById(String id) async {
    final count = await (_database.delete(_database.bookAnnotations)
          ..where((table) => table.id.equals(id)))
        .go();
    return count > 0;
  }

  @override
  Future<int> deleteByBook({
    required int bookSourceId,
    required String bookName,
  }) {
    return (_database.delete(_database.bookAnnotations)
          ..where((table) =>
              table.bookSourceId.equals(bookSourceId) &
              table.bookName.equals(bookName)))
        .go();
  }

  BookAnnotation _fromRow(db.BookAnnotation row) {
    return BookAnnotation(
      id: row.id,
      bookSourceId: row.bookSourceId,
      bookName: row.bookName,
      chapterIndex: row.chapterIndex,
      chapterName: row.chapterName,
      locatorJson: row.locatorJson,
      type: BookAnnotationType.values.byName(row.type),
      excerpt: row.excerpt,
      note: row.note,
      colorValue: row.colorValue,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  String _escapeLike(String value) => value
      .replaceAll(r'\', r'\\')
      .replaceAll('%', r'\%')
      .replaceAll('_', r'\_');
}
