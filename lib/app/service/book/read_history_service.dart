import 'package:drift/drift.dart' as drift;

import '../../database/dao/reading_session_dao.dart';
import '../../database/dao/book_read_history_dao.dart';
import '../../database/drift/app_database.dart' as db;
import 'reader_locator.dart';

/// 阅读历史服务：负责开始/结束章节阅读记录。
class ReadHistoryService {
  final db.AppDatabase _db;
  late final ReadingSessionDao _sessionDao = ReadingSessionDao(database: _db);
  late final BookReadHistoryDao _chapterHistoryDao =
      BookReadHistoryDao(database: _db);

  DateTime? _readStartTime;
  int? _currentReadHistoryId;
  ReaderLocator? _startLocator;
  final DateTime Function() _now;

  ReadHistoryService({
    db.AppDatabase? database,
    DateTime Function()? now,
  })  : _db = database ?? db.AppDatabase.instance,
        _now = now ?? DateTime.now;

  Future<void> startHistory({
    required int bookSourceId,
    required String bookName,
    required String chapterName,
    required int chapterIndex,
    required ReaderLocator locator,
  }) async {
    // 章节切换通常会先结束旧会话。这里仍主动收口，避免快速切换或
    // 生命周期回调乱序时留下永不结束的记录。
    await endHistory();
    await _chapterHistoryDao.markChapterRead(
      bookSourceId: bookSourceId,
      bookName: bookName,
      chapterName: chapterName,
      chapterIndex: chapterIndex,
    );
    _readStartTime = _now();
    _startLocator = locator;

    _currentReadHistoryId = await _sessionDao.insert(
      db.ReadingSessionsCompanion.insert(
        bookSourceId: bookSourceId,
        bookName: bookName,
        chapterName: drift.Value(chapterName),
        chapterIndex: chapterIndex,
        startLocatorJson: locator.encode(),
        startedAt: _readStartTime!,
      ),
    );
  }

  Future<void> endHistory({ReaderLocator? locator}) async {
    if (_currentReadHistoryId == null || _readStartTime == null) return;

    final endTime = _now();
    final duration = endTime.difference(_readStartTime!).inSeconds;

    await _sessionDao.finish(
      id: _currentReadHistoryId!,
      endedAt: endTime,
      durationSeconds: duration,
      endLocatorJson: locator?.encode() ?? _startLocator!.encode(),
    );

    _currentReadHistoryId = null;
    _readStartTime = null;
    _startLocator = null;
  }
}
