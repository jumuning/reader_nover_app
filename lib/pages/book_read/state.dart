import 'dart:collection';

import 'package:flutter/material.dart';
import '../../app/service/annotation/book_annotation.dart';
import 'package:reader_nover/app/constants/default_setting.dart';
import 'package:reader_nover/app/routes/route_args.dart';
import 'package:reader_nover/app/service/book/models/source_book_info.dart';
import 'package:reader_nover/app/service/tts/tts_service.dart';
import 'package:reader_nover/pages/book_read/models/tts_playback_cursor.dart';
import 'package:reader_nover/pages/book_read/models/tts_read_ahead_buffer.dart';
import 'package:reader_nover/util/color_utils.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import '../../app/database/drift/app_database.dart' as db;
import '../../app/database/models/models.dart';
import '../../util/paper/paper_point_ireader.dart';
import 'page_turn/two_page_spread_strategy.dart';

/// 垂直滚动模式的章节数据
class VerticalChapterData {
  final int chapterIndex;
  final String chapterName;
  final String content;
  final GlobalKey key;

  VerticalChapterData({
    required this.chapterIndex,
    required this.chapterName,
    required this.content,
  }) : key = GlobalKey();
}

/// 章节缓存结构
class ChapterCache {
  final String chapterName;
  final String chapterUrl;
  final int chapterIndex;
  final String content;
  final List<String> pages;
  final String paginationCacheKey;

  ChapterCache({
    required this.chapterName,
    required this.chapterUrl,
    required this.chapterIndex,
    required this.content,
    required this.pages,
    required this.paginationCacheKey,
  });

  /// 是否是最后一页
  bool isLastIndex(int pageIndex) => pageIndex >= pages.length - 1;

  /// 获取最后一页
  String? get lastPage => pages.isNotEmpty ? pages.last : null;

  /// 获取最后一页索引
  int get lastPageIndex => pages.isNotEmpty ? pages.length - 1 : 0;

  /// 获取指定页面
  String? getPage(int index) {
    if (index >= 0 && index < pages.length) {
      return pages[index];
    }
    return null;
  }

  /// 页面数量
  int get pageSize => pages.length;
}

abstract class BookReadPageTurnStateSource {
  bool get isAnimating;
  bool get isNext;
  int? get targetPage;
}

@immutable
class BookReadPageTurnStateSnapshot implements BookReadPageTurnStateSource {
  const BookReadPageTurnStateSnapshot({
    required this.isAnimating,
    required this.isNext,
    required this.targetPage,
  });

  factory BookReadPageTurnStateSnapshot.fromState(
    BookReadPageTurnStateSource source,
  ) {
    return BookReadPageTurnStateSnapshot(
      isAnimating: source.isAnimating,
      isNext: source.isNext,
      targetPage: source.targetPage,
    );
  }

  @override
  final bool isAnimating;

  @override
  final bool isNext;

  @override
  final int? targetPage;

  @override
  bool operator ==(Object other) {
    return other is BookReadPageTurnStateSnapshot &&
        other.isAnimating == isAnimating &&
        other.isNext == isNext &&
        other.targetPage == targetPage;
  }

  @override
  int get hashCode => Object.hash(isAnimating, isNext, targetPage);
}

abstract class BookReadHighlightStateSource {
  bool get isTtsPlaying;
  bool get isTtsPaused;
  int get currentPage;
  int get currentChapterIndex;
  String? get ttsCurrentSentence;
  int? get ttsHighlightStart;
  int? get ttsHighlightEnd;
  int? get ttsHighlightPageIndex;
  int? get ttsHighlightChapterIndex;
  int? get paragraphPreviewStartInPage;
  int? get paragraphPreviewEndInPage;
  int? get paragraphPreviewPageIndex;
  int? get paragraphPreviewStartInChapter;
  int? get paragraphPreviewEndInChapter;
  int? get paragraphPreviewChapterIndex;
  TtsPlaybackCursor? get ttsPlaybackCursor;
}

@immutable
class BookReadTextHighlightStateSnapshot
    implements BookReadHighlightStateSource {
  const BookReadTextHighlightStateSnapshot({
    required this.isTtsPlaying,
    required this.isTtsPaused,
    required this.currentPage,
    required this.currentChapterIndex,
    required this.ttsCurrentSentence,
    required this.ttsHighlightStart,
    required this.ttsHighlightEnd,
    required this.ttsHighlightPageIndex,
    required this.ttsHighlightChapterIndex,
    required this.paragraphPreviewStartInPage,
    required this.paragraphPreviewEndInPage,
    required this.paragraphPreviewPageIndex,
    required this.paragraphPreviewStartInChapter,
    required this.paragraphPreviewEndInChapter,
    required this.paragraphPreviewChapterIndex,
    required this.ttsPlaybackCursor,
  });

  factory BookReadTextHighlightStateSnapshot.fromState(
    BookReadHighlightStateSource source,
  ) {
    return BookReadTextHighlightStateSnapshot(
      isTtsPlaying: source.isTtsPlaying,
      isTtsPaused: source.isTtsPaused,
      currentPage: source.currentPage,
      currentChapterIndex: source.currentChapterIndex,
      ttsCurrentSentence: source.ttsCurrentSentence,
      ttsHighlightStart: source.ttsHighlightStart,
      ttsHighlightEnd: source.ttsHighlightEnd,
      ttsHighlightPageIndex: source.ttsHighlightPageIndex,
      ttsHighlightChapterIndex: source.ttsHighlightChapterIndex,
      paragraphPreviewStartInPage: source.paragraphPreviewStartInPage,
      paragraphPreviewEndInPage: source.paragraphPreviewEndInPage,
      paragraphPreviewPageIndex: source.paragraphPreviewPageIndex,
      paragraphPreviewStartInChapter: source.paragraphPreviewStartInChapter,
      paragraphPreviewEndInChapter: source.paragraphPreviewEndInChapter,
      paragraphPreviewChapterIndex: source.paragraphPreviewChapterIndex,
      ttsPlaybackCursor: source.ttsPlaybackCursor,
    );
  }

  @override
  final bool isTtsPlaying;

  @override
  final bool isTtsPaused;

  @override
  final int currentPage;

  @override
  final int currentChapterIndex;

  @override
  final String? ttsCurrentSentence;

  @override
  final int? ttsHighlightStart;

  @override
  final int? ttsHighlightEnd;

  @override
  final int? ttsHighlightPageIndex;

  @override
  final int? ttsHighlightChapterIndex;

  @override
  final int? paragraphPreviewStartInPage;

  @override
  final int? paragraphPreviewEndInPage;

  @override
  final int? paragraphPreviewPageIndex;

  @override
  final int? paragraphPreviewStartInChapter;

  @override
  final int? paragraphPreviewEndInChapter;

  @override
  final int? paragraphPreviewChapterIndex;

  @override
  final TtsPlaybackCursor? ttsPlaybackCursor;

  @override
  bool operator ==(Object other) {
    return other is BookReadTextHighlightStateSnapshot &&
        other.isTtsPlaying == isTtsPlaying &&
        other.isTtsPaused == isTtsPaused &&
        other.currentPage == currentPage &&
        other.currentChapterIndex == currentChapterIndex &&
        other.ttsCurrentSentence == ttsCurrentSentence &&
        other.ttsHighlightStart == ttsHighlightStart &&
        other.ttsHighlightEnd == ttsHighlightEnd &&
        other.ttsHighlightPageIndex == ttsHighlightPageIndex &&
        other.ttsHighlightChapterIndex == ttsHighlightChapterIndex &&
        other.paragraphPreviewStartInPage == paragraphPreviewStartInPage &&
        other.paragraphPreviewEndInPage == paragraphPreviewEndInPage &&
        other.paragraphPreviewPageIndex == paragraphPreviewPageIndex &&
        other.paragraphPreviewStartInChapter ==
            paragraphPreviewStartInChapter &&
        other.paragraphPreviewEndInChapter == paragraphPreviewEndInChapter &&
        other.paragraphPreviewChapterIndex == paragraphPreviewChapterIndex &&
        _samePlaybackCursor(other.ttsPlaybackCursor, ttsPlaybackCursor);
  }

  @override
  int get hashCode => Object.hash(
        isTtsPlaying,
        isTtsPaused,
        currentPage,
        currentChapterIndex,
        ttsCurrentSentence,
        ttsHighlightStart,
        ttsHighlightEnd,
        ttsHighlightPageIndex,
        ttsHighlightChapterIndex,
        paragraphPreviewStartInPage,
        paragraphPreviewEndInPage,
        paragraphPreviewPageIndex,
        paragraphPreviewStartInChapter,
        paragraphPreviewEndInChapter,
        paragraphPreviewChapterIndex,
        _playbackCursorHash(ttsPlaybackCursor),
      );

  static bool _samePlaybackCursor(
    TtsPlaybackCursor? previous,
    TtsPlaybackCursor? current,
  ) {
    if (identical(previous, current)) return true;
    if (previous == null || current == null) return false;
    return previous.chapterIndex == current.chapterIndex &&
        previous.pageIndex == current.pageIndex &&
        previous.sentenceIndex == current.sentenceIndex &&
        previous.sentenceStartInPage == current.sentenceStartInPage &&
        previous.sentenceEndInPage == current.sentenceEndInPage &&
        previous.sentenceStartInChapter == current.sentenceStartInChapter &&
        previous.sentenceEndInChapter == current.sentenceEndInChapter;
  }

  static int _playbackCursorHash(TtsPlaybackCursor? cursor) {
    if (cursor == null) return 0;
    return Object.hash(
      cursor.chapterIndex,
      cursor.pageIndex,
      cursor.sentenceIndex,
      cursor.sentenceStartInPage,
      cursor.sentenceEndInPage,
      cursor.sentenceStartInChapter,
      cursor.sentenceEndInChapter,
    );
  }
}

class BookReadState
    implements BookReadHighlightStateSource, BookReadPageTurnStateSource {
  late BookDetail bookDetail;
  late BookInfo bookInfo;
  late String currentChapter;
  late String currentChapterUrl;
  @override
  late int currentChapterIndex;
  late BookContentInfo bookContentInfo;

  /// 是否正在加载初始数据
  bool isInitialLoading = true;

  /// 初次进入阅读页时的加载错误。为空表示没有错误。
  String? initialLoadErrorMessage;

  /// 目录列表控制器
  final ItemScrollController directoryScrollController = ItemScrollController();
  final ItemPositionsListener directoryPositionsListener =
      ItemPositionsListener.create();

  /// 垂直滚动模式控制器
  final ScrollController verticalScrollController = ScrollController();

  /// 垂直滚动模式：当前滚动位置对应的阅读进度 (0.0 - 1.0)
  double verticalScrollProgress = 0.0;

  /// 垂直滚动模式：已加载的章节内容列表（支持多章节连续显示）
  List<VerticalChapterData> verticalChapters = [];

  /// 垂直滚动模式：当前可见的章节索引
  int verticalVisibleChapterIndex = 0;

  /// 是否正在执行翻页动画
  @override
  bool isAnimating = false;

  /// 拖动开始位置
  double startDrag = 0.0;

  /// 拖动总量
  double totalDrag = 0.0;

  /// 小说内容
  String bookContent = '';

  /// 是否显示 AppBar
  bool isAppBarVisible = false;

  /// textPainter
  late TextPainter textPainter;

  /// 对内容分页
  int pageSize = 1;

  /// 当前页
  @override
  int currentPage = 0;

  /// 初始页码（从阅读进度恢复）
  int initialPageIndex = 0;

  /// 翻页动画时显示的目标页（下一页或上一页的索引）
  @override
  int? targetPage;

  ///文本类容页
  List<String> bookContentList = [];

  /// 文本最后一章类容数据
  String lastBookContent = '';

  /// 当前屏幕 宽度
  double screenWidth = 0;

  /// 当前屏幕 高度
  double screenHeight = 0;

  /// 屏幕安全区域
  EdgeInsets safePadding = EdgeInsets.zero;

  /// 文本缩放器
  TextScaler textScaler = TextScaler.noScaling;

  /// 小说字体配置
  late TextStyle contentStyle;

  /// 当前屏幕方向（用于避免重复重新分页）
  Orientation? currentOrientation;

  /// 是否修改了字体大小
  bool isFontSizeChanged = false;

  /// 是否开启护眼模式
  bool isEyeProtectionMode = false;

  /// 是否开启自动阅读模式
  bool isAutoReading = false;

  /// 是否启用 TTS
  bool isTtsEnabled = true;
  @override
  bool isTtsPlaying = false;
  @override
  bool isTtsPaused = false;
  bool isTtsLongPressStopping = false;
  bool isTtsLoadingVoices = false;
  double ttsRate = DefaultSetting.defaultTtsRate;
  double ttsPitch = DefaultSetting.defaultTtsPitch;
  double ttsVolume = DefaultSetting.defaultTtsVolume;
  String? ttsVoiceName;
  bool ttsAutoNextPage = DefaultSetting.defaultTtsAutoNextPage;
  bool ttsAutoNextChapter = DefaultSetting.defaultTtsAutoNextChapter;
  bool ttsResumeAfterInterrupt = DefaultSetting.defaultTtsResumeAfterInterrupt;
  List<String> currentPageSentences = [];
  int ttsSentenceIndex = 0;
  @override
  String? ttsCurrentSentence;
  @override
  int? ttsHighlightStart;
  @override
  int? ttsHighlightEnd;
  @override
  int? ttsHighlightPageIndex;
  @override
  int? ttsHighlightChapterIndex;
  @override
  int? paragraphPreviewStartInPage;
  @override
  int? paragraphPreviewEndInPage;
  @override
  int? paragraphPreviewPageIndex;
  @override
  int? paragraphPreviewStartInChapter;
  @override
  int? paragraphPreviewEndInChapter;
  @override
  int? paragraphPreviewChapterIndex;
  List<TtsVoiceOption> ttsVoices = const <TtsVoiceOption>[];
  @override
  TtsPlaybackCursor? ttsPlaybackCursor;
  TtsReadAheadBuffer? ttsReadAheadBuffer;
  bool isTtsPreparingNext = false;
  bool isTtsProgressReliable = true;
  bool isTtsTransitioningChapter = false;
  String? ttsTransitionMessage;

  /// 每页最多多少字
  int pageCharCount = -1;

  /// 目录排序状态，true = 正序（第一章 -> 最后一章），false = 倒序（最后一章 -> 第一章）
  late bool isAscending = true;

  List<BookChapterInfo> get directoryChapters {
    final chapters = bookDetail.chapters ?? const <BookChapterInfo>[];
    if (isAscending) {
      return chapters;
    }
    return chapters.reversed.toList(growable: false);
  }

  /// 是否加入书架
  bool isInBookshelf = false;

  /// 初始亮度
  double brightness = 0.8;

  // 初始字体大小
  double fontSize = 16.0;

  // 字体名称
  String? fontFamily;

  // 初始背景颜色
  Color backgroundColor = const Color(0xFFF8F9E8);

  /// 根据背景颜色计算的文字颜色
  Color textColor = Colors.black87;
  Color secondaryTextColor = Colors.black54;
  Color iconColor = Colors.black87;

  // 初始翻页方式
  String pageTurnType = '仿真';

  bool get isTwoPageMode => TwoPageSpreadStrategy.isEnabled(
        viewportWidth: screenWidth,
        isVerticalMode: pageTurnType == DefaultSetting.pageTurnTypeVertical,
      );
  double pageTurnSpeed = 1.2;

  // 行间距，初始值 1.2
  double lineSpacing = 1.2;

  // 字体间距，初始值 0.5
  double letterSpacing = 0.5;

  // 底部页码行高
  double endPadding = 24.0;

  // 是否上，下一章
  @override
  bool isNext = true;

  late ValueNotifier<PaperPointIReader> paperPoint;
  late ValueNotifier<double> slideOffsetX;

  /// 已阅读章节索引集合
  Set<int> readChapterIndices = {};

  /// 已缓存章节索引集合
  Set<int> cachedChapterIndices = {};

  /// 换源相关状态
  List<SourceBookInfo> availableSources = [];
  bool isSearchingSources = false;
  String? currentSourceName;

  /// 跨章节翻页预览内容
  String? crossChapterContent;
  String? crossChapterName;
  int? crossChapterIndex;
  String? crossChapterUrl;
  bool isCrossChapterTransition = false;
  bool isCrossChapterTransitionSlow = false;
  bool isCrossChapterTransitionFailed = false;
  String? crossChapterStatusMessage;

  // ==================== 三章缓存机制 ====================
  /// 上一章缓存
  ChapterCache? prevChapterCache;

  /// 当前章缓存
  ChapterCache? curChapterCache;

  /// 下一章缓存
  ChapterCache? nextChapterCache;

  /// 会话级章节缓存，避免重复读取正文与重复分页。
  final LinkedHashMap<int, ChapterCache> sessionChapterCache =
      LinkedHashMap<int, ChapterCache>();

  /// 会话级章节缓存容量
  int maxSessionChapterCacheCount = 8;

  /// 是否正在预加载上一章
  bool isPreloadingPrev = false;

  /// 是否正在预加载下一章
  bool isPreloadingNext = false;

  // ==================== 章节缓存下载状态 ====================
  /// 是否正在缓存
  bool isCaching = false;

  /// 缓存进度 (0.0 - 1.0)
  double cacheProgress = 0.0;

  /// 已缓存章节数
  int cachedChapterCount = 0;

  /// 总需缓存章节数
  int totalCacheChapterCount = 0;

  /// 缓存取消标志
  bool isCacheCancelled = false;

  /// 当前章节是否已添加书签
  bool isCurrentChapterBookmarked = false;

  /// 当前书的书签列表
  List<db.Bookmark> bookmarkList = [];

  /// 当前书的高亮、下划线和笔记
  List<BookAnnotation> annotationList = [];

  /// 更新文字颜色（根据背景颜色计算）
  void updateTextColors() {
    textColor = ColorUtils.getContrastTextColor(backgroundColor);
    secondaryTextColor =
        ColorUtils.getContrastSecondaryTextColor(backgroundColor);
    iconColor = textColor;
  }

  BookReadState({required BookReadArgs args}) {
    // 提前初始化字体样式，避免 late 初始化错误
    contentStyle = const TextStyle(
        fontSize: DefaultSetting.defaultBookReadSettingFontSize,
        height: DefaultSetting.defaultBookReadSettingFontHeight,
        wordSpacing: DefaultSetting.defaultBookReadSettingWordSpacing,
        letterSpacing: DefaultSetting.defaultBookReadSettingLetterSpacing,
        color: Colors.black);

    // 延迟获取屏幕尺寸，避免阻塞路由跳转
    // 屏幕尺寸将在 logic.onInit 中初始化
    screenWidth = 0;
    screenHeight = 0;

    bookInfo = args.bookInfo;
    currentChapter = args.chapterName;
    currentChapterUrl = args.chapterUrl;
    currentChapterIndex = args.chapterIndex;
    initialPageIndex = args.pageIndex;
    bookDetail = args.bookDetail;
    isAscending = bookDetail.isAscending;
  }

  /// 初始化屏幕尺寸（在 logic.onInit 中调用）
  void initScreenSize(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenSize = mediaQuery.size;
    screenWidth = screenSize.width;
    screenHeight = screenSize.height;
    safePadding = mediaQuery.padding;
    textScaler = mediaQuery.textScaler;
    currentOrientation = mediaQuery.orientation;

    // 初始化 paperPoint
    paperPoint =
        ValueNotifier(PaperPointIReader.empty(Size(screenWidth, screenHeight)));
    slideOffsetX = ValueNotifier<double>(0.0);
  }
}
