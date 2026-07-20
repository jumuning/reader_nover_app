import '../models/tts_page_snapshot.dart';
import '../models/tts_sentence_segment.dart';
import '../utils/tts_text_utils.dart';

class TtsUtterancePlanner {
  const TtsUtterancePlanner();

  TtsPageUtterancePlan planPage({
    required int chapterIndex,
    required int pageIndex,
    required String pageText,
    int pageStartOffsetInChapter = 0,
  }) {
    return planSnapshot(
      snapshot: TtsTextUtils.buildPageSnapshot(
        chapterIndex: chapterIndex,
        pageIndex: pageIndex,
        rawText: pageText,
        pageStartOffsetInChapter: pageStartOffsetInChapter,
      ),
    );
  }

  TtsPageUtterancePlan planSnapshot({required TtsPageSnapshot snapshot}) {
    final utterances = <TtsPlannedUtterance>[];
    for (var index = 0; index < snapshot.segments.length; index++) {
      final segment = snapshot.segments[index];
      utterances.add(TtsPlannedUtterance(
        id: 'c${snapshot.chapterIndex}:p${snapshot.pageIndex}:s$index',
        chapterIndex: snapshot.chapterIndex,
        pageIndex: snapshot.pageIndex,
        segmentIndex: index,
        chapterStart: snapshot.pageStartOffsetInChapter + segment.start,
        chapterEnd: snapshot.pageStartOffsetInChapter + segment.end,
        segment: segment,
      ));
    }
    return TtsPageUtterancePlan(
      snapshot: snapshot,
      utterances: List.unmodifiable(utterances),
    );
  }

  TtsChapterUtterancePlan planChapter({
    required int chapterIndex,
    required List<String> pageTexts,
  }) {
    var pageStart = 0;
    final pages = <TtsPageUtterancePlan>[];
    final utterances = <TtsPlannedUtterance>[];
    for (var index = 0; index < pageTexts.length; index++) {
      final page = planPage(
        chapterIndex: chapterIndex,
        pageIndex: index,
        pageText: pageTexts[index],
        pageStartOffsetInChapter: pageStart,
      );
      pages.add(page);
      utterances.addAll(page.utterances);
      pageStart += pageTexts[index].length;
    }
    return TtsChapterUtterancePlan(
      chapterIndex: chapterIndex,
      pages: List.unmodifiable(pages),
      utterances: List.unmodifiable(utterances),
      rawTextLength: pageStart,
    );
  }
}

class TtsChapterUtterancePlan {
  const TtsChapterUtterancePlan({
    required this.chapterIndex,
    required this.pages,
    required this.utterances,
    required this.rawTextLength,
  });

  final int chapterIndex;
  final List<TtsPageUtterancePlan> pages;
  final List<TtsPlannedUtterance> utterances;
  final int rawTextLength;
}

class TtsPageUtterancePlan {
  const TtsPageUtterancePlan(
      {required this.snapshot, required this.utterances});

  final TtsPageSnapshot snapshot;
  final List<TtsPlannedUtterance> utterances;
}

class TtsPlannedUtterance {
  const TtsPlannedUtterance({
    required this.id,
    required this.chapterIndex,
    required this.pageIndex,
    required this.segmentIndex,
    required this.chapterStart,
    required this.chapterEnd,
    required this.segment,
  });

  final String id;
  final int chapterIndex;
  final int pageIndex;
  final int segmentIndex;
  final int chapterStart;
  final int chapterEnd;
  final TtsSentenceSegment segment;
  String get text => segment.text;
}
