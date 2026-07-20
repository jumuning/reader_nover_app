import 'book_annotation.dart';
import 'book_annotation_dao.dart';

class InMemoryBookAnnotationDao implements BookAnnotationDao {
  final Map<String, BookAnnotation> _items = {};

  @override
  Future<void> upsert(BookAnnotation annotation) async {
    _items[annotation.id] = annotation;
  }

  @override
  Future<BookAnnotation?> findById(String id) async => _items[id];

  @override
  Future<List<BookAnnotation>> list(BookAnnotationQuery query) async {
    final keyword = query.keyword?.trim().toLowerCase();
    final result = _items.values.where((item) {
      if (query.bookSourceId != null &&
          item.bookSourceId != query.bookSourceId) {
        return false;
      }
      if (query.bookName != null && item.bookName != query.bookName) {
        return false;
      }
      if (query.chapterIndex != null &&
          item.chapterIndex != query.chapterIndex) {
        return false;
      }
      if (query.type != null && item.type != query.type) return false;
      if (keyword != null &&
          keyword.isNotEmpty &&
          !item.excerpt.toLowerCase().contains(keyword) &&
          !item.note.toLowerCase().contains(keyword) &&
          !item.chapterName.toLowerCase().contains(keyword)) {
        return false;
      }
      return true;
    }).toList()
      ..sort((a, b) {
        final chapterOrder = a.chapterIndex.compareTo(b.chapterIndex);
        return chapterOrder != 0
            ? chapterOrder
            : a.createdAt.compareTo(b.createdAt);
      });
    return result;
  }

  @override
  Future<bool> deleteById(String id) async => _items.remove(id) != null;

  @override
  Future<int> deleteByBook({
    required int bookSourceId,
    required String bookName,
  }) async {
    final ids = _items.values
        .where((item) =>
            item.bookSourceId == bookSourceId && item.bookName == bookName)
        .map((item) => item.id)
        .toList();
    for (final id in ids) {
      _items.remove(id);
    }
    return ids.length;
  }
}
