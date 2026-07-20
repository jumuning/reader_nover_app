import '../../../util/log_utils.dart';
import '../../database/dao/book_content_info_dao.dart';
import '../../database/dao/book_read_history_dao.dart';
import '../../database/drift/app_database.dart';
import '../../database/models/models.dart';
import '../local_book/local_book_constants.dart';

/// Shared service for loading read/cached chapter indices.
/// Used by both BookReadLogic and BookDetailLogic to avoid code duplication.
class ReadChapterService {
  final AppDatabase _db;
  late final BookContentInfoDao _contentInfoDao =
      BookContentInfoDao(database: _db);
  late final BookReadHistoryDao _readHistoryDao =
      BookReadHistoryDao(database: _db);

  ReadChapterService({required AppDatabase database}) : _db = database;

  /// Load indices of chapters that have been read (based on read history).
  Future<Set<int>> loadReadChapterIndices({
    required int bookSourceId,
    required String bookName,
    required List<BookChapterInfo> chapters,
  }) async {
    try {
      final histories = await _readHistoryDao.listByBook(
        bookSourceId: bookSourceId,
        bookName: bookName,
      );

      final readChapterNames =
          histories.map((h) => h.chapterName).whereType<String>().toSet();
      return chapters
          .where((c) => readChapterNames.contains(c.chapterName))
          .map((c) => c.chapterIndex!)
          .toSet();
    } catch (e) {
      LogUtils.e('加载已阅读章节失败: $e');
      return {};
    }
  }

  /// Load indices of chapters that have cached content.
  Future<Set<int>> loadCachedChapterIndices({
    required int bookSourceId,
    required String bookName,
    required List<BookChapterInfo> chapters,
  }) async {
    if (LocalBookConstants.isLocalBookSource(bookSourceId)) {
      return chapters
          .map((chapter) => chapter.chapterIndex)
          .whereType<int>()
          .toSet();
    }

    try {
      final cachedChapters =
          await _contentInfoDao.listCachedChapterIdentitiesByBook(
        bookSourceId: bookSourceId,
        bookName: bookName,
      );

      if (chapters.isEmpty) return {};

      final cachedChapterIndices =
          cachedChapters.map((c) => c.chapterIndex).whereType<int>().toSet();
      final cachedChapterNames =
          cachedChapters.map((c) => c.chapterName).whereType<String>().toSet();

      return chapters
          .where((c) {
            final chapterIndex = c.chapterIndex;
            if (chapterIndex != null &&
                cachedChapterIndices.contains(chapterIndex)) {
              return true;
            }
            return cachedChapterNames.contains(c.chapterName);
          })
          .map((c) => c.chapterIndex)
          .whereType<int>()
          .toSet();
    } catch (e) {
      LogUtils.e('加载缓存章节失败: $e');
      return {};
    }
  }
}
