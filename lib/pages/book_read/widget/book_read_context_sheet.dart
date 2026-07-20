import 'package:flutter/material.dart';
import '../../../app/service/annotation/book_annotation.dart';
import '../logic.dart';
import '../page_turn/pagination_service.dart';
import '../state.dart';
import '../utils/reader_text_hit_test.dart';
import '../utils/tts_highlight_resolver.dart';
import 'book_read_paragraph_action_sheet.dart';
import 'book_read_annotation_editor_sheet.dart';
import 'tts_playback_rich_text.dart';

class BookReadContextSheet extends StatefulWidget {
  const BookReadContextSheet({
    super.key,
    required this.logic,
    required this.state,
    this.showTargetPage = false,
    this.pageOffset = 0,
  });

  final BookReadLogic logic;
  final BookReadState state;
  final bool showTargetPage;
  final int pageOffset;

  static const double _contentHorizontalPadding = 16.0;

  @override
  State<BookReadContextSheet> createState() => _BookReadContextSheetState();
}

class _BookReadContextSheetState extends State<BookReadContextSheet> {
  Orientation? _lastOrientation;
  Size? _lastSize;
  bool _hasPendingOrientationSync = false;

  BookReadLogic get logic => widget.logic;
  BookReadState get state => widget.state;
  bool get showTargetPage => widget.showTargetPage;
  int get pageOffset => widget.pageOffset;

  bool get _isAnimatingNextChapterPlaceholder =>
      showTargetPage &&
      state.isAnimating &&
      state.isNext &&
      state.targetPage != null &&
      state.targetPage! >= state.pageSize &&
      !logic.isNextPageCrossChapter();

  String _resolveCrossChapterTitle() {
    final currentTitle = state.crossChapterName?.trim();
    if (currentTitle != null && currentTitle.isNotEmpty) {
      return currentTitle;
    }
    final upcomingTitle = logic.getUpcomingNextChapterName()?.trim();
    if (upcomingTitle != null && upcomingTitle.isNotEmpty) {
      return upcomingTitle;
    }
    return '下一章';
  }

  Future<void> _showParagraphMenu(
    BuildContext context,
    Offset localPosition, {
    required String content,
    required List<InlineSpan> leadingSpans,
    required TextStyle baseStyle,
    required StrutStyle strutStyle,
    required int pageIndex,
  }) async {
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) return;

    final paragraph = ReaderTextHitTest.resolveParagraphAtPosition(
      localPosition: localPosition,
      maxWidth: renderBox.size.width,
      content: content,
      leadingSpans: leadingSpans,
      baseStyle: baseStyle,
      textScaler: MediaQuery.textScalerOf(context),
      strutStyle: strutStyle,
    );
    if (paragraph == null) return;

    logic.showParagraphPreviewForPage(
      pageIndex: pageIndex,
      chapterIndex: state.currentChapterIndex,
      start: paragraph.start,
      end: paragraph.end,
    );
    try {
      final result = await BookReadParagraphActionSheet.show(
        context,
        state: state,
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
        var chapterOffset = paragraph.start;
        for (var i = 0; i < pageIndex; i++) {
          chapterOffset += state.bookContentList[i].length;
        }
        await logic.createAnnotation(
          type: type,
          chapterIndex: state.currentChapterIndex,
          chapterName: state.currentChapter,
          chapterText: state.bookContent,
          start: chapterOffset,
          end: chapterOffset + paragraph.text.length,
          note: note,
        );
      }

      if (result?.start == true) {
        logic.clearParagraphPreview();
        await logic.startTtsFromPageParagraph(
          pageIndex: pageIndex,
          pageTextOffset: paragraph.start,
        );
      }
    } finally {
      logic.clearParagraphPreview();
    }
  }

  void _scheduleOrientationSync({
    required Orientation orientation,
    required Size size,
  }) {
    if (_lastOrientation == orientation && _lastSize == size) {
      return;
    }
    _lastOrientation = orientation;
    _lastSize = size;
    if (_hasPendingOrientationSync) {
      return;
    }
    _hasPendingOrientationSync = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _hasPendingOrientationSync = false;
      if (!mounted) return;
      logic.onOrientationChanged(orientation, size);
    });
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        _scheduleOrientationSync(
          orientation: orientation,
          size: MediaQuery.of(context).size,
        );

        return ValueListenableBuilder<BookReadPageTurnStateSnapshot>(
          valueListenable: logic.uiRefreshController.pageTurnStateListenable,
          builder: (context, _, __) {
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
                  _buildContentArea(context),
                  _buildPageFooter(context),
                ],
              ),
            );
          },
        );
      },
    );
  }

  //  内容区域（支持跨章节显示）
  Widget _buildContentArea(BuildContext context) {
    if (!showTargetPage && state.isCrossChapterTransition) {
      return _buildCrossChapterTransitionBody(context);
    }

    if (_isAnimatingNextChapterPlaceholder) {
      return _buildCrossChapterTransitionBody(
        context,
        isPreview: true,
      );
    }

    String content = '';
    String? chapterTitle;
    bool showTitle = false;
    int displayPageIndex = state.currentPage;
    int displayChapterIndex = state.currentChapterIndex;

    if (state.isTwoPageMode) {
      final delta =
          showTargetPage && state.isAnimating ? (state.isNext ? 2 : -2) : 0;
      displayPageIndex = state.currentPage + delta + pageOffset;
      displayChapterIndex = state.currentChapterIndex;
      if (displayPageIndex >= 0 && displayPageIndex < state.pageSize) {
        content = state.bookContentList[displayPageIndex];
        chapterTitle = state.currentChapter;
        showTitle = displayPageIndex == 0 && chapterTitle.isNotEmpty;
      } else if (displayPageIndex >= state.pageSize &&
          state.nextChapterCache != null) {
        final nextIndex = displayPageIndex - state.pageSize;
        final cache = state.nextChapterCache!;
        content = cache.getPage(nextIndex) ?? '';
        displayPageIndex = nextIndex;
        displayChapterIndex = cache.chapterIndex;
        chapterTitle = cache.chapterName;
        showTitle = nextIndex == 0;
      } else if (displayPageIndex < 0 && state.prevChapterCache != null) {
        final cache = state.prevChapterCache!;
        final previousIndex = cache.pageSize + displayPageIndex;
        content = cache.getPage(previousIndex) ?? '';
        displayPageIndex = previousIndex;
        displayChapterIndex = cache.chapterIndex;
        chapterTitle = cache.chapterName;
        showTitle = previousIndex == 0;
      } else {
        content = '';
      }
    } else

    // 使用 isAnimating 和 targetPage 判断是否在翻页动画中
    // 回弹动画时 targetPage 为 null，不应显示目标页内容
    if (!state.isTwoPageMode &&
        showTargetPage &&
        state.isAnimating &&
        state.targetPage != null) {
      // ===== 翻页动画时，使用 PageFactory 获取跨章内容 =====
      if (state.isNext) {
        // 下一页
        content = logic.getNextPageContent() ?? '';
        // 如果是跨章节，获取新章节标题
        if (logic.isNextPageCrossChapter()) {
          chapterTitle = logic.getNextPageChapterName();
          showTitle = chapterTitle != null && chapterTitle.isNotEmpty;
          displayPageIndex = 0; // 新章节第一页
          displayChapterIndex =
              state.nextChapterCache?.chapterIndex ?? state.currentChapterIndex;
        } else {
          displayPageIndex = state.currentPage + 1;
          displayChapterIndex = state.currentChapterIndex;
          // 同章节内翻页不显示标题
          showTitle = false;
        }
      } else {
        // 上一页
        content = logic.getPrevPageContent() ?? '';
        // 如果是跨章节，判断是否显示标题
        if (logic.isPrevPageCrossChapter()) {
          chapterTitle = logic.getPrevPageChapterName();
          // 上一章最后一页通常不需要显示标题
          final prevCache = state.prevChapterCache;
          displayPageIndex = prevCache?.lastPageIndex ?? 0;
          displayChapterIndex =
              prevCache?.chapterIndex ?? state.currentChapterIndex;
          showTitle = displayPageIndex == 0 && chapterTitle != null;
        } else {
          displayPageIndex = state.currentPage - 1;
          displayChapterIndex = state.currentChapterIndex;
          showTitle = displayPageIndex == 0 && state.currentChapter.isNotEmpty;
          chapterTitle = state.currentChapter;
        }
      }
    } else if (!state.isTwoPageMode) {
      // ===== 正常显示当前页 =====
      displayPageIndex = state.currentPage;
      displayChapterIndex = state.currentChapterIndex;
      content = state.bookContentList.isNotEmpty &&
              displayPageIndex >= 0 &&
              displayPageIndex < state.bookContentList.length
          ? state.bookContentList[displayPageIndex]
          : state.lastBookContent;
      showTitle = displayPageIndex == 0 && state.currentChapter.isNotEmpty;
      chapterTitle = state.currentChapter;
    }

    final List<InlineSpan> children = [];

    if (showTitle && chapterTitle != null) {
      children.add(
        TextSpan(
          text: '$chapterTitle\n\n',
          style: state.contentStyle.copyWith(
            fontSize: state.contentStyle.fontSize! + 4,
            fontWeight: FontWeight.bold,
            height: 1.4,
            color: state.textColor,
          ),
        ),
      );
    }

    final canHandleParagraphAction = !(showTargetPage && state.isAnimating);
    final baseStyle = state.contentStyle.copyWith(color: state.textColor);
    final strutStyle = StrutStyle(
      fontSize: state.contentStyle.fontSize,
      height: state.contentStyle.height,
      forceStrutHeight: false,
    );

    // 获取状态栏高度，沉浸式模式需要手动加上
    final statusBarHeight = MediaQuery.of(context).padding.top;
    // 内容区高度 ≈ 屏高 - 顶栏 padding - 底栏 endPadding；与分页测量可用高语义对齐。
    final availableHeight =
        MediaQuery.sizeOf(context).height - statusBarHeight - state.endPadding;
    final maxImageHeight = PaginationService.clampedImageHeight(
      availableHeight: availableHeight,
    );

    return Positioned.fill(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          BookReadContextSheet._contentHorizontalPadding,
          statusBarHeight,
          BookReadContextSheet._contentHorizontalPadding,
          state.endPadding,
        ),
        child: ClipRect(
          child: Builder(
            builder: (contentContext) {
              return Listener(
                behavior: HitTestBehavior.opaque,
                onPointerDown: !canHandleParagraphAction
                    ? null
                    : (event) {
                        logic.beginParagraphActionGesture(
                          event.position,
                          () => _showParagraphMenu(
                            contentContext,
                            event.localPosition,
                            content: content,
                            leadingSpans: children,
                            baseStyle: baseStyle,
                            strutStyle: strutStyle,
                            pageIndex: displayPageIndex,
                          ),
                        );
                      },
                onPointerMove: !canHandleParagraphAction
                    ? null
                    : (event) {
                        logic.updateParagraphActionGesture(event.position);
                      },
                onPointerUp: !canHandleParagraphAction
                    ? null
                    : (_) {
                        logic.cancelParagraphActionGesture();
                      },
                onPointerCancel: !canHandleParagraphAction
                    ? null
                    : (_) {
                        logic.cancelParagraphActionGesture();
                      },
                child:
                    ValueListenableBuilder<BookReadTextHighlightStateSnapshot>(
                  valueListenable:
                      logic.uiRefreshController.textHighlightStateListenable,
                  builder: (context, highlightState, _) {
                    final descriptor = TtsHighlightResolver.resolveForPage(
                      highlightState,
                      content: content,
                      displayPageIndex: displayPageIndex,
                      displayChapterIndex: displayChapterIndex,
                    );
                    return TtsPlaybackRichText(
                      content: content,
                      annotationRanges: logic.annotationRangesForContent(
                        chapterIndex: displayChapterIndex,
                        chapterText: state.bookContent,
                        contentOffsetInChapter: state.bookContentList
                            .take(displayPageIndex)
                            .fold<int>(0, (sum, page) => sum + page.length),
                        contentLength: content.length,
                      ),
                      descriptor: descriptor,
                      leadingSpans: children,
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
          ),
        ),
      ),
    );
  }

  Widget _buildCrossChapterTransitionBody(
    BuildContext context, {
    bool isPreview = false,
  }) {
    final title = _resolveCrossChapterTitle();
    final isFailed = !isPreview && state.isCrossChapterTransitionFailed;
    final statusMessage = isPreview
        ? '继续翻页进入下一章'
        : (state.crossChapterStatusMessage ?? '正在加载下一章');
    final hintMessage = isPreview
        ? '正文将优先从缓存读取，未命中时自动联网加载'
        : (state.isCrossChapterTransitionSlow
            ? '网络较慢，正文返回后会自动替换当前页面'
            : '下一章内容准备好后会直接显示');
    final titleStyle = state.contentStyle.copyWith(
      fontSize: state.contentStyle.fontSize! + 4,
      fontWeight: FontWeight.bold,
      height: 1.4,
      color: state.textColor,
    );
    final bodyStyle = state.contentStyle.copyWith(
      color: state.textColor.withValues(alpha: 0.72),
      fontSize: (state.contentStyle.fontSize ?? 18) - 1,
      height: 1.5,
    );
    final statusColor = isFailed
        ? Colors.redAccent.shade200
        : state.textColor.withValues(alpha: 0.72);
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return Positioned.fill(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          BookReadContextSheet._contentHorizontalPadding,
          statusBarHeight,
          BookReadContextSheet._contentHorizontalPadding,
          state.endPadding,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: SizedBox(
              width: double.infinity,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(title, style: titleStyle, textAlign: TextAlign.center),
                  const SizedBox(height: 28),
                  ...List<Widget>.generate(
                    5,
                    (index) => Padding(
                      padding: EdgeInsets.only(bottom: index == 4 ? 0 : 14),
                      child: FractionallySizedBox(
                        widthFactor: index == 4 ? 0.58 : (0.96 - index * 0.06),
                        child: Container(
                          height: 16,
                          decoration: BoxDecoration(
                            color: state.textColor.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 10,
                    runSpacing: 8,
                    children: [
                      if (!isFailed)
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: state.textColor.withValues(alpha: 0.75),
                          ),
                        ),
                      Text(
                        statusMessage,
                        textAlign: TextAlign.center,
                        style: bodyStyle.copyWith(
                          color: statusColor,
                          fontWeight:
                              isPreview ? FontWeight.w500 : FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    hintMessage,
                    textAlign: TextAlign.center,
                    style: bodyStyle.copyWith(
                      fontSize: (state.contentStyle.fontSize ?? 18) - 3,
                      color: state.textColor.withValues(alpha: 0.58),
                    ),
                  ),
                  if (isFailed) ...[
                    const SizedBox(height: 22),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        FilledButton.tonal(
                          onPressed: () {
                            logic.retryCrossChapterTransition();
                          },
                          child: const Text('重试'),
                        ),
                        TextButton(
                          onPressed: logic.dismissCrossChapterTransition,
                          child: const Text('返回本章'),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  //  页码区域（支持跨章节显示）
  Widget _buildPageFooter(BuildContext context) {
    if ((!showTargetPage && state.isCrossChapterTransition) ||
        _isAnimatingNextChapterPlaceholder) {
      final statusText = _isAnimatingNextChapterPlaceholder
          ? '下一章'
          : (state.isCrossChapterTransitionFailed
              ? '加载失败'
              : (state.isCrossChapterTransitionSlow ? '网络较慢' : '加载中'));
      return Positioned(
        left: 0,
        right: 0,
        bottom: 15,
        child: Container(
          height: state.endPadding,
          padding: const EdgeInsets.symmetric(horizontal: 16),
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _resolveCrossChapterTitle(),
                style: state.contentStyle.copyWith(
                  height: 1.0,
                  fontSize: 14.0,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                statusText,
                style: state.contentStyle.copyWith(
                  height: 1.0,
                  fontSize: 14.0,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    int displayPageIndex;
    int displayPageSize;

    // 使用 isAnimating 判断是否在翻页动画中
    if (showTargetPage && state.isAnimating) {
      if (state.isNext && logic.isNextPageCrossChapter()) {
        // 下一章第一页
        displayPageIndex = 0;
        displayPageSize = state.nextChapterCache?.pageSize ?? state.pageSize;
      } else if (!state.isNext && logic.isPrevPageCrossChapter()) {
        // 上一章最后一页
        final prevCache = state.prevChapterCache;
        displayPageIndex = prevCache?.lastPageIndex ?? 0;
        displayPageSize = prevCache?.pageSize ?? state.pageSize;
      } else {
        // 同章节内翻页
        displayPageIndex =
            state.isNext ? state.currentPage + 1 : state.currentPage - 1;
        displayPageSize = state.pageSize;
      }
    } else {
      displayPageIndex = state.currentPage + pageOffset;
      displayPageSize = state.pageSize;
    }

    return Positioned(
      left: 0,
      right: 0,
      bottom: 15,
      child: Container(
        height: state.endPadding, // 包含 safeBottom
        padding: const EdgeInsets.symmetric(horizontal: 16),
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '第${displayPageIndex + 1}页',
              style: state.contentStyle.copyWith(
                height: 1.0,
                fontSize: 14.0,
                color: Colors.grey[600],
              ),
            ),
            Text(
              '共$displayPageSize页',
              style: state.contentStyle.copyWith(
                height: 1.0,
                fontSize: 14.0,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
