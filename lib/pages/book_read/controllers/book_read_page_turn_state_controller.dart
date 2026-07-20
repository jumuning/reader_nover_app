import 'dart:math';

import 'package:flutter/material.dart';

import '../../../util/paper/paper_point_ireader.dart';
import '../state.dart';

class BookReadPageTurnStateController {
  const BookReadPageTurnStateController({
    required this.state,
    required this.onAnimationStateChanged,
  });

  final BookReadState state;
  final VoidCallback onAnimationStateChanged;

  void setTurnDirection(bool isNext, {bool notify = true}) {
    state.isNext = isNext;
    _notifyIfNeeded(notify);
  }

  void setTargetPage(int? targetPage, {bool notify = true}) {
    state.targetPage = targetPage;
    _notifyIfNeeded(notify);
  }

  void clearTargetPage({bool notify = true}) {
    setTargetPage(null, notify: notify);
  }

  void setAnimating(bool isAnimating, {bool notify = true}) {
    state.isAnimating = isAnimating;
    _notifyIfNeeded(notify);
  }

  void updatePaperPoint(
    Point<double> point, {
    required Size size,
    required bool anchorLeft,
    bool notify = true,
  }) {
    state.paperPoint.value = PaperPointIReader(
      point,
      size,
      anchorLeft: anchorLeft,
    );
    _notifyIfNeeded(notify);
  }

  void resetPaperPoint(Size size, {bool notify = true}) {
    state.paperPoint.value = PaperPointIReader.empty(size);
    _notifyIfNeeded(notify);
  }

  void updateSlideOffset(double offset, {bool notify = true}) {
    state.slideOffsetX.value = offset;
    _notifyIfNeeded(notify);
  }

  void resetSlideOffset({bool notify = true}) {
    state.slideOffsetX.value = 0.0;
    _notifyIfNeeded(notify);
  }

  void notifyAnimationChanged() {
    onAnimationStateChanged();
  }

  void _notifyIfNeeded(bool notify) {
    if (notify) {
      onAnimationStateChanged();
    }
  }
}
