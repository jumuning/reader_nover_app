import 'package:flutter/foundation.dart';

import '../state.dart';

class BookReadPreviewController {
  const BookReadPreviewController({
    required this.state,
    required this.onPreviewChanged,
  });

  final BookReadState state;
  final VoidCallback onPreviewChanged;

  void showParagraphPreviewForPage({
    required int pageIndex,
    required int chapterIndex,
    required int start,
    required int end,
  }) {
    state.paragraphPreviewPageIndex = pageIndex;
    state.paragraphPreviewChapterIndex = chapterIndex;
    state.paragraphPreviewStartInPage = start;
    state.paragraphPreviewEndInPage = end;
    state.paragraphPreviewStartInChapter = null;
    state.paragraphPreviewEndInChapter = null;
    onPreviewChanged();
  }

  void showParagraphPreviewForChapter({
    required int chapterIndex,
    required int start,
    required int end,
  }) {
    state.paragraphPreviewChapterIndex = chapterIndex;
    state.paragraphPreviewStartInChapter = start;
    state.paragraphPreviewEndInChapter = end;
    state.paragraphPreviewPageIndex = null;
    state.paragraphPreviewStartInPage = null;
    state.paragraphPreviewEndInPage = null;
    onPreviewChanged();
  }

  void clearParagraphPreview() {
    final hadPreview = state.paragraphPreviewChapterIndex != null ||
        state.paragraphPreviewPageIndex != null ||
        state.paragraphPreviewStartInPage != null ||
        state.paragraphPreviewEndInPage != null ||
        state.paragraphPreviewStartInChapter != null ||
        state.paragraphPreviewEndInChapter != null;
    state.paragraphPreviewPageIndex = null;
    state.paragraphPreviewChapterIndex = null;
    state.paragraphPreviewStartInPage = null;
    state.paragraphPreviewEndInPage = null;
    state.paragraphPreviewStartInChapter = null;
    state.paragraphPreviewEndInChapter = null;
    if (hadPreview) {
      onPreviewChanged();
    }
  }
}
