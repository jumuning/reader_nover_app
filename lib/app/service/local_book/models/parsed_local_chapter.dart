class ParsedLocalChapter {
  const ParsedLocalChapter({
    required this.index,
    required this.name,
    required this.startOffset,
    required this.endOffset,
    this.contentCharLength,
    this.content,
  });

  final int index;
  final String name;
  final int startOffset;
  final int endOffset;
  final int? contentCharLength;
  final String? content;

  int get contentLength => contentCharLength ?? 0;
}
