import 'package:flutter/foundation.dart';

import '../../../app/service/annotation/book_annotation.dart';
import '../../../app/service/annotation/book_annotation_service.dart';
import '../../../app/service/book/reader_locator.dart';
import '../state.dart';

class BookReadAnnotationController {
  BookReadAnnotationController({
    required this.state,
    required this.onUpdate,
    required this.onJumpToChapter,
    BookAnnotationService? service,
  }) : _service = service ?? BookAnnotationService();

  final BookReadState state;
  final VoidCallback onUpdate;
  final Future<void> Function(int chapterIndex) onJumpToChapter;
  final BookAnnotationService _service;

  Future<void> load() async {
    state.annotationList = await _service.list(_bookQuery());
    onUpdate();
  }

  Future<BookAnnotation> create({
    required BookAnnotationType type,
    required int chapterIndex,
    required String chapterName,
    required String chapterText,
    required int start,
    required int end,
    String note = '',
  }) async {
    final safeStart = start.clamp(0, chapterText.length);
    final safeEnd = end.clamp(safeStart, chapterText.length);
    final locator = const ReaderLocatorService().create(
      chapterIndex: chapterIndex,
      chapterName: chapterName,
      chapterText: chapterText,
      offsetUtf16: safeStart,
      quoteLength: (safeEnd - safeStart).clamp(1, 120),
    );
    final annotation = await _service.create(
      BookAnnotationDraft(
        bookSourceId: state.bookInfo.bookSourceId,
        bookName: state.bookInfo.name,
        chapterIndex: chapterIndex,
        chapterName: chapterName,
        locatorJson: locator.encode(),
        type: type,
        excerpt: chapterText.substring(safeStart, safeEnd),
        note: note,
        colorValue: type == BookAnnotationType.highlight ? 0xFFFFC857 : null,
      ),
    );
    state.annotationList = [
      ...state.annotationList.where((item) => item.id != annotation.id),
      annotation,
    ]..sort((a, b) => a.chapterIndex.compareTo(b.chapterIndex));
    onUpdate();
    return annotation;
  }

  Future<void> update(BookAnnotation annotation, String note) async {
    final updated = await _service.update(id: annotation.id, note: note);
    state.annotationList = state.annotationList
        .map((item) => item.id == updated.id ? updated : item)
        .toList();
    onUpdate();
  }

  Future<void> delete(BookAnnotation annotation) async {
    if (!await _service.delete(annotation.id)) return;
    state.annotationList =
        state.annotationList.where((item) => item.id != annotation.id).toList();
    onUpdate();
  }

  Future<void> jumpTo(BookAnnotation annotation) async {
    final locator = ReaderLocator.decode(annotation.locatorJson);
    await onJumpToChapter(locator.chapterIndex);
  }

  BookAnnotationQuery _bookQuery() => BookAnnotationQuery(
        bookSourceId: state.bookInfo.bookSourceId,
        bookName: state.bookInfo.name,
      );
}
