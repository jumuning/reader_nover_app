import 'package:reader_nover/pages/book_read/models/tts_highlight_descriptor.dart';
import 'package:reader_nover/pages/book_read/state.dart';

class TtsHighlightResolver {
  const TtsHighlightResolver._();

  static TtsHighlightDescriptor? resolveForPage(
    BookReadHighlightStateSource state, {
    required String content,
    required int displayPageIndex,
    required int displayChapterIndex,
  }) {
    final paragraphPreview = _resolveParagraphPreviewForPage(
      state,
      content: content,
      displayPageIndex: displayPageIndex,
      displayChapterIndex: displayChapterIndex,
    );
    if (paragraphPreview != null) {
      return paragraphPreview;
    }

    if (!(state.isTtsPlaying || state.isTtsPaused)) return null;

    final cursor = state.ttsPlaybackCursor;
    if (cursor != null &&
        cursor.pageIndex == displayPageIndex &&
        cursor.chapterIndex == displayChapterIndex) {
      // UI 只做当前朗读段落高亮，不消费 TTS progress 的逐字/逐词区间。
      return _buildValidatedDescriptor(
        contentLength: content.length,
        sentenceStart: cursor.sentenceStartInPage,
        sentenceEnd: cursor.sentenceEndInPage,
      );
    }

    final highlightPageIndex = state.ttsHighlightPageIndex ?? state.currentPage;
    final highlightChapterIndex =
        state.ttsHighlightChapterIndex ?? state.currentChapterIndex;
    final canHighlight = state.ttsCurrentSentence != null &&
        state.ttsHighlightStart != null &&
        state.ttsHighlightEnd != null &&
        displayPageIndex == highlightPageIndex &&
        displayChapterIndex == highlightChapterIndex;
    if (!canHighlight) return null;

    return _buildValidatedDescriptor(
      contentLength: content.length,
      sentenceStart: state.ttsHighlightStart!,
      sentenceEnd: state.ttsHighlightEnd!,
    );
  }

  static TtsHighlightDescriptor? resolveForChapter(
    BookReadHighlightStateSource state, {
    required String content,
    required int displayChapterIndex,
    required int fallbackPageOffsetInChapter,
  }) {
    final paragraphPreview = _resolveParagraphPreviewForChapter(
      state,
      content: content,
      displayChapterIndex: displayChapterIndex,
    );
    if (paragraphPreview != null) {
      return paragraphPreview;
    }

    if (!(state.isTtsPlaying || state.isTtsPaused)) return null;

    final cursor = state.ttsPlaybackCursor;
    if (cursor != null && cursor.chapterIndex == displayChapterIndex) {
      // UI 只做当前朗读段落高亮，不消费 TTS progress 的逐字/逐词区间。
      return _buildValidatedDescriptor(
        contentLength: content.length,
        sentenceStart: cursor.sentenceStartInChapter,
        sentenceEnd: cursor.sentenceEndInChapter,
      );
    }

    final highlightChapterIndex =
        state.ttsHighlightChapterIndex ?? state.currentChapterIndex;
    final canHighlight = state.ttsCurrentSentence != null &&
        state.ttsHighlightStart != null &&
        state.ttsHighlightEnd != null &&
        displayChapterIndex == highlightChapterIndex;
    if (!canHighlight) return null;

    return _buildValidatedDescriptor(
      contentLength: content.length,
      sentenceStart: fallbackPageOffsetInChapter + state.ttsHighlightStart!,
      sentenceEnd: fallbackPageOffsetInChapter + state.ttsHighlightEnd!,
    );
  }

  static TtsHighlightDescriptor? _buildValidatedDescriptor({
    required int contentLength,
    required int sentenceStart,
    required int sentenceEnd,
    int? progressStart,
    int? progressEnd,
  }) {
    if (sentenceStart < 0 ||
        sentenceEnd <= sentenceStart ||
        sentenceEnd > contentLength) {
      return null;
    }

    final hasPreciseProgress = progressStart != null &&
        progressEnd != null &&
        progressStart >= sentenceStart &&
        progressEnd > progressStart &&
        progressEnd <= sentenceEnd;

    return TtsHighlightDescriptor(
      sentenceStart: sentenceStart,
      sentenceEnd: sentenceEnd,
      progressStart: hasPreciseProgress ? progressStart : null,
      progressEnd: hasPreciseProgress ? progressEnd : null,
    );
  }

  static TtsHighlightDescriptor? _resolveParagraphPreviewForPage(
    BookReadHighlightStateSource state, {
    required String content,
    required int displayPageIndex,
    required int displayChapterIndex,
  }) {
    final previewPageIndex = state.paragraphPreviewPageIndex;
    final previewChapterIndex = state.paragraphPreviewChapterIndex;
    final previewStart = state.paragraphPreviewStartInPage;
    final previewEnd = state.paragraphPreviewEndInPage;
    if (previewPageIndex == null ||
        previewChapterIndex == null ||
        previewStart == null ||
        previewEnd == null ||
        previewPageIndex != displayPageIndex ||
        previewChapterIndex != displayChapterIndex) {
      return null;
    }

    return _buildValidatedDescriptor(
      contentLength: content.length,
      sentenceStart: previewStart,
      sentenceEnd: previewEnd,
    );
  }

  static TtsHighlightDescriptor? _resolveParagraphPreviewForChapter(
    BookReadHighlightStateSource state, {
    required String content,
    required int displayChapterIndex,
  }) {
    final previewChapterIndex = state.paragraphPreviewChapterIndex;
    final previewStart = state.paragraphPreviewStartInChapter;
    final previewEnd = state.paragraphPreviewEndInChapter;
    if (previewChapterIndex == null ||
        previewStart == null ||
        previewEnd == null ||
        previewChapterIndex != displayChapterIndex) {
      return null;
    }

    return _buildValidatedDescriptor(
      contentLength: content.length,
      sentenceStart: previewStart,
      sentenceEnd: previewEnd,
    );
  }
}
