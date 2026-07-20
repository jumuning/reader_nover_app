import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../../util/log_utils.dart';
import 'book_annotation_tables.dart';
import 'reading_session_table.dart';

part 'app_database.g.dart';
part 'app_database_source_tables.dart';
part 'app_database_reader_tables.dart';
part 'app_database_library_tables.dart';
part 'app_database_migrations.dart';
part 'app_database_connection.dart';

@DriftDatabase(tables: [
  BookSources,
  RuleBookInfos,
  RuleContents,
  RuleSearchs,
  RuleTocs,
  RuleExplores,
  BookReadSettings,
  BookContentInfos,
  BookSearchInfos,
  BookReadProgresses,
  SearchHistories,
  BookReadHistories,
  Books,
  BookChapters,
  LocalBookFiles,
  Bookmarks,
  ReadingSessions,
  BookAnnotations,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase._internal() : super(openAppDatabaseConnection());

  AppDatabase.forTesting(super.e);

  static AppDatabase? _instance;

  static AppDatabase get instance {
    _instance ??= AppDatabase._internal();
    return _instance!;
  }

  @override
  int get schemaVersion => 26;

  @override
  MigrationStrategy get migration => buildAppDatabaseMigration(this);

  /// 初始化数据库（用于替代原来的 AppDatabase.init()）
  static Future<void> init() async {
    if (_instance != null) {
      LogUtils.d('Drift数据库已初始化，跳过重复初始化');
      return;
    }
    _instance = AppDatabase._internal();
    LogUtils.d('Drift数据库初始化完成');
  }
}
