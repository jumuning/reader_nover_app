import 'dart:async';
import 'dart:collection';

typedef TtsReadAheadKeyOf<T> = String Function(T request);
typedef TtsReadAheadDispatch<T> = Future<void> Function(T request);
typedef TtsReadAheadErrorHandler<T> = void Function(
  Object error,
  StackTrace stackTrace,
  T request,
);

enum TtsReadAheadPriority {
  currentPlayback,
  samePage,
  nextPage,
  nextChapter,
}

/// A session-aware, priority-ordered scheduler for TTS cache warm-up.
///
/// Current playback is not dispatched through this scheduler. Calling
/// [schedule] resets [dispatchDelay], leaving the foreground speak request a
/// short head start before read-ahead work is dispatched.
class TtsReadAheadScheduler<T> {
  TtsReadAheadScheduler({
    required TtsReadAheadKeyOf<T> keyOf,
    required TtsReadAheadDispatch<T> dispatch,
    this.samePageWindow = 6,
    this.nextPageWindow = 3,
    this.nextChapterWindow = 1,
    this.dispatchDelay = const Duration(milliseconds: 150),
    this.maxCachedKeys = 128,
    this.onError,
  })  : assert(samePageWindow >= 0),
        assert(nextPageWindow >= 0),
        assert(nextChapterWindow >= 0),
        assert(maxCachedKeys > 0),
        _keyOf = keyOf,
        _dispatch = dispatch;

  final int samePageWindow;
  final int nextPageWindow;
  final int nextChapterWindow;
  final Duration dispatchDelay;
  final int maxCachedKeys;
  final TtsReadAheadErrorHandler<T>? onError;

  final TtsReadAheadKeyOf<T> _keyOf;
  final TtsReadAheadDispatch<T> _dispatch;
  final List<_ScheduledReadAhead<T>> _queue = <_ScheduledReadAhead<T>>[];
  final Set<String> _pendingKeys = <String>{};
  final LinkedHashSet<String> _cachedKeys = LinkedHashSet<String>();

  Object? _sessionId;
  Timer? _dispatchTimer;
  Completer<void>? _idleCompleter;
  int _sequence = 0;
  int _generation = 0;
  bool _isDraining = false;
  bool _isDisposed = false;

  int get pendingCount => _pendingKeys.length;
  int get cachedKeyCount => _cachedKeys.length;
  bool get isIdle => !_isDraining && _dispatchTimer == null && _queue.isEmpty;

  /// Starts a clean playback session and cancels queued work from the old one.
  void startSession(Object sessionId) {
    _ensureNotDisposed();
    if (_sessionId == sessionId) return;
    _generation++;
    _sessionId = sessionId;
    _dispatchTimer?.cancel();
    _dispatchTimer = null;
    _queue.clear();
    _pendingKeys.clear();
    _cachedKeys.clear();
    _completeIdleIfNeeded();
  }

  /// Adds a bounded read-ahead window in playback priority order.
  ///
  /// Returns the number of new requests accepted after session and key
  /// de-duplication. Calling this method also gives current playback a fresh
  /// [dispatchDelay] head start.
  int schedule({
    required Object sessionId,
    Iterable<T> samePage = const <Never>[],
    Iterable<T> nextPage = const <Never>[],
    Iterable<T> nextChapter = const <Never>[],
  }) {
    _ensureNotDisposed();
    if (_sessionId != sessionId) startSession(sessionId);

    _generation++;
    var accepted = 0;
    accepted += _enqueue(
      samePage,
      TtsReadAheadPriority.samePage,
      samePageWindow,
    );
    accepted += _enqueue(
      nextPage,
      TtsReadAheadPriority.nextPage,
      nextPageWindow,
    );
    accepted += _enqueue(
      nextChapter,
      TtsReadAheadPriority.nextChapter,
      nextChapterWindow,
    );
    _queue.sort(_compareEntries);
    _armDispatchDelay();
    return accepted;
  }

  /// Cancels queued work. An already running callback is allowed to finish.
  void cancel() {
    if (_isDisposed) return;
    _generation++;
    _dispatchTimer?.cancel();
    _dispatchTimer = null;
    _queue.clear();
    _pendingKeys.clear();
    _completeIdleIfNeeded();
  }

  Future<void> waitUntilIdle() {
    if (isIdle) return Future<void>.value();
    return (_idleCompleter ??= Completer<void>()).future;
  }

  void dispose() {
    if (_isDisposed) return;
    cancel();
    _isDisposed = true;
    _sessionId = null;
    _cachedKeys.clear();
  }

  int _enqueue(
    Iterable<T> requests,
    TtsReadAheadPriority priority,
    int limit,
  ) {
    if (limit == 0) return 0;
    var examined = 0;
    var accepted = 0;
    for (final request in requests) {
      if (examined++ >= limit) break;
      final key = _keyOf(request);
      if (key.isEmpty ||
          _pendingKeys.contains(key) ||
          _cachedKeys.contains(key)) {
        continue;
      }
      _pendingKeys.add(key);
      _queue.add(_ScheduledReadAhead<T>(
        key: key,
        request: request,
        priority: priority,
        sequence: _sequence++,
      ));
      accepted++;
    }
    return accepted;
  }

  void _armDispatchDelay() {
    _dispatchTimer?.cancel();
    _dispatchTimer = null;
    if (_queue.isEmpty) {
      _completeIdleIfNeeded();
      return;
    }
    _idleCompleter ??= Completer<void>();
    final generation = _generation;
    _dispatchTimer = Timer(dispatchDelay, () {
      _dispatchTimer = null;
      if (!_isDisposed && generation == _generation) {
        unawaited(_drain(generation));
      }
    });
  }

  Future<void> _drain(int generation) async {
    if (_isDraining) return;
    _isDraining = true;
    try {
      while (!_isDisposed && generation == _generation && _queue.isNotEmpty) {
        final entry = _queue.removeAt(0);
        try {
          await _dispatch(entry.request);
          if (!_isDisposed && generation == _generation) {
            _rememberCached(entry.key);
          }
        } catch (error, stackTrace) {
          onError?.call(error, stackTrace, entry.request);
        } finally {
          _pendingKeys.remove(entry.key);
        }
      }
    } finally {
      _isDraining = false;
      if (!_isDisposed && _queue.isNotEmpty && _dispatchTimer == null) {
        _armDispatchDelay();
      } else {
        _completeIdleIfNeeded();
      }
    }
  }

  void _rememberCached(String key) {
    _cachedKeys.remove(key);
    _cachedKeys.add(key);
    while (_cachedKeys.length > maxCachedKeys) {
      _cachedKeys.remove(_cachedKeys.first);
    }
  }

  int _compareEntries(
    _ScheduledReadAhead<T> left,
    _ScheduledReadAhead<T> right,
  ) {
    final priority = left.priority.index.compareTo(right.priority.index);
    return priority != 0 ? priority : left.sequence.compareTo(right.sequence);
  }

  void _completeIdleIfNeeded() {
    if (!isIdle) return;
    final completer = _idleCompleter;
    _idleCompleter = null;
    if (completer != null && !completer.isCompleted) completer.complete();
  }

  void _ensureNotDisposed() {
    if (_isDisposed) {
      throw StateError('TtsReadAheadScheduler has been disposed');
    }
  }
}

class _ScheduledReadAhead<T> {
  const _ScheduledReadAhead({
    required this.key,
    required this.request,
    required this.priority,
    required this.sequence,
  });

  final String key;
  final T request;
  final TtsReadAheadPriority priority;
  final int sequence;
}
