import 'package:flutter/material.dart';
import 'package:reader_nover/app/routes/route_args.dart';
import 'package:reader_nover/util/book_help.dart';
import 'package:reader_nover/util/color_utils.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../app/database/drift/app_database.dart' as db;
import '../../app/database/models/models.dart';
import '../../app/service/local_book/local_book_constants.dart';

class BookDetailState {
  late BookInfo bookInfo;
  late List<BookChapterInfo> chapterInfo; // 章节信息
  late List<BookChapterInfo> displayedChapters; // 当前显示的章节
  late db.BookSource? bookSource;
  late BookDetail bookDetail;
  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();

  late int chapterPageSize = 30; // 每页显示的章节数
  late bool isInBookshelf = false; // 是否加入书架
  late bool isAscending = true; // 排序状态，true = 正序（第一章 -> 最后一章）
  bool isHasMore = true; // 是否还有更多数据
  int? currentReadChapterIndex; // 当前阅读章节索引（原始索引）
  int currentReadPageIndex = 0; // 当前阅读页码

  // 章节列表加载状态
  bool isChapterLoading = false;
  bool isChapterLoaded = false;
  bool isChapterLoadError = false;

  // 底部按钮操作中
  bool isBottomBarBusy = false;

  /// 已阅读章节索引集合
  Set<int> readChapterIndices = {};

  /// 已缓存章节索引集合
  Set<int> cachedChapterIndices = {};

  /// 根据封面图片计算的文字颜色（用于在模糊背景上显示）
  Color coverTextColor = Colors.black87;
  Color coverSecondaryTextColor = Colors.black54;

  /// 目录列表的文字颜色（根据主题动态计算）
  Color chapterListTextColor = Colors.black87;
  Color chapterListSecondaryTextColor = Colors.black54;
  Color chapterListIconColor = Colors.black87;

  /// 简介展开状态
  bool isIntroExpanded = false;

  Color? _lastChapterListBg;

  bool get isLocalBook =>
      LocalBookConstants.isLocalBookSource(bookInfo.bookSourceId);

  /// 根据主题背景色更新目录列表文字颜色（相同背景色时跳过计算）
  void updateChapterListColors(Color backgroundColor) {
    if (_lastChapterListBg == backgroundColor) return;
    _lastChapterListBg = backgroundColor;
    chapterListTextColor = ColorUtils.getContrastTextColor(backgroundColor);
    chapterListSecondaryTextColor =
        ColorUtils.getContrastSecondaryTextColor(backgroundColor);
    chapterListIconColor = chapterListTextColor;
  }

  BookDetailState({required BookDetailArgs args}) {
    bookInfo = args.bookInfo;
    bookSource = null; // 初始化为 null，后续异步加载
    // 使用 bookInfo 的数据初始化 bookDetail，这样在加载完成前也能显示搜索结果的信息
    bookDetail = BookDetail(
      bookSourceId: bookInfo.bookSourceId,
      name: bookInfo.name,
      author: bookInfo.author,
      cover: bookInfo.cover,
      intro: BookHelp.formatIntro(bookInfo.intro),
      kind: _splitKind(bookInfo.kind),
      lastChapter: bookInfo.lastChapter ?? '',
      wordCount: bookInfo.wordCount,
      bookUrl: bookInfo.bookUrl,
      tocUrl: bookInfo.tocUrl,
    );
    isAscending = bookDetail.isAscending;
    chapterInfo = [];
    displayedChapters = [];
  }
}

List<String> _splitKind(String? raw) {
  final value = raw?.trim();
  if (value == null || value.isEmpty) return const <String>[];
  return value
      .split(RegExp(r'[,，、/|;\n\r\t]+'))
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty)
      .toList();
}
