import 'dart:convert';

/// A layout-independent position in a chapter.
class ReaderLocator {
  const ReaderLocator({
    required this.chapterIndex,
    this.chapterId,
    this.chapterName,
    this.resourceHref,
    this.offsetUtf16,
    this.quote,
    this.prefix,
    this.suffix,
    this.chapterProgression,
  });

  final int chapterIndex;
  final String? chapterId;
  final String? chapterName;
  final String? resourceHref;
  final int? offsetUtf16;
  final String? quote;
  final String? prefix;
  final String? suffix;
  final double? chapterProgression;

  Map<String, Object?> toJson() => <String, Object?>{
        'version': 1,
        'chapterIndex': chapterIndex,
        if (chapterId != null) 'chapterId': chapterId,
        if (chapterName != null) 'chapterName': chapterName,
        if (resourceHref != null) 'resourceHref': resourceHref,
        if (offsetUtf16 != null) 'offsetUtf16': offsetUtf16,
        if (quote != null) 'quote': quote,
        if (prefix != null) 'prefix': prefix,
        if (suffix != null) 'suffix': suffix,
        if (chapterProgression != null)
          'chapterProgression': chapterProgression,
      };

  String encode() => jsonEncode(toJson());

  factory ReaderLocator.fromJson(Map<String, Object?> json) {
    final progression = (json['chapterProgression'] as num?)?.toDouble();
    return ReaderLocator(
      chapterIndex: (json['chapterIndex'] as num).toInt(),
      chapterId: json['chapterId'] as String?,
      chapterName: json['chapterName'] as String?,
      resourceHref: json['resourceHref'] as String?,
      offsetUtf16: (json['offsetUtf16'] as num?)?.toInt(),
      quote: json['quote'] as String?,
      prefix: json['prefix'] as String?,
      suffix: json['suffix'] as String?,
      chapterProgression: progression?.clamp(0, 1),
    );
  }

  factory ReaderLocator.decode(String value) {
    final decoded = jsonDecode(value);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Reader locator must be a JSON object');
    }
    return ReaderLocator.fromJson(decoded);
  }
}

enum ReaderLocatorResolutionKind {
  exactOffset,
  quoteContext,
  quote,
  progression,
  start,
}

class ReaderLocatorResolution {
  const ReaderLocatorResolution({
    required this.offsetUtf16,
    required this.kind,
  });

  final int offsetUtf16;
  final ReaderLocatorResolutionKind kind;
}

class ReaderLocatorService {
  const ReaderLocatorService();

  static const int _contextLength = 32;

  ReaderLocator create({
    required int chapterIndex,
    required String chapterText,
    required int offsetUtf16,
    String? chapterId,
    String? chapterName,
    String? resourceHref,
    int quoteLength = 48,
  }) {
    final offset = offsetUtf16.clamp(0, chapterText.length);
    final quoteEnd = (offset + quoteLength).clamp(offset, chapterText.length);
    final prefixStart = (offset - _contextLength).clamp(0, offset);
    final suffixEnd = (quoteEnd + _contextLength).clamp(
      quoteEnd,
      chapterText.length,
    );
    return ReaderLocator(
      chapterIndex: chapterIndex,
      chapterId: chapterId,
      chapterName: chapterName,
      resourceHref: resourceHref,
      offsetUtf16: offset,
      quote: chapterText.substring(offset, quoteEnd),
      prefix: chapterText.substring(prefixStart, offset),
      suffix: chapterText.substring(quoteEnd, suffixEnd),
      chapterProgression: chapterText.isEmpty ? 0 : offset / chapterText.length,
    );
  }

  ReaderLocatorResolution resolve({
    required ReaderLocator locator,
    required String chapterText,
  }) {
    if (chapterText.isEmpty) {
      return const ReaderLocatorResolution(
        offsetUtf16: 0,
        kind: ReaderLocatorResolutionKind.start,
      );
    }

    final quote = locator.quote;
    final hint = locator.offsetUtf16?.clamp(0, chapterText.length);
    if (quote != null && quote.isNotEmpty && hint != null) {
      final end = hint + quote.length;
      if (end <= chapterText.length &&
          chapterText.substring(hint, end) == quote) {
        return ReaderLocatorResolution(
          offsetUtf16: hint,
          kind: ReaderLocatorResolutionKind.exactOffset,
        );
      }
    }

    if (quote != null && quote.isNotEmpty) {
      final matches = _allMatches(chapterText, quote);
      if (matches.isNotEmpty) {
        final contextual = _bestContextMatch(
          text: chapterText,
          matches: matches,
          quoteLength: quote.length,
          prefix: locator.prefix,
          suffix: locator.suffix,
          hint: hint,
        );
        return ReaderLocatorResolution(
          offsetUtf16: contextual,
          kind: (locator.prefix?.isNotEmpty ?? false) ||
                  (locator.suffix?.isNotEmpty ?? false)
              ? ReaderLocatorResolutionKind.quoteContext
              : ReaderLocatorResolutionKind.quote,
        );
      }
    }

    final progression = locator.chapterProgression;
    if (progression != null) {
      return ReaderLocatorResolution(
        offsetUtf16: (chapterText.length * progression.clamp(0, 1)).round(),
        kind: ReaderLocatorResolutionKind.progression,
      );
    }
    return const ReaderLocatorResolution(
      offsetUtf16: 0,
      kind: ReaderLocatorResolutionKind.start,
    );
  }

  List<int> _allMatches(String text, String quote) {
    final matches = <int>[];
    var start = 0;
    while (start <= text.length - quote.length) {
      final index = text.indexOf(quote, start);
      if (index < 0) break;
      matches.add(index);
      start = index + 1;
    }
    return matches;
  }

  int _bestContextMatch({
    required String text,
    required List<int> matches,
    required int quoteLength,
    required String? prefix,
    required String? suffix,
    required int? hint,
  }) {
    var best = matches.first;
    var bestScore = -1;
    var bestDistance = 1 << 62;
    for (final match in matches) {
      var score = 0;
      if (prefix != null && prefix.isNotEmpty) {
        final start = (match - prefix.length).clamp(0, match);
        if (text.substring(start, match).endsWith(prefix)) score++;
      }
      if (suffix != null && suffix.isNotEmpty) {
        final start = match + quoteLength;
        final end = (start + suffix.length).clamp(start, text.length);
        if (text.substring(start, end).startsWith(suffix)) score++;
      }
      final distance = hint == null ? 0 : (match - hint).abs();
      if (score > bestScore ||
          (score == bestScore && distance < bestDistance)) {
        best = match;
        bestScore = score;
        bestDistance = distance;
      }
    }
    return best;
  }
}
