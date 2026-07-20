import '../../../database/drift/app_database.dart' as db;

/// 换源候选书籍信息
class SourceBookInfo {
  const SourceBookInfo({
    required this.bookSource,
    required this.bookUrl,
    this.lastChapter,
  });

  final db.BookSource bookSource;
  final String bookUrl;
  final String? lastChapter;
}
