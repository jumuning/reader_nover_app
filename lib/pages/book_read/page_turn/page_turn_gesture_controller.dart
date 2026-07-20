import 'dart:math';

import 'package:flutter/material.dart';
import 'package:reader_nover/app/constants/default_setting.dart';

import '../../../util/log_utils.dart';
import '../controllers/book_read_page_turn_state_controller.dart';
import '../state.dart';

/// 阅读页手势与翻页动画控制器。
class PageTurnGestureController {
  final BookReadState state;
  final TickerProvider vsync;
  final BookReadPageTurnStateController pageTurnStateController;
  final VoidCallback onToggleAppBarVisibility;
  final VoidCallback onPreviousPage;
  final VoidCallback onNextPage;

  Point<double>? _currentDragPoint;

  /// 当前翻页是否为左侧锚点（上一页）
  bool _currentAnchorLeft = false;

  // 手势方向追踪
  double _totalDragDeltaX = 0.0; // 累计水平拖动距离
  bool? _dragDirection; // true: 向右滑动(上一页), false: 向左滑动(下一页), null: 未确定
  bool _isDragHandled = false; // 防止重复处理翻页

  // 垂直拖动累计距离
  double _totalDragDeltaY = 0.0;

  // 动画控制器
  AnimationController? _animationController;
  Animation<double>? _animation;

  // 翻页判断参数（优化手感）
  static const double _velocityThreshold = 500.0;
  static const double _minDragRatio = 0.15;
  static const Duration _normalAnimationDuration = Duration(milliseconds: 250);
  static const Duration _slowAnimationDuration = Duration(milliseconds: 300);

  PageTurnGestureController({
    required this.state,
    required this.vsync,
    required this.pageTurnStateController,
    required this.onToggleAppBarVisibility,
    required this.onPreviousPage,
    required this.onNextPage,
  });

  void dispose() {
    _stopCurrentAnimation();
  }

  /// 处理拖动开始
  void onDragStart(DragStartDetails details, BoxConstraints constraints) {
    // 停止任何正在进行的动画
    _stopCurrentAnimation();

    if (state.isAppBarVisible) {
      onToggleAppBarVisibility();
    }

    final touchPoint =
        Point(details.localPosition.dx, details.localPosition.dy);

    // 初始化手势追踪
    _totalDragDeltaX = 0.0;
    _dragDirection = null;
    _isDragHandled = false;

    // 清除目标页，防止拖动过程中内容闪现
    pageTurnStateController.clearTargetPage(notify: false);

    // 通过检查后才设置 currentDragPoint（边界检查移到 onDragEnd 中根据方向判断）
    _currentDragPoint = touchPoint;

    pageTurnStateController.notifyAnimationChanged();
  }

  void onDragUpdate(DragUpdateDetails details, BoxConstraints constraints) {
    if (state.isAnimating || _currentDragPoint == null) return;

    final move = details.localPosition;
    _totalDragDeltaX += details.delta.dx;

    if (_dragDirection == null && _totalDragDeltaX.abs() > 10) {
      _dragDirection = _totalDragDeltaX > 0;
    }

    final bool isGoingPrevious = _dragDirection ?? (_totalDragDeltaX > 0);
    pageTurnStateController.setTurnDirection(!isGoingPrevious, notify: false);

    // 边界检查
    if (isGoingPrevious) {
      if (state.currentPage == 0 && state.currentChapterIndex == 0) {
        return;
      }
    } else {
      final chaptersLen = state.bookDetail.chapters?.length ?? 0;
      if (state.currentPage >= state.pageSize - 1 &&
          state.currentChapterIndex >= chaptersLen - 1) {
        return;
      }
    }

    if (state.pageTurnType == DefaultSetting.pageTurnTypeSimulation) {
      final clampedX = move.dx.clamp(0.0, constraints.maxWidth);
      final clampedY = move.dy.clamp(1.0, constraints.maxHeight - 1);

      final bool isMiddleArea =
          _currentDragPoint!.y > constraints.maxHeight * 0.25 &&
              _currentDragPoint!.y < constraints.maxHeight * 0.75;
      final bool isTopArea =
          _currentDragPoint!.y <= constraints.maxHeight * 0.25;

      final anchorLeft = isGoingPrevious;
      _currentAnchorLeft = anchorLeft;

      final double effectiveY =
          (isMiddleArea || isTopArea) ? constraints.maxHeight - 1 : clampedY;

      pageTurnStateController.updatePaperPoint(
        Point(clampedX, effectiveY),
        size: Size(constraints.maxWidth, constraints.maxHeight),
        anchorLeft: anchorLeft,
        notify: false,
      );
    } else {
      final deltaX = move.dx - _currentDragPoint!.x;
      final clampedDelta =
          deltaX.clamp(-constraints.maxWidth, constraints.maxWidth);
      pageTurnStateController.updateSlideOffset(
        clampedDelta.toDouble(),
        notify: false,
      );
    }
  }

  void onDragEnd(DragEndDetails details, BoxConstraints constraints) {
    if (state.isAnimating || _currentDragPoint == null || _isDragHandled) {
      return;
    }

    _isDragHandled = true;

    final velocity = details.velocity.pixelsPerSecond.dx;
    final screenWidth = constraints.maxWidth;

    // 如果几乎没有拖动，直接回弹
    if (_totalDragDeltaX.abs() < 5 && velocity.abs() < _velocityThreshold) {
      pageTurnStateController.setTurnDirection(false, notify: false);
      pageTurnStateController.clearTargetPage(notify: false);
      _animateBackSmooth(constraints, () {});
      _resetDragState();
      return;
    }

    // 根据最终状态判断方向：优先使用速度，其次使用累计距离
    bool isGoingPrevious;
    if (velocity.abs() > _velocityThreshold) {
      isGoingPrevious = velocity > 0;
    } else {
      isGoingPrevious = _totalDragDeltaX > 0;
    }

    // 检测方向变化：如果初始方向和最终方向/速度不一致，应该回弹
    bool shouldCancelDueToDirectionChange = false;
    if (_dragDirection != null) {
      // 检查速度方向是否与初始方向相反
      bool velocityOpposite = (velocity > 0) != _dragDirection!;
      // 检查最终位置是否与初始方向相反
      bool positionOpposite = (_totalDragDeltaX > 0) != _dragDirection!;

      // 如果速度明显相反，或者位置已经反向，则取消翻页
      if (velocityOpposite && velocity.abs() > 100) {
        shouldCancelDueToDirectionChange = true;
      } else if (positionOpposite) {
        shouldCancelDueToDirectionChange = true;
      }
    }

    if (state.pageTurnType == DefaultSetting.pageTurnTypeSimulation) {
      final actualDragDistance = _totalDragDeltaX.abs();
      final absVelocity = velocity.abs();

      const double bottomCornerXRatio = 0.25;
      const double bottomCornerYRatio = 0.75;
      const double bottomCornerDistanceRatio = 0.12;
      const double normalDistanceRatio = 0.15;

      final bool isBottomCorner = _currentDragPoint!.y >
              constraints.maxHeight * bottomCornerYRatio &&
          (_currentDragPoint!.x < constraints.maxWidth * bottomCornerXRatio ||
              _currentDragPoint!.x >
                  constraints.maxWidth * (1 - bottomCornerXRatio));

      final double requiredDistance = isBottomCorner
          ? screenWidth * bottomCornerDistanceRatio
          : screenWidth * normalDistanceRatio;

      final bool fastSwipe = absVelocity > _velocityThreshold * 0.6;

      final bool shouldTurnPage;
      // 如果方向改变了，强制回弹
      if (shouldCancelDueToDirectionChange) {
        shouldTurnPage = false;
      } else {
        shouldTurnPage = actualDragDistance > requiredDistance || fastSwipe;
      }

      if (shouldTurnPage) {
        pageTurnStateController.setTurnDirection(
          !isGoingPrevious,
          notify: false,
        );

        if (isGoingPrevious) {
          _animateToPrePageSmooth(constraints, absVelocity, () {
            onPreviousPage();
          });
        } else {
          _animateToNextPageSmooth(constraints, absVelocity, () {
            onNextPage();
          });
        }
      } else {
        pageTurnStateController.setTurnDirection(false, notify: false);
        pageTurnStateController.clearTargetPage(notify: false);
        _animateBackSmooth(constraints, () {});
      }
    } else {
      // 平移 / 覆盖
      final delta = state.slideOffsetX.value;
      final slideThreshold = screenWidth * _minDragRatio;

      // 同样检查方向变化
      if (shouldCancelDueToDirectionChange) {
        pageTurnStateController.setTurnDirection(false, notify: false);
        pageTurnStateController.clearTargetPage(notify: false);
        _animateSlideBack(constraints);
      } else if (isGoingPrevious) {
        if (delta > slideThreshold || velocity > _velocityThreshold) {
          pageTurnStateController.setTurnDirection(false, notify: false);
          _animateSlideToPrev(constraints, velocity.abs(), () {
            onPreviousPage();
          });
        } else {
          pageTurnStateController.setTurnDirection(false, notify: false);
          pageTurnStateController.clearTargetPage(notify: false);
          _animateSlideBack(constraints);
        }
      } else {
        if (delta < -slideThreshold || velocity < -_velocityThreshold) {
          pageTurnStateController.setTurnDirection(true, notify: false);
          _animateSlideToNext(constraints, velocity.abs(), () {
            onNextPage();
          });
        } else {
          pageTurnStateController.setTurnDirection(false, notify: false);
          pageTurnStateController.clearTargetPage(notify: false);
          _animateSlideBack(constraints);
        }
      }
    }

    _resetDragState();
  }

  /// 垂直拖动开始
  void onVerticalDragStart(
      DragStartDetails details, BoxConstraints constraints) {
    _stopCurrentAnimation();

    if (state.isAppBarVisible) {
      onToggleAppBarVisibility();
    }

    final touchPoint =
        Point(details.localPosition.dx, details.localPosition.dy);
    _totalDragDeltaY = 0.0;
    _dragDirection = null;
    _isDragHandled = false;
    _currentDragPoint = touchPoint;

    pageTurnStateController.notifyAnimationChanged();
  }

  /// 垂直拖动更新
  void onVerticalDragUpdate(
      DragUpdateDetails details, BoxConstraints constraints) {
    if (state.isAnimating) return;
    if (_currentDragPoint == null) return;

    // 累计垂直拖动距离
    _totalDragDeltaY += details.delta.dy;

    // 根据累计距离确定方向（向下滑动为正，上一页；向上滑动为负，下一页）
    if (_dragDirection == null && _totalDragDeltaY.abs() > 10) {
      _dragDirection = _totalDragDeltaY > 0; // true: 上一页, false: 下一页
    }

    bool isGoingPrevious = _dragDirection ?? (_totalDragDeltaY > 0);
    pageTurnStateController.setTurnDirection(!isGoingPrevious, notify: false);

    // 边界检查
    if (isGoingPrevious) {
      if (state.currentPage == 0 && state.currentChapterIndex == 0) {
        return;
      }
    } else {
      final chaptersLength = state.bookDetail.chapters?.length ?? 0;
      if (state.currentPage >= state.pageSize - 1 &&
          state.currentChapterIndex >= chaptersLength - 1) {
        return;
      }
    }

    // 设置翻页方向
    pageTurnStateController.setTurnDirection(!isGoingPrevious, notify: false);

    // 将垂直偏移转换为水平偏移（slideOffsetX 用于动画计算）
    // 比例转换：垂直偏移 * (宽度/高度)
    final deltaY = details.localPosition.dy - _currentDragPoint!.y;
    final ratio = constraints.maxWidth / constraints.maxHeight;
    final equivalentX = deltaY * ratio;
    pageTurnStateController.updateSlideOffset(
      equivalentX.clamp(-constraints.maxWidth, constraints.maxWidth).toDouble(),
      notify: false,
    );
  }

  /// 垂直拖动结束
  void onVerticalDragEnd(DragEndDetails details, BoxConstraints constraints) {
    if (state.isAnimating || _currentDragPoint == null || _isDragHandled) {
      return;
    }

    _isDragHandled = true;

    final velocity = details.velocity.pixelsPerSecond.dy;
    final ratio = constraints.maxWidth / constraints.maxHeight;

    if (_totalDragDeltaY.abs() < 5 && velocity.abs() < _velocityThreshold) {
      _resetVerticalDragState();
      return;
    }

    bool isGoingPrevious;
    if (_dragDirection != null) {
      isGoingPrevious = _dragDirection!;
    } else if (velocity.abs() > _velocityThreshold) {
      isGoingPrevious = velocity > 0;
    } else {
      isGoingPrevious = _totalDragDeltaY > 0;
    }

    final threshold = constraints.maxHeight * _minDragRatio;

    if (isGoingPrevious) {
      if (state.currentPage == 0 && state.currentChapterIndex == 0) {
        _animateSlideBack(constraints);
        _resetVerticalDragState();
        return;
      }
      final shouldPrev =
          _totalDragDeltaY > threshold || velocity > _velocityThreshold;
      if (shouldPrev) {
        _animateSlideToPrev(constraints, velocity.abs() * ratio, () {
          onPreviousPage();
        });
      } else {
        _animateSlideBack(constraints);
      }
    } else {
      final chaptersLen = state.bookDetail.chapters?.length ?? 0;
      if (state.currentPage >= state.pageSize - 1 &&
          state.currentChapterIndex >= chaptersLen - 1) {
        _animateSlideBack(constraints);
        _resetVerticalDragState();
        return;
      }
      final shouldNext =
          _totalDragDeltaY < -threshold || velocity < -_velocityThreshold;
      if (shouldNext) {
        _animateSlideToNext(constraints, velocity.abs() * ratio, () {
          onNextPage();
        });
      } else {
        _animateSlideBack(constraints);
      }
    }

    _resetVerticalDragState();
  }

  /// 停止当前动画
  void _stopCurrentAnimation() {
    if (_animationController != null) {
      _animationController!.stop();
      _animationController!.dispose();
      _animationController = null;
      _animation = null;
    }
  }

  /// 计算动画时长 - 基于速度和剩余距离
  Duration _calculateAnimationDuration(
      double velocity, double distance, double maxDistance) {
    // 速度越快，动画时间越短
    final velocityFactor = (velocity.abs() / 2000).clamp(0.3, 1.5);
    // 距离越短，动画时间越短
    final distanceFactor = (distance / maxDistance).clamp(0.2, 1.0);

    final baseDuration = _normalAnimationDuration.inMilliseconds;
    final calculatedDuration =
        (baseDuration * distanceFactor / velocityFactor * state.pageTurnSpeed)
            .round();

    return Duration(milliseconds: calculatedDuration.clamp(150, 350));
  }

  /// 重置拖动状态
  void _resetDragState() {
    _currentDragPoint = null;
    _totalDragDeltaX = 0.0;
    _dragDirection = null;
    _isDragHandled = false;
  }

  /// 重置垂直拖动状态
  void _resetVerticalDragState() {
    _currentDragPoint = null;
    _totalDragDeltaY = 0.0;
    _dragDirection = null;
    _isDragHandled = false;
  }

  /// 下一页动画 - 使用 Flutter 原生动画系统
  void _animateToNextPageSmooth(
      BoxConstraints constraints, double velocity, VoidCallback onComplete) {
    if (state.isAnimating) return;

    pageTurnStateController.setAnimating(true, notify: false);
    // 设置目标页（下一页）
    pageTurnStateController.setTargetPage(
      state.currentPage + 1,
      notify: false,
    );
    pageTurnStateController.notifyAnimationChanged();
    _stopCurrentAnimation();

    try {
      final startPoint = state.paperPoint.value.a;
      final startX = startPoint.x;
      final startY = startPoint.y;
      final endX = -constraints.maxWidth * 0.1; // 翻过屏幕边缘一点
      final endY = constraints.maxHeight;

      // 计算距离和动画时长
      final distance = (startX - endX).abs();
      final duration = _calculateAnimationDuration(
          velocity, distance, constraints.maxWidth * 2);

      _animationController = AnimationController(
        vsync: vsync,
        duration: duration,
      );

      // 使用自定义曲线 - 模拟真实翻页物理效果
      // 开始快，结束减速，但保持流畅
      final curve = CurvedAnimation(
        parent: _animationController!,
        curve: Curves.easeOutCubic,
      );

      _animation = Tween<double>(begin: 0, end: 1).animate(curve);

      _animationController!.addListener(() {
        final progress = _animation!.value;

        // X轴：使用缓动曲线
        final newX = startX + (endX - startX) * progress;
        // Y轴：平滑过渡到底部
        final newY = startY + (endY - startY) * progress;

        pageTurnStateController.updatePaperPoint(
          Point(newX, newY),
          size: Size(constraints.maxWidth, constraints.maxHeight),
          anchorLeft: false,
          notify: false,
        );
      });

      _animationController!.addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          pageTurnStateController.setAnimating(false, notify: false);
          pageTurnStateController.clearTargetPage(notify: false);
          pageTurnStateController.resetPaperPoint(
            Size(constraints.maxWidth, constraints.maxHeight),
            notify: false,
          );
          onComplete();
          pageTurnStateController.notifyAnimationChanged();
        } else if (status == AnimationStatus.dismissed) {
          // 动画被取消时也要清理状态
          pageTurnStateController.setAnimating(false, notify: false);
          pageTurnStateController.clearTargetPage(notify: false);
          pageTurnStateController.notifyAnimationChanged();
        }
      });

      _animationController!.forward();
    } catch (e) {
      // 异常时确保清理状态
      LogUtils.e('动画执行失败: $e');
      _stopCurrentAnimation();
      pageTurnStateController.setAnimating(false, notify: false);
      pageTurnStateController.clearTargetPage(notify: false);
      pageTurnStateController.notifyAnimationChanged();
    }
  }

  /// 上一页动画 - 使用 Flutter 原生动画系统
  void _animateToPrePageSmooth(
      BoxConstraints constraints, double velocity, VoidCallback onComplete) {
    if (state.isAnimating) return;

    pageTurnStateController.setAnimating(true, notify: false);
    // 设置目标页（上一页）
    pageTurnStateController.setTargetPage(
      state.currentPage > 0 ? state.currentPage - 1 : null,
      notify: false,
    );
    pageTurnStateController.notifyAnimationChanged();
    _stopCurrentAnimation();

    try {
      final startPoint = state.paperPoint.value.a;
      final startX = startPoint.x;
      final startY = startPoint.y;
      final endX = constraints.maxWidth + constraints.maxWidth * 0.1;
      final endY = constraints.maxHeight;

      // 计算距离和动画时长
      final distance = (endX - startX).abs();
      final duration = _calculateAnimationDuration(
          velocity, distance, constraints.maxWidth * 2);

      _animationController = AnimationController(
        vsync: vsync,
        duration: duration,
      );

      final curve = CurvedAnimation(
        parent: _animationController!,
        curve: Curves.easeOutCubic,
      );

      _animation = Tween<double>(begin: 0, end: 1).animate(curve);

      _animationController!.addListener(() {
        final progress = _animation!.value;

        final newX = (startX + (endX - startX) * progress)
            .clamp(0.0, constraints.maxWidth * 1.1);
        final newY = startY + (endY - startY) * progress * 0.5;

        pageTurnStateController.updatePaperPoint(
          Point(newX, newY.clamp(startY, constraints.maxHeight)),
          size: Size(constraints.maxWidth, constraints.maxHeight),
          anchorLeft: true,
          notify: false,
        );
      });

      _animationController!.addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          // 先切换页面内容，再重置动画状态，避免闪屏
          onComplete();

          // 使用 Future.microtask 确保页面内容更新后再重置 paperPoint
          Future.microtask(() {
            pageTurnStateController.setAnimating(false, notify: false);
            pageTurnStateController.clearTargetPage(notify: false);
            pageTurnStateController.resetPaperPoint(
              Size(constraints.maxWidth, constraints.maxHeight),
              notify: false,
            );
            pageTurnStateController.notifyAnimationChanged();
          });
        } else if (status == AnimationStatus.dismissed) {
          // 动画被取消时也要清理状态
          pageTurnStateController.setAnimating(false, notify: false);
          pageTurnStateController.clearTargetPage(notify: false);
          pageTurnStateController.notifyAnimationChanged();
        }
      });

      _animationController!.forward();
    } catch (e) {
      // 异常时确保清理状态
      LogUtils.e('动画执行失败: $e');
      _stopCurrentAnimation();
      pageTurnStateController.setAnimating(false, notify: false);
      pageTurnStateController.clearTargetPage(notify: false);
      pageTurnStateController.notifyAnimationChanged();
    }
  }

  /// 回弹动画 - 使用自然的减速效果
  void _animateBackSmooth(BoxConstraints constraints, VoidCallback onComplete) {
    if (state.isAnimating) return;

    pageTurnStateController.setAnimating(true, notify: false);
    pageTurnStateController.clearTargetPage(notify: false);
    pageTurnStateController.setTurnDirection(false, notify: false);
    pageTurnStateController.notifyAnimationChanged();
    _stopCurrentAnimation();

    try {
      final startPoint = state.paperPoint.value.a;
      final startX = startPoint.x;
      final startY = startPoint.y;
      final endX = _currentAnchorLeft ? 0.0 : constraints.maxWidth;
      final endY = constraints.maxHeight;

      // 根据回弹距离计算动画时长，距离越短时间越短
      final distance = (startX - endX).abs();
      final distanceRatio = (distance / constraints.maxWidth).clamp(0.1, 1.0);
      final duration =
          Duration(milliseconds: (180 + 120 * distanceRatio).round());

      _animationController = AnimationController(
        vsync: vsync,
        duration: duration,
      );

      // 使用平滑的减速曲线，不要过度弹性
      final curve = CurvedAnimation(
        parent: _animationController!,
        curve: Curves.easeOutCubic,
      );

      _animation = Tween<double>(begin: 0, end: 1).animate(curve);

      _animationController!.addListener(() {
        final progress = _animation!.value;

        final newX = startX + (endX - startX) * progress;
        final newY = startY + (endY - startY) * progress;

        pageTurnStateController.updatePaperPoint(
          Point(
            newX.clamp(0.0, constraints.maxWidth),
            newY.clamp(0.0, constraints.maxHeight),
          ),
          size: Size(constraints.maxWidth, constraints.maxHeight),
          anchorLeft: _currentAnchorLeft,
          notify: false,
        );
      });

      _animationController!.addStatusListener((status) {
        if (status == AnimationStatus.completed ||
            status == AnimationStatus.dismissed) {
          pageTurnStateController.setAnimating(false, notify: false);
          pageTurnStateController.clearTargetPage(notify: false);
          pageTurnStateController.resetPaperPoint(
            Size(constraints.maxWidth, constraints.maxHeight),
            notify: false,
          );
          onComplete();
          pageTurnStateController.notifyAnimationChanged();
        }
      });

      _animationController!.forward();
    } catch (e) {
      // 异常时确保清理状态
      LogUtils.e('回弹动画执行失败: $e');
      _stopCurrentAnimation();
      pageTurnStateController.setAnimating(false, notify: false);
      pageTurnStateController.clearTargetPage(notify: false);
      pageTurnStateController.resetPaperPoint(
        Size(constraints.maxWidth, constraints.maxHeight),
        notify: false,
      );
      pageTurnStateController.notifyAnimationChanged();
    }
  }

  /// 平移：下一页动画
  void _animateSlideToNext(
      BoxConstraints constraints, double velocity, VoidCallback onComplete) {
    if (state.isAnimating) return;
    pageTurnStateController.setAnimating(true, notify: false);
    // 设置目标页（下一页）
    pageTurnStateController.setTargetPage(
      state.currentPage + 1,
      notify: false,
    );
    pageTurnStateController.notifyAnimationChanged();
    _stopCurrentAnimation();
    final start = state.slideOffsetX.value;
    final end = -constraints.maxWidth;
    final distance = (end - start).abs();
    final duration =
        _calculateAnimationDuration(velocity, distance, constraints.maxWidth);
    _animationController =
        AnimationController(vsync: vsync, duration: duration);
    final curve = CurvedAnimation(
        parent: _animationController!, curve: Curves.easeOutCubic);
    _animation =
        Tween<double>(begin: start, end: end.toDouble()).animate(curve);
    _animationController!.addListener(() {
      pageTurnStateController.updateSlideOffset(
        _animation!.value,
        notify: false,
      );
    });
    _animationController!.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        onComplete();
        // 重置偏移
        pageTurnStateController.resetSlideOffset(notify: false);
        pageTurnStateController.clearTargetPage(notify: false);
        pageTurnStateController.setAnimating(false, notify: false);
        pageTurnStateController.notifyAnimationChanged();
      }
    });
    _animationController!.forward();
  }

  /// 平移：上一页动画
  void _animateSlideToPrev(
      BoxConstraints constraints, double velocity, VoidCallback onComplete) {
    if (state.isAnimating) return;
    pageTurnStateController.setAnimating(true, notify: false);
    // 设置目标页（上一页）
    pageTurnStateController.setTargetPage(
      state.currentPage > 0 ? state.currentPage - 1 : null,
      notify: false,
    );
    pageTurnStateController.notifyAnimationChanged();
    _stopCurrentAnimation();
    final start = state.slideOffsetX.value;
    final end = constraints.maxWidth;
    final distance = (end - start).abs();
    final duration =
        _calculateAnimationDuration(velocity, distance, constraints.maxWidth);
    _animationController =
        AnimationController(vsync: vsync, duration: duration);
    final curve = CurvedAnimation(
        parent: _animationController!, curve: Curves.easeOutCubic);
    _animation =
        Tween<double>(begin: start, end: end.toDouble()).animate(curve);
    _animationController!.addListener(() {
      pageTurnStateController.updateSlideOffset(
        _animation!.value,
        notify: false,
      );
    });
    _animationController!.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        onComplete();
        pageTurnStateController.resetSlideOffset(notify: false);
        pageTurnStateController.clearTargetPage(notify: false);
        pageTurnStateController.setAnimating(false, notify: false);
        pageTurnStateController.notifyAnimationChanged();
      }
    });
    _animationController!.forward();
  }

  /// 平移：回弹动画
  void _animateSlideBack(BoxConstraints constraints) {
    if (state.isAnimating) return;
    pageTurnStateController.setAnimating(true, notify: false);
    pageTurnStateController.notifyAnimationChanged();
    _stopCurrentAnimation();
    final start = state.slideOffsetX.value;
    const end = 0.0;
    _animationController =
        AnimationController(vsync: vsync, duration: _slowAnimationDuration);
    final curve = CurvedAnimation(
        parent: _animationController!, curve: Curves.easeOutCubic);
    _animation = Tween<double>(begin: start, end: end).animate(curve);
    _animationController!.addListener(() {
      pageTurnStateController.updateSlideOffset(
        _animation!.value,
        notify: false,
      );
    });
    _animationController!.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        pageTurnStateController.clearTargetPage(notify: false);
        pageTurnStateController.setAnimating(false, notify: false);
        pageTurnStateController.notifyAnimationChanged();
      }
    });
    _animationController!.forward();
  }
}
