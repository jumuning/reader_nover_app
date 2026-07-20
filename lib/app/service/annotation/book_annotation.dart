import 'dart:convert';

enum BookAnnotationType { highlight, underline, note }

class BookAnnotation {
  const BookAnnotation({
    required this.id,
    required this.bookSourceId,
    required this.bookName,
    required this.chapterIndex,
    required this.chapterName,
    required this.locatorJson,
    required this.type,
    required this.excerpt,
    required this.note,
    required this.colorValue,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final int bookSourceId;
  final String bookName;
  final int chapterIndex;
  final String chapterName;

  /// Opaque serialized locator. Its schema belongs to the reader locator model.
  final String locatorJson;
  final BookAnnotationType type;
  final String excerpt;
  final String note;
  final int? colorValue;
  final DateTime createdAt;
  final DateTime updatedAt;

  BookAnnotation copyWith({
    BookAnnotationType? type,
    String? excerpt,
    String? note,
    int? colorValue,
    bool clearColor = false,
    String? locatorJson,
    DateTime? updatedAt,
  }) {
    return BookAnnotation(
      id: id,
      bookSourceId: bookSourceId,
      bookName: bookName,
      chapterIndex: chapterIndex,
      chapterName: chapterName,
      locatorJson: locatorJson ?? this.locatorJson,
      type: type ?? this.type,
      excerpt: excerpt ?? this.excerpt,
      note: note ?? this.note,
      colorValue: clearColor ? null : colorValue ?? this.colorValue,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static bool isValidLocatorJson(String value) {
    try {
      return jsonDecode(value) is Map<String, dynamic>;
    } on FormatException {
      return false;
    }
  }
}

class BookAnnotationDraft {
  const BookAnnotationDraft({
    required this.bookSourceId,
    required this.bookName,
    required this.chapterIndex,
    required this.chapterName,
    required this.locatorJson,
    required this.type,
    this.excerpt = '',
    this.note = '',
    this.colorValue,
  });

  final int bookSourceId;
  final String bookName;
  final int chapterIndex;
  final String chapterName;
  final String locatorJson;
  final BookAnnotationType type;
  final String excerpt;
  final String note;
  final int? colorValue;
}

class BookAnnotationQuery {
  const BookAnnotationQuery({
    this.bookSourceId,
    this.bookName,
    this.chapterIndex,
    this.type,
    this.keyword,
  });

  final int? bookSourceId;
  final String? bookName;
  final int? chapterIndex;
  final BookAnnotationType? type;
  final String? keyword;
}

class BookAnnotationStats {
  const BookAnnotationStats({
    required this.total,
    required this.highlightCount,
    required this.underlineCount,
    required this.noteCount,
  });

  final int total;
  final int highlightCount;
  final int underlineCount;
  final int noteCount;
}
