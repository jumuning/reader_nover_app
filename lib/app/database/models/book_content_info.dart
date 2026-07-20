part of 'models.dart';

// 缓存章节内容
@freezed
class BookContentInfo with _$BookContentInfo {
  const BookContentInfo._();

  const factory BookContentInfo({
    required int id,
    required int bookSourceId,
    String? name,
    int? chapterIndex,
    List<String>? bookContentList,
    int? pageSize,
  }) = _BookContentInfo;

  factory BookContentInfo.fromJson(Map<String, dynamic> json) =>
      _$BookContentInfoFromJson(json);
}
