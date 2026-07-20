import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reader_nover/app/database/drift/app_database.dart' as db;
import 'package:reader_nover/app/service/annotation/book_annotation.dart';
import 'package:reader_nover/app/l10n/generated/l10n.dart';

import '../controllers/book_read_ui_refresh_controller.dart';
import '../logic.dart';
import '../state.dart';
import 'book_read_bookmark_editor_sheet.dart';
import 'book_read_annotation_editor_sheet.dart';

class BookReadDirectorySheet extends StatefulWidget {
  final BookReadLogic logic;
  final BookReadState state;
  final VoidCallback? onClose;
  const BookReadDirectorySheet(
      {super.key, required this.logic, required this.state, this.onClose});

  @override
  State<BookReadDirectorySheet> createState() => _BookReadDirectorySheetState();
}

class _BookReadDirectorySheetState extends State<BookReadDirectorySheet> {
  static const double _chapterItemExtent = 65;
  static const double _progressThumbHeight = 30;

  /// 0 = 目录, 1 = 书签, 2 = 批注
  int _currentTab = 0;
  late final ScrollController _directoryListScrollController;

  BookReadLogic get logic => widget.logic;
  BookReadState get state => widget.state;

  @override
  void initState() {
    super.initState();
    _directoryListScrollController = ScrollController(
      initialScrollOffset: _getInitialScrollOffset(),
    );
    // 打开侧栏时加载书签
    logic.loadBookmarks();
    logic.loadAnnotations();
  }

  @override
  void dispose() {
    _directoryListScrollController.dispose();
    super.dispose();
  }

  // 获取当前阅读章节在列表中的位置
  int _getInitialScrollIndex() {
    final chapters = state.directoryChapters;
    if (chapters.isEmpty) return 0;
    if (!state.isAscending) return 0;

    final index = chapters.indexWhere(
      (c) => c.chapterIndex == state.currentChapterIndex,
    );

    return index >= 0 ? index : 0;
  }

  double _getInitialScrollOffset() {
    return _getInitialScrollIndex() * _chapterItemExtent;
  }

  void _sortChapters() {
    logic.sortChapters();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_directoryListScrollController.hasClients) return;

      final position = _directoryListScrollController.position;
      if (!position.hasContentDimensions) return;

      _directoryListScrollController.jumpTo(
        _getInitialScrollOffset().clamp(
          0.0,
          position.maxScrollExtent,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BookReadLogic>(
      init: logic,
      global: false,
      id: BookReadUiRefreshController.overlayUpdateId,
      builder: (_) {
        return Container(
          width: MediaQuery.of(context).size.width * 0.7,
          height: double.infinity,
          decoration: BoxDecoration(
            color: state.backgroundColor,
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(2, 0),
              ),
            ],
          ),
          child: SafeArea(
            child: Column(
              children: [
                // 顶部 Tab 栏
                _buildTabBar(context),
                Divider(
                    height: 1,
                    color: state.secondaryTextColor.withValues(alpha: 0.3)),
                // 内容区域
                Expanded(
                  child: switch (_currentTab) {
                    0 => _buildChapterList(context),
                    1 => _buildBookmarkList(context),
                    _ => _buildAnnotationList(context),
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Tab 栏
  Widget _buildTabBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: _buildTabItem(
                    context,
                    S.of(context).directory,
                    0,
                    icon: state.cachedChapterIndices.isEmpty
                        ? Icons.download_outlined
                        : Icons.cloud_download,
                    countText:
                        '${state.cachedChapterIndices.length}/${state.directoryChapters.length}',
                    countColor: state.cachedChapterIndices.isEmpty
                        ? state.secondaryTextColor
                        : Colors.green.shade700,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTabItem(
                    context,
                    S.of(context).annotations,
                    2,
                    count: state.annotationList.length,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTabItem(
                    context,
                    S.of(context).bookmarks,
                    1,
                    count: state.bookmarkList.length,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),
          if (_currentTab == 0)
            _buildSortActionButton(
              onPressed: _sortChapters,
            ),
        ],
      ),
    );
  }

  Widget _buildSortActionButton({
    required VoidCallback onPressed,
  }) {
    return TextButton.icon(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        minimumSize: const Size(52, 32),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
        foregroundColor: state.iconColor,
      ),
      icon: Icon(
        state.isAscending
            ? Icons.arrow_downward_rounded
            : Icons.arrow_upward_rounded,
        size: 18,
        color: state.iconColor,
      ),
      label: Text(
        state.isAscending ? S.of(context).ascending : S.of(context).descending,
        style: TextStyle(
          fontSize: 11,
          color: state.secondaryTextColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  /// 单个 tab
  Widget _buildTabItem(
    BuildContext context,
    String title,
    int index, {
    int? count,
    String? countText,
    IconData? icon,
    Color? countColor,
  }) {
    final isSelected = _currentTab == index;
    final displayText = countText ?? (count != null ? '($count)' : null);
    final displayColor = countColor ?? state.secondaryTextColor;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        setState(() {
          _currentTab = index;
        });
      },
      child: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: double.infinity,
              child: Align(
                alignment: Alignment.centerLeft,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: isSelected ? 17 : 14,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected
                              ? state.textColor
                              : state.secondaryTextColor,
                        ),
                      ),
                      if (displayText != null) ...[
                        const SizedBox(width: 4),
                        if (icon != null) ...[
                          Icon(
                            icon,
                            size: 13,
                            color: displayColor,
                          ),
                          const SizedBox(width: 2),
                        ],
                        Text(
                          displayText,
                          style: TextStyle(
                            fontSize: 11,
                            color: displayColor,
                            fontWeight: icon != null
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Container(
              height: 2,
              width: 20,
              decoration: BoxDecoration(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 目录列表
  Widget _buildChapterList(BuildContext context) {
    final chapters = state.directoryChapters;
    final chapterCount = chapters.length;

    return Stack(
      children: [
        ListView.builder(
          controller: _directoryListScrollController,
          physics: const ClampingScrollPhysics(),
          itemExtent: _chapterItemExtent,
          itemCount: chapterCount,
          itemBuilder: (context, index) {
            final chapter = chapters[index];
            final isCurrent = chapter.chapterIndex == state.currentChapterIndex;
            final isRead =
                state.readChapterIndices.contains(chapter.chapterIndex);
            final isCached =
                state.cachedChapterIndices.contains(chapter.chapterIndex);

            return Column(
              children: [
                ListTile(
                  selected: isCurrent,
                  selectedTileColor: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.08),
                  contentPadding: const EdgeInsets.fromLTRB(16, 4, 34, 4),
                  leading: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isCurrent
                          ? Theme.of(context)
                              .colorScheme
                              .primary
                              .withValues(alpha: 0.15)
                          : (isCached
                              ? Colors.green.withValues(alpha: 0.12)
                              : Colors.transparent),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      isCurrent
                          ? Icons.my_location_sharp
                          : (isCached
                              ? Icons.cloud_done
                              : Icons.cloud_download),
                      size: 18,
                      color: isCurrent
                          ? Theme.of(context).colorScheme.primary
                          : (isCached
                              ? Colors.green.shade700
                              : (isRead
                                  ? state.secondaryTextColor
                                      .withValues(alpha: 0.7)
                                  : state.secondaryTextColor)),
                    ),
                  ),
                  title: Text(
                    chapter.chapterName ?? S.of(context).chapterError,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight:
                          isCurrent ? FontWeight.bold : FontWeight.normal,
                      color: isCurrent
                          ? Theme.of(context).colorScheme.primary
                          : (isCached
                              ? state.textColor
                              : (isRead
                                  ? state.secondaryTextColor
                                  : state.textColor)),
                    ),
                  ),
                  trailing: isCurrent
                      ? Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            S.of(context).lastRead,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                      : null,
                  onTap: () {
                    if (widget.onClose != null) {
                      widget.onClose!();
                    } else {
                      Navigator.of(context).pop();
                    }
                    logic.jumpToChapter(chapter.chapterIndex!);
                  },
                ),
                if (index < chapterCount - 1)
                  Divider(
                    height: 1,
                    color: state.secondaryTextColor.withValues(alpha: 0.2),
                  ),
              ],
            );
          },
        ),
        _buildChapterScrollProgress(context, chapterCount),
      ],
    );
  }

  Widget _buildChapterScrollProgress(BuildContext context, int chapterCount) {
    if (chapterCount <= 1) return const SizedBox.shrink();

    final primaryColor = Theme.of(context).colorScheme.primary;
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _directoryListScrollController,
        builder: (context, _) {
          final progress = _getDirectoryScrollProgress();

          return LayoutBuilder(
            builder: (context, constraints) {
              final movableHeight =
                  constraints.maxHeight > _progressThumbHeight + 16
                      ? constraints.maxHeight - _progressThumbHeight - 16
                      : 0.0;
              final top = 8 + movableHeight * progress;

              void scrollByThumbDelta(double deltaDy) {
                _scrollChapterListByThumbDelta(
                  deltaDy: deltaDy,
                  trackMovableHeight: movableHeight,
                );
              }

              return Stack(
                children: [
                  Positioned(
                    top: 8,
                    bottom: 8,
                    right: 0,
                    width: 32,
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onVerticalDragUpdate: (details) =>
                          scrollByThumbDelta(details.delta.dy),
                      child: Align(
                        alignment: Alignment.center,
                        child: Container(
                          width: 2,
                          decoration: BoxDecoration(
                            color: state.secondaryTextColor
                                .withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: top,
                    right: 2,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onVerticalDragUpdate: (details) =>
                          scrollByThumbDelta(details.delta.dy),
                      child: Container(
                        height: _progressThumbHeight,
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        decoration: BoxDecoration(
                          color: state.backgroundColor.withValues(alpha: 0.96),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: primaryColor.withValues(alpha: 0.35),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.drag_indicator_rounded,
                          size: 16,
                          color: primaryColor,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  void _scrollChapterListByThumbDelta({
    required double deltaDy,
    required double trackMovableHeight,
  }) {
    if (deltaDy == 0 ||
        trackMovableHeight <= 0 ||
        !_directoryListScrollController.hasClients) {
      return;
    }

    final position = _directoryListScrollController.position;
    if (!position.hasContentDimensions) return;

    final maxScrollExtent = position.maxScrollExtent;
    if (maxScrollExtent <= 0) return;

    final nextOffset =
        (position.pixels + deltaDy / trackMovableHeight * maxScrollExtent)
            .clamp(0.0, maxScrollExtent);
    _directoryListScrollController.jumpTo(nextOffset);
  }

  double _getDirectoryScrollProgress() {
    if (!_directoryListScrollController.hasClients) return 0;

    final position = _directoryListScrollController.position;
    if (!position.hasContentDimensions) return 0;

    final maxScrollExtent = position.maxScrollExtent;
    if (maxScrollExtent <= 0) return 0;

    return (position.pixels / maxScrollExtent).clamp(0.0, 1.0);
  }

  Widget _buildAnnotationList(BuildContext context) {
    if (state.annotationList.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.highlight_alt_rounded,
              size: 44,
              color: state.secondaryTextColor.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 12),
            Text(S.of(context).noAnnotations,
                style: TextStyle(color: state.secondaryTextColor)),
          ],
        ),
      );
    }
    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: state.annotationList.length,
      separatorBuilder: (_, __) => Divider(
        height: 1,
        color: state.secondaryTextColor.withValues(alpha: 0.2),
      ),
      itemBuilder: (context, index) {
        final annotation = state.annotationList[index];
        return Dismissible(
          key: ValueKey('annotation-${annotation.id}'),
          direction: DismissDirection.endToStart,
          background: const SizedBox.shrink(),
          secondaryBackground: _buildBookmarkDismissBackground(context),
          onDismissed: (_) => logic.deleteAnnotation(annotation),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            leading: Icon(
              _annotationIcon(annotation.type),
              color: _annotationColor(context, annotation),
            ),
            title: Text(
              annotation.chapterName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: state.textColor, fontSize: 14),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (annotation.excerpt.isNotEmpty)
                  Text(
                    annotation.excerpt,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: state.secondaryTextColor,
                      fontSize: 12,
                    ),
                  ),
                if (annotation.note.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      annotation.note,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
            trailing: IconButton(
              tooltip: annotation.note.isEmpty
                  ? S.of(context).addNote
                  : S.of(context).editNote,
              icon: const Icon(Icons.edit_note_rounded),
              onPressed: () => _editAnnotation(context, annotation),
            ),
            onTap: () async {
              widget.onClose?.call();
              if (widget.onClose == null && context.mounted) {
                Navigator.of(context).pop();
              }
              await logic.jumpToAnnotation(annotation);
            },
          ),
        );
      },
    );
  }

  IconData _annotationIcon(BookAnnotationType type) => switch (type) {
        BookAnnotationType.highlight => Icons.highlight_alt_rounded,
        BookAnnotationType.underline => Icons.format_underlined_rounded,
        BookAnnotationType.note => Icons.sticky_note_2_outlined,
      };

  Color _annotationColor(BuildContext context, BookAnnotation annotation) {
    final value = annotation.colorValue;
    return value == null ? Theme.of(context).colorScheme.primary : Color(value);
  }

  Future<void> _editAnnotation(
    BuildContext context,
    BookAnnotation annotation,
  ) async {
    final note = await BookReadAnnotationEditorSheet.show(
      context,
      annotation: annotation,
    );
    if (note != null) await logic.updateAnnotation(annotation, note);
  }

  /// 书签列表
  Widget _buildBookmarkList(BuildContext context) {
    if (state.bookmarkList.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.bookmark_border,
              size: 48,
              color: state.secondaryTextColor.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 12),
            Text(
              S.of(context).noBookmarks,
              style: TextStyle(
                color: state.secondaryTextColor,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              S.of(context).bookmarkEmptyHint,
              style: TextStyle(
                color: state.secondaryTextColor.withValues(alpha: 0.6),
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: state.bookmarkList.length,
      separatorBuilder: (context, index) => Divider(
        height: 1,
        color: state.secondaryTextColor.withValues(alpha: 0.2),
      ),
      itemBuilder: (context, index) {
        final bookmark = state.bookmarkList[index];
        return Dismissible(
          key: ValueKey('bookmark-${bookmark.id}'),
          direction: DismissDirection.endToStart,
          dismissThresholds: const <DismissDirection, double>{
            DismissDirection.endToStart: 0.28,
          },
          background: const SizedBox.shrink(),
          secondaryBackground: _buildBookmarkDismissBackground(context),
          onDismissed: (_) {
            logic.deleteBookmark(bookmark);
          },
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            leading: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.bookmark,
                size: 18,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            title: Text(
              bookmark.chapterName,
              style: TextStyle(
                color: state.textColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: _buildBookmarkSubtitle(context, bookmark),
            isThreeLine: false,
            trailing: _buildBookmarkTrailing(context, bookmark),
            onTap: () {
              if (widget.onClose != null) {
                widget.onClose!();
              } else {
                Navigator.of(context).pop();
              }
              logic.jumpToBookmark(bookmark);
            },
          ),
        );
      },
    );
  }

  Widget? _buildBookmarkSubtitle(BuildContext context, db.Bookmark bookmark) {
    final hasNote = bookmark.content.isNotEmpty;
    final hasExcerpt = bookmark.bookText.isNotEmpty;
    if (!hasNote && !hasExcerpt) {
      return null;
    }

    final primaryColor = Theme.of(context).colorScheme.primary;
    if (!hasNote) {
      return Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Text(
          bookmark.bookText,
          style: TextStyle(
            color: state.secondaryTextColor,
            fontSize: 12,
            height: 1.35,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(top: 6),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: primaryColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        bookmark.content,
        style: TextStyle(
          color: primaryColor,
          fontSize: 12,
          height: 1.35,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildBookmarkTrailing(BuildContext context, db.Bookmark bookmark) {
    final hasNote = bookmark.content.isNotEmpty;
    return SizedBox(
      width: hasNote ? 78 : 40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasNote)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                S.of(context).remark,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          IconButton(
            onPressed: () => _openBookmarkEditor(context, bookmark),
            icon: Icon(
              Icons.edit_note_rounded,
              size: 20,
              color: state.secondaryTextColor,
            ),
            tooltip: hasNote ? S.of(context).editNote : S.of(context).addNote,
            splashRadius: 18,
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }

  Widget _buildBookmarkDismissBackground(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      color: const Color(0xFFE2574C),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.delete_outline_rounded,
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(width: 6),
          Text(
            S.of(context).delete,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _openBookmarkEditor(BuildContext context, db.Bookmark bookmark) {
    BookReadBookmarkEditorSheet.show(
      context,
      bookmark: bookmark,
      state: state,
      onSave: (content) {
        logic.updateBookmark(bookmark, content);
      },
    );
  }
}
