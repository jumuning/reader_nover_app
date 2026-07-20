import 'tts_prepared_target.dart';

class TtsReadAheadBuffer {
  const TtsReadAheadBuffer({
    required this.playbackToken,
    required this.preparedAt,
    this.current,
    this.nextSentence,
    this.nextPageFirstSentence,
    this.nextChapterFirstSentence,
  });

  final int playbackToken;
  final DateTime preparedAt;
  final TtsPreparedTarget? current;
  final TtsPreparedTarget? nextSentence;
  final TtsPreparedTarget? nextPageFirstSentence;
  final TtsPreparedTarget? nextChapterFirstSentence;

  TtsReadAheadBuffer copyWith({
    int? playbackToken,
    DateTime? preparedAt,
    TtsPreparedTarget? current,
    TtsPreparedTarget? nextSentence,
    TtsPreparedTarget? nextPageFirstSentence,
    TtsPreparedTarget? nextChapterFirstSentence,
    bool clearCurrent = false,
    bool clearNextSentence = false,
    bool clearNextPageFirstSentence = false,
    bool clearNextChapterFirstSentence = false,
  }) {
    return TtsReadAheadBuffer(
      playbackToken: playbackToken ?? this.playbackToken,
      preparedAt: preparedAt ?? this.preparedAt,
      current: clearCurrent ? null : current ?? this.current,
      nextSentence:
          clearNextSentence ? null : nextSentence ?? this.nextSentence,
      nextPageFirstSentence: clearNextPageFirstSentence
          ? null
          : nextPageFirstSentence ?? this.nextPageFirstSentence,
      nextChapterFirstSentence: clearNextChapterFirstSentence
          ? null
          : nextChapterFirstSentence ?? this.nextChapterFirstSentence,
    );
  }
}
