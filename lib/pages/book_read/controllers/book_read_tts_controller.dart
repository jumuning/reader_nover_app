import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import 'package:reader_nover/app/service/tts/tts_service.dart';
import 'package:reader_nover/app/service/tts/tts_read_ahead_scheduler.dart';
import 'package:reader_nover/pages/book_read/models/tts_page_snapshot.dart';
import 'package:reader_nover/pages/book_read/models/tts_playback_cursor.dart';
import 'package:reader_nover/pages/book_read/models/tts_prepared_target.dart';
import 'package:reader_nover/pages/book_read/models/tts_read_ahead_buffer.dart';
import 'package:reader_nover/pages/book_read/models/tts_sentence_segment.dart';
import 'package:reader_nover/pages/book_read/models/tts_speak_request.dart';
import 'package:reader_nover/pages/book_read/state.dart';
import 'package:reader_nover/pages/book_read/page_turn/two_page_spread_strategy.dart';
import 'package:reader_nover/pages/book_read/utils/reader_paragraph_utils.dart';
import 'package:reader_nover/util/dialog/dialog_utils.dart';
import 'package:reader_nover/util/log_utils.dart';

import 'book_read_tts_snapshot_controller.dart';
import 'book_read_tts_visual_controller.dart';
import 'tts_playback_session.dart';

class BookReadTtsController {
  BookReadTtsController({
    required this.state,
    required TtsService ttsService,
    required this.onUpdate,
    required this.onPlaybackVisualUpdate,
    required this.onJumpToPageAndSettle,
    required this.onJumpToChapterAndSettle,
    required this.onNextChapterAndSettle,
    required this.onLoadChapterCache,
    required this.onWaitForReadPageSettled,
  })  : _ttsService = ttsService,
        _snapshotController = BookReadTtsSnapshotController(state: state),
        _visualController = BookReadTtsVisualController(
          state: state,
          onPlaybackVisualUpdate: onPlaybackVisualUpdate,
        ) {
    _readAheadScheduler = TtsReadAheadScheduler<TtsSpeakRequest>(
      keyOf: _preloadRequestKey,
      dispatch: (request) => _ttsService.preload(
        text: request.text,
      ),
      onError: (error, stackTrace, request) {
        LogUtils.w('TTS 预合成失败: $error');
      },
    );
  }

  final BookReadState state;
  final TtsService _ttsService;
  final VoidCallback onUpdate;
  final VoidCallback onPlaybackVisualUpdate;
  final Future<void> Function(int page) onJumpToPageAndSettle;
  final Future<void> Function(int chapterIndex) onJumpToChapterAndSettle;
  final Future<void> Function(
    bool pre, {
    FutureOr<void> Function()? onContentReady,
  }) onNextChapterAndSettle;
  final Future<ChapterCache?> Function(int chapterIndex) onLoadChapterCache;
  final Future<void> Function() onWaitForReadPageSettled;
  final BookReadTtsSnapshotController _snapshotController;
  final BookReadTtsVisualController _visualController;
  late final TtsReadAheadScheduler<TtsSpeakRequest> _readAheadScheduler;

  static const int _readAheadRefreshRemainingChars = 8;
  static const double _readAheadRefreshThreshold = 0.6;
  static const int _maxConsecutiveSentencesWithoutProgress = 3;

  final TtsPlaybackSession _session = TtsPlaybackSession();
  int _readingPositionChangeEpoch = 0;
  bool _isLoadingNextChapterReadAhead = false;
  bool _isDisposed = false;

  Future<void> init() async {
    _ttsService.onStart = _handleStart;
    _ttsService.onComplete = _handleSentenceComplete;
    _ttsService.onError = _handleError;
    _ttsService.onProgress = _handleProgress;
    try {
      await _ttsService.init();
      await _applySettings();
      await loadVoices();
    } catch (e, stackTrace) {
      state.isTtsEnabled = false;
      state.isTtsLoadingVoices = false;
      LogUtils.e('TTS 初始化失败，已跳过朗读初始化: $e', stackTrace: stackTrace);
      onUpdate();
    }
  }

  Future<void> loadVoices() async {
    if (_isDisposed) return;
    state.isTtsLoadingVoices = true;
    onUpdate();
    try {
      state.ttsVoices = await _ttsService.loadVoices();
      if (!_hasValidSelectedVoice() && state.ttsVoices.isNotEmpty) {
        final preferred = state.ttsVoices.firstWhere(
          (voice) => (voice.locale ?? '').toLowerCase().startsWith('zh'),
          orElse: () => state.ttsVoices.first,
        );
        state.ttsVoiceName = preferred.name;
        await _ttsService.setVoiceByName(preferred.name);
      }
    } catch (e) {
      LogUtils.e('加载 TTS 发音人失败: $e');
    } finally {
      state.isTtsLoadingVoices = false;
      onUpdate();
    }
  }

  Future<void> start() async {
    if (_isDisposed) return;
    if (!state.isTtsEnabled) return;
    if (state.isTtsPlaying && !state.isTtsPaused) {
      return;
    }

    _readingPositionChangeEpoch++;
    _beginNewSession();

    final prepared = _prepareTargetForCurrentPage(
      chapterIndex: state.currentChapterIndex,
      pageIndex: state.currentPage,
      forceResetSentence: state.ttsCurrentSentence == null,
      allowResumeFromCursor: state.isTtsPaused,
      playbackToken: _currentSessionToken,
    );
    if (prepared == null) {
      await stop();
      return;
    }

    _activatePreparedTarget(prepared);
    state.isTtsPlaying = true;
    state.isTtsPaused = false;
    onUpdate();

    await _applySettings();
    await _speakPreparedTarget(prepared);
  }

  Future<void> pause() async {
    if (!state.isTtsEnabled) return;
    if (!state.isTtsPlaying || state.isTtsPaused) return;
    _readingPositionChangeEpoch++;
    state.isTtsPaused = true;
    _invalidateActivePlayback(resetSessionToken: true);
    onUpdate();
    try {
      await _ttsService.pause();
    } catch (e) {
      LogUtils.e('暂停 TTS 失败: $e');
    }
  }

  Future<void> stop() async {
    _readingPositionChangeEpoch++;
    _invalidateActivePlayback(resetSessionToken: true);
    if (state.isTtsEnabled) {
      try {
        await _ttsService.stop();
      } catch (e) {
        LogUtils.e('停止 TTS 失败: $e');
      }
    }
    _resetPlaybackState(clearSentenceState: true);
    onUpdate();
  }

  Future<void> toggle() async {
    if (state.isTtsPlaying && !state.isTtsPaused) {
      await pause();
      return;
    }
    await start();
  }

  Future<bool> startFromCurrentPageParagraphOffset(int pageTextOffset) async {
    return startFromPageParagraphOffset(
      pageIndex: state.currentPage,
      pageTextOffset: pageTextOffset,
    );
  }

  Future<bool> startFromPageParagraphOffset({
    required int pageIndex,
    required int pageTextOffset,
  }) async {
    if (_isDisposed) return false;
    if (!state.isTtsEnabled) return false;

    final snapshot = _snapshotController.getCurrentPageSnapshot(
      chapterIndex: state.currentChapterIndex,
      pageIndex: pageIndex,
    );
    if (snapshot == null || snapshot.segments.isEmpty) {
      return false;
    }

    final paragraph =
        ReaderParagraphUtils.resolveAt(snapshot.rawText, pageTextOffset);
    if (paragraph == null || paragraph.isEmpty) {
      return false;
    }

    final sentenceIndex =
        ReaderParagraphUtils.findFirstSentenceIndexForParagraph(
      snapshot.segments,
      paragraph,
    );
    if (sentenceIndex == null) {
      return false;
    }

    await _restartPlaybackFromSnapshot(
      snapshot: snapshot,
      sentenceIndex: sentenceIndex,
    );
    return true;
  }

  Future<bool> startFromChapterParagraphOffset({
    required int chapterIndex,
    required int chapterOffset,
  }) async {
    if (_isDisposed) return false;
    if (!state.isTtsEnabled) return false;

    if (state.currentChapterIndex != chapterIndex ||
        state.bookContentList.isEmpty) {
      await onJumpToChapterAndSettle(chapterIndex);
    }
    if (_isDisposed ||
        state.currentChapterIndex != chapterIndex ||
        state.bookContentList.isEmpty) {
      return false;
    }

    final safeChapterOffset = chapterOffset
        .clamp(
          0,
          math.max(0, state.bookContent.length - 1),
        )
        .toInt();
    final targetPageIndex =
        _snapshotController.locatePageIndexForChapterOffset(safeChapterOffset);
    if (targetPageIndex < 0 ||
        targetPageIndex >= state.bookContentList.length) {
      return false;
    }

    if (state.currentPage != targetPageIndex) {
      await onJumpToPageAndSettle(targetPageIndex);
    }
    if (_isDisposed ||
        state.currentChapterIndex != chapterIndex ||
        state.currentPage != targetPageIndex) {
      return false;
    }

    final snapshot = _snapshotController.getCurrentPageSnapshot(
      chapterIndex: chapterIndex,
      pageIndex: targetPageIndex,
    );
    if (snapshot == null || snapshot.segments.isEmpty) {
      return false;
    }

    final pageStartOffset =
        _snapshotController.computePageStartOffsetInChapter(targetPageIndex);
    final pageOffset = (safeChapterOffset - pageStartOffset)
        .clamp(
          0,
          math.max(0, snapshot.rawText.length - 1),
        )
        .toInt();
    final sentenceIndex = _snapshotController.findSentenceIndexForPageOffset(
      snapshot,
      pageOffset,
    );
    if (sentenceIndex == null) {
      return false;
    }

    await _restartPlaybackFromSnapshot(
      snapshot: snapshot,
      sentenceIndex: sentenceIndex,
    );
    return true;
  }

  Future<void> updateRate(double value) async {
    await _ttsService.setRate(value);
  }

  Future<void> updatePitch(double value) async {
    await _ttsService.setPitch(value);
  }

  Future<void> updateVolume(double value) async {
    await _ttsService.setVolume(value);
  }

  Future<void> updateVoiceName(String? voiceName) async {
    await _ttsService.setVoiceByName(voiceName);
  }

  Future<void> handleReadingPositionChanged({
    bool forceResume = false,
  }) async {
    if (!state.isTtsPlaying) return;
    if (state.isTtsPaused) return;
    if (!forceResume && !state.ttsResumeAfterInterrupt) {
      await stop();
      return;
    }

    final positionChangeEpoch = ++_readingPositionChangeEpoch;
    _invalidateActivePlayback(resetSessionToken: false);
    _beginNewSession();

    await onWaitForReadPageSettled();
    if (_isDisposed ||
        positionChangeEpoch != _readingPositionChangeEpoch ||
        !state.isTtsPlaying ||
        state.isTtsPaused) {
      return;
    }

    await _speakCurrentPosition(
      forceResetSentence: true,
      allowResumeFromCursor: false,
      playbackToken: _currentSessionToken,
    );
  }

  Future<void> dispose() async {
    _isDisposed = true;
    _session.dispose();
    _readAheadScheduler.dispose();
    _visualController.dispose();
    _snapshotController.clear();
    await _ttsService.dispose();
  }

  Future<void> _applySettings() async {
    await _ttsService.setRate(state.ttsRate);
    await _ttsService.setPitch(state.ttsPitch);
    await _ttsService.setVolume(state.ttsVolume);
    await _ttsService.setVoiceByName(state.ttsVoiceName);
  }

  bool _hasValidSelectedVoice() {
    final currentVoiceName = state.ttsVoiceName?.trim();
    if (currentVoiceName == null || currentVoiceName.isEmpty) {
      return false;
    }
    for (final voice in state.ttsVoices) {
      if (voice.name == currentVoiceName) {
        return true;
      }
    }
    return false;
  }

  Future<void> _speakCurrentPosition({
    required bool forceResetSentence,
    required bool allowResumeFromCursor,
    required int playbackToken,
  }) async {
    if (_isDisposed) return;

    final prepared = _prepareTargetForCurrentPage(
      chapterIndex: state.currentChapterIndex,
      pageIndex: state.currentPage,
      forceResetSentence: forceResetSentence,
      allowResumeFromCursor: allowResumeFromCursor,
      playbackToken: playbackToken,
    );
    if (prepared == null) {
      await stop();
      return;
    }

    _activatePreparedTarget(prepared);
    state.isTtsPlaying = true;
    state.isTtsPaused = false;
    onUpdate();
    await _speakPreparedTarget(prepared);
  }

  Future<void> _restartPlaybackFromSnapshot({
    required TtsPageSnapshot snapshot,
    required int sentenceIndex,
  }) async {
    if (sentenceIndex < 0 || sentenceIndex >= snapshot.segments.length) {
      return;
    }

    _readingPositionChangeEpoch++;
    _invalidateActivePlayback(resetSessionToken: true);
    await _ttsService.stop();
    _resetPlaybackState(clearSentenceState: true);
    _beginNewSession();

    _session.setActivePage(
      chapterIndex: snapshot.chapterIndex,
      pageIndex: snapshot.pageIndex,
    );
    state.currentPageSentences =
        snapshot.segments.map((item) => item.text).toList(growable: false);

    final prepared = _buildPreparedTarget(
      snapshot: snapshot,
      segment: snapshot.segments[sentenceIndex],
      sentenceIndex: sentenceIndex,
      resumeOffsetInSentence: 0,
      playbackToken: _currentSessionToken,
    );

    _activatePreparedTarget(prepared);
    state.isTtsPlaying = true;
    state.isTtsPaused = false;
    onUpdate();

    await _applySettings();
    await _speakPreparedTarget(prepared);
  }

  TtsPreparedTarget? _prepareTargetForCurrentPage({
    required int chapterIndex,
    required int pageIndex,
    required bool forceResetSentence,
    required bool allowResumeFromCursor,
    required int playbackToken,
  }) {
    final snapshot = _snapshotController.getCurrentPageSnapshot(
      chapterIndex: chapterIndex,
      pageIndex: pageIndex,
    );
    if (snapshot == null || snapshot.segments.isEmpty) {
      return null;
    }

    final segments = snapshot.segments;
    if (forceResetSentence ||
        !_session.matchesActivePage(
          chapterIndex: chapterIndex,
          pageIndex: pageIndex,
        ) ||
        state.ttsSentenceIndex >= segments.length) {
      state.ttsSentenceIndex = 0;
    }

    _session.setActivePage(
      chapterIndex: chapterIndex,
      pageIndex: pageIndex,
    );
    state.currentPageSentences =
        segments.map((item) => item.text).toList(growable: false);

    var sentenceIndex = state.ttsSentenceIndex;
    var resumeOffsetInSentence = 0;
    if (allowResumeFromCursor) {
      final resumePlan = _resolveResumePlan(
        snapshot,
        sentenceIndex: sentenceIndex,
        playbackToken: playbackToken,
      );
      if (resumePlan.redirectTarget != null) {
        return resumePlan.redirectTarget;
      }
      sentenceIndex = resumePlan.sentenceIndex;
      resumeOffsetInSentence = resumePlan.resumeOffsetInSentence;
    }

    final segment = segments[sentenceIndex];
    return _buildPreparedTarget(
      snapshot: snapshot,
      segment: segment,
      sentenceIndex: sentenceIndex,
      resumeOffsetInSentence: resumeOffsetInSentence,
      playbackToken: playbackToken,
    );
  }

  _ResumePlan _resolveResumePlan(
    TtsPageSnapshot snapshot, {
    required int sentenceIndex,
    required int playbackToken,
  }) {
    final resumeOffset = _resolveResumeOffset(
      snapshot,
      sentenceIndex: sentenceIndex,
    );
    final segment = snapshot.segments[sentenceIndex];
    final remainingLength =
        (segment.text.length - resumeOffset).clamp(0, segment.text.length);
    if (resumeOffset <= 0 ||
        remainingLength > _minResumeRemainingCharsForPlatform) {
      return _ResumePlan(
        sentenceIndex: sentenceIndex,
        resumeOffsetInSentence: resumeOffset,
      );
    }

    if (sentenceIndex < snapshot.segments.length - 1) {
      final nextSegment = snapshot.segments[sentenceIndex + 1];
      return _ResumePlan(
        sentenceIndex: sentenceIndex + 1,
        redirectTarget: _buildPreparedTarget(
          snapshot: snapshot,
          segment: nextSegment,
          sentenceIndex: sentenceIndex + 1,
          resumeOffsetInSentence: 0,
          playbackToken: playbackToken,
        ),
      );
    }

    if (state.ttsAutoNextPage && snapshot.pageIndex < state.pageSize - 1) {
      final nextPageTarget = _prepareFirstTargetForCurrentChapterPage(
        chapterIndex: snapshot.chapterIndex,
        pageIndex: snapshot.pageIndex + 1,
        playbackToken: playbackToken,
      );
      if (nextPageTarget != null) {
        return _ResumePlan(
          sentenceIndex: sentenceIndex,
          redirectTarget: nextPageTarget,
        );
      }
    }

    if (state.ttsAutoNextChapter) {
      final nextChapterTarget = _prepareFirstTargetForNextChapter(
        playbackToken: playbackToken,
      );
      if (nextChapterTarget != null) {
        return _ResumePlan(
          sentenceIndex: sentenceIndex,
          redirectTarget: nextChapterTarget,
        );
      }
    }

    return _ResumePlan(
      sentenceIndex: sentenceIndex,
      resumeOffsetInSentence: resumeOffset,
    );
  }

  TtsPreparedTarget _buildPreparedTarget({
    required TtsPageSnapshot snapshot,
    required TtsSentenceSegment segment,
    required int sentenceIndex,
    required int resumeOffsetInSentence,
    required int playbackToken,
  }) {
    return TtsPreparedTarget(
      snapshot: snapshot,
      segment: segment,
      sentenceIndex: sentenceIndex,
      resumeOffsetInSentence: resumeOffsetInSentence,
      playbackToken: playbackToken,
      preparedAt: DateTime.now(),
    );
  }

  TtsPreparedTarget? _prepareFirstTargetForCurrentChapterPage({
    required int chapterIndex,
    required int pageIndex,
    required int playbackToken,
  }) {
    final snapshot = _snapshotController.getCurrentPageSnapshot(
      chapterIndex: chapterIndex,
      pageIndex: pageIndex,
    );
    if (snapshot == null || snapshot.segments.isEmpty) {
      return null;
    }

    return _buildPreparedTarget(
      snapshot: snapshot,
      segment: snapshot.segments.first,
      sentenceIndex: 0,
      resumeOffsetInSentence: 0,
      playbackToken: playbackToken,
    );
  }

  TtsPreparedTarget? _prepareTargetFromActiveSnapshot({
    required int sentenceIndex,
    required int playbackToken,
  }) {
    final snapshot = _session.activeTarget?.snapshot;
    if (snapshot == null ||
        sentenceIndex < 0 ||
        sentenceIndex >= snapshot.segments.length) {
      return null;
    }

    return _buildPreparedTarget(
      snapshot: snapshot,
      segment: snapshot.segments[sentenceIndex],
      sentenceIndex: sentenceIndex,
      resumeOffsetInSentence: 0,
      playbackToken: playbackToken,
    );
  }

  TtsPreparedTarget? _prepareFirstTargetForNextChapter({
    required int playbackToken,
  }) {
    final nextCache = state.nextChapterCache;
    if (nextCache == null || nextCache.pages.isEmpty) {
      return null;
    }

    final nextChapterSnapshot = _snapshotController.getSnapshotForText(
      chapterIndex: nextCache.chapterIndex,
      pageIndex: 0,
      pageText: nextCache.pages.first,
      pageStartOffsetInChapter: 0,
    );
    if (nextChapterSnapshot.segments.isEmpty) {
      return null;
    }

    return _buildPreparedTarget(
      snapshot: nextChapterSnapshot,
      segment: nextChapterSnapshot.segments.first,
      sentenceIndex: 0,
      resumeOffsetInSentence: 0,
      playbackToken: playbackToken,
    );
  }

  int _resolveResumeOffset(
    TtsPageSnapshot snapshot, {
    required int sentenceIndex,
  }) {
    if (!state.isTtsProgressReliable) {
      return 0;
    }

    final cursor = state.ttsPlaybackCursor;
    if (cursor == null ||
        cursor.chapterIndex != snapshot.chapterIndex ||
        cursor.pageIndex != snapshot.pageIndex ||
        cursor.sentenceIndex != sentenceIndex ||
        cursor.progressStartInSentence == null) {
      return 0;
    }

    final segment = snapshot.segments[sentenceIndex];
    final progressStart = cursor.progressStartInSentence!;
    final resumeOffset =
        math.max(0, progressStart - _resumeRewindCharsForPlatform);
    return resumeOffset.clamp(0, segment.text.length);
  }

  void _activatePreparedTarget(TtsPreparedTarget prepared) {
    _session.setActiveTarget(prepared);
    state.currentPageSentences = prepared.snapshot.segments
        .map((item) => item.text)
        .toList(growable: false);
    _visualController.resetProgressCadence();
    _syncPlaybackState(
      prepared: prepared,
      highlightStartInPage: prepared.initialHighlightStartInPage,
      highlightEndInPage: prepared.initialHighlightEndInPage,
      progressStartInSentence: prepared.resumeOffsetInSentence > 0
          ? prepared.resumeOffsetInSentence
          : null,
      progressEndInSentence: prepared.resumeOffsetInSentence > 0
          ? prepared.resumeOffsetInSentence
          : null,
    );
    _prepareReadAhead(prepared);
  }

  void _prepareReadAhead(
    TtsPreparedTarget current, {
    bool forceRefresh = false,
  }) {
    if (!forceRefresh &&
        state.ttsReadAheadBuffer?.current?.sentenceIndex ==
            current.sentenceIndex &&
        state.ttsReadAheadBuffer?.current?.pageIndex == current.pageIndex &&
        state.ttsReadAheadBuffer?.current?.chapterIndex ==
            current.chapterIndex &&
        state.ttsReadAheadBuffer?.playbackToken == current.playbackToken) {
      return;
    }

    state.isTtsPreparingNext = true;

    final snapshot = current.snapshot;
    final nextSentenceIndex = current.sentenceIndex + 1;
    final nextSentence = nextSentenceIndex < snapshot.segments.length
        ? _buildPreparedTarget(
            snapshot: snapshot,
            segment: snapshot.segments[nextSentenceIndex],
            sentenceIndex: nextSentenceIndex,
            resumeOffsetInSentence: 0,
            playbackToken: current.playbackToken,
          )
        : null;
    final preloadSentences = <TtsPreparedTarget>[];
    final preloadSentenceEnd = math.min(
      snapshot.segments.length,
      current.sentenceIndex + _readAheadScheduler.samePageWindow + 1,
    );
    for (var index = nextSentenceIndex + 1;
        index < preloadSentenceEnd;
        index++) {
      preloadSentences.add(
        _buildPreparedTarget(
          snapshot: snapshot,
          segment: snapshot.segments[index],
          sentenceIndex: index,
          resumeOffsetInSentence: 0,
          playbackToken: current.playbackToken,
        ),
      );
    }

    final nextPageFirstSentence = snapshot.pageIndex < state.pageSize - 1
        ? _prepareFirstTargetForCurrentChapterPage(
            chapterIndex: snapshot.chapterIndex,
            pageIndex: snapshot.pageIndex + 1,
            playbackToken: current.playbackToken,
          )
        : null;

    final nextChapterFirstSentence = _prepareFirstTargetForNextChapter(
      playbackToken: current.playbackToken,
    );

    state.ttsReadAheadBuffer = TtsReadAheadBuffer(
      playbackToken: current.playbackToken,
      preparedAt: DateTime.now(),
      current: current,
      nextSentence: nextSentence,
      nextPageFirstSentence: nextPageFirstSentence,
      nextChapterFirstSentence: nextChapterFirstSentence,
    );
    state.isTtsPreparingNext = false;
    final nextPagePreloadTargets = _targetsStartingAt(
      nextPageFirstSentence,
      count: _readAheadScheduler.nextPageWindow,
    );
    _scheduleReadAhead(
      sessionId: current.playbackToken,
      samePage: <TtsPreparedTarget?>[nextSentence, ...preloadSentences],
      nextPage: nextPagePreloadTargets,
      nextChapter: <TtsPreparedTarget?>[nextChapterFirstSentence],
    );
    if (nextChapterFirstSentence == null) {
      unawaited(_primeNextChapterReadAheadIfNeeded(current));
    }
  }

  void _handleStart() {
    if (!_hasActivePlayback) return;
    state.isTtsPlaying = true;
    state.isTtsPaused = false;
    _visualController.requestPlaybackVisualUpdate(immediate: true);
    onUpdate();
  }

  Future<void> _handleSentenceComplete() async {
    if (!_hasActivePlayback || !state.isTtsPlaying || state.isTtsPaused) {
      return;
    }

    _updateProgressReliabilityAfterSentence();

    final sentences = state.currentPageSentences;
    if (sentences.isEmpty) {
      await stop();
      return;
    }

    if (state.ttsSentenceIndex < sentences.length - 1) {
      state.ttsSentenceIndex++;
      final nextPrepared = _takeReadAheadNextSentence() ??
          _prepareTargetFromActiveSnapshot(
            sentenceIndex: state.ttsSentenceIndex,
            playbackToken: _currentSessionToken,
          );
      if (nextPrepared == null) {
        await stop();
        return;
      }

      _activatePreparedTarget(nextPrepared);
      state.isTtsPlaying = true;
      state.isTtsPaused = false;
      onUpdate();
      await _speakPreparedTarget(nextPrepared);
      return;
    }

    final completedTarget = _session.activeTarget;
    final completedSnapshot = completedTarget?.snapshot;
    if (state.ttsAutoNextPage &&
        completedSnapshot != null &&
        completedSnapshot.chapterIndex == state.currentChapterIndex &&
        completedSnapshot.pageIndex < state.pageSize - 1) {
      final playbackEpoch = _session.activeSpeakEpoch;
      final nextPage = completedSnapshot.pageIndex + 1;
      final nextPrepared = _takeReadAheadNextPageFirstSentence(
            chapterIndex: completedSnapshot.chapterIndex,
            pageIndex: nextPage,
          ) ??
          _prepareFirstTargetForCurrentChapterPage(
            chapterIndex: completedSnapshot.chapterIndex,
            pageIndex: nextPage,
            playbackToken: _currentSessionToken,
          );
      if (nextPrepared == null) {
        await stop();
        return;
      }

      _activatePreparedTarget(nextPrepared);
      state.isTtsPlaying = true;
      state.isTtsPaused = false;
      onUpdate();
      final nextVisibleAnchor = state.isTwoPageMode
          ? TwoPageSpreadStrategy.anchorFor(nextPage)
          : nextPage;
      if (state.currentChapterIndex == completedSnapshot.chapterIndex &&
          state.currentPage != nextVisibleAnchor) {
        await onJumpToPageAndSettle(nextPage);
        if (!_session.isEpochActive(playbackEpoch)) {
          return;
        }
      }
      await _speakPreparedTarget(nextPrepared);
      return;
    }

    if (state.ttsAutoNextChapter) {
      final currentIndex = _findCurrentChapterListIndex();
      final chapters = state.bookDetail.chapters;
      if (chapters != null &&
          currentIndex >= 0 &&
          currentIndex < chapters.length - 1) {
        final nextChapterName = chapters[currentIndex + 1].chapterName;
        final pendingNextPrepared = _takeReadAheadNextChapterFirstSentence();
        TtsPreparedTarget? preparedAfterContentReady;
        final playbackEpoch = _session.activeSpeakEpoch;
        final previousChapterIndex = state.currentChapterIndex;
        final previousPageIndex = state.currentPage;
        if (pendingNextPrepared == null) {
          _setChapterTransitionState(
            nextChapterName?.trim().isNotEmpty == true
                ? '加载 ${nextChapterName!.trim()}'
                : '加载下一章',
          );
        }
        await onNextChapterAndSettle(
          false,
          onContentReady: pendingNextPrepared == null
              ? () {
                  if (!_session.isEpochActive(playbackEpoch)) return;
                  preparedAfterContentReady = _prepareTargetForCurrentPage(
                    chapterIndex: state.currentChapterIndex,
                    pageIndex: state.currentPage,
                    forceResetSentence: true,
                    allowResumeFromCursor: false,
                    playbackToken: _currentSessionToken,
                  );
                }
              : null,
        );
        _clearChapterTransitionState();
        if (!_session.isEpochActive(playbackEpoch)) {
          return;
        }

        final didMoveToNewChapter =
            state.currentChapterIndex != previousChapterIndex ||
                state.currentPage != previousPageIndex;
        if (!didMoveToNewChapter && pendingNextPrepared == null) {
          await stop();
          return;
        }

        final nextPrepared = pendingNextPrepared ??
            preparedAfterContentReady ??
            _takeReadAheadNextChapterFirstSentence();
        if (nextPrepared != null &&
            _matchesStatePage(
              nextPrepared,
              chapterIndex: state.currentChapterIndex,
              pageIndex: state.currentPage,
            )) {
          _activatePreparedTarget(nextPrepared);
          state.isTtsPlaying = true;
          state.isTtsPaused = false;
          onUpdate();
          await _speakPreparedTarget(nextPrepared);
          return;
        }

        await _speakCurrentPosition(
          forceResetSentence: true,
          allowResumeFromCursor: false,
          playbackToken: _currentSessionToken,
        );
        return;
      }
    }

    await stop();
  }

  void _handleProgress(TtsSpeechProgress progress) {
    if (!_hasActivePlayback || state.isTtsPaused) return;

    final activePrepared = _session.activeTarget;
    if (activePrepared == null) return;

    final sentenceText =
        _session.activeRequest?.text ?? activePrepared.sentence;
    if (sentenceText.isNotEmpty &&
        progress.text.isNotEmpty &&
        progress.text != sentenceText) {
      return;
    }

    final wasProgressReliable = state.isTtsProgressReliable;
    _session.markProgressReceived();
    if (!state.isTtsProgressReliable) {
      state.isTtsProgressReliable = true;
    }

    final segment = activePrepared.segment;
    final sentenceLength = segment.text.length;
    final rawProgressStart =
        activePrepared.resumeOffsetInSentence + progress.start;
    final rawProgressEnd = activePrepared.resumeOffsetInSentence + progress.end;
    final progressStartInSentence = rawProgressStart.clamp(0, sentenceLength);
    var progressEndInSentence =
        rawProgressEnd.clamp(progressStartInSentence, sentenceLength);
    if (progressEndInSentence <= progressStartInSentence &&
        progress.word.isNotEmpty) {
      progressEndInSentence = (progressStartInSentence + progress.word.length)
          .clamp(progressStartInSentence, sentenceLength);
    }
    if (progressEndInSentence <= progressStartInSentence) {
      return;
    }

    _refreshReadAheadIfNeeded(
      activePrepared,
      progressStartInSentence: progressStartInSentence,
      sentenceLength: sentenceLength,
    );

    final previousCursor = state.ttsPlaybackCursor;
    final progressUpdatedAt = DateTime.now();
    _visualController.recordProgressEvent(progressUpdatedAt);
    final playbackCursor = _buildPlaybackCursor(
      prepared: activePrepared,
      highlightStartInPage: segment.start,
      highlightEndInPage: segment.end,
      progressStartInSentence: progressStartInSentence,
      progressEndInSentence: progressEndInSentence,
      currentWord: progress.word,
      lastProgressAt: progressUpdatedAt,
    );
    state.ttsPlaybackCursor = playbackCursor;
    final visualComparisonCursor =
        _visualController.resolveVisualComparisonCursor(
      prepared: activePrepared,
      fallbackCursor: previousCursor,
    );
    final progressUiThrottle = _visualController.resolveProgressUiThrottle(
      current: activePrepared,
      progressStartInSentence: progressStartInSentence,
      progressEndInSentence: progressEndInSentence,
      currentWord: progress.word,
    );

    if (!_visualController.shouldApplyProgressVisualUpdate(
      comparisonCursor: visualComparisonCursor,
      progressStartInSentence: progressStartInSentence,
      progressEndInSentence: progressEndInSentence,
      currentWord: progress.word,
      progressUpdatedAt: progressUpdatedAt,
      progressUiThrottle: progressUiThrottle,
    )) {
      return;
    }

    _applyPlaybackVisualState(
      prepared: activePrepared,
      playbackCursor: playbackCursor,
    );

    final progressReliabilityChanged =
        wasProgressReliable != state.isTtsProgressReliable;
    if (progressReliabilityChanged ||
        _visualController.didProgressVisualPayloadChange(
          visualComparisonCursor,
          playbackCursor,
        )) {
      _visualController.requestPlaybackVisualUpdate(
        immediate: _visualController.shouldFlushProgressVisualImmediately(
          comparisonCursor: visualComparisonCursor,
          current: activePrepared,
          currentCursor: playbackCursor,
          progressUpdatedAt: progressUpdatedAt,
          progressUiThrottle: progressUiThrottle,
        ),
        throttle: progressUiThrottle,
      );
    }
  }

  void _refreshReadAheadIfNeeded(
    TtsPreparedTarget current, {
    required int progressStartInSentence,
    required int sentenceLength,
  }) {
    if (!state.isTtsProgressReliable) return;
    if (_session.readAheadRefreshed) return;
    if (sentenceLength <= 0) return;

    final progressRatio = progressStartInSentence / sentenceLength;
    final remainingLength = sentenceLength - progressStartInSentence;
    if (progressRatio < _readAheadRefreshThreshold &&
        remainingLength > _readAheadRefreshRemainingChars) {
      return;
    }

    _session.markReadAheadRefreshed();
    _prepareReadAhead(current, forceRefresh: true);
  }

  Future<void> _primeNextChapterReadAheadIfNeeded(
    TtsPreparedTarget current,
  ) async {
    if (_isDisposed || _isLoadingNextChapterReadAhead) return;
    if (state.nextChapterCache != null &&
        state.nextChapterCache!.chapterIndex != current.chapterIndex) {
      return;
    }

    final chapters = state.bookDetail.chapters;
    if (chapters == null || chapters.isEmpty) return;
    final currentIndex = chapters.indexWhere(
      (chapter) => chapter.chapterIndex == current.chapterIndex,
    );
    if (currentIndex < 0 || currentIndex >= chapters.length - 1) return;

    final nextChapter = chapters[currentIndex + 1];
    final nextChapterIndex = nextChapter.chapterIndex;
    if (nextChapterIndex == null) return;
    if (state.nextChapterCache?.chapterIndex == nextChapterIndex) return;

    _isLoadingNextChapterReadAhead = true;
    state.isTtsPreparingNext = true;

    try {
      final cache = await onLoadChapterCache(nextChapterIndex);
      if (cache == null ||
          _isDisposed ||
          current.playbackToken != _currentSessionToken ||
          _session.activeTarget?.chapterIndex != current.chapterIndex) {
        return;
      }

      state.nextChapterCache = cache;
      final target = _prepareFirstTargetForNextChapter(
        playbackToken: current.playbackToken,
      );
      final buffer = state.ttsReadAheadBuffer;
      if (target != null &&
          buffer != null &&
          buffer.playbackToken == current.playbackToken) {
        state.ttsReadAheadBuffer = buffer.copyWith(
          nextChapterFirstSentence: target,
          preparedAt: DateTime.now(),
        );
        _scheduleReadAhead(
          sessionId: current.playbackToken,
          nextChapter: <TtsPreparedTarget?>[target],
        );
      }
    } catch (e) {
      LogUtils.w('TTS 预取下一章失败: $e');
    } finally {
      _isLoadingNextChapterReadAhead = false;
      if (!_isDisposed) {
        state.isTtsPreparingNext = false;
      }
    }
  }

  void _handleError(String message) {
    LogUtils.e('TTS 播放失败: $message');
    unawaited(DialogUtils.waring('TTS 播放失败：$message'));
    unawaited(stop());
  }

  void _setChapterTransitionState(String message) {
    if (state.isTtsTransitioningChapter &&
        state.ttsTransitionMessage == message) {
      return;
    }
    state.isTtsTransitioningChapter = true;
    state.ttsTransitionMessage = message;
    onUpdate();
  }

  void _clearChapterTransitionState() {
    if (!state.isTtsTransitioningChapter &&
        state.ttsTransitionMessage == null) {
      return;
    }
    state.isTtsTransitioningChapter = false;
    state.ttsTransitionMessage = null;
    onUpdate();
  }

  int get _resumeRewindCharsForPlatform {
    if (kIsWeb) return 4;

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 5;
      case TargetPlatform.iOS:
        return 7;
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
        return 8;
      case TargetPlatform.fuchsia:
        return 6;
    }
  }

  int get _minResumeRemainingCharsForPlatform {
    if (kIsWeb) return 3;

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 4;
      case TargetPlatform.iOS:
        return 5;
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
        return 6;
      case TargetPlatform.fuchsia:
        return 4;
    }
  }

  void _updateProgressReliabilityAfterSentence() {
    state.isTtsProgressReliable = _session.finishSentenceProgress(
      unreliableAfter: _maxConsecutiveSentencesWithoutProgress,
    );
  }

  Future<void> _speakPreparedTarget(TtsPreparedTarget prepared) async {
    final request = prepared.toSpeakRequest();
    final playbackEpoch = _session.beginSpeak(prepared);
    await _ttsService.speak(
      text: request.text,
    );
    if (!_session.isEpochActive(playbackEpoch)) {
      LogUtils.d('忽略过期的 TTS 播放请求');
    }
  }

  void _scheduleReadAhead({
    required int sessionId,
    Iterable<TtsPreparedTarget?> samePage = const <TtsPreparedTarget?>[],
    Iterable<TtsPreparedTarget?> nextPage = const <TtsPreparedTarget?>[],
    Iterable<TtsPreparedTarget?> nextChapter = const <TtsPreparedTarget?>[],
  }) {
    Iterable<TtsSpeakRequest> requests(Iterable<TtsPreparedTarget?> targets) {
      return targets
          .whereType<TtsPreparedTarget>()
          .where((target) => target.playbackToken == _currentSessionToken)
          .map((target) => target.toSpeakRequest())
          .where((request) => request.text.trim().isNotEmpty);
    }

    _readAheadScheduler.schedule(
      sessionId: sessionId,
      samePage: requests(samePage),
      nextPage: requests(nextPage),
      nextChapter: requests(nextChapter),
    );
  }

  static String _preloadRequestKey(TtsSpeakRequest request) {
    return '${request.chapterIndex}:'
        '${request.pageIndex}:'
        '${request.sentenceIndex}:'
        '${request.text.hashCode}';
  }

  List<TtsPreparedTarget> _targetsStartingAt(
    TtsPreparedTarget? first, {
    required int count,
  }) {
    if (first == null || count <= 0) return const <TtsPreparedTarget>[];
    final snapshot = first.snapshot;
    final end = math.min(snapshot.segments.length, first.sentenceIndex + count);
    return List<TtsPreparedTarget>.generate(
      end - first.sentenceIndex,
      (offset) {
        final sentenceIndex = first.sentenceIndex + offset;
        if (offset == 0) return first;
        return _buildPreparedTarget(
          snapshot: snapshot,
          segment: snapshot.segments[sentenceIndex],
          sentenceIndex: sentenceIndex,
          resumeOffsetInSentence: 0,
          playbackToken: first.playbackToken,
        );
      },
      growable: false,
    );
  }

  void _syncPlaybackState({
    required TtsPreparedTarget prepared,
    required int highlightStartInPage,
    required int highlightEndInPage,
    int? progressStartInSentence,
    int? progressEndInSentence,
    String? currentWord,
    DateTime? lastProgressAt,
  }) {
    final playbackCursor = _buildPlaybackCursor(
      prepared: prepared,
      highlightStartInPage: highlightStartInPage,
      highlightEndInPage: highlightEndInPage,
      progressStartInSentence: progressStartInSentence,
      progressEndInSentence: progressEndInSentence,
      currentWord: currentWord,
      lastProgressAt: lastProgressAt,
    );
    state.ttsPlaybackCursor = playbackCursor;
    _applyPlaybackVisualState(
      prepared: prepared,
      playbackCursor: playbackCursor,
    );
  }

  TtsPlaybackCursor _buildPlaybackCursor({
    required TtsPreparedTarget prepared,
    required int highlightStartInPage,
    required int highlightEndInPage,
    int? progressStartInSentence,
    int? progressEndInSentence,
    String? currentWord,
    DateTime? lastProgressAt,
  }) {
    final snapshot = prepared.snapshot;
    final segment = prepared.segment;
    final safeHighlightStart =
        highlightStartInPage.clamp(0, snapshot.rawText.length);
    final safeHighlightEnd =
        highlightEndInPage.clamp(safeHighlightStart, snapshot.rawText.length);
    final sentenceStartInChapter =
        snapshot.pageStartOffsetInChapter + segment.start;
    final sentenceEndInChapter =
        snapshot.pageStartOffsetInChapter + segment.end;
    final progressStartInPage = progressStartInSentence == null
        ? null
        : prepared.mapSentenceOffsetToRaw(progressStartInSentence);
    final progressEndInPage = progressEndInSentence == null
        ? null
        : prepared.mapSentenceOffsetToRawEnd(progressEndInSentence);
    final progressStartInChapter = progressStartInPage == null
        ? null
        : snapshot.pageStartOffsetInChapter + progressStartInPage;
    final progressEndInChapter = progressEndInPage == null
        ? null
        : snapshot.pageStartOffsetInChapter + progressEndInPage;

    return TtsPlaybackCursor(
      chapterIndex: snapshot.chapterIndex,
      pageIndex: snapshot.pageIndex,
      sentenceIndex: prepared.sentenceIndex,
      sentenceText: segment.text,
      sentenceStartInPage: segment.start,
      sentenceEndInPage: segment.end,
      sentenceStartInChapter: sentenceStartInChapter,
      sentenceEndInChapter: sentenceEndInChapter,
      progressStartInPage: progressStartInPage,
      progressEndInPage: progressEndInPage,
      progressStartInChapter: progressStartInChapter,
      progressEndInChapter: progressEndInChapter,
      highlightStartInPage: safeHighlightStart,
      highlightEndInPage: safeHighlightEnd,
      highlightStartInChapter:
          snapshot.pageStartOffsetInChapter + safeHighlightStart,
      highlightEndInChapter:
          snapshot.pageStartOffsetInChapter + safeHighlightEnd,
      progressStartInSentence: progressStartInSentence,
      progressEndInSentence: progressEndInSentence,
      currentWord: currentWord,
      lastProgressAt: lastProgressAt,
    );
  }

  void _applyPlaybackVisualState({
    required TtsPreparedTarget prepared,
    required TtsPlaybackCursor playbackCursor,
  }) {
    state.ttsSentenceIndex = prepared.sentenceIndex;
    state.ttsCurrentSentence = prepared.segment.text;
    state.ttsHighlightStart = playbackCursor.highlightStartInPage;
    state.ttsHighlightEnd = playbackCursor.highlightEndInPage;
    state.ttsHighlightPageIndex = playbackCursor.pageIndex;
    state.ttsHighlightChapterIndex = playbackCursor.chapterIndex;
  }

  void _invalidateActivePlayback({required bool resetSessionToken}) {
    _session.invalidate(resetSessionToken: resetSessionToken);
    _readAheadScheduler.cancel();
    _clearReadAheadBuffer();
    _visualController.clearPendingVisualUpdate(
      clearLastUiUpdateAt: true,
    );
  }

  void _clearReadAheadBuffer() {
    state.ttsReadAheadBuffer = null;
    state.isTtsPreparingNext = false;
    state.isTtsTransitioningChapter = false;
    state.ttsTransitionMessage = null;
    _session.clearActiveTarget();
    _isLoadingNextChapterReadAhead = false;
  }

  void _beginNewSession() {
    final sessionToken = _session.beginSession();
    _readAheadScheduler.startSession(sessionToken);
    _clearReadAheadBuffer();
  }

  int get _currentSessionToken => _session.currentToken;

  bool get _hasActivePlayback => !_isDisposed && _session.isActive;

  TtsPreparedTarget? _takeReadAheadNextSentence() {
    final buffer = state.ttsReadAheadBuffer;
    if (buffer == null) return null;

    final target = buffer.nextSentence;
    state.ttsReadAheadBuffer = buffer.copyWith(
      clearNextSentence: true,
      current: target ?? buffer.current,
      preparedAt: DateTime.now(),
    );
    return _isPreparedTargetActive(target) ? target : null;
  }

  TtsPreparedTarget? _takeReadAheadNextPageFirstSentence({
    required int chapterIndex,
    required int pageIndex,
  }) {
    final buffer = state.ttsReadAheadBuffer;
    if (buffer == null) return null;

    final target = buffer.nextPageFirstSentence;
    state.ttsReadAheadBuffer = buffer.copyWith(
      clearNextPageFirstSentence: true,
      current: target ?? buffer.current,
      preparedAt: DateTime.now(),
    );
    if (!_isPreparedTargetActive(target)) return null;
    if (!_matchesStatePage(target!,
        chapterIndex: chapterIndex, pageIndex: pageIndex)) {
      return null;
    }
    return target;
  }

  TtsPreparedTarget? _takeReadAheadNextChapterFirstSentence() {
    final buffer = state.ttsReadAheadBuffer;
    if (buffer == null) return null;

    final target = buffer.nextChapterFirstSentence;
    state.ttsReadAheadBuffer = buffer.copyWith(
      clearNextChapterFirstSentence: true,
      current: target ?? buffer.current,
      preparedAt: DateTime.now(),
    );
    return _isPreparedTargetActive(target) ? target : null;
  }

  bool _isPreparedTargetActive(TtsPreparedTarget? target) {
    if (target == null) return false;
    return target.playbackToken == _currentSessionToken;
  }

  bool _matchesStatePage(
    TtsPreparedTarget prepared, {
    required int chapterIndex,
    required int pageIndex,
  }) {
    if (prepared.chapterIndex != chapterIndex ||
        prepared.pageIndex != pageIndex) {
      return false;
    }

    if (chapterIndex == state.currentChapterIndex &&
        pageIndex >= 0 &&
        pageIndex < state.bookContentList.length) {
      return state.bookContentList[pageIndex] == prepared.snapshot.rawText;
    }

    final nextCache = state.nextChapterCache;
    if (nextCache != null &&
        nextCache.chapterIndex == chapterIndex &&
        pageIndex >= 0 &&
        pageIndex < nextCache.pages.length) {
      return nextCache.pages[pageIndex] == prepared.snapshot.rawText;
    }

    return false;
  }

  int _findCurrentChapterListIndex() {
    final chapters = state.bookDetail.chapters;
    if (chapters == null || chapters.isEmpty) return -1;
    return chapters.indexWhere(
      (chapter) => chapter.chapterIndex == state.currentChapterIndex,
    );
  }

  void _resetPlaybackState({required bool clearSentenceState}) {
    state.isTtsPlaying = false;
    state.isTtsPaused = false;
    _clearReadAheadBuffer();
    _visualController.clearPendingVisualUpdate(
      clearLastUiUpdateAt: true,
      clearLastVisualCursor: clearSentenceState,
    );
    if (clearSentenceState) {
      state.currentPageSentences = const <String>[];
      state.ttsSentenceIndex = 0;
      state.ttsCurrentSentence = null;
      state.ttsHighlightStart = null;
      state.ttsHighlightEnd = null;
      state.ttsHighlightPageIndex = null;
      state.ttsHighlightChapterIndex = null;
      state.ttsPlaybackCursor = null;
      state.ttsReadAheadBuffer = null;
      state.isTtsPreparingNext = false;
      state.isTtsProgressReliable = true;
    }
    _session.reset();
  }
}

class _ResumePlan {
  const _ResumePlan({
    required this.sentenceIndex,
    this.resumeOffsetInSentence = 0,
    this.redirectTarget,
  });

  final int sentenceIndex;
  final int resumeOffsetInSentence;
  final TtsPreparedTarget? redirectTarget;
}
