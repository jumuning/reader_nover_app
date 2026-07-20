part of 'models.dart';

// 定义书籍详情类
@freezed
class BookDetail with _$BookDetail {
  const BookDetail._();

  const factory BookDetail({
    required int bookSourceId,
    String? name,
    String? author,
    String? cover,
    String? intro,
    List<String>? kind,
    String? lastChapter,
    String? wordCount,
    String? downloadUrls,
    String? bookUrl,
    String? tocUrl,
    String? updateTime,
    // 添加章节 排序字段
    @Default(true) bool isAscending,
    // 添加章节列表字段  正序
    List<BookChapterInfo>? chapters,
  }) = _BookDetail;

  factory BookDetail.fromJson(Map<String, dynamic> json) =>
      _$BookDetailFromJson(json);
}
