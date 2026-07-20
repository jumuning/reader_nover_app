import 'tts_sentence_segment.dart';

class TtsPageSnapshot {
  const TtsPageSnapshot({
    required this.chapterIndex,
    required this.pageIndex,
    required this.rawText,
    required this.normalizedText,
    required this.normalizedToRawIndexMap,
    required this.segments,
    required this.pageStartOffsetInChapter,
  });

  final int chapterIndex;
  final int pageIndex;
  final String rawText;
  final String normalizedText;
  final List<int> normalizedToRawIndexMap;
  final List<TtsSentenceSegment> segments;
  final int pageStartOffsetInChapter;

  bool get isEmpty => rawText.isEmpty || segments.isEmpty;

  int mapNormalizedStartToRaw(int normalizedOffset) {
    if (normalizedToRawIndexMap.isEmpty) return 0;
    if (normalizedOffset <= 0) {
      return normalizedToRawIndexMap.first.clamp(0, rawText.length);
    }
    if (normalizedOffset >= normalizedToRawIndexMap.length) {
      return rawText.length;
    }
    return normalizedToRawIndexMap[normalizedOffset].clamp(0, rawText.length);
  }

  int mapNormalizedEndToRaw(int normalizedOffset) {
    if (normalizedToRawIndexMap.isEmpty || normalizedOffset <= 0) return 0;

    final index = normalizedOffset - 1;
    if (index >= normalizedToRawIndexMap.length) {
      return rawText.length;
    }

    return (normalizedToRawIndexMap[index] + 1).clamp(0, rawText.length);
  }
}
