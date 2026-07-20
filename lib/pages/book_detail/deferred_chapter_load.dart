import 'dart:async';

/// Delays complete TOC loading so opening the first chapter gets network and
/// parser priority. A pending load can be cancelled before navigation.
class DeferredChapterLoad {
  DeferredChapterLoad({
    required this.delay,
    required this.load,
  });

  final Duration delay;
  final Future<void> Function() load;

  Timer? _timer;

  bool get isScheduled => _timer?.isActive ?? false;

  void schedule() {
    if (isScheduled) return;
    _timer = Timer(delay, () {
      _timer = null;
      unawaited(load());
    });
  }

  void cancel() {
    _timer?.cancel();
    _timer = null;
  }
}
