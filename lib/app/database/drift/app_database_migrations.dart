part of 'app_database.dart';

MigrationStrategy buildAppDatabaseMigration(AppDatabase database) {
  return MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
      await _ensureLibraryPerformanceIndexes(database);
    },
    onUpgrade: (Migrator m, int from, int to) async {
      if (from < 2) {
        await m.createTable(database.bookReadProgresses);
      }
      if (from < 3) {
        await m.createTable(database.searchHistories);
      }
      if (from < 4) {
        await m.createTable(database.bookReadHistories);
      }
      if (from < 5) {
        await m.deleteTable('book_content_infos');
        await m.createTable(database.bookContentInfos);
      }
      if (from < 6) {
        await database.customStatement(
          'ALTER TABLE book_read_settings ADD COLUMN brightness REAL',
        );
        await database.customStatement(
          'ALTER TABLE book_read_settings ADD COLUMN background_color INTEGER',
        );
        await database.customStatement(
          'ALTER TABLE book_read_settings ADD COLUMN page_turn_type TEXT',
        );
        await database.customStatement(
          'ALTER TABLE book_read_settings ADD COLUMN is_eye_protection_mode INTEGER',
        );
      }
      if (from < 7) {
        await database.customStatement(
          'ALTER TABLE book_content_infos ADD COLUMN chapter_name TEXT',
        );
        await database.customStatement(
          'ALTER TABLE book_read_progresses ADD COLUMN chapter_name TEXT',
        );
        await database.customStatement(
          'ALTER TABLE book_read_histories ADD COLUMN chapter_name TEXT',
        );
      }
      if (from < 8) {
        await database.customStatement(
          'ALTER TABLE book_read_settings ADD COLUMN theme_mode TEXT',
        );
      }
      if (from < 9) {
        await m.createTable(database.ruleExplores);
      }
      if (from < 10) {
        await database.customStatement(
          'ALTER TABLE book_read_settings ADD COLUMN bookshelf_layout TEXT',
        );
      }
      if (from < 11) {
        await m.createTable(database.books);
        await m.createTable(database.bookChapters);
      }
      if (from < 12) {
        await m.createTable(database.bookmarks);
      }
      if (from < 13) {
        await database.customStatement(
          'ALTER TABLE book_sources ADD COLUMN js_lib TEXT',
        );
      }
      if (from < 14) {
        await database.customStatement(
          'ALTER TABLE books ADD COLUMN word_count TEXT',
        );
      }
      if (from < 15) {
        await database.customStatement(
          'ALTER TABLE book_sources ADD COLUMN concurrent_rate TEXT',
        );
        await database.customStatement(
          'ALTER TABLE book_sources ADD COLUMN respond_time INTEGER',
        );
        await database.customStatement(
          'ALTER TABLE book_sources ADD COLUMN login_ui TEXT',
        );
        await database.customStatement(
          'ALTER TABLE book_sources ADD COLUMN login_check_js TEXT',
        );
        await database.customStatement(
          'ALTER TABLE book_sources ADD COLUMN cover_decode_js TEXT',
        );
        await database.customStatement(
          'ALTER TABLE book_sources ADD COLUMN variable_comment TEXT',
        );
        await database.customStatement(
          'ALTER TABLE book_sources ADD COLUMN explore_screen TEXT',
        );
        await database.customStatement(
          'ALTER TABLE rule_book_infos ADD COLUMN can_re_name TEXT',
        );
        await database.customStatement(
          'ALTER TABLE rule_book_infos ADD COLUMN download_urls TEXT',
        );
        await database.customStatement(
          'ALTER TABLE rule_book_infos ADD COLUMN update_time TEXT',
        );
        await database.customStatement(
          'ALTER TABLE rule_contents ADD COLUMN title TEXT',
        );
        await database.customStatement(
          'ALTER TABLE rule_contents ADD COLUMN web_js TEXT',
        );
        await database.customStatement(
          'ALTER TABLE rule_contents ADD COLUMN source_regex TEXT',
        );
        await database.customStatement(
          'ALTER TABLE rule_contents ADD COLUMN image_style TEXT',
        );
        await database.customStatement(
          'ALTER TABLE rule_contents ADD COLUMN image_decode TEXT',
        );
        await database.customStatement(
          'ALTER TABLE rule_contents ADD COLUMN pay_action TEXT',
        );
        await database.customStatement(
          'ALTER TABLE rule_searchs ADD COLUMN check_key_word TEXT',
        );
        await database.customStatement(
          'ALTER TABLE rule_tocs ADD COLUMN pre_update_js TEXT',
        );
        await database.customStatement(
          'ALTER TABLE rule_tocs ADD COLUMN format_js TEXT',
        );
        await database.customStatement(
          'ALTER TABLE rule_tocs ADD COLUMN is_volume TEXT',
        );
        await database.customStatement(
          'ALTER TABLE rule_tocs ADD COLUMN is_vip TEXT',
        );
        await database.customStatement(
          'ALTER TABLE rule_tocs ADD COLUMN is_pay TEXT',
        );
        await database.customStatement(
          'ALTER TABLE rule_explores ADD COLUMN word_count TEXT',
        );
      }
      if (from < 16) {
        await database.customStatement(
          'ALTER TABLE rule_searchs ADD COLUMN update_time TEXT',
        );
        await database.customStatement(
          'ALTER TABLE rule_tocs ADD COLUMN update_time TEXT',
        );
      }
      if (from < 17) {
        await database.customStatement(
          'ALTER TABLE book_read_settings ADD COLUMN tts_rate REAL',
        );
        await database.customStatement(
          'ALTER TABLE book_read_settings ADD COLUMN tts_pitch REAL',
        );
        await database.customStatement(
          'ALTER TABLE book_read_settings ADD COLUMN tts_volume REAL',
        );
        await database.customStatement(
          'ALTER TABLE book_read_settings ADD COLUMN tts_voice_name TEXT',
        );
        await database.customStatement(
          'ALTER TABLE book_read_settings ADD COLUMN tts_auto_next_page INTEGER',
        );
        await database.customStatement(
          'ALTER TABLE book_read_settings ADD COLUMN tts_auto_next_chapter INTEGER',
        );
        await database.customStatement(
          'ALTER TABLE book_read_settings ADD COLUMN tts_resume_after_interrupt INTEGER',
        );
      }
      if (from < 18) {
        await _migrateBookContentInfosToV18(database, m);
        await _migrateBookReadProgressesToV18(database, m);
      }
      if (from < _libraryPerformanceIndexSchemaVersion) {
        await _ensureLibraryPerformanceIndexes(database);
      }
      if (from < 23) {
        await m.createTable(database.localBookFiles);
      }
      if (from < 24) {
        await m.deleteTable('book_read_progresses');
        await m.createTable(database.bookReadProgresses);
        await m.deleteTable('book_read_histories');
        await m.createTable(database.bookReadHistories);
        await m.createTable(database.readingSessions);
        await m.createTable(database.bookAnnotations);
      }
      if (from < 25) {
        await database.customStatement('''
          DELETE FROM book_annotations
          WHERE rowid NOT IN (
            SELECT MIN(rowid)
            FROM book_annotations
            GROUP BY book_source_id, book_name, chapter_index, locator_json, type
          )
        ''');
        await database.customStatement('''
          CREATE UNIQUE INDEX IF NOT EXISTS idx_book_annotations_location_type
          ON book_annotations(
            book_source_id, book_name, chapter_index, locator_json, type
          )
        ''');
      }
      if (from < 26) {
        await m.deleteTable('bookmarks');
        await m.createTable(database.bookmarks);
      }
    },
    beforeOpen: (_) async {
      // 当前 schemaVersion 仍由别处维护，这里用幂等建索引兜底已有 v18 用户。
      await _ensureLibraryPerformanceIndexes(database);
    },
  );
}

Future<void> _migrateBookContentInfosToV18(
  AppDatabase database,
  Migrator migrator,
) async {
  await database.customStatement(
    'ALTER TABLE book_content_infos RENAME TO book_content_infos_v17',
  );
  await migrator.createTable(database.bookContentInfos);
  await database.customStatement('''
    INSERT OR REPLACE INTO book_content_infos (
      book_source_id,
      name,
      chapter_name,
      chapter_index,
      book_content
    )
    SELECT
      book_source_id,
      name,
      chapter_name,
      chapter_index,
      book_content
    FROM book_content_infos_v17
    ORDER BY id
  ''');
  await migrator.deleteTable('book_content_infos_v17');
}

Future<void> _migrateBookReadProgressesToV18(
  AppDatabase database,
  Migrator migrator,
) async {
  await database.customStatement(
    'ALTER TABLE book_read_progresses RENAME TO book_read_progresses_v17',
  );
  await migrator.createTable(database.bookReadProgresses);
  await database.customStatement('''
    INSERT OR REPLACE INTO book_read_progresses (
      book_source_id,
      book_name,
      chapter_name,
      chapter_index,
      page_index,
      update_time
    )
    SELECT
      book_source_id,
      book_name,
      chapter_name,
      chapter_index,
      page_index,
      update_time
    FROM book_read_progresses_v17
    ORDER BY id
  ''');
  await migrator.deleteTable('book_read_progresses_v17');
}

Future<void> _ensureLibraryPerformanceIndexes(AppDatabase database) async {
  for (final statement in _libraryPerformanceIndexStatements) {
    await database.customStatement(statement);
  }
}
