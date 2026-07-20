import 'dart:async';

import '../../../app/database/dao/book_read_progress_dao.dart';
import '../../../app/database/dao/bookshelf_dao.dart';
import '../../../app/database/drift/app_database.dart' as db;
import '../../../util/log_utils.dart';
import '../../../app/service/book/reader_locator.dart';
import '../state.dart';

class BookReadProgressController {
  BookReadProgressController({
    required db.AppDatabase database,
    required this.state,
  }) : _database = database;

  static const Duration _debounceDuration = Duration(milliseconds: 1200);

  final db.AppDatabase _database;
  final BookReadState state;
  late final BookReadProgressDao _readProgressDao =
      BookReadProgressDao(database: _database);
  late final BookshelfDao _bookshelfDao = BookshelfDao(database: _database);

  Timer? _debounceTimer;
  _ReadProgressSnapshot? _pendingSnapshot;
  _ReadProgressSnapshot? _lastSavedSnapshot;
  bool _isFlushing = false;

  void scheduleSave({bool immediate = false}) {
    final snapshot = _captureSnapshot();
    if (!immediate &&
        (_pendingSnapshot == snapshot || _lastSavedSnapshot == snapshot)) {
      return;
    }

    _pendingSnapshot = snapshot;
    _debounceTimer?.cancel();
    _debounceTimer = null;

    if (immediate) {
      unawaited(flush());
      return;
    }

    _debounceTimer = Timer(_debounceDuration, () {
      _debounceTimer = null;
      unawaited(flush());
    });
  }

  Future<void> flush({bool force = false}) async {
    if (_isFlushing || _pendingSnapshot == null) return;

    _isFlushing = true;
    _debounceTimer?.cancel();
    _debounceTimer = null;
    _ReadProgressSnapshot? failedSnapshot;

    try {
      while (_pendingSnapshot != null) {
        final snapshot = _pendingSnapshot!;
        _pendingSnapshot = null;
        failedSnapshot = snapshot;

        if (!force && snapshot == _lastSavedSnapshot) {
          failedSnapshot = null;
          continue;
        }

        final now = DateTime.now();
        await _readProgressDao.save(
          bookSourceId: snapshot.bookSourceId,
          bookName: snapshot.bookName,
          chapterName: snapshot.chapterName,
          chapterIndex: snapshot.chapterIndex,
          locatorJson: snapshot.locatorJson,
          updateTime: now,
        );
        await _bookshelfDao.updateReadSummaryBySourceAndName(
          bookSourceId: snapshot.bookSourceId,
          bookName: snapshot.bookName,
          chapterIndex: snapshot.chapterIndex,
          pageIndex: snapshot.pageIndex,
          lastReadTime: now,
        );

        _lastSavedSnapshot = snapshot;
        failedSnapshot = null;
        force = false;
      }
    } catch (e) {
      if (failedSnapshot != null) {
        _pendingSnapshot ??= failedSnapshot;
      }
      final snapshotForLog = failedSnapshot ??
          _pendingSnapshot ??
          _lastSavedSnapshot ??
          _captureSnapshot();
      LogUtils.e(
        '保存阅读进度失败: ${_progressLogContext(snapshot: snapshotForLog)}, error=$e',
      );
    } finally {
      _isFlushing = false;
      if (_pendingSnapshot != null) {
        scheduleSave();
      }
    }
  }

  Future<void> saveCurrentProgress() async {
    _pendingSnapshot = _captureSnapshot();
    _debounceTimer?.cancel();
    _debounceTimer = null;
    await flush(force: true);
  }

  Future<void> dispose({
    bool flushBeforeDispose = false,
    bool forceSave = false,
  }) async {
    _debounceTimer?.cancel();
    _debounceTimer = null;
    if (flushBeforeDispose) {
      if (forceSave || _pendingSnapshot == null) {
        _pendingSnapshot = _captureSnapshot();
      }
      await flush(force: forceSave);
    } else {
      _pendingSnapshot = null;
    }
  }

  _ReadProgressSnapshot _captureSnapshot() {
    return _ReadProgressSnapshot(
      bookSourceId: state.bookInfo.bookSourceId,
      bookName: state.bookInfo.name,
      chapterName: state.currentChapter,
      chapterIndex: state.currentChapterIndex,
      pageIndex: state.currentPage,
      locatorJson: _currentLocator().encode(),
    );
  }

  String _progressLogContext({
    required _ReadProgressSnapshot snapshot,
  }) {
    return 'bookSourceId=${snapshot.bookSourceId}, '
        'bookName=${snapshot.bookName}, '
        'chapterName=${snapshot.chapterName}, '
        'chapterIndex=${snapshot.chapterIndex}, '
        'locator=${snapshot.locatorJson}';
  }

  ReaderLocator _currentLocator() {
    final page = state.currentPage.clamp(0, state.bookContentList.length);
    final offset = state.bookContentList
        .take(page)
        .fold<int>(0, (total, text) => total + text.length);
    return const ReaderLocatorService().create(
      chapterIndex: state.currentChapterIndex,
      chapterName: state.currentChapter,
      chapterText: state.bookContent,
      offsetUtf16: offset,
    );
  }
}

class _ReadProgressSnapshot {
  const _ReadProgressSnapshot({
    required this.bookSourceId,
    required this.bookName,
    required this.chapterName,
    required this.chapterIndex,
    required this.pageIndex,
    required this.locatorJson,
  });

  final int bookSourceId;
  final String bookName;
  final String chapterName;
  final int chapterIndex;
  final int pageIndex;
  final String locatorJson;

  @override
  bool operator ==(Object other) {
    return other is _ReadProgressSnapshot &&
        other.bookSourceId == bookSourceId &&
        other.bookName == bookName &&
        other.chapterName == chapterName &&
        other.chapterIndex == chapterIndex &&
        other.pageIndex == pageIndex &&
        other.locatorJson == locatorJson;
  }

  @override
  int get hashCode => Object.hash(
        bookSourceId,
        bookName,
        chapterName,
        chapterIndex,
        pageIndex,
        locatorJson,
      );
}
