class TtsHighlightDescriptor {
  const TtsHighlightDescriptor({
    required this.sentenceStart,
    required this.sentenceEnd,
    this.progressStart,
    this.progressEnd,
  });

  final int sentenceStart;
  final int sentenceEnd;
  final int? progressStart;
  final int? progressEnd;

  bool get hasPreciseProgress =>
      progressStart != null &&
      progressEnd != null &&
      progressEnd! > progressStart!;

  bool isSameSentence(TtsHighlightDescriptor other) {
    return sentenceStart == other.sentenceStart &&
        sentenceEnd == other.sentenceEnd;
  }

  TtsHighlightDescriptor copyWith({
    int? sentenceStart,
    int? sentenceEnd,
    int? progressStart,
    int? progressEnd,
    bool clearProgress = false,
  }) {
    return TtsHighlightDescriptor(
      sentenceStart: sentenceStart ?? this.sentenceStart,
      sentenceEnd: sentenceEnd ?? this.sentenceEnd,
      progressStart: clearProgress ? null : progressStart ?? this.progressStart,
      progressEnd: clearProgress ? null : progressEnd ?? this.progressEnd,
    );
  }
}
