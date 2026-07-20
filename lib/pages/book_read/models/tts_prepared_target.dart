import 'tts_page_snapshot.dart';
import 'tts_sentence_segment.dart';
import 'tts_speak_request.dart';

class TtsPreparedTarget {
  const TtsPreparedTarget({
    required this.snapshot,
    required this.segment,
    required this.sentenceIndex,
    required this.resumeOffsetInSentence,
    required this.playbackToken,
    required this.preparedAt,
  });

  final TtsPageSnapshot snapshot;
  final TtsSentenceSegment segment;
  final int sentenceIndex;
  final int resumeOffsetInSentence;
  final int playbackToken;
  final DateTime preparedAt;

  int get chapterIndex => snapshot.chapterIndex;
  int get pageIndex => snapshot.pageIndex;

  String get sentence {
    final offset = resumeOffsetInSentence.clamp(0, segment.text.length);
    return segment.text.substring(offset);
  }

  int get remainingLength => (segment.text.length - resumeOffsetInSentence)
      .clamp(0, segment.text.length);

  int get initialHighlightStartInPage {
    if (resumeOffsetInSentence <= 0) return segment.start;
    return mapSentenceOffsetToRaw(resumeOffsetInSentence);
  }

  int get initialHighlightEndInPage => segment.end;

  int mapSentenceOffsetToRaw(int sentenceOffset) {
    final absoluteNormalizedOffset =
        segment.normalizedStart + sentenceOffset.clamp(0, segment.text.length);
    return snapshot.mapNormalizedStartToRaw(absoluteNormalizedOffset);
  }

  int mapSentenceOffsetToRawEnd(int sentenceOffset) {
    final absoluteNormalizedOffset =
        segment.normalizedStart + sentenceOffset.clamp(0, segment.text.length);
    return snapshot.mapNormalizedEndToRaw(absoluteNormalizedOffset);
  }

  TtsPreparedTarget copyWith({
    TtsPageSnapshot? snapshot,
    TtsSentenceSegment? segment,
    int? sentenceIndex,
    int? resumeOffsetInSentence,
    int? playbackToken,
    DateTime? preparedAt,
  }) {
    return TtsPreparedTarget(
      snapshot: snapshot ?? this.snapshot,
      segment: segment ?? this.segment,
      sentenceIndex: sentenceIndex ?? this.sentenceIndex,
      resumeOffsetInSentence:
          resumeOffsetInSentence ?? this.resumeOffsetInSentence,
      playbackToken: playbackToken ?? this.playbackToken,
      preparedAt: preparedAt ?? this.preparedAt,
    );
  }

  TtsSpeakRequest toSpeakRequest() {
    return TtsSpeakRequest(
      text: sentence,
      chapterIndex: chapterIndex,
      pageIndex: pageIndex,
      sentenceIndex: sentenceIndex,
      resumeOffsetInSentence: resumeOffsetInSentence,
      playbackToken: playbackToken,
    );
  }
}
