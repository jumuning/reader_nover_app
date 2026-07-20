import 'dart:async';

import 'package:flutter/material.dart';

class BookReadParagraphActionController {
  static const Duration _pressDuration = Duration(milliseconds: 500);
  static const double _horizontalMoveTolerance = 24.0;
  static const double _overallMoveTolerance = 36.0;

  Timer? _gestureTimer;
  Offset? _startGlobalPosition;
  Future<void> Function()? _trigger;
  bool _suppressNextReaderTap = false;

  void beginGesture(
    Offset globalPosition,
    Future<void> Function() onTrigger,
  ) {
    cancelGesture();
    _startGlobalPosition = globalPosition;
    _trigger = onTrigger;
    _gestureTimer = Timer(_pressDuration, () {
      _gestureTimer = null;
      _startGlobalPosition = null;
      final callback = _trigger;
      _trigger = null;
      if (callback == null) return;
      _suppressNextReaderTap = true;
      unawaited(callback());
    });
  }

  void updateGesture(Offset globalPosition) {
    final start = _startGlobalPosition;
    if (start == null) return;
    final delta = globalPosition - start;
    final horizontalDistance = delta.dx.abs();
    final overallDistance = delta.distance;
    if (horizontalDistance > _horizontalMoveTolerance ||
        overallDistance > _overallMoveTolerance) {
      cancelGesture();
    }
  }

  void cancelGesture() {
    _gestureTimer?.cancel();
    _gestureTimer = null;
    _startGlobalPosition = null;
    _trigger = null;
  }

  bool consumeTapSuppression() {
    final shouldSuppress = _suppressNextReaderTap;
    _suppressNextReaderTap = false;
    return shouldSuppress;
  }

  void dispose() {
    cancelGesture();
  }
}
