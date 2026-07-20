import '../models/reader_paragraph_range.dart';
import '../models/tts_sentence_segment.dart';

class ReaderParagraphUtils {
  const ReaderParagraphUtils._();

  static ReaderParagraphRange? resolveAt(String text, int offset) {
    if (text.isEmpty) return null;

    final safeOffset = offset.clamp(0, text.length - 1);
    final effectiveOffset = _resolveEffectiveOffset(text, safeOffset);
    if (effectiveOffset == null) return null;

    final previousBreak = text.lastIndexOf('\n', effectiveOffset - 1);
    final nextBreak = text.indexOf('\n', effectiveOffset);
    var start = previousBreak >= 0 ? previousBreak + 1 : 0;
    var end = nextBreak >= 0 ? nextBreak : text.length;

    while (start < end && text[start].trim().isEmpty) {
      start++;
    }
    while (end > start && text[end - 1].trim().isEmpty) {
      end--;
    }

    if (end <= start) return null;
    return ReaderParagraphRange(
      start: start,
      end: end,
      text: text.substring(start, end),
    );
  }

  static int? findFirstSentenceIndexForParagraph(
    List<TtsSentenceSegment> segments,
    ReaderParagraphRange paragraph,
  ) {
    if (segments.isEmpty || paragraph.isEmpty) return null;

    for (var index = 0; index < segments.length; index++) {
      final segment = segments[index];
      if (segment.end <= paragraph.start) {
        continue;
      }
      if (segment.start >= paragraph.end) {
        break;
      }
      return index;
    }

    for (var index = 0; index < segments.length; index++) {
      if (segments[index].start >= paragraph.start) {
        return index;
      }
    }

    return null;
  }

  static int? _resolveEffectiveOffset(String text, int offset) {
    if (!_isLineBreak(text[offset])) {
      return offset;
    }

    for (var delta = 1; delta < text.length; delta++) {
      final next = offset + delta;
      if (next < text.length && !_isLineBreak(text[next])) {
        return next;
      }

      final previous = offset - delta;
      if (previous >= 0 && !_isLineBreak(text[previous])) {
        return previous;
      }
    }

    return null;
  }

  static bool _isLineBreak(String value) => value == '\n' || value == '\r';
}
