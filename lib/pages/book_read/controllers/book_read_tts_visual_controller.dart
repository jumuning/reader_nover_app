import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../models/tts_playback_cursor.dart';
import '../models/tts_prepared_target.dart';
import '../state.dart';

class BookReadTtsVisualController {
  BookReadTtsVisualController({
    required this.state,
    required this.onPlaybackVisualUpdate,
  });

  final BookReadState state;
  final VoidCallback onPlaybackVisualUpdate;

  static const Duration _defaultProgressUiThrottle = Duration(milliseconds: 40);
  static const Duration _minProgressUiThrottle = Duration(milliseconds: 24);
  static const Duration _maxProgressUiThrottle = Duration(milliseconds: 56);
  static const int _minProgressAdvanceChars = 2;
  static const int _progressImmediateRefreshDeltaChars = 6;
  static const double _progressImmediateRefreshDeltaRatio = 0.18;
  static const double _sparseProgressIntervalThresholdMs = 72;

  DateTime? _lastProgressUiUpdateAt;
  DateTime? _lastProgressEventAt;
  Timer? _pendingProgressUiTimer;
  Duration? _pendingProgressUiDelay;
  bool _hasPendingProgressUiUpdate = false;
  double? _progressEventIntervalEstimateMs;
  TtsPlaybackCursor? _lastVisualPlaybackCursor;

  void resetProgressCadence() {
    _lastProgressEventAt = null;
    _progressEventIntervalEstimateMs = null;
  }

  void clearPendingVisualUpdate({
    bool clearLastUiUpdateAt = false,
    bool clearLastVisualCursor = false,
  }) {
    _hasPendingProgressUiUpdate = false;
    _pendingProgressUiTimer?.cancel();
    _pendingProgressUiTimer = null;
    _pendingProgressUiDelay = null;
    if (clearLastUiUpdateAt) {
      _lastProgressUiUpdateAt = null;
    }
    if (clearLastVisualCursor) {
      _lastVisualPlaybackCursor = null;
    }
  }

  void recordProgressEvent(DateTime progressUpdatedAt) {
    final lastProgressEventAt = _lastProgressEventAt;
    _lastProgressEventAt = progressUpdatedAt;
    if (lastProgressEventAt == null) return;

    final deltaMs = progressUpdatedAt
        .difference(lastProgressEventAt)
        .inMilliseconds
        .clamp(8, 160);
    final previousEstimate = _progressEventIntervalEstimateMs;
    if (previousEstimate == null) {
      _progressEventIntervalEstimateMs = deltaMs.toDouble();
      return;
    }

    _progressEventIntervalEstimateMs = previousEstimate * 0.65 + deltaMs * 0.35;
  }

  Duration resolveProgressUiThrottle({
    required TtsPreparedTarget current,
    required int progressStartInSentence,
    required int progressEndInSentence,
    required String currentWord,
  }) {
    final sentenceLength = math.max(1, current.segment.text.length);
    final progressRatio = progressEndInSentence / sentenceLength;
    final wordLength = currentWord.runes.length;
    final intervalEstimateMs = _progressEventIntervalEstimateMs;

    var throttleMs = intervalEstimateMs == null
        ? _defaultProgressUiThrottle.inMilliseconds.toDouble()
        : intervalEstimateMs <= 20
            ? intervalEstimateMs * 1.9
            : intervalEstimateMs <= 44
                ? intervalEstimateMs * 1.45
                : intervalEstimateMs <= _sparseProgressIntervalThresholdMs
                    ? intervalEstimateMs * 1.0
                    : math.min(intervalEstimateMs * 0.45, 32.0);

    if (progressRatio <= 0.12 || progressRatio >= 0.88) {
      throttleMs -= 8;
    }
    if (sentenceLength <= 18) {
      throttleMs -= 4;
    } else if (sentenceLength >= 80) {
      throttleMs += 8;
    }
    if (wordLength <= 1) {
      throttleMs -= 4;
    }

    throttleMs = throttleMs.clamp(
      _minProgressUiThrottle.inMilliseconds.toDouble(),
      _maxProgressUiThrottle.inMilliseconds.toDouble(),
    );
    return Duration(milliseconds: throttleMs.round());
  }

  TtsPlaybackCursor? resolveVisualComparisonCursor({
    required TtsPreparedTarget prepared,
    required TtsPlaybackCursor? fallbackCursor,
  }) {
    final visualCursor = _lastVisualPlaybackCursor;
    if (_matchesPreparedSentence(visualCursor, prepared)) {
      return visualCursor;
    }
    if (_matchesPreparedSentence(fallbackCursor, prepared)) {
      return fallbackCursor;
    }
    return null;
  }

  bool shouldApplyProgressVisualUpdate({
    required TtsPlaybackCursor? comparisonCursor,
    required int progressStartInSentence,
    required int progressEndInSentence,
    required String currentWord,
    required DateTime progressUpdatedAt,
    required Duration progressUiThrottle,
  }) {
    if (comparisonCursor == null) return true;

    final lastProgressAt =
        _lastProgressUiUpdateAt ?? comparisonCursor.lastProgressAt;
    if (lastProgressAt == null) return true;

    final startDelta = (progressStartInSentence -
            (comparisonCursor.progressStartInSentence ?? 0))
        .abs();
    final endDelta =
        (progressEndInSentence - (comparisonCursor.progressEndInSentence ?? 0))
            .abs();
    final wordChanged =
        (comparisonCursor.currentWord ?? '').trim() != currentWord.trim();
    final elapsed = progressUpdatedAt.difference(lastProgressAt);

    if (wordChanged) return true;
    if (startDelta >= _minProgressAdvanceChars ||
        endDelta >= _minProgressAdvanceChars) {
      return true;
    }

    return elapsed >= progressUiThrottle;
  }

  bool shouldFlushProgressVisualImmediately({
    required TtsPlaybackCursor? comparisonCursor,
    required TtsPreparedTarget current,
    required TtsPlaybackCursor currentCursor,
    required DateTime progressUpdatedAt,
    required Duration progressUiThrottle,
  }) {
    if (comparisonCursor == null) return true;

    final lastUiUpdateAt = _lastProgressUiUpdateAt;
    if (lastUiUpdateAt == null) return true;

    final startDelta = ((currentCursor.progressStartInSentence ?? 0) -
            (comparisonCursor.progressStartInSentence ?? 0))
        .abs();
    final endDelta = ((currentCursor.progressEndInSentence ?? 0) -
            (comparisonCursor.progressEndInSentence ?? 0))
        .abs();
    final maxDelta = math.max(startDelta, endDelta);
    final sentenceLength = math.max(1, current.segment.text.length);
    final deltaRatio = maxDelta / sentenceLength;
    final wordChanged = (comparisonCursor.currentWord ?? '').trim() !=
        (currentCursor.currentWord ?? '').trim();
    final elapsedMs =
        progressUpdatedAt.difference(lastUiUpdateAt).inMilliseconds;
    final progressEnd = currentCursor.progressEndInSentence ?? 0;
    final nearSentenceEdge =
        progressEnd <= 3 || sentenceLength - progressEnd <= 3;

    if ((_progressEventIntervalEstimateMs ?? 0) >=
            _sparseProgressIntervalThresholdMs &&
        wordChanged) {
      return true;
    }
    if (maxDelta >= _progressImmediateRefreshDeltaChars ||
        deltaRatio >= _progressImmediateRefreshDeltaRatio) {
      return true;
    }
    if (nearSentenceEdge &&
        elapsedMs >= (progressUiThrottle.inMilliseconds / 2).round()) {
      return true;
    }
    if (_hasPendingProgressUiUpdate &&
        _pendingProgressUiDelay != null &&
        wordChanged &&
        _pendingProgressUiDelay!.inMilliseconds >=
            math.max(16, progressUiThrottle.inMilliseconds ~/ 2)) {
      return true;
    }
    return false;
  }

  bool didProgressVisualPayloadChange(
    TtsPlaybackCursor? previousCursor,
    TtsPlaybackCursor currentCursor,
  ) {
    if (previousCursor == null) return true;
    return previousCursor.chapterIndex != currentCursor.chapterIndex ||
        previousCursor.pageIndex != currentCursor.pageIndex ||
        previousCursor.sentenceIndex != currentCursor.sentenceIndex ||
        previousCursor.highlightStartInPage !=
            currentCursor.highlightStartInPage ||
        previousCursor.highlightEndInPage != currentCursor.highlightEndInPage;
  }

  void requestPlaybackVisualUpdate({
    bool immediate = false,
    Duration? throttle,
  }) {
    final effectiveThrottle = throttle ?? _defaultProgressUiThrottle;
    final now = DateTime.now();
    final lastUpdateAt = _lastProgressUiUpdateAt;
    if (immediate || lastUpdateAt == null) {
      _flushPlaybackVisualUpdate(now);
      return;
    }

    final elapsed = now.difference(lastUpdateAt);
    if (elapsed >= effectiveThrottle) {
      _flushPlaybackVisualUpdate(now);
      return;
    }

    _hasPendingProgressUiUpdate = true;
    final delay = effectiveThrottle - elapsed;
    if (_pendingProgressUiTimer != null &&
        _pendingProgressUiDelay != null &&
        _pendingProgressUiDelay! <= delay) {
      return;
    }

    _pendingProgressUiDelay = delay;
    _pendingProgressUiTimer?.cancel();
    _pendingProgressUiTimer = Timer(
      delay,
      () {
        _pendingProgressUiTimer = null;
        _pendingProgressUiDelay = null;
        if (!_hasPendingProgressUiUpdate) return;
        _flushPlaybackVisualUpdate(DateTime.now());
      },
    );
  }

  void dispose() {
    clearPendingVisualUpdate(
      clearLastUiUpdateAt: true,
      clearLastVisualCursor: true,
    );
  }

  bool _matchesPreparedSentence(
    TtsPlaybackCursor? cursor,
    TtsPreparedTarget prepared,
  ) {
    if (cursor == null) return false;
    return cursor.chapterIndex == prepared.chapterIndex &&
        cursor.pageIndex == prepared.pageIndex &&
        cursor.sentenceIndex == prepared.sentenceIndex;
  }

  void _flushPlaybackVisualUpdate(DateTime updatedAt) {
    _hasPendingProgressUiUpdate = false;
    _pendingProgressUiTimer?.cancel();
    _pendingProgressUiTimer = null;
    _pendingProgressUiDelay = null;
    _lastProgressUiUpdateAt = updatedAt;
    _lastVisualPlaybackCursor = state.ttsPlaybackCursor;
    onPlaybackVisualUpdate();
  }
}
