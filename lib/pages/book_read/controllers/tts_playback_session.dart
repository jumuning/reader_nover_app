import '../models/tts_prepared_target.dart';
import '../models/tts_speak_request.dart';

/// Pure playback-session state. UI state and navigation stay in the page
/// controller; token/epoch ownership lives here so stale callbacks are easy to
/// reject and test.
class TtsPlaybackSession {
  int? activeChapterIndex;
  int? activePageIndex;

  TtsPreparedTarget? activeTarget;
  TtsSpeakRequest? activeRequest;

  int _playbackEpoch = 0;
  int _activeSpeakEpoch = 0;
  int _sessionToken = 0;
  bool _disposed = false;
  bool _readAheadRefreshed = false;
  bool _progressReceived = false;
  int _consecutiveMissingProgress = 0;

  int get currentToken {
    if (_sessionToken == 0) _sessionToken = 1;
    return _sessionToken;
  }

  bool get isActive => isEpochActive(_activeSpeakEpoch);
  int get activeSpeakEpoch => _activeSpeakEpoch;
  bool get readAheadRefreshed => _readAheadRefreshed;

  int beginSession() {
    _sessionToken++;
    clearActiveTarget();
    return currentToken;
  }

  void setActivePage({required int chapterIndex, required int pageIndex}) {
    activeChapterIndex = chapterIndex;
    activePageIndex = pageIndex;
  }

  bool matchesActivePage({required int chapterIndex, required int pageIndex}) {
    return activeChapterIndex == chapterIndex && activePageIndex == pageIndex;
  }

  void setActiveTarget(TtsPreparedTarget target) {
    activeTarget = target;
    activeRequest = target.toSpeakRequest();
    _readAheadRefreshed = false;
    _progressReceived = false;
  }

  int beginSpeak(TtsPreparedTarget target) {
    setActiveTarget(target);
    _activeSpeakEpoch = ++_playbackEpoch;
    return _activeSpeakEpoch;
  }

  bool isEpochActive(int epoch) {
    return !_disposed &&
        epoch != 0 &&
        epoch == _activeSpeakEpoch &&
        epoch == _playbackEpoch;
  }

  void invalidate({required bool resetSessionToken}) {
    _playbackEpoch++;
    clearActiveTarget();
    if (resetSessionToken) _sessionToken = 0;
  }

  void markReadAheadRefreshed() {
    _readAheadRefreshed = true;
  }

  void markProgressReceived() {
    _progressReceived = true;
    _consecutiveMissingProgress = 0;
  }

  bool finishSentenceProgress({required int unreliableAfter}) {
    if (_progressReceived) {
      _consecutiveMissingProgress = 0;
      return true;
    }
    _consecutiveMissingProgress++;
    return _consecutiveMissingProgress < unreliableAfter;
  }

  void clearActiveTarget() {
    activeTarget = null;
    activeRequest = null;
    _readAheadRefreshed = false;
    _progressReceived = false;
  }

  void reset() {
    clearActiveTarget();
    activeChapterIndex = null;
    activePageIndex = null;
  }

  void dispose() {
    _disposed = true;
    _playbackEpoch++;
    reset();
  }
}
