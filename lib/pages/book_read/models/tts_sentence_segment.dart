class TtsSentenceSegment {
  const TtsSentenceSegment({
    required this.text,
    required this.start,
    required this.end,
    required this.normalizedStart,
    required this.normalizedEnd,
  });

  final String text;

  /// 原始页文本中的起始偏移（包含）
  final int start;

  /// 原始页文本中的结束偏移（不包含）
  final int end;

  /// 标准化文本中的起始偏移（包含）
  final int normalizedStart;

  /// 标准化文本中的结束偏移（不包含）
  final int normalizedEnd;

  int get rawLength => end - start;

  int get normalizedLength => normalizedEnd - normalizedStart;
}
