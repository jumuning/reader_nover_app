class TtsPlaybackCursor {
  const TtsPlaybackCursor({
    required this.chapterIndex,
    required this.pageIndex,
    required this.sentenceIndex,
    required this.sentenceText,
    required this.sentenceStartInPage,
    required this.sentenceEndInPage,
    required this.sentenceStartInChapter,
    required this.sentenceEndInChapter,
    this.progressStartInPage,
    this.progressEndInPage,
    this.progressStartInChapter,
    this.progressEndInChapter,
    required this.highlightStartInPage,
    required this.highlightEndInPage,
    required this.highlightStartInChapter,
    required this.highlightEndInChapter,
    this.progressStartInSentence,
    this.progressEndInSentence,
    this.currentWord,
    this.lastProgressAt,
  });

  final int chapterIndex;
  final int pageIndex;
  final int sentenceIndex;
  final String sentenceText;
  final int sentenceStartInPage;
  final int sentenceEndInPage;
  final int sentenceStartInChapter;
  final int sentenceEndInChapter;
  final int? progressStartInPage;
  final int? progressEndInPage;
  final int? progressStartInChapter;
  final int? progressEndInChapter;
  final int highlightStartInPage;
  final int highlightEndInPage;
  final int highlightStartInChapter;
  final int highlightEndInChapter;
  final int? progressStartInSentence;
  final int? progressEndInSentence;
  final String? currentWord;
  final DateTime? lastProgressAt;

  bool get hasPreciseProgress =>
      progressStartInSentence != null && progressEndInSentence != null;
}
