part of 'models.dart';

// 定义章节类
@freezed
class BookChapterInfo with _$BookChapterInfo {
  const BookChapterInfo._();

  const factory BookChapterInfo({
    required int bookSourceId,
    int? chapterIndex,
    String? chapterName,
    String? chapterUrl,
    @Default(false) bool isVolume,
    @Default(false) bool isVip,
    @Default(false) bool isPay,
    String? updateTime,
    String? baseUrl,
    @Default(<String, String>{}) Map<String, String> variables,
  }) = _BookChapterInfo;

  factory BookChapterInfo.fromJson(Map<String, dynamic> json) =>
      _$BookChapterInfoFromJson(json);
}
