import 'book_annotation.dart';
import 'book_annotation_dao.dart';
import 'drift_book_annotation_dao.dart';

typedef AnnotationIdFactory = String Function();
typedef AnnotationClock = DateTime Function();

class BookAnnotationService {
  BookAnnotationService({
    BookAnnotationDao? dao,
    AnnotationIdFactory? idFactory,
    AnnotationClock? clock,
  })  : _dao = dao ?? DriftBookAnnotationDao(),
        _idFactory = idFactory ?? _defaultId,
        _clock = clock ?? DateTime.now;

  final BookAnnotationDao _dao;
  final AnnotationIdFactory _idFactory;
  final AnnotationClock _clock;

  static int _sequence = 0;
  static String _defaultId() =>
      '${DateTime.now().microsecondsSinceEpoch}-${_sequence++}';

  Future<BookAnnotation> create(BookAnnotationDraft draft) async {
    _validateDraft(draft);
    final normalizedBookName = draft.bookName.trim();
    final existing = await _dao.list(
      BookAnnotationQuery(
        bookSourceId: draft.bookSourceId,
        bookName: normalizedBookName,
        chapterIndex: draft.chapterIndex,
        type: draft.type,
      ),
    );
    for (final annotation in existing) {
      if (annotation.locatorJson == draft.locatorJson) {
        return annotation;
      }
    }
    final now = _clock();
    final annotation = BookAnnotation(
      id: _idFactory(),
      bookSourceId: draft.bookSourceId,
      bookName: normalizedBookName,
      chapterIndex: draft.chapterIndex,
      chapterName: draft.chapterName.trim(),
      locatorJson: draft.locatorJson,
      type: draft.type,
      excerpt: draft.excerpt.trim(),
      note: draft.note.trim(),
      colorValue: draft.colorValue,
      createdAt: now,
      updatedAt: now,
    );
    await _dao.upsert(annotation);
    return annotation;
  }

  Future<BookAnnotation> update({
    required String id,
    BookAnnotationType? type,
    String? excerpt,
    String? note,
    int? colorValue,
    bool clearColor = false,
    String? locatorJson,
  }) async {
    final current = await _dao.findById(id);
    if (current == null) throw StateError('Annotation not found: $id');
    if (locatorJson != null &&
        !BookAnnotation.isValidLocatorJson(locatorJson)) {
      throw const FormatException('locatorJson must be a JSON object');
    }
    final updated = current.copyWith(
      type: type,
      excerpt: excerpt?.trim(),
      note: note?.trim(),
      colorValue: colorValue,
      clearColor: clearColor,
      locatorJson: locatorJson,
      updatedAt: _clock(),
    );
    _validateContent(updated.type, updated.excerpt, updated.note);
    await _dao.upsert(updated);
    return updated;
  }

  Future<List<BookAnnotation>> list(BookAnnotationQuery query) =>
      _dao.list(query);

  Future<bool> delete(String id) => _dao.deleteById(id);

  Future<BookAnnotationStats> stats(BookAnnotationQuery query) async {
    final items = await _dao.list(query);
    var highlights = 0;
    var underlines = 0;
    var notes = 0;
    for (final item in items) {
      switch (item.type) {
        case BookAnnotationType.highlight:
          highlights++;
        case BookAnnotationType.underline:
          underlines++;
        case BookAnnotationType.note:
          notes++;
      }
    }
    return BookAnnotationStats(
      total: items.length,
      highlightCount: highlights,
      underlineCount: underlines,
      noteCount: notes,
    );
  }

  void _validateDraft(BookAnnotationDraft draft) {
    if (draft.bookName.trim().isEmpty) {
      throw ArgumentError.value(draft.bookName, 'bookName', 'is required');
    }
    if (draft.chapterIndex < 0) {
      throw ArgumentError.value(
        draft.chapterIndex,
        'chapterIndex',
        'must not be negative',
      );
    }
    if (!BookAnnotation.isValidLocatorJson(draft.locatorJson)) {
      throw const FormatException('locatorJson must be a JSON object');
    }
    _validateContent(draft.type, draft.excerpt.trim(), draft.note.trim());
  }

  void _validateContent(
    BookAnnotationType type,
    String excerpt,
    String note,
  ) {
    if (type == BookAnnotationType.note) {
      if (note.isEmpty) throw ArgumentError('A note must contain note text');
      return;
    }
    if (excerpt.isEmpty) {
      throw ArgumentError('A highlight or underline must contain an excerpt');
    }
  }
}
