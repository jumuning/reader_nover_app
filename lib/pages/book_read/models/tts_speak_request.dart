class TtsSpeakRequest {
  const TtsSpeakRequest({
    required this.text,
    required this.chapterIndex,
    required this.pageIndex,
    required this.sentenceIndex,
    required this.resumeOffsetInSentence,
    required this.playbackToken,
  });

  final String text;
  final int chapterIndex;
  final int pageIndex;
  final int sentenceIndex;
  final int resumeOffsetInSentence;
  final int playbackToken;
}
