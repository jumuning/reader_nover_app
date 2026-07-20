import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reader_nover/app/service/local_book/local_book_constants.dart';

import '../controllers/book_read_ui_refresh_controller.dart';
import '../logic.dart';

class BookReadAppBar extends StatelessWidget {
  const BookReadAppBar({
    super.key,
    required this.logic,
  });

  final BookReadLogic logic;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BookReadLogic>(
      init: logic,
      global: false,
      id: BookReadUiRefreshController.chromeUpdateId,
      builder: (logic) {
        final state = logic.state;
        return AnimatedPositioned(
          top: state.isAppBarVisible ? 0 : -kToolbarHeight * 2,
          left: 0,
          right: 0,
          duration: const Duration(milliseconds: 200),
          child: Container(
            color: state.backgroundColor,
            child: SafeArea(
              bottom: false,
              child: SizedBox(
                height: kToolbarHeight,
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: state.iconColor),
                      onPressed: () {
                        unawaited(logic.exitReadPage());
                      },
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  state.bookInfo.name,
                                  style: TextStyle(
                                    color: state.iconColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: logic.toggleBookshelf,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: state.isInBookshelf
                                        ? state.iconColor
                                            .withValues(alpha: 0.15)
                                        : state.iconColor
                                            .withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        state.isInBookshelf
                                            ? Icons.library_books
                                            : Icons.library_add,
                                        size: 10,
                                        color: state.iconColor
                                            .withValues(alpha: 0.8),
                                      ),
                                      const SizedBox(width: 2),
                                      Text(
                                        state.isInBookshelf ? '已在书架' : '加入书库',
                                        style: TextStyle(
                                          color: state.iconColor
                                              .withValues(alpha: 0.8),
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            state.currentChapter,
                            style: TextStyle(
                              color: state.iconColor.withValues(alpha: 0.7),
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: logic.toggleBookmark,
                      icon: Icon(
                        state.isCurrentChapterBookmarked
                            ? Icons.bookmark_add
                            : Icons.bookmark_add_outlined,
                      ),
                      tooltip:
                          state.isCurrentChapterBookmarked ? '移除书签' : '添加书签',
                    ),
                    _BookReadCacheButton(logic: logic),
                    if (!LocalBookConstants.isLocalBookSource(
                      state.bookInfo.bookSourceId,
                    ))
                      IconButton(
                        onPressed: logic.showSourceDialog,
                        icon: Icon(Icons.swap_horiz, color: state.iconColor),
                        tooltip: '换源',
                      ),
                    IconButton(
                      onPressed: logic.reloadCurrentChapter,
                      icon: Icon(Icons.refresh, color: state.iconColor),
                      tooltip: '重新加载',
                    ),
                    if (!LocalBookConstants.isLocalBookSource(
                      state.bookInfo.bookSourceId,
                    ))
                      IconButton(
                        onPressed: logic.executePayActionAndReload,
                        icon: Icon(Icons.payment_outlined,
                            color: state.iconColor),
                        tooltip: '付费动作',
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _BookReadCacheButton extends StatelessWidget {
  const _BookReadCacheButton({required this.logic});

  final BookReadLogic logic;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BookReadLogic>(
      init: logic,
      global: false,
      builder: (logic) {
        final state = logic.state;
        final totalChapters = state.bookDetail.chapters?.length ?? 0;
        final cachedCount = state.cachedChapterIndices.length;
        final isAllCached = totalChapters > 0 && cachedCount == totalChapters;

        if (state.isCaching) {
          final percent = (state.cacheProgress * 100).toInt();
          return GestureDetector(
            onTap: logic.cancelCache,
            child: SizedBox(
              width: 48,
              height: 48,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      value: state.cacheProgress,
                      strokeWidth: 2,
                      color: state.iconColor,
                    ),
                  ),
                  Text(
                    '$percent%',
                    style: TextStyle(
                      fontSize: 8,
                      color: state.iconColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (isAllCached) {
          return IconButton(
            onPressed: () {
              Get.snackbar(
                '缓存信息',
                '已缓存 $cachedCount/$totalChapters 章',
                snackPosition: SnackPosition.BOTTOM,
                duration: const Duration(seconds: 2),
              );
            },
            icon: Icon(Icons.cloud_done, color: Colors.green.shade700),
            tooltip: '已缓存 $cachedCount 章',
          );
        }

        return GestureDetector(
          onTap: logic.cacheAllChapters,
          child: SizedBox(
            width: 48,
            height: 48,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  cachedCount > 0 ? Icons.cloud_download : Icons.download,
                  size: 20,
                  color: state.iconColor,
                ),
                Text(
                  '$cachedCount/$totalChapters',
                  style: TextStyle(
                    fontSize: 9,
                    color: state.iconColor,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
