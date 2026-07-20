import 'dart:async';
import 'package:flutter/foundation.dart';

/// 防抖工具类
class Debouncer {
  Timer? _timer;
  final Duration delay;

  Debouncer({this.delay = const Duration(milliseconds: 500)});

  /// 执行防抖操作
  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }

  /// 取消防抖
  void cancel() {
    _timer?.cancel();
  }

  /// 释放资源
  void dispose() {
    _timer?.cancel();
  }
}

/// 节流工具类
class Throttler {
  Timer? _timer;
  final Duration duration;
  bool _isRunning = false;

  Throttler({this.duration = const Duration(milliseconds: 500)});

  /// 执行节流操作
  void run(VoidCallback action) {
    if (_isRunning) return;

    _isRunning = true;
    action();

    _timer = Timer(duration, () {
      _isRunning = false;
    });
  }

  /// 释放资源
  void dispose() {
    _timer?.cancel();
  }
}