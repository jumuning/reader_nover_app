part of 'app_database.dart';

const int _libraryPerformanceIndexSchemaVersion = 20;

const String _booksFindBySourceAndNameIndexName =
    'idx_books_source_name_id_desc';
const String _booksFindBySourceAndNameIndexSql =
    'CREATE INDEX IF NOT EXISTS $_booksFindBySourceAndNameIndexName '
    'ON books (book_source_id, name, id DESC)';

const String _bookChaptersByBookAndChapterIndexName =
    'idx_book_chapters_book_id_chapter_index';
const String _bookChaptersByBookAndChapterIndexSql =
    'CREATE INDEX IF NOT EXISTS $_bookChaptersByBookAndChapterIndexName '
    'ON book_chapters (book_id, chapter_index)';

const String _booksByLastReadTimeIndexName = 'idx_books_last_read_time_id_desc';
const String _booksByLastReadTimeIndexSql =
    'CREATE INDEX IF NOT EXISTS $_booksByLastReadTimeIndexName '
    'ON books (last_read_time DESC, id DESC)';

const List<String> _libraryPerformanceIndexStatements = <String>[
  _booksFindBySourceAndNameIndexSql,
  _bookChaptersByBookAndChapterIndexSql,
  _booksByLastReadTimeIndexSql,
];

/// 书籍表（从 BookMySelfs.bookDetail 拆分）
class Books extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get bookSourceId => integer()();
  TextColumn get bookUrl => text().nullable()();
  TextColumn get name => text()();
  TextColumn get author => text().nullable()();
  TextColumn get cover => text().nullable()();
  TextColumn get intro => text().nullable()();
  TextColumn get kind => text().nullable()(); // JSON 数组
  TextColumn get wordCount => text().nullable()();
  TextColumn get lastChapter => text().nullable()();
  IntColumn get totalChapterNum => integer().withDefault(const Constant(0))();
  // 书架首页直接依赖的阅读摘要字段，避免回查进度表/正文缓存。
  IntColumn get durChapterIndex => integer().withDefault(const Constant(0))();
  IntColumn get durChapterPos => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastReadTime => dateTime().nullable()();
  BoolColumn get isAscending => boolean().withDefault(const Constant(true))();
  IntColumn get customOrder => integer().withDefault(const Constant(0))();
  TextColumn get bookGroup => text().nullable()();
}

/// 章节表（从 BookDetail.chapters 拆分）
class BookChapters extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get bookId => integer()(); // 外键，关联 Books.id
  IntColumn get bookSourceId => integer()();
  IntColumn get chapterIndex => integer()();
  TextColumn get chapterName => text()();
  TextColumn get chapterUrl => text()();
  BoolColumn get isVip => boolean().withDefault(const Constant(false))();
  TextColumn get wordCount => text().nullable()();
}

/// 本地导入书籍原文件信息表
class LocalBookFiles extends Table {
  IntColumn get bookId => integer()();
  TextColumn get originalFileName => text()();
  TextColumn get storedFilePath => text()();
  TextColumn get format => text()();
  TextColumn get charset => text().nullable()();
  IntColumn get fileSize => integer()();
  TextColumn get fileHash => text().nullable()();
  DateTimeColumn get importTime => dateTime()();
  DateTimeColumn get sourceModifiedTime => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {bookId};
}
