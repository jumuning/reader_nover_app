abstract final class LocalBookConstants {
  static const int sourceId = -1;
  static const String sourceName = '本地书籍';
  static const String sourceUrl = 'local://imported-books';
  static const String bookGroup = '本地';
  static const String kind = '本地';
  static const String txtFormat = 'txt';
  static const String epubFormat = 'epub';

  static bool isLocalBookSource(int bookSourceId) => bookSourceId == sourceId;

  static bool isLocalChapterUrl(String? url) {
    return url?.trim().startsWith('local://') == true;
  }

  static String chapterUrl({
    required int bookId,
    required int chapterIndex,
    int? startOffset,
    int? endOffset,
  }) {
    final hasRange = startOffset != null && endOffset != null;
    if (!hasRange) {
      return 'local://book/$bookId/chapter/$chapterIndex';
    }
    return 'local://book/$bookId/chapter/$chapterIndex'
        '?start=$startOffset&end=$endOffset&unit=byte';
  }

  static LocalChapterReference? parseChapterUrl(String? url) {
    final normalized = url?.trim();
    if (normalized == null || normalized.isEmpty) return null;

    final uri = Uri.tryParse(normalized);
    if (uri == null || uri.scheme != 'local' || uri.host != 'book') {
      return null;
    }

    final segments = uri.pathSegments;
    if (segments.length < 3 || segments[1] != 'chapter') {
      return null;
    }

    final bookId = int.tryParse(segments[0]);
    final chapterIndex = int.tryParse(segments[2]);
    if (bookId == null || chapterIndex == null) return null;

    return LocalChapterReference(
      bookId: bookId,
      chapterIndex: chapterIndex,
      startOffset: int.tryParse(uri.queryParameters['start'] ?? ''),
      endOffset: int.tryParse(uri.queryParameters['end'] ?? ''),
      rangeUnit: uri.queryParameters['unit'],
    );
  }
}

class LocalChapterReference {
  const LocalChapterReference({
    required this.bookId,
    required this.chapterIndex,
    required this.startOffset,
    required this.endOffset,
    required this.rangeUnit,
  });

  final int bookId;
  final int chapterIndex;
  final int? startOffset;
  final int? endOffset;
  final String? rangeUnit;

  bool get hasRange =>
      startOffset != null && endOffset != null && startOffset! <= endOffset!;

  bool get isByteRange => hasRange && rangeUnit == 'byte';
}
