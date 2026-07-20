import 'parsed_local_chapter.dart';

class ParsedLocalBook {
  const ParsedLocalBook({
    required this.title,
    required this.author,
    required this.charset,
    required this.chapters,
    this.intro,
    this.coverPath,
    this.format = 'txt',
  });

  final String title;
  final String? author;
  final String charset;
  final List<ParsedLocalChapter> chapters;
  final String? intro;
  final String? coverPath;
  final String format;
}
