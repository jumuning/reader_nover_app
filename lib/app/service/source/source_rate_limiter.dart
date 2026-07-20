import 'dart:async';
import 'dart:collection';

/// 书源请求速率限制器
///
/// 对应书源的 concurrent_rate 字段，格式 "N,ms"
/// 表示在 ms 毫秒的滑动窗口内最多允许 N 次请求。
///
/// 示例：concurrent_rate = "1,1000" 表示每秒最多 1 次请求。
class SourceRateLimiter {
  static final _limiters = <String, _SlidingWindowBucket>{};

  /// 在允许请求前等待（如有必要）
  ///
  /// [sourceUrl] 书源地址，用于区分不同书源的速率限制
  /// [concurrentRate] 格式 "N,ms"，null 或空字符串时直接放行
  static Future<void> acquire(String sourceUrl, String? concurrentRate) async {
    if (concurrentRate == null || concurrentRate.trim().isEmpty) return;
    final bucket = _limiters.putIfAbsent(
      sourceUrl,
      () =>
          _SlidingWindowBucket.parse(concurrentRate) ??
          _SlidingWindowBucket.unlimited(),
    );
    await bucket.acquire();
  }

  /// 清除某书源的速率限制器（书源删除时调用）
  static void remove(String sourceUrl) {
    _limiters.remove(sourceUrl);
  }
}

class _SlidingWindowBucket {
  final int maxCount;
  final Duration window;
  final Queue<DateTime> _timestamps = Queue();
  final bool _unlimited;

  _SlidingWindowBucket({required this.maxCount, required this.window})
      : _unlimited = false;

  _SlidingWindowBucket.unlimited()
      : maxCount = 0,
        window = Duration.zero,
        _unlimited = true;

  static _SlidingWindowBucket? parse(String rate) {
    final parts = rate.split(',');
    if (parts.length < 2) return null;
    final n = int.tryParse(parts[0].trim());
    final ms = int.tryParse(parts[1].trim());
    if (n == null || ms == null || n <= 0 || ms <= 0) return null;
    return _SlidingWindowBucket(
        maxCount: n, window: Duration(milliseconds: ms));
  }

  Future<void> acquire() async {
    if (_unlimited) return;
    final now = DateTime.now();
    final cutoff = now.subtract(window);

    // 移除窗口外的旧记录
    while (_timestamps.isNotEmpty && _timestamps.first.isBefore(cutoff)) {
      _timestamps.removeFirst();
    }

    // 窗口已满，等待到最早记录过期后再进入
    if (_timestamps.length >= maxCount) {
      final oldest = _timestamps.first;
      final waitUntil = oldest.add(window);
      final delay = waitUntil.difference(DateTime.now());
      if (delay > Duration.zero) {
        await Future.delayed(delay);
      }
      // 等待结束后再次清理
      final cutoff2 = DateTime.now().subtract(window);
      while (_timestamps.isNotEmpty && _timestamps.first.isBefore(cutoff2)) {
        _timestamps.removeFirst();
      }
    }

    _timestamps.addLast(DateTime.now());
  }
}
