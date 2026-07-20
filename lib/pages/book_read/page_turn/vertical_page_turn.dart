import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:reader_nover/app/database/models/models.dart';
import 'package:reader_nover/app/service/annotation/book_annotation.dart';
import 'package:reader_nover/util/performance_log_helper.dart';

import '../controllers/vertical_read_visible_chapter_tracker.dart';
import '../logic.dart';
import '../state.dart';
import '../utils/reader_text_hit_test.dart';
import '../utils/tts_highlight_resolver.dart';
import '../widget/book_read_paragraph_action_sheet.dart';
import '../widget/book_read_annotation_editor_sheet.dart';
import '../widget/tts_playback_rich_text.dart';
import 'pagination_service.dart';

/// 垂直滚动阅读模式
/// 保留有限窗口的章节节点，避免已读章节无限挂在渲染树中。
class VerticalPageTurn extends StatefulWidget {
  const VerticalPageTurn({
    super.key,
    required this.logic,
    required this.state,
    required this.constraints,
    required this.currentPageWidget,
    required this.targetPageWidget,
  });

  final BookReadLogic logic;
  final BookReadState state;
  final BoxConstraints constraints;
  final Widget currentPageWidget;
  final Widget targetPageWidget;

  @override
  State<VerticalPageTurn> createState() => _VerticalPageTurnState();
}

class _VerticalPageTurnState extends State<VerticalPageTurn> {
  static const int _maxRetainedChapters = 5;
  static const int _preferredLeadingChapters = 2;
  static const int _preferredTrailingChapters = 2;
  static const double _horizontalPadding = 16.0;
  static const double _contentTopPadding = 16.0;
  static const double _chapterBottomSpacing = 40.0;
  static const double _footerTopSpacing = 40.0;
  static const double _topLoadingIndicatorExtent = 40.0;
  static const double _loadTriggerOffset = 200.0;

  final VerticalReadVisibleChapterTracker _visibleChapterTracker =
      VerticalReadVisibleChapterTracker();

  bool _isLoadingPrev = false;
  bool _isLoadingNext = false;
  bool _isVisibleChapterRefreshScheduled = false;
  int? _trackingLayoutSignature;

  @override
  void initState() {
    super.initState();
    widget.state.verticalScrollController.addListener(_onScroll);
    _initCurrentChapter();
    _updateTrackingConfiguration();
  }

  @override
  void didUpdateWidget(covariant VerticalPageTurn oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.state.bookContentList.isNotEmpty) {
      _initCurrentChapter();
    }
    _syncVisibleChapterTracker();
    _updateTrackingConfiguration();
  }

  @override
  void dispose() {
    widget.state.verticalScrollController.removeListener(_onScroll);
    super.dispose();
  }

  void _initCurrentChapter() {
    final state = widget.state;
    if (state.bookContentList.isEmpty) return;

    if (state.verticalChapters
        .any((chapter) => chapter.chapterIndex == state.currentChapterIndex)) {
      return;
    }

    state.verticalChapters
      ..clear()
      ..add(
        VerticalChapterData(
          chapterIndex: state.currentChapterIndex,
          chapterName: state.currentChapter,
          content: state.bookContent,
        ),
      );
    state.verticalVisibleChapterIndex = state.currentChapterIndex;
    _visibleChapterTracker.invalidateMeasuredExtents();
    _syncVisibleChapterTracker();
    _visibleChapterTracker.setVisibleChapterIndex(state.currentChapterIndex);
    PerformanceLogHelper.logVerticalWindow(
      event: 'window_init',
      mountedChapterCount: state.verticalChapters.length,
      visibleChapterIndex: state.verticalVisibleChapterIndex,
    );
    _scheduleVisibleChapterRefresh();
  }

  void _syncVisibleChapterTracker() {
    _visibleChapterTracker.updateLoadedChapters(widget.state.verticalChapters);
    _visibleChapterTracker
        .setVisibleChapterIndex(widget.state.verticalVisibleChapterIndex);
  }

  void _updateTrackingConfiguration() {
    final fallbackExtent = math.max(widget.constraints.maxHeight * 0.9, 1.0);
    _visibleChapterTracker.updateFallbackChapterExtent(fallbackExtent);

    final style = widget.state.contentStyle;
    final signature = Object.hashAll(<Object?>[
      widget.constraints.maxWidth.toStringAsFixed(1),
      widget.constraints.maxHeight.toStringAsFixed(1),
      style.fontSize,
      style.height,
      style.fontWeight,
      style.fontStyle,
      style.fontFamily,
      style.letterSpacing,
      style.wordSpacing,
      widget.state.textScaler.hashCode,
    ]);
    if (_trackingLayoutSignature == signature) return;

    _trackingLayoutSignature = signature;
    _visibleChapterTracker.invalidateMeasuredExtents();
    _scheduleVisibleChapterRefresh();
  }

  void _scheduleVisibleChapterRefresh() {
    if (_isVisibleChapterRefreshScheduled) return;
    _isVisibleChapterRefreshScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _isVisibleChapterRefreshScheduled = false;
      if (!mounted) return;
      _updateVisibleChapter();
    });
  }

  double _listTopPadding(BuildContext context) {
    return MediaQuery.of(context).padding.top + _contentTopPadding;
  }

  double _leadingChapterContentExtent(BuildContext context) {
    return _listTopPadding(context) +
        (_isLoadingPrev ? _topLoadingIndicatorExtent : 0.0);
  }

  void _onScroll() {
    final controller = widget.state.verticalScrollController;
    if (!controller.hasClients) return;

    final maxScroll = controller.position.maxScrollExtent;
    final currentScroll = controller.offset;

    widget.state.verticalScrollProgress =
        maxScroll > 0 ? currentScroll / maxScroll : 0.0;

    _updateVisibleChapter();

    if (currentScroll <= _loadTriggerOffset && !_isLoadingPrev) {
      _loadPreviousChapter();
    }

    if (currentScroll >= maxScroll - _loadTriggerOffset && !_isLoadingNext) {
      _loadNextChapter();
    }
  }

  void _updateVisibleChapter() {
    final visibleChapterIndex = _resolveVisibleChapterIndex();
    if (visibleChapterIndex == null ||
        visibleChapterIndex == widget.state.verticalVisibleChapterIndex) {
      return;
    }

    _visibleChapterTracker.setVisibleChapterIndex(visibleChapterIndex);
    setState(() {
      widget.state.verticalVisibleChapterIndex = visibleChapterIndex;
    });

    if (!(widget.state.isTtsPlaying && !widget.state.isTtsPaused)) {
      widget.logic.updateCurrentChapterForVerticalScroll(visibleChapterIndex);
    }
  }

  int? _resolveVisibleChapterIndex() {
    final chapters = widget.state.verticalChapters;
    if (chapters.isEmpty) return null;

    _syncVisibleChapterTracker();

    final controller = widget.state.verticalScrollController;
    final viewportHeight = controller.hasClients
        ? controller.position.viewportDimension
        : MediaQuery.of(context).size.height;
    return _visibleChapterTracker.resolveVisibleChapterIndex(
      scrollOffset: controller.hasClients ? controller.offset : 0.0,
      viewportExtent: viewportHeight,
      leadingScrollExtent: _leadingChapterContentExtent(context),
    );
  }

  Future<void> _loadPreviousChapter() async {
    final state = widget.state;
    if (_isLoadingPrev || state.verticalChapters.isEmpty) return;

    final previousChapter = _resolveAdjacentLoadedChapter(isNext: false);
    final prevIndex = previousChapter?.chapterIndex;
    if (prevIndex == null) return;

    _isLoadingPrev = true;
    if (mounted) setState(() {});

    final content =
        await widget.logic.loadChapterContentForVerticalScroll(prevIndex);
    if (content != null && mounted) {
      final controller = state.verticalScrollController;
      final oldMaxScroll =
          controller.hasClients ? controller.position.maxScrollExtent : 0.0;

      setState(() {
        state.verticalChapters.insert(
          0,
          VerticalChapterData(
            chapterIndex: prevIndex,
            chapterName: previousChapter?.chapterName ?? '第${prevIndex + 1}章',
            content: content,
          ),
        );
        _trimChapterWindow(preferKeepingTail: false);
      });
      PerformanceLogHelper.logVerticalWindow(
        event: 'prepend_chapter',
        mountedChapterCount: state.verticalChapters.length,
        visibleChapterIndex: state.verticalVisibleChapterIndex,
      );

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!controller.hasClients) return;
        final newMaxScroll = controller.position.maxScrollExtent;
        final addedHeight = math.max(0.0, newMaxScroll - oldMaxScroll);
        final targetOffset = controller.offset + addedHeight;
        controller.jumpTo(
          targetOffset.clamp(
            controller.position.minScrollExtent,
            controller.position.maxScrollExtent,
          ),
        );
        _scheduleVisibleChapterRefresh();
      });
    }

    _isLoadingPrev = false;
    if (mounted) setState(() {});
  }

  Future<void> _loadNextChapter() async {
    final state = widget.state;
    if (_isLoadingNext || state.verticalChapters.isEmpty) return;

    final nextChapter = _resolveAdjacentLoadedChapter(isNext: true);
    final nextIndex = nextChapter?.chapterIndex;
    if (nextIndex == null) return;

    _isLoadingNext = true;
    if (mounted) setState(() {});

    final content =
        await widget.logic.loadChapterContentForVerticalScroll(nextIndex);
    if (content != null && mounted) {
      final controller = state.verticalScrollController;
      final currentOffset = controller.hasClients ? controller.offset : 0.0;

      var removedLeadingExtent = 0.0;
      setState(() {
        state.verticalChapters.add(
          VerticalChapterData(
            chapterIndex: nextIndex,
            chapterName: nextChapter?.chapterName ?? '第${nextIndex + 1}章',
            content: content,
          ),
        );
        removedLeadingExtent = _trimChapterWindow(preferKeepingTail: true);
      });
      PerformanceLogHelper.logVerticalWindow(
        event: 'append_chapter',
        mountedChapterCount: state.verticalChapters.length,
        visibleChapterIndex: state.verticalVisibleChapterIndex,
        removedLeadingExtent:
            removedLeadingExtent > 0 ? removedLeadingExtent : null,
      );

      if (removedLeadingExtent > 0) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!controller.hasClients) return;
          final targetOffset =
              math.max(0.0, currentOffset - removedLeadingExtent);
          controller.jumpTo(
            targetOffset.clamp(
              controller.position.minScrollExtent,
              controller.position.maxScrollExtent,
            ),
          );
          _scheduleVisibleChapterRefresh();
        });
      } else {
        _scheduleVisibleChapterRefresh();
      }
    }

    _isLoadingNext = false;
    if (mounted) setState(() {});
  }

  BookChapterInfo? _resolveAdjacentLoadedChapter({required bool isNext}) {
    final allChapters = widget.state.bookDetail.chapters;
    final loadedChapters = widget.state.verticalChapters;
    if (allChapters == null || allChapters.isEmpty || loadedChapters.isEmpty) {
      return null;
    }

    final anchorChapterIndex = isNext
        ? loadedChapters.last.chapterIndex
        : loadedChapters.first.chapterIndex;
    final anchorListIndex = allChapters.indexWhere(
      (chapter) => chapter.chapterIndex == anchorChapterIndex,
    );
    if (anchorListIndex < 0) return null;

    final targetListIndex = isNext ? anchorListIndex + 1 : anchorListIndex - 1;
    if (targetListIndex < 0 || targetListIndex >= allChapters.length) {
      return null;
    }
    return allChapters[targetListIndex];
  }

  double _trimChapterWindow({required bool preferKeepingTail}) {
    final chapters = widget.state.verticalChapters;
    if (chapters.length <= _maxRetainedChapters) {
      _syncVisibleChapterTracker();
      return 0.0;
    }

    var removedLeadingExtent = 0.0;
    var trimmedChapterCount = 0;
    while (chapters.length > _maxRetainedChapters) {
      final visiblePosition = chapters.indexWhere(
        (chapter) =>
            chapter.chapterIndex == widget.state.verticalVisibleChapterIndex,
      );
      final canRemoveHead =
          visiblePosition < 0 || visiblePosition > _preferredLeadingChapters;
      final canRemoveTail = visiblePosition < 0 ||
          (chapters.length - visiblePosition - 1) > _preferredTrailingChapters;

      if (preferKeepingTail && canRemoveHead) {
        removedLeadingExtent += _removeLeadingChapter();
        trimmedChapterCount++;
        continue;
      }
      if (!preferKeepingTail && canRemoveTail) {
        chapters.removeLast();
        trimmedChapterCount++;
        continue;
      }
      if (canRemoveHead) {
        removedLeadingExtent += _removeLeadingChapter();
        trimmedChapterCount++;
        continue;
      }
      if (canRemoveTail) {
        chapters.removeLast();
        trimmedChapterCount++;
        continue;
      }
      break;
    }

    _syncVisibleChapterTracker();
    if (trimmedChapterCount > 0) {
      PerformanceLogHelper.logVerticalWindow(
        event: 'trim_window',
        mountedChapterCount: chapters.length,
        visibleChapterIndex: widget.state.verticalVisibleChapterIndex,
        trimmedChapterCount: trimmedChapterCount,
        removedLeadingExtent:
            removedLeadingExtent > 0 ? removedLeadingExtent : null,
      );
    }
    return removedLeadingExtent;
  }

  double _removeLeadingChapter() {
    final chapters = widget.state.verticalChapters;
    if (chapters.isEmpty) return 0.0;
    final removedChapter = chapters.removeAt(0);
    return _visibleChapterTracker
        .resolveChapterExtent(removedChapter.chapterIndex);
  }

  void _onChapterExtentChanged(int chapterIndex, double extent) {
    if (!_visibleChapterTracker.recordChapterExtent(
      chapterIndex: chapterIndex,
      extent: extent,
    )) {
      return;
    }
    _scheduleVisibleChapterRefresh();
  }

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final state = widget.state;

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: state.backgroundColor,
        gradient: state.isEyeProtectionMode
            ? const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFF8F9E8),
                  Color(0xFFF0F1E0),
                ],
              )
            : null,
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: ListView.builder(
              controller: state.verticalScrollController,
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                _horizontalPadding,
                statusBarHeight + _contentTopPadding,
                _horizontalPadding,
                state.endPadding + _footerTopSpacing,
              ),
              itemCount: state.verticalChapters.length + 2,
              itemBuilder: (context, index) => _buildListItem(index),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    (state.isEyeProtectionMode
                            ? const Color(0xFFF0F1E0)
                            : state.backgroundColor)
                        .withValues(alpha: 0.0),
                    state.isEyeProtectionMode
                        ? const Color(0xFFF0F1E0)
                        : state.backgroundColor,
                  ],
                ),
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        _getCurrentChapterName(),
                        style: TextStyle(
                          fontSize: 12,
                          color: state.secondaryTextColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      '${(state.verticalScrollProgress * 100).toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: 12,
                        color: state.secondaryTextColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChapterWidget(VerticalChapterData chapter) {
    final state = widget.state;
    return _VerticalChapterExtentReporter(
      key: ValueKey<int>(chapter.chapterIndex),
      onExtentChanged: (extent) {
        _onChapterExtentChanged(chapter.chapterIndex, extent);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: _chapterBottomSpacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (chapter.chapterIndex !=
                state.verticalChapters.first.chapterIndex)
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: state.secondaryTextColor.withValues(alpha: 0.3),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        '第${chapter.chapterIndex + 1}章',
                        style: TextStyle(
                          fontSize: 12,
                          color: state.secondaryTextColor,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: state.secondaryTextColor.withValues(alpha: 0.3),
                      ),
                    ),
                  ],
                ),
              ),
            if (chapter.chapterName.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  chapter.chapterName,
                  style: state.contentStyle.copyWith(
                    fontSize: (state.contentStyle.fontSize ?? 16) + 4,
                    fontWeight: FontWeight.bold,
                    height: 1.4,
                    color: state.textColor,
                  ),
                ),
              ),
            _buildChapterContent(chapter),
          ],
        ),
      ),
    );
  }

  Widget _buildListItem(int index) {
    final chapterCount = widget.state.verticalChapters.length;
    if (index == 0) {
      if (!_isLoadingPrev) {
        return const SizedBox.shrink();
      }
      return const Padding(
        padding: EdgeInsets.only(bottom: 20),
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    if (index == chapterCount + 1) {
      return Column(
        children: [
          const SizedBox(height: _footerTopSpacing),
          Center(
            child: _isLoadingNext
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    _isLastChapter() ? '— 全书完 —' : '— 继续滚动加载下一章 —',
                    style: TextStyle(
                      color: widget.state.secondaryTextColor,
                      fontSize: 14,
                    ),
                  ),
          ),
        ],
      );
    }

    return _buildChapterWidget(widget.state.verticalChapters[index - 1]);
  }

  Widget _buildChapterContent(VerticalChapterData chapter) {
    final state = widget.state;
    final baseStyle = state.contentStyle.copyWith(color: state.textColor);
    final strutStyle = StrutStyle(
      fontSize: state.contentStyle.fontSize,
      height: state.contentStyle.height,
      forceStrutHeight: false,
    );
    return Builder(
      builder: (contentContext) {
        // 竖滚：优先用 ListView viewport，否则 MediaQuery 屏高估算可用高。
        final controller = state.verticalScrollController;
        final viewportHeight = controller.hasClients
            ? controller.position.viewportDimension
            : MediaQuery.sizeOf(contentContext).height;
        final maxImageHeight = PaginationService.clampedImageHeight(
          availableHeight: viewportHeight > 0
              ? viewportHeight
              : MediaQuery.sizeOf(contentContext).height,
        );
        return Listener(
          behavior: HitTestBehavior.opaque,
          onPointerDown: (event) {
            widget.logic.beginParagraphActionGesture(
              event.position,
              () => _showParagraphMenu(
                contentContext,
                event.localPosition,
                chapter: chapter,
                baseStyle: baseStyle,
                strutStyle: strutStyle,
              ),
            );
          },
          onPointerMove: (event) {
            widget.logic.updateParagraphActionGesture(event.position);
          },
          onPointerUp: (_) {
            widget.logic.cancelParagraphActionGesture();
          },
          onPointerCancel: (_) {
            widget.logic.cancelParagraphActionGesture();
          },
          child: ValueListenableBuilder<BookReadTextHighlightStateSnapshot>(
            valueListenable:
                widget.logic.uiRefreshController.textHighlightStateListenable,
            builder: (context, highlightState, _) {
              final fallbackPageIndex = highlightState.ttsHighlightPageIndex ??
                  highlightState.currentPage;
              final descriptor = TtsHighlightResolver.resolveForChapter(
                highlightState,
                content: chapter.content,
                displayChapterIndex: chapter.chapterIndex,
                fallbackPageOffsetInChapter: _pageOffsetInChapter(
                  fallbackPageIndex,
                ),
              );
              return TtsPlaybackRichText(
                content: chapter.content,
                annotationRanges: widget.logic.annotationRangesForContent(
                  chapterIndex: chapter.chapterIndex,
                  chapterText: chapter.content,
                  contentOffsetInChapter: 0,
                  contentLength: chapter.content.length,
                ),
                descriptor: descriptor,
                baseStyle: baseStyle,
                textColor: state.textColor,
                backgroundColor: state.backgroundColor,
                strutStyle: strutStyle,
                textScaler: MediaQuery.textScalerOf(context),
                maxImageHeight: maxImageHeight,
              );
            },
          ),
        );
      },
    );
  }

  int _pageOffsetInChapter(int pageIndex) {
    final pages = widget.state.bookContentList;
    if (pages.isEmpty || pageIndex <= 0) return 0;

    var offset = 0;
    final limit = pageIndex > pages.length ? pages.length : pageIndex;
    for (var i = 0; i < limit; i++) {
      offset += pages[i].length;
    }
    return offset;
  }

  Future<void> _showParagraphMenu(
    BuildContext context,
    Offset localPosition, {
    required VerticalChapterData chapter,
    required TextStyle baseStyle,
    required StrutStyle strutStyle,
  }) async {
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize || chapter.content.isEmpty) {
      return;
    }

    final paragraph = ReaderTextHitTest.resolveParagraphAtPosition(
      localPosition: localPosition,
      maxWidth: renderBox.size.width,
      content: chapter.content,
      baseStyle: baseStyle,
      textScaler: MediaQuery.textScalerOf(context),
      strutStyle: strutStyle,
    );
    if (paragraph == null || paragraph.isEmpty) return;

    widget.logic.showParagraphPreviewForChapter(
      chapterIndex: chapter.chapterIndex,
      start: paragraph.start,
      end: paragraph.end,
    );
    try {
      final result = await BookReadParagraphActionSheet.show(
        context,
        state: widget.state,
        previewText: paragraph.toPreview(maxLength: 72),
      );

      if (result != null &&
          result.action != BookReadParagraphAction.cancel &&
          result.action != BookReadParagraphAction.tts) {
        final type = switch (result.action) {
          BookReadParagraphAction.highlight => BookAnnotationType.highlight,
          BookReadParagraphAction.underline => BookAnnotationType.underline,
          BookReadParagraphAction.note => BookAnnotationType.note,
          _ => throw StateError('Unsupported paragraph action'),
        };
        var note = '';
        if (type == BookAnnotationType.note) {
          if (!context.mounted) return;
          note = await BookReadAnnotationEditorSheet.show(
                context,
                excerpt: paragraph.text,
              ) ??
              '';
          if (note.isEmpty) return;
        }
        await widget.logic.createAnnotation(
          type: type,
          chapterIndex: chapter.chapterIndex,
          chapterName: chapter.chapterName,
          chapterText: chapter.content,
          start: paragraph.start,
          end: paragraph.end,
          note: note,
        );
      }

      if (result?.start == true) {
        widget.logic.clearParagraphPreview();
        await widget.logic.startTtsFromChapterParagraph(
          chapterIndex: chapter.chapterIndex,
          chapterOffset: paragraph.start,
        );
      }
    } finally {
      widget.logic.clearParagraphPreview();
    }
  }

  String _getCurrentChapterName() {
    final currentChapter = widget.state.verticalChapters
        .cast<VerticalChapterData?>()
        .firstWhere(
          (chapter) =>
              chapter?.chapterIndex == widget.state.verticalVisibleChapterIndex,
          orElse: () => null,
        );
    return currentChapter?.chapterName ?? widget.state.currentChapter;
  }

  bool _isLastChapter() {
    final state = widget.state;
    if (state.verticalChapters.isEmpty) return false;
    final lastLoadedChapterIndex = state.verticalChapters.last.chapterIndex;
    final allChapters = state.bookDetail.chapters;
    if (allChapters == null || allChapters.isEmpty) return false;
    return allChapters.last.chapterIndex == lastLoadedChapterIndex;
  }
}

class _VerticalChapterExtentReporter extends StatefulWidget {
  const _VerticalChapterExtentReporter({
    super.key,
    required this.onExtentChanged,
    required this.child,
  });

  final ValueChanged<double> onExtentChanged;
  final Widget child;

  @override
  State<_VerticalChapterExtentReporter> createState() =>
      _VerticalChapterExtentReporterState();
}

class _VerticalChapterExtentReporterState
    extends State<_VerticalChapterExtentReporter> {
  double? _lastReportedExtent;

  @override
  void initState() {
    super.initState();
    _scheduleReport();
  }

  @override
  void didUpdateWidget(covariant _VerticalChapterExtentReporter oldWidget) {
    super.didUpdateWidget(oldWidget);
    _scheduleReport();
  }

  void _scheduleReport() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final extent = context.size?.height;
      if (extent == null ||
          extent <= 0 ||
          (_lastReportedExtent != null &&
              (_lastReportedExtent! - extent).abs() < 0.5)) {
        return;
      }

      _lastReportedExtent = extent;
      widget.onExtentChanged(extent);
    });
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<SizeChangedLayoutNotification>(
      onNotification: (_) {
        _scheduleReport();
        return false;
      },
      child: SizeChangedLayoutNotifier(
        child: widget.child,
      ),
    );
  }
}
