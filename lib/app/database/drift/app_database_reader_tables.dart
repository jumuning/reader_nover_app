part of 'app_database.dart';

/// 阅读设置表
class BookReadSettings extends Table {
  IntColumn get id => integer()();
  DateTimeColumn get updateTime => dateTime()();
  RealColumn get fontSize => real().nullable()();
  RealColumn get fontHeight => real().nullable()();
  RealColumn get wordSpacing => real().nullable()();
  RealColumn get letterSpacing => real().nullable()();
  TextColumn get fontFamily => text().nullable()();
  RealColumn get brightness => real().nullable()();
  IntColumn get backgroundColor => integer().nullable()();
  TextColumn get pageTurnType => text().nullable()();
  BoolColumn get isEyeProtectionMode => boolean().nullable()();
  RealColumn get ttsRate => real().nullable()();
  RealColumn get ttsPitch => real().nullable()();
  RealColumn get ttsVolume => real().nullable()();
  TextColumn get ttsVoiceName => text().nullable()();
  BoolColumn get ttsAutoNextPage => boolean().nullable()();
  BoolColumn get ttsAutoNextChapter => boolean().nullable()();
  BoolColumn get ttsResumeAfterInterrupt => boolean().nullable()();
  TextColumn get themeMode =>
      text().nullable()(); // 主题模式: 'light', 'dark', 'system'
  TextColumn get bookshelfLayout => text().nullable()(); // 书架布局: 'list', 'grid'

  @override
  Set<Column> get primaryKey => {id};
}

/// 章节内容缓存表
class BookContentInfos extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get bookSourceId => integer()();
  TextColumn get name => text().nullable()();
  TextColumn get chapterName => text().nullable()();
  IntColumn get chapterIndex => integer().nullable()();
  TextColumn get bookContent => text().nullable()(); // 原始内容

  @override
  List<String> get customConstraints => const <String>[
        'UNIQUE(book_source_id, name, chapter_name)',
      ];
}

/// 阅读进度表
class BookReadProgresses extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get bookSourceId => integer()();
  TextColumn get bookName => text()();
  TextColumn get chapterName => text().nullable()();
  IntColumn get chapterIndex => integer()();
  TextColumn get locatorJson => text()();
  DateTimeColumn get updateTime => dateTime()();

  @override
  List<String> get customConstraints => const <String>[
        'UNIQUE(book_source_id, book_name)',
      ];
}

/// 搜索历史表
class SearchHistories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get keyword => text()();
  DateTimeColumn get searchTime => dateTime()();
}

/// 阅读历史记录表
class BookReadHistories extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get bookSourceId => integer()();
  TextColumn get bookName => text()();
  TextColumn get chapterName => text().nullable()();
  IntColumn get chapterIndex => integer()();
}

/// 书签表
class Bookmarks extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get bookSourceId => integer()();
  TextColumn get bookName => text()();
  TextColumn get locatorJson => text()();
  TextColumn get chapterName => text().withDefault(const Constant(''))();
  TextColumn get bookText => text().withDefault(const Constant(''))();
  TextColumn get content => text().withDefault(const Constant(''))();
  DateTimeColumn get createTime => dateTime()();
}
