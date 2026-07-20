import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:reader_nover/pages/book_read/models/tts_highlight_descriptor.dart';
import 'package:reader_nover/pages/book_read/page_turn/pagination_service.dart';
import 'package:reader_nover/pages/book_read/utils/reader_content_spans.dart';
import 'package:reader_nover/app/service/annotation/book_annotation.dart';
import 'package:reader_nover/app/service/annotation/reader_annotation_range.dart';

class TtsPlaybackRichText extends StatefulWidget {
  const TtsPlaybackRichText({
    super.key,
    required this.content,
    required this.baseStyle,
    required this.textColor,
    required this.backgroundColor,
    required this.textScaler,
    this.descriptor,
    this.leadingSpans = const <InlineSpan>[],
    this.textAlign = TextAlign.left,
    this.strutStyle,
    this.maxImageWidth = PaginationService.imagePlaceholderMaxWidth,
    this.maxImageHeight = PaginationService.imagePlaceholderMaxHeight,
    this.annotationRanges = const <ReaderAnnotationRange>[],
  });

  final String content;
  final TextStyle baseStyle;
  final Color textColor;
  final Color backgroundColor;
  final TextScaler textScaler;
  final TtsHighlightDescriptor? descriptor;
  final List<InlineSpan> leadingSpans;
  final TextAlign textAlign;
  final StrutStyle? strutStyle;

  /// 与分页测量占位宽对齐；默认 [PaginationService.imagePlaceholderMaxWidth]。
  final double maxImageWidth;

  /// 应传入按可用高度 clamp 后的值，默认 [PaginationService.imagePlaceholderMaxHeight]。
  final double maxImageHeight;
  final List<ReaderAnnotationRange> annotationRanges;

  @override
  State<TtsPlaybackRichText> createState() => _TtsPlaybackRichTextState();
}

class _TtsPlaybackRichTextState extends State<TtsPlaybackRichText>
    with SingleTickerProviderStateMixin {
  static const Duration _animationFrameInterval = Duration(milliseconds: 33);
  static const Duration _minAnimationDuration = Duration(milliseconds: 36);
  static const Duration _maxAnimationDuration = Duration(milliseconds: 120);
  static const Duration _defaultAnimationDuration = Duration(milliseconds: 72);
  static const String _compactFocusIgnoredPunctuation =
      ',，。！？；、.!?:：;"\'()[]{}<>《》“”‘’…—-';

  late final AnimationController _animationController;
  TtsHighlightDescriptor? _displayedDescriptor;
  TtsHighlightDescriptor? _animationStartDescriptor;
  TtsHighlightDescriptor? _animationTargetDescriptor;
  DateTime? _lastDescriptorUpdatedAt;
  int? _cachedClusterSentenceStart;
  int? _cachedClusterSentenceEnd;
  List<_VisibleCluster>? _cachedVisibleClusters;
  Duration _lastRenderedAnimationElapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    _displayedDescriptor = widget.descriptor;
    if (widget.descriptor != null) {
      _lastDescriptorUpdatedAt = DateTime.now();
    }
    _animationController = AnimationController(vsync: this)
      ..addListener(() {
        if (!mounted) return;
        final elapsed = _animationController.lastElapsedDuration;
        final shouldRender = elapsed == null ||
            elapsed - _lastRenderedAnimationElapsed >=
                _animationFrameInterval ||
            _animationController.value >= 1;
        if (!shouldRender) return;
        _lastRenderedAnimationElapsed = elapsed ?? Duration.zero;
        setState(() {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed ||
            status == AnimationStatus.dismissed) {
          _animationStartDescriptor = null;
          _animationTargetDescriptor = null;
        }
      });
  }

  @override
  void didUpdateWidget(covariant TtsPlaybackRichText oldWidget) {
    super.didUpdateWidget(oldWidget);

    final nextDescriptor = widget.descriptor;
    if (widget.content != oldWidget.content) {
      _stopAnimation();
      _clearVisibleClusterCache();
      _displayedDescriptor = nextDescriptor;
      return;
    }

    final currentDescriptor = _resolveCurrentDescriptorForAnimation();
    final descriptorUpdatedAt = DateTime.now();
    final observedDescriptorInterval = _lastDescriptorUpdatedAt == null
        ? null
        : descriptorUpdatedAt.difference(_lastDescriptorUpdatedAt!);
    _lastDescriptorUpdatedAt = descriptorUpdatedAt;
    if (!_shouldAnimateDescriptor(currentDescriptor, nextDescriptor)) {
      _stopAnimation();
      _displayedDescriptor = nextDescriptor;
      return;
    }

    _displayedDescriptor = nextDescriptor;
    _animationStartDescriptor = currentDescriptor;
    _animationTargetDescriptor = nextDescriptor;
    _animationController.duration = _resolveAnimationDuration(
      currentDescriptor!,
      nextDescriptor!,
      observedDescriptorInterval: observedDescriptorInterval,
    );
    _lastRenderedAnimationElapsed = Duration.zero;
    _animationController.forward(from: 0);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final descriptor = _resolveEffectiveDescriptor();
    return RepaintBoundary(
      child: RichText(
        text: TextSpan(
          children: <InlineSpan>[
            ...widget.leadingSpans,
            ..._buildContentSpans(descriptor),
          ],
        ),
        textAlign: widget.textAlign,
        strutStyle: widget.strutStyle,
        textScaler: widget.textScaler,
      ),
    );
  }

  _RenderedHighlightDescriptor? _resolveEffectiveDescriptor() {
    final start = _animationStartDescriptor;
    final target = _animationTargetDescriptor;
    if (!_animationController.isAnimating || start == null || target == null) {
      final displayed = _displayedDescriptor;
      if (displayed == null) return null;
      return _RenderedHighlightDescriptor.fromDescriptor(displayed);
    }

    final t = Curves.easeOut.transform(_animationController.value);
    return _RenderedHighlightDescriptor(
      sentenceStart: target.sentenceStart,
      sentenceEnd: target.sentenceEnd,
      progressStart: target.progressStart,
      progressEnd: target.progressEnd,
      visualProgressStart: _lerpDouble(
        start.progressStart?.toDouble() ?? target.progressStart?.toDouble(),
        target.progressStart?.toDouble(),
        t,
      ),
      visualProgressEnd: _lerpDouble(
        start.progressEnd?.toDouble() ?? target.progressEnd?.toDouble(),
        target.progressEnd?.toDouble(),
        t,
      ),
    );
  }

  TtsHighlightDescriptor? _resolveCurrentDescriptorForAnimation() {
    final descriptor = _resolveEffectiveDescriptor();
    if (descriptor == null) return null;
    return TtsHighlightDescriptor(
      sentenceStart: descriptor.sentenceStart,
      sentenceEnd: descriptor.sentenceEnd,
      progressStart: descriptor.visualProgressStart?.floor(),
      progressEnd: descriptor.visualProgressEnd?.ceil(),
    );
  }

  bool _shouldAnimateDescriptor(
    TtsHighlightDescriptor? current,
    TtsHighlightDescriptor? next,
  ) {
    if (current == null || next == null) return false;
    if (!current.hasPreciseProgress || !next.hasPreciseProgress) return false;
    if (!current.isSameSentence(next)) return false;

    final currentEnd = current.progressEnd!;
    final nextStart = next.progressStart!;
    final nextEnd = next.progressEnd!;

    if (nextEnd <= currentEnd) return false;
    if (nextStart < current.sentenceStart || nextEnd > current.sentenceEnd) {
      return false;
    }

    return true;
  }

  Duration _resolveAnimationDuration(
    TtsHighlightDescriptor current,
    TtsHighlightDescriptor target, {
    Duration? observedDescriptorInterval,
  }) {
    final currentProgressEnd = current.progressEnd;
    final targetProgressEnd = target.progressEnd;
    if (currentProgressEnd == null || targetProgressEnd == null) {
      return _minAnimationDuration;
    }

    final delta = (targetProgressEnd - currentProgressEnd).abs();
    final intervalMs = (observedDescriptorInterval ?? _defaultAnimationDuration)
        .inMilliseconds
        .toDouble();
    var durationMs = 24 + delta * 8.0;
    durationMs = math.max(durationMs, intervalMs * 0.55);
    durationMs = math.min(durationMs, intervalMs * 0.92);
    durationMs = durationMs.clamp(
      _minAnimationDuration.inMilliseconds.toDouble(),
      _maxAnimationDuration.inMilliseconds.toDouble(),
    );
    return Duration(milliseconds: durationMs.round());
  }

  double? _lerpDouble(double? begin, double? end, double t) {
    if (begin == null && end == null) return null;
    if (begin == null) return end;
    if (end == null) return begin;
    return begin + (end - begin) * t;
  }

  void _stopAnimation() {
    _animationController.stop();
    _animationStartDescriptor = null;
    _animationTargetDescriptor = null;
  }

  void _clearVisibleClusterCache() {
    _cachedClusterSentenceStart = null;
    _cachedClusterSentenceEnd = null;
    _cachedVisibleClusters = null;
  }

  List<InlineSpan> _buildContentSpans(
      _RenderedHighlightDescriptor? descriptor) {
    // 含 <img> 时走图文混排；TTS 精确定位在含图页降级为整段展示。
    if (readerContentHasImages(widget.content)) {
      return buildReaderContentSpans(
        content: widget.content,
        style: widget.baseStyle,
        maxImageWidth: widget.maxImageWidth,
        maxImageHeight: widget.maxImageHeight,
      );
    }

    if (descriptor == null) {
      return _buildAnnotationSpans();
    }

    final sentenceStyle = _buildSentenceHighlightStyle();
    final playedStyle = _buildPlayedHighlightStyle();
    final progressStyle = _buildProgressHighlightStyle();
    final sentenceStart = descriptor.sentenceStart;
    final sentenceEnd = descriptor.sentenceEnd;
    final progressStart = descriptor.progressStart;
    final progressEnd = descriptor.progressEnd;

    if (!descriptor.hasPreciseProgress ||
        progressStart == null ||
        progressEnd == null ||
        progressStart < sentenceStart ||
        progressEnd > sentenceEnd ||
        progressEnd <= progressStart) {
      final fallbackSentenceStyle = _buildFallbackSentenceHighlightStyle();
      return <InlineSpan>[
        if (sentenceStart > 0)
          TextSpan(
            text: widget.content.substring(0, sentenceStart),
            style: widget.baseStyle,
          ),
        TextSpan(
          text: widget.content.substring(sentenceStart, sentenceEnd),
          style: fallbackSentenceStyle,
        ),
        if (sentenceEnd < widget.content.length)
          TextSpan(
            text: widget.content.substring(sentenceEnd),
            style: widget.baseStyle,
          ),
      ];
    }

    return <InlineSpan>[
      if (sentenceStart > 0)
        TextSpan(
          text: widget.content.substring(0, sentenceStart),
          style: widget.baseStyle,
        ),
      ..._buildAnimatedSentenceSpans(
        descriptor: descriptor,
        sentenceStyle: sentenceStyle,
        playedStyle: playedStyle,
        progressStyle: progressStyle,
      ),
      if (sentenceEnd < widget.content.length)
        TextSpan(
          text: widget.content.substring(sentenceEnd),
          style: widget.baseStyle,
        ),
    ];
  }

  List<InlineSpan> _buildAnnotationSpans() {
    if (widget.annotationRanges.isEmpty) {
      return <InlineSpan>[
        TextSpan(text: widget.content, style: widget.baseStyle)
      ];
    }
    final spans = <InlineSpan>[];
    var cursor = 0;
    for (final range in widget.annotationRanges) {
      final start = range.start.clamp(cursor, widget.content.length);
      final end = range.end.clamp(start, widget.content.length);
      if (end <= start) continue;
      if (start > cursor) {
        spans.add(TextSpan(
          text: widget.content.substring(cursor, start),
          style: widget.baseStyle,
        ));
      }
      final color = Color(range.colorValue ?? 0x66FFC857);
      final style = switch (range.type) {
        BookAnnotationType.highlight => widget.baseStyle.copyWith(
            backgroundColor: color.withValues(alpha: 0.38),
          ),
        BookAnnotationType.underline => widget.baseStyle.copyWith(
            decoration: TextDecoration.underline,
            decorationColor: color.withValues(alpha: 0.9),
            decorationThickness: 2,
          ),
        BookAnnotationType.note => widget.baseStyle.copyWith(
            backgroundColor: color.withValues(alpha: 0.18),
          ),
      };
      spans.add(
          TextSpan(text: widget.content.substring(start, end), style: style));
      cursor = end;
    }
    if (cursor < widget.content.length) {
      spans.add(TextSpan(
        text: widget.content.substring(cursor),
        style: widget.baseStyle,
      ));
    }
    return spans;
  }

  TextStyle _buildSentenceHighlightStyle() {
    return widget.baseStyle.copyWith(
      color: widget.textColor,
    );
  }

  TextStyle _buildPlayedHighlightStyle() {
    return widget.baseStyle.copyWith(
      color: widget.textColor,
    );
  }

  TextStyle _buildProgressHighlightStyle() {
    final isDark =
        ThemeData.estimateBrightnessForColor(widget.backgroundColor) ==
            Brightness.dark;
    final progressColor =
        isDark ? const Color(0xFFFFD98C) : const Color(0xFF8D6526);

    return widget.baseStyle.copyWith(
      color: progressColor,
      decoration: TextDecoration.underline,
      decorationColor: progressColor.withValues(alpha: isDark ? 0.62 : 0.48),
      decorationThickness: 1.8,
    );
  }

  TextStyle _buildFallbackSentenceHighlightStyle() {
    final isDark =
        ThemeData.estimateBrightnessForColor(widget.backgroundColor) ==
            Brightness.dark;
    final hintColor =
        isDark ? const Color(0xFFFFE2A8) : const Color(0xFF9A7844);

    return widget.baseStyle.copyWith(
      color: hintColor.withValues(alpha: isDark ? 0.92 : 0.82),
      decoration: TextDecoration.underline,
      decorationColor: hintColor.withValues(alpha: isDark ? 0.28 : 0.22),
      decorationThickness: 1.2,
    );
  }

  List<InlineSpan> _buildAnimatedSentenceSpans({
    required _RenderedHighlightDescriptor descriptor,
    required TextStyle sentenceStyle,
    required TextStyle playedStyle,
    required TextStyle progressStyle,
  }) {
    final sentenceStart = descriptor.sentenceStart;
    final sentenceEnd = descriptor.sentenceEnd;
    final visualProgressStart =
        (descriptor.visualProgressStart ?? descriptor.progressStart?.toDouble())
            ?.clamp(sentenceStart.toDouble(), sentenceEnd.toDouble());
    final visualProgressEnd =
        (descriptor.visualProgressEnd ?? descriptor.progressEnd?.toDouble())
            ?.clamp(sentenceStart.toDouble(), sentenceEnd.toDouble());

    if (visualProgressStart == null ||
        visualProgressEnd == null ||
        visualProgressEnd <= visualProgressStart) {
      return <InlineSpan>[
        TextSpan(
          text: widget.content.substring(sentenceStart, sentenceEnd),
          style: sentenceStyle,
        ),
      ];
    }

    final activeFocusRange = _resolveActiveFocusRange(
      descriptor: descriptor,
      visualProgressStart: visualProgressStart,
      visualProgressEnd: visualProgressEnd,
    );
    final spans = <InlineSpan>[];
    final buffer = StringBuffer();
    TextStyle? currentStyle;

    void flushBuffer() {
      if (buffer.isEmpty || currentStyle == null) return;
      spans.add(
        TextSpan(
          text: buffer.toString(),
          style: currentStyle,
        ),
      );
      buffer.clear();
    }

    for (final cluster in _resolveVisibleClusters(sentenceStart, sentenceEnd)) {
      final overlap = _resolveCharacterOverlap(
        characterStart: cluster.start.toDouble(),
        characterEnd: cluster.end.toDouble(),
        progressStart: activeFocusRange.start,
        progressEnd: activeFocusRange.end,
      );
      final baseStyle =
          cluster.end <= activeFocusRange.start ? playedStyle : sentenceStyle;
      final activeIntensity = _resolveActiveClusterIntensity(
        characterStart: cluster.start.toDouble(),
        characterEnd: cluster.end.toDouble(),
        progressStart: activeFocusRange.start,
        progressEnd: activeFocusRange.end,
        overlap: overlap,
      );
      final style = overlap <= 0
          ? baseStyle
          : activeIntensity >= 0.999
              ? progressStyle
              : TextStyle.lerp(baseStyle, progressStyle, activeIntensity) ??
                  progressStyle;
      if (currentStyle != style) {
        flushBuffer();
        currentStyle = style;
      }
      buffer.write(cluster.text);
    }

    flushBuffer();
    return spans;
  }

  // iOS 的 AVSpeechSynthesizer 对中日韩文本经常按词段回调 progress，
  // 这里把强高亮收窄到前锋字符，避免一次亮 2~3 个字。
  _HighlightFocusRange _resolveActiveFocusRange({
    required _RenderedHighlightDescriptor descriptor,
    required double visualProgressStart,
    required double visualProgressEnd,
  }) {
    if (!_shouldCompactIosCjkFocus(descriptor)) {
      return _HighlightFocusRange(
        start: visualProgressStart,
        end: visualProgressEnd,
      );
    }

    final frontierCluster = _resolveFrontierCluster(
      clusters: _resolveVisibleClusters(
        descriptor.sentenceStart,
        descriptor.sentenceEnd,
      ),
      visualProgressStart: visualProgressStart,
      visualProgressEnd: visualProgressEnd,
    );
    if (frontierCluster == null) {
      return _HighlightFocusRange(
        start: visualProgressStart,
        end: visualProgressEnd,
      );
    }

    return _HighlightFocusRange(
      start: frontierCluster.start.toDouble(),
      end: frontierCluster.end.toDouble(),
    );
  }

  bool _shouldCompactIosCjkFocus(_RenderedHighlightDescriptor descriptor) {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.iOS) return false;

    final progressStart = descriptor.progressStart;
    final progressEnd = descriptor.progressEnd;
    if (progressStart == null ||
        progressEnd == null ||
        progressEnd - progressStart <= 1 ||
        progressStart < 0 ||
        progressEnd > widget.content.length) {
      return false;
    }

    final meaningfulRunes = widget.content
        .substring(progressStart, progressEnd)
        .runes
        .where((rune) => !_isCompactFocusIgnoredRune(rune))
        .toList(growable: false);
    if (meaningfulRunes.length <= 1 || meaningfulRunes.length > 4) {
      return false;
    }

    return meaningfulRunes.every(_isCjkLikeRune);
  }

  _VisibleCluster? _resolveFrontierCluster({
    required List<_VisibleCluster> clusters,
    required double visualProgressStart,
    required double visualProgressEnd,
  }) {
    const epsilon = 0.001;
    _VisibleCluster? fallback;

    for (final cluster in clusters) {
      if (cluster.end <= visualProgressStart ||
          !_isMeaningfulCompactFocusCluster(cluster.text)) {
        continue;
      }

      fallback ??= cluster;
      if (cluster.end > visualProgressEnd - epsilon) {
        return cluster;
      }
    }

    return fallback;
  }

  bool _isMeaningfulCompactFocusCluster(String text) {
    return text.runes.any((rune) => !_isCompactFocusIgnoredRune(rune));
  }

  bool _isCompactFocusIgnoredRune(int rune) {
    final character = String.fromCharCode(rune);
    return character.trim().isEmpty ||
        _compactFocusIgnoredPunctuation.contains(character);
  }

  bool _isCjkLikeRune(int rune) {
    return (rune >= 0x3400 && rune <= 0x4DBF) ||
        (rune >= 0x4E00 && rune <= 0x9FFF) ||
        (rune >= 0xF900 && rune <= 0xFAFF) ||
        (rune >= 0x20000 && rune <= 0x2EBEF) ||
        (rune >= 0x3040 && rune <= 0x309F) ||
        (rune >= 0x30A0 && rune <= 0x30FF) ||
        (rune >= 0x31F0 && rune <= 0x31FF) ||
        (rune >= 0xAC00 && rune <= 0xD7AF);
  }

  double _resolveCharacterOverlap({
    required double characterStart,
    required double characterEnd,
    required double progressStart,
    required double progressEnd,
  }) {
    final start = math.max(characterStart, progressStart);
    final end = math.min(characterEnd, progressEnd);
    final clusterLength = math.max(1.0, characterEnd - characterStart);
    return ((end - start) / clusterLength).clamp(0.0, 1.0);
  }

  double _resolveActiveClusterIntensity({
    required double characterStart,
    required double characterEnd,
    required double progressStart,
    required double progressEnd,
    required double overlap,
  }) {
    if (overlap <= 0) return 0;

    final progressLength = math.max(1.0, progressEnd - progressStart);
    final clusterCenter = (characterStart + characterEnd) / 2;
    final normalizedCenter =
        ((clusterCenter - progressStart) / progressLength).clamp(0.0, 1.0);

    // 让当前词内部靠近前锋的位置更亮，尾迹更柔和。
    final leadingEdgeWeight = Curves.easeOut.transform(normalizedCenter);
    return (overlap * 0.55 + leadingEdgeWeight * 0.45).clamp(0.0, 1.0);
  }

  Iterable<_VisibleCluster> _buildVisibleClusters(
    int sentenceStart,
    int sentenceEnd,
  ) sync* {
    final sentenceText = widget.content.substring(sentenceStart, sentenceEnd);
    var offset = sentenceStart;
    for (final cluster in sentenceText.characters) {
      final clusterEnd = offset + cluster.length;
      yield _VisibleCluster(
        text: cluster,
        start: offset,
        end: clusterEnd,
      );
      offset = clusterEnd;
    }
  }

  List<_VisibleCluster> _resolveVisibleClusters(
    int sentenceStart,
    int sentenceEnd,
  ) {
    if (_cachedClusterSentenceStart == sentenceStart &&
        _cachedClusterSentenceEnd == sentenceEnd &&
        _cachedVisibleClusters != null) {
      return _cachedVisibleClusters!;
    }

    final clusters = _buildVisibleClusters(sentenceStart, sentenceEnd)
        .toList(growable: false);
    _cachedClusterSentenceStart = sentenceStart;
    _cachedClusterSentenceEnd = sentenceEnd;
    _cachedVisibleClusters = clusters;
    return clusters;
  }
}

class _RenderedHighlightDescriptor {
  const _RenderedHighlightDescriptor({
    required this.sentenceStart,
    required this.sentenceEnd,
    this.progressStart,
    this.progressEnd,
    this.visualProgressStart,
    this.visualProgressEnd,
  });

  factory _RenderedHighlightDescriptor.fromDescriptor(
    TtsHighlightDescriptor descriptor,
  ) {
    return _RenderedHighlightDescriptor(
      sentenceStart: descriptor.sentenceStart,
      sentenceEnd: descriptor.sentenceEnd,
      progressStart: descriptor.progressStart,
      progressEnd: descriptor.progressEnd,
      visualProgressStart: descriptor.progressStart?.toDouble(),
      visualProgressEnd: descriptor.progressEnd?.toDouble(),
    );
  }

  final int sentenceStart;
  final int sentenceEnd;
  final int? progressStart;
  final int? progressEnd;
  final double? visualProgressStart;
  final double? visualProgressEnd;

  bool get hasPreciseProgress =>
      progressStart != null &&
      progressEnd != null &&
      progressEnd! > progressStart!;
}

class _HighlightFocusRange {
  const _HighlightFocusRange({
    required this.start,
    required this.end,
  });

  final double start;
  final double end;
}

class _VisibleCluster {
  const _VisibleCluster({
    required this.text,
    required this.start,
    required this.end,
  });

  final String text;
  final int start;
  final int end;
}
