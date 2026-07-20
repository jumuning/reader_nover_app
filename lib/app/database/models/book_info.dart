part of 'models.dart';

// 定义书籍简介类
@freezed
class BookInfo with _$BookInfo {
  const BookInfo._();

  const factory BookInfo({
    required int bookSourceId,
    required String name,
    String? author,
    String? cover,
    String? intro,
    String? kind,
    String? lastChapter,
    String? wordCount,
    String? bookUrl,
    String? tocUrl,
  }) = _BookInfo;

  factory BookInfo.fromJson(Map<String, dynamic> json) =>
      _$BookInfoFromJson(json);
}
