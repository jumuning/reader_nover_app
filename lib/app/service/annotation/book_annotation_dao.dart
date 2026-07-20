import 'book_annotation.dart';

abstract interface class BookAnnotationDao {
  Future<void> upsert(BookAnnotation annotation);

  Future<BookAnnotation?> findById(String id);

  Future<List<BookAnnotation>> list(BookAnnotationQuery query);

  Future<bool> deleteById(String id);

  Future<int> deleteByBook({
    required int bookSourceId,
    required String bookName,
  });
}
