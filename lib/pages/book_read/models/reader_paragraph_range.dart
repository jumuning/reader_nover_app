class ReaderParagraphRange {
  const ReaderParagraphRange({
    required this.start,
    required this.end,
    required this.text,
  });

  final int start;
  final int end;
  final String text;

  bool get isEmpty => end <= start || text.trim().isEmpty;

  String toPreview({int maxLength = 28}) {
    final normalized = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (normalized.length <= maxLength) {
      return normalized;
    }
    return '${normalized.substring(0, maxLength)}...';
  }
}
