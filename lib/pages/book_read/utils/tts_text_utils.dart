import '../models/tts_page_snapshot.dart';
import '../models/tts_sentence_segment.dart';

class TtsTextUtils {
  TtsTextUtils._();

  static final RegExp _splitPattern = RegExp(r'(?<=[。！？；.!?\n])');

  static String normalize(String? raw) => raw?.trim() ?? '';

  static List<String> splitIntoSentences(String? raw) =>
      splitIntoSegments(raw).map((segment) => segment.text).toList();

  static List<TtsSentenceSegment> splitIntoSegments(String? raw) =>
      buildPageSnapshot(chapterIndex: 0, pageIndex: 0, rawText: raw ?? '')
          .segments;

  static TtsPageSnapshot buildPageSnapshot({
    required int chapterIndex,
    required int pageIndex,
    required String rawText,
    int pageStartOffsetInChapter = 0,
  }) {
    final segments = <TtsSentenceSegment>[];
    var cursor = 0;
    for (final part in rawText.split(_splitPattern)) {
      final start = rawText.indexOf(part, cursor);
      if (start < 0) continue;
      cursor = start + part.length;
      final trimmed = part.trim();
      if (trimmed.runes.length < 2) continue;
      final leading = part.indexOf(trimmed);
      final segmentStart = start + leading;
      segments.add(TtsSentenceSegment(
        text: trimmed,
        start: segmentStart,
        end: segmentStart + trimmed.length,
        normalizedStart: segmentStart,
        normalizedEnd: segmentStart + trimmed.length,
      ));
    }
    return TtsPageSnapshot(
      chapterIndex: chapterIndex,
      pageIndex: pageIndex,
      rawText: rawText,
      normalizedText: rawText,
      normalizedToRawIndexMap: List<int>.generate(rawText.length, (i) => i),
      segments: List.unmodifiable(segments),
      pageStartOffsetInChapter: pageStartOffsetInChapter,
    );
  }
}
