import 'dart:collection';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:reader_nover/util/performance_log_helper.dart';

/// 分页所需的屏幕/样式配置，与 state 解耦
class PaginationConfig {
  final double screenWidth;
  final double screenHeight;
  final EdgeInsets safePadding;
  final TextScaler textScaler;
  final TextStyle contentStyle;
  final double endPadding;

  const PaginationConfig({
    required this.screenWidth,
    required this.screenHeight,
    required this.safePadding,
    required this.textScaler,
    required this.contentStyle,
    required this.endPadding,
  });
}

class PaginationCacheIdentity {
  final String bookSourceId;
  final String bookName;
  final int chapterIndex;

  const PaginationCacheIdentity({
    required this.bookSourceId,
    required this.bookName,
    required this.chapterIndex,
  });
}

class PaginationResult {
  final String cacheKey;
  final List<String> pages;
  final bool isCacheHit;

  const PaginationResult({
    required this.cacheKey,
    required this.pages,
    required this.isCacheHit,
  });
}

/// 分页服务：将章节文本按屏幕/样式分割为页列表，以及页面重定位
class PaginationService {
  static const int _maxCachedPaginationResults = 48;

  /// 与 `reader_content_spans.dart` 默认图宽高对齐，供 TextPainter 占位。
  /// 实际测量高度会再按 [availableHeight] clamp，避免小屏上「图独占一页仍溢出」。
  static const double imagePlaceholderMaxWidth = 280;
  static const double imagePlaceholderMaxHeight = 360;

  /// 与渲染侧 `EdgeInsets.symmetric(vertical: 8)` 合计一致。
  static const double imagePlaceholderVerticalPadding = 16;

  /// 完整 `<img ... src=...>`，用于测量高度占位。
  static final RegExp _imgTagPattern = RegExp(
    r'''<img\b[^>]*?\bsrc\s*=\s*["']([^"']+)["'][^>]*>''',
    caseSensitive: false,
  );

  /// 任意 `<img ...>` 开标签起点（含不完整/无 src），用于禁止页边界切断标签。
  static final RegExp _imgOpenPattern = RegExp(r'<img\b', caseSensitive: false);

  TextPainter? _painter;
  int _layoutCount = 0;
  final LinkedHashMap<String, _CachedPaginationResult> _paginationCache =
      LinkedHashMap<String, _CachedPaginationResult>();

  PaginationResult splitContentWithCache(
    String content,
    PaginationConfig config, {
    required PaginationCacheIdentity cacheIdentity,
    String chapterTitle = '',
  }) {
    final perf = PerformanceLogHelper.start(
      'reader.pagination',
      fields: <String, Object?>{
        'bookSourceId': cacheIdentity.bookSourceId,
        'bookName': cacheIdentity.bookName,
        'chapterIndex': cacheIdentity.chapterIndex,
        'contentLength': content.length,
      },
    );
    final cacheKey = buildStableCacheKey(
      cacheIdentity,
      config,
      chapterTitle: chapterTitle,
    );
    var cacheState = 'miss';
    final cached = _paginationCache.remove(cacheKey);
    if (cached != null) {
      _paginationCache[cacheKey] = cached;
      if (cached.matches(content: content, chapterTitle: chapterTitle)) {
        return perf.completeWith(
          PaginationResult(
            cacheKey: cacheKey,
            pages: List<String>.from(cached.pages),
            isCacheHit: true,
          ),
          fields: <String, Object?>{
            'cacheHit': true,
            'cacheState': 'hit',
            'pageCount': cached.pages.length,
            'cacheEntries': _paginationCache.length,
          },
        );
      }
      cacheState = 'stale';
    }

    final pages = splitContent(
      content,
      config,
      chapterTitle: chapterTitle,
    );
    _rememberPagination(
      cacheKey: cacheKey,
      content: content,
      chapterTitle: chapterTitle,
      pages: pages,
    );
    return perf.completeWith(
      PaginationResult(
        cacheKey: cacheKey,
        pages: pages,
        isCacheHit: false,
      ),
      fields: <String, Object?>{
        'cacheHit': false,
        'cacheState': cacheState,
        'pageCount': pages.length,
        'cacheEntries': _paginationCache.length,
      },
    );
  }

  String buildStableCacheKey(
    PaginationCacheIdentity cacheIdentity,
    PaginationConfig config, {
    String chapterTitle = '',
  }) {
    final bodyFontSize = config.contentStyle.fontSize ?? 0.0;
    final titleFontSize = bodyFontSize + 4.0;

    return <String>[
      _escapeKeyPart(cacheIdentity.bookSourceId),
      _escapeKeyPart(cacheIdentity.bookName),
      cacheIdentity.chapterIndex.toString(),
      _doubleToken(config.screenWidth),
      _doubleToken(config.screenHeight),
      _doubleToken(config.safePadding.left),
      _doubleToken(config.safePadding.top),
      _doubleToken(config.safePadding.right),
      _doubleToken(config.safePadding.bottom),
      _doubleToken(config.endPadding),
      _doubleToken(bodyFontSize),
      _doubleToken(config.textScaler.scale(bodyFontSize)),
      _doubleToken(config.textScaler.scale(titleFontSize)),
      _doubleToken(config.contentStyle.height ?? 0.0),
      _doubleToken(config.contentStyle.letterSpacing ?? 0.0),
      _doubleToken(config.contentStyle.wordSpacing ?? 0.0),
      _escapeKeyPart(config.contentStyle.fontFamily ?? ''),
      _escapeKeyPart(chapterTitle),
    ].join('|');
  }

  /// 将章节内容分页，返回 List<String>（每个元素为一页的文本）
  ///
  /// [chapterTitle] 非空时，首页将为标题预留空间（与 UI 渲染保持一致）
  List<String> splitContent(
    String content,
    PaginationConfig config, {
    String chapterTitle = '',
  }) {
    if (content.isEmpty) {
      return chapterTitle.trim().isEmpty
          ? const <String>[]
          : const <String>[''];
    }
    if (config.screenWidth <= 0 || config.screenHeight <= 0) return [content];

    final List<String> pages = [];
    int pageStart = 0;
    final int total = content.length;
    int pageIndex = 0;

    while (pageStart < total) {
      final String remaining = content.substring(pageStart);
      final int count = calculatePagination(
        remaining,
        isFirstPage: pageIndex == 0,
        config: config,
        chapterTitle: chapterTitle,
      );

      // Never land page boundaries inside an <img ...> tag.
      final int safeCount = _clampBreakOutsideImgTag(remaining, count);
      final int pageEnd = (pageStart + safeCount).clamp(0, total);
      String pageContent = content.substring(pageStart, pageEnd);

      if (pageEnd < total) {
        final int breakPoint =
            _findBestBreakPoint(pageContent, pageContent.length);
        if (breakPoint < pageContent.length) {
          pageContent = pageContent.substring(0, breakPoint);
        }
      }

      // Final guard: if still mid-tag (e.g. punctuation search), clamp again.
      if (pageStart + pageContent.length < total) {
        final relativeEnd = _clampBreakOutsideImgTag(
          content.substring(pageStart),
          pageContent.length,
        );
        if (relativeEnd != pageContent.length && relativeEnd > 0) {
          pageContent = content.substring(pageStart, pageStart + relativeEnd);
        }
      }

      // Avoid infinite loop if clamp collapsed to zero while content remains.
      if (pageContent.isEmpty && pageStart < total) {
        final force = _forceAdvancePastIncompleteTag(content, pageStart);
        pageContent = content.substring(pageStart, force);
      }

      pages.add(pageContent);
      pageStart += pageContent.length;
      pageIndex++;
    }

    return pages;
  }

  /// 核心分页算法：二分查找当前页能容纳的字符数
  ///
  /// [chapterTitle] 非空时，首页在正文前插入标题 span。
  int calculatePagination(
    String fullText, {
    required bool isFirstPage,
    required PaginationConfig config,
    String chapterTitle = '',
  }) {
    const double horizontalPadding = 16.0 * 2;

    final double availableWidth = (config.screenWidth -
            config.safePadding.left -
            config.safePadding.right -
            horizontalPadding)
        .clamp(0.0, double.infinity);

    final double availableHeight =
        config.screenHeight - config.safePadding.top - config.endPadding - 10;

    // 复用 TextPainter 以提高性能
    if (_painter == null || _painter!.textScaler != config.textScaler) {
      _painter?.dispose();
      _painter = TextPainter(
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.left,
        textScaler: config.textScaler,
        maxLines: null,
        strutStyle: StrutStyle(
          fontSize: config.contentStyle.fontSize,
          height: config.contentStyle.height,
          forceStrutHeight: false,
        ),
      );
    }

    final TextPainter painter = _painter!;

    final measuredHeights = <int, double>{};
    double measure(int end) => measuredHeights.putIfAbsent(
          end,
          () {
            _layoutCount++;
            return _layoutPrefixHeight(
              painter,
              fullText,
              end,
              isFirstPage: isFirstPage,
              config: config,
              chapterTitle: chapterTitle,
              availableWidth: availableWidth,
              availableHeight: availableHeight,
            );
          },
        );

    final searchBounds = _resolveSearchBounds(
      fullText,
      isFirstPage: isFirstPage,
      config: config,
      chapterTitle: chapterTitle,
      availableWidth: availableWidth,
      availableHeight: availableHeight,
      measure: measure,
    );

    int low = searchBounds.low;
    int high = searchBounds.high;
    int bestFit = searchBounds.bestFit;

    while (low <= high) {
      final int mid = (low + high) >> 1;

      if (mid == 0 && !(isFirstPage && chapterTitle.isNotEmpty)) {
        low = mid + 1;
        continue;
      }

      final double realHeight = measure(mid);

      if (realHeight <= availableHeight) {
        bestFit = mid;
        low = mid + 1;
      } else {
        high = mid - 1;
      }
    }

    // Prefer whole <img> tags: if bestFit is mid-tag, try including the full
    // tag when it still fits; otherwise drop the partial tag from this page.
    bestFit = _snapFitOutsideImgTag(
      fullText,
      bestFit,
      isFirstPage: isFirstPage,
      config: config,
      chapterTitle: chapterTitle,
      availableWidth: availableWidth,
      availableHeight: availableHeight,
      painter: painter,
      measure: measure,
    );

    if (bestFit < 1) {
      // Nothing fit: still consume a whole leading img (never split markup).
      final leading = _imgTagBoundsAt(fullText, 0);
      if (leading != null) return leading.end;
      return math.min(1, fullText.length);
    }
    return bestFit.clamp(1, fullText.length);
  }

  /// Snap [fit] so it is never strictly inside an `<img ...>` tag.
  int _snapFitOutsideImgTag(
    String fullText,
    int fit, {
    required bool isFirstPage,
    required PaginationConfig config,
    required String chapterTitle,
    required double availableWidth,
    required double availableHeight,
    required TextPainter painter,
    double Function(int end)? measure,
  }) {
    if (fit <= 0 || fit >= fullText.length) return fit;
    final bounds = _imgTagBoundsContaining(fullText, fit);
    if (bounds == null) return fit;

    final includeEnd = bounds.end;
    final includeHeight = measure?.call(includeEnd) ??
        _layoutPrefixHeight(
          painter,
          fullText,
          includeEnd,
          isFirstPage: isFirstPage,
          config: config,
          chapterTitle: chapterTitle,
          availableWidth: availableWidth,
          availableHeight: availableHeight,
        );
    // Include whole tag when height allows, or when the tag starts the page
    // (image taller than one page still must stay atomic).
    if (includeHeight <= availableHeight || bounds.start == 0) {
      return includeEnd;
    }
    return bounds.start;
  }

  /// If pagination would stall, consume at least one complete tag or char.
  int _forceAdvancePastIncompleteTag(String content, int pageStart) {
    final bounds = _imgTagBoundsAt(content, pageStart);
    if (bounds != null) return bounds.end;
    return math.min(content.length, pageStart + 1);
  }

  /// Img tag span `[start, end)` containing [index] (start < index < end).
  /// Incomplete tags (no `>`) use `text.length` as end.
  _ImgTagBounds? _imgTagBoundsContaining(String text, int index) {
    if (index <= 0 || index > text.length) return null;
    for (final match in _imgOpenPattern.allMatches(text)) {
      if (match.start >= index) break;
      final gt = text.indexOf('>', match.start);
      final end = gt < 0 ? text.length : gt + 1;
      if (index < end) {
        return _ImgTagBounds(match.start, end);
      }
    }
    return null;
  }

  /// Img tag that begins exactly at [index], if any.
  _ImgTagBounds? _imgTagBoundsAt(String text, int index) {
    if (index < 0 || index >= text.length) return null;
    final match = _imgOpenPattern.matchAsPrefix(text, index);
    if (match == null) return null;
    final gt = text.indexOf('>', match.start);
    final end = gt < 0 ? text.length : gt + 1;
    return _ImgTagBounds(match.start, end);
  }

  _PaginationSearchBounds _resolveSearchBounds(
    String fullText, {
    required bool isFirstPage,
    required PaginationConfig config,
    required String chapterTitle,
    required double availableWidth,
    required double availableHeight,
    required double Function(int end) measure,
  }) {
    int high = _estimatePageCharCapacity(
      config,
      availableWidth: availableWidth,
      availableHeight: availableHeight,
      isFirstPage: isFirstPage,
      chapterTitle: chapterTitle,
    ).clamp(1, fullText.length);

    var bestFit = 0;
    while (true) {
      final height = measure(high);
      if (height > availableHeight) {
        break;
      }

      bestFit = high;
      if (high >= fullText.length) {
        return _PaginationSearchBounds(
          low: fullText.length + 1,
          high: fullText.length,
          bestFit: fullText.length,
        );
      }

      final nextHigh = math.min(
        fullText.length,
        math.max(high + 1, high * 2),
      );
      if (nextHigh == high) break;
      high = nextHigh;
    }

    return _PaginationSearchBounds(
      low: bestFit + 1,
      high: high - 1,
      bestFit: bestFit,
    );
  }

  @visibleForTesting
  int get layoutCount => _layoutCount;

  int _estimatePageCharCapacity(
    PaginationConfig config, {
    required double availableWidth,
    required double availableHeight,
    required bool isFirstPage,
    required String chapterTitle,
  }) {
    final bodyFontSize = config.contentStyle.fontSize ?? 16.0;
    final scaledBodyFontSize = config.textScaler.scale(bodyFontSize);
    final lineHeight = math.max(
      1.0,
      scaledBodyFontSize * (config.contentStyle.height ?? 1.0),
    );

    var bodyHeight = availableHeight;
    if (isFirstPage && chapterTitle.isNotEmpty) {
      final titleFontSize = config.textScaler.scale(bodyFontSize + 4.0);
      bodyHeight -= titleFontSize * 1.4 * 2;
    }

    final maxLines = math.max(1, (bodyHeight / lineHeight).floor());
    final letterSpacing = config.contentStyle.letterSpacing ?? 0.0;
    final averageCharacterWidth =
        math.max(4.0, scaledBodyFontSize + letterSpacing);
    final charsPerLine =
        math.max(1, (availableWidth / averageCharacterWidth).floor());

    return (maxLines * charsPerLine * 1.35).ceil();
  }

  double _layoutPrefixHeight(
    TextPainter painter,
    String fullText,
    int end, {
    required bool isFirstPage,
    required PaginationConfig config,
    required String chapterTitle,
    required double availableWidth,
    required double availableHeight,
  }) {
    final spans = _buildMeasurementSpans(
      fullText,
      end,
      isFirstPage: isFirstPage,
      config: config,
      chapterTitle: chapterTitle,
      availableWidth: availableWidth,
      availableHeight: availableHeight,
    );
    final placeholders = _placeholderDimensionsFor(spans);
    painter.text = TextSpan(children: spans);
    if (placeholders.isNotEmpty) {
      painter.setPlaceholderDimensions(placeholders);
    }
    painter.layout(maxWidth: availableWidth);
    return painter.height;
  }

  List<InlineSpan> _buildMeasurementSpans(
    String fullText,
    int end, {
    required bool isFirstPage,
    required PaginationConfig config,
    required String chapterTitle,
    required double availableWidth,
    required double availableHeight,
  }) {
    final spans = <InlineSpan>[];
    final titleReserve = _titleReserveHeight(
      isFirstPage: isFirstPage,
      config: config,
      chapterTitle: chapterTitle,
    );

    // 首页添加标题（样式与 book_read_context_sheet.dart 完全一致）
    if (isFirstPage && chapterTitle.isNotEmpty) {
      spans.add(
        TextSpan(
          text: '$chapterTitle\n\n',
          style: config.contentStyle.copyWith(
            fontSize: (config.contentStyle.fontSize ?? 16.0) + 4,
            fontWeight: FontWeight.bold,
            height: 1.4,
            letterSpacing: 1.0,
          ),
        ),
      );
    }

    if (end > 0) {
      final slice = fullText.substring(0, end);
      spans.addAll(
        _contentMeasurementSpans(
          slice,
          style: config.contentStyle,
          availableWidth: availableWidth,
          availableHeight: availableHeight,
          titleReserve: titleReserve,
        ),
      );
    }

    return spans;
  }

  /// 首页标题预留高度（与 [_estimatePageCharCapacity] 一致）。
  double _titleReserveHeight({
    required bool isFirstPage,
    required PaginationConfig config,
    required String chapterTitle,
  }) {
    if (!isFirstPage || chapterTitle.isEmpty) return 0;
    final bodyFontSize = config.contentStyle.fontSize ?? 16.0;
    final titleFontSize = config.textScaler.scale(bodyFontSize + 4.0);
    return titleFontSize * 1.4 * 2;
  }

  /// 图占位/渲染高度：默认 [imagePlaceholderMaxHeight]，但不超过可用页高。
  ///
  /// `imageHeight = min(max, max(1, availableHeight - titleReserve - padding))`
  ///
  /// 渲染侧与测量侧共用，避免分页测量高度与 `buildReaderContentSpans` 不一致。
  static double clampedImageHeight({
    required double availableHeight,
    double titleReserve = 0,
  }) {
    final room =
        availableHeight - titleReserve - imagePlaceholderVerticalPadding;
    return math.min(
      imagePlaceholderMaxHeight,
      math.max(1.0, room),
    );
  }

  double _clampedImagePlaceholderHeight({
    required double availableHeight,
    required double titleReserve,
  }) {
    return clampedImageHeight(
      availableHeight: availableHeight,
      titleReserve: titleReserve,
    );
  }

  /// 测量用 span：把 `<img>` 换成高度占位 WidgetSpan，避免当短文本低估高度。
  /// 高度相对 [availableHeight] clamp，与渲染侧 maxImageHeight 语义对齐。
  List<InlineSpan> _contentMeasurementSpans(
    String text, {
    required TextStyle style,
    required double availableWidth,
    required double availableHeight,
    required double titleReserve,
  }) {
    if (!_imgTagPattern.hasMatch(text)) {
      return <InlineSpan>[TextSpan(text: text, style: style)];
    }

    final imageHeight = _clampedImagePlaceholderHeight(
      availableHeight: availableHeight,
      titleReserve: titleReserve,
    );
    final spans = <InlineSpan>[];
    var cursor = 0;
    for (final match in _imgTagPattern.allMatches(text)) {
      if (match.start > cursor) {
        final chunk = text.substring(cursor, match.start);
        if (chunk.isNotEmpty) {
          spans.add(TextSpan(text: chunk, style: style));
        }
      }
      final imageWidth =
          math.min(imagePlaceholderMaxWidth, math.max(1.0, availableWidth));
      spans.add(const TextSpan(text: '\n'));
      spans.add(
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: SizedBox(
            width: imageWidth,
            height: imageHeight + imagePlaceholderVerticalPadding,
          ),
        ),
      );
      spans.add(const TextSpan(text: '\n'));
      cursor = match.end;
    }
    if (cursor < text.length) {
      final chunk = text.substring(cursor);
      if (chunk.isNotEmpty) {
        spans.add(TextSpan(text: chunk, style: style));
      }
    }
    return spans.isEmpty
        ? <InlineSpan>[TextSpan(text: text, style: style)]
        : spans;
  }

  List<PlaceholderDimensions> _placeholderDimensionsFor(
    List<InlineSpan> spans,
  ) {
    final dims = <PlaceholderDimensions>[];
    void walk(InlineSpan span) {
      if (span is WidgetSpan) {
        final child = span.child;
        // 优先读 SizedBox（已含 availableHeight clamp）；无尺寸时用默认上限。
        var width = imagePlaceholderMaxWidth;
        var height =
            imagePlaceholderMaxHeight + imagePlaceholderVerticalPadding;
        if (child is SizedBox) {
          width = child.width ?? width;
          height = child.height ?? height;
        }
        dims.add(
          PlaceholderDimensions(
            size: Size(width, height),
            alignment: span.alignment,
            baseline: span.baseline,
          ),
        );
      } else if (span is TextSpan && span.children != null) {
        for (final child in span.children!) {
          walk(child);
        }
      }
    }

    for (final span in spans) {
      walk(span);
    }
    return dims;
  }

  /// 根据锚点文本在新页列表中定位对应页索引
  ///
  /// 返回找到的页索引，未找到时返回 0。
  int relocatePage(List<String> pages, String anchorText) {
    if (pages.isEmpty || anchorText.isEmpty) return 0;

    final prevAnchor = _buildAnchor(anchorText);
    final normAnchor = _normalizeText(prevAnchor);

    for (int i = 0; i < pages.length; i++) {
      if (_normalizeText(pages[i]).contains(normAnchor)) {
        return i;
      }
    }

    return 0;
  }

  void dispose() {
    _painter?.dispose();
    _painter = null;
    _paginationCache.clear();
  }

  // ---- 纯函数 ----

  /// 在文本内找到最佳断点（优先在句末标点处断开）
  int _findBestBreakPoint(String text, int maxChars) {
    if (maxChars <= 0) {
      final leading = _imgTagBoundsAt(text, 0);
      return leading?.end ?? 1;
    }
    // Even when maxChars == text.length, clamp if the slice ends mid-tag
    // (caller may have truncated fullText mid-img).
    maxChars = _clampBreakOutsideImgTag(text, maxChars.clamp(0, text.length));
    if (maxChars <= 0) {
      final leading = _imgTagBoundsAt(text, 0);
      return leading?.end ?? 1;
    }
    if (maxChars >= text.length) {
      // Slice ends with an unclosed <img: drop it unless the whole page is the tag.
      _ImgTagBounds? lastOpen;
      for (final match in _imgOpenPattern.allMatches(text)) {
        final gt = text.indexOf('>', match.start);
        if (gt < 0) {
          lastOpen = _ImgTagBounds(match.start, text.length);
        }
      }
      if (lastOpen != null) {
        return lastOpen.start > 0 ? lastOpen.start : text.length;
      }
      return text.length;
    }

    // 搜索范围：从 maxChars 往前找，最多回退 15%
    final int searchStart = (maxChars * 0.85).round();
    final int searchEnd = maxChars;

    // 优先级：句号 > 问号/感叹号 > 逗号/分号 > 其他标点
    const sentenceEndPunctuation = '。！？"\'';
    const midPunctuation = '，；：、,;:';
    const closingPunctuation = '"\'）】》)]}>';

    final punctuationGroups = [
      sentenceEndPunctuation,
      midPunctuation,
      closingPunctuation,
    ];

    for (final punctuation in punctuationGroups) {
      for (int i = searchEnd - 1; i >= searchStart; i--) {
        if (punctuation.contains(text[i]) && !_indexInsideImgTag(text, i)) {
          return i + 1;
        }
      }
    }

    return maxChars;
  }

  /// Move [index] outside any `<img ...>` so page boundaries never split markup.
  ///
  /// Prefer retreating to tag start (image goes to next page). If the tag
  /// starts at 0, advance to tag end so the whole tag stays on this page.
  int _clampBreakOutsideImgTag(String text, int index) {
    if (index <= 0) return index;
    if (index > text.length) index = text.length;
    final bounds = _imgTagBoundsContaining(text, index);
    if (bounds == null) return index;
    if (bounds.start > 0) return bounds.start;
    return bounds.end;
  }

  bool _indexInsideImgTag(String text, int index) {
    return _imgTagBoundsContaining(text, index) != null;
  }

  String _normalizeText(String s) {
    return s.replaceAll(RegExp(r'\s+'), '').replaceAll('\u3000', '');
  }

  String _buildAnchor(String s) {
    final String n = _normalizeText(s);
    const int maxLen = 30;
    return n.length > maxLen ? n.substring(0, maxLen) : n;
  }

  void _rememberPagination({
    required String cacheKey,
    required String content,
    required String chapterTitle,
    required List<String> pages,
  }) {
    if (_paginationCache.length >= _maxCachedPaginationResults) {
      _paginationCache.remove(_paginationCache.keys.first);
    }
    _paginationCache[cacheKey] = _CachedPaginationResult(
      content: content,
      chapterTitle: chapterTitle,
      pages: List<String>.unmodifiable(pages),
    );
  }

  String _doubleToken(double value) => value.toStringAsFixed(4);

  String _escapeKeyPart(String value) => Uri.encodeComponent(value);
}

class _ImgTagBounds {
  final int start;
  final int end;

  const _ImgTagBounds(this.start, this.end);
}

class _PaginationSearchBounds {
  final int low;
  final int high;
  final int bestFit;

  const _PaginationSearchBounds({
    required this.low,
    required this.high,
    required this.bestFit,
  });
}

class _CachedPaginationResult {
  final String content;
  final String chapterTitle;
  final List<String> pages;

  const _CachedPaginationResult({
    required this.content,
    required this.chapterTitle,
    required this.pages,
  });

  bool matches({
    required String content,
    required String chapterTitle,
  }) {
    return this.content == content && this.chapterTitle == chapterTitle;
  }
}
