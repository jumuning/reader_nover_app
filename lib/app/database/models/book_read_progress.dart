part of 'models.dart';

@freezed
class BookReadProgress with _$BookReadProgress {
  const factory BookReadProgress({
    required int id,
    required int bookSourceId,
    required String bookName,
    required int chapterIndex,
    required String locatorJson,
    required DateTime updateTime,
  }) = _BookReadProgress;

  factory BookReadProgress.fromJson(Map<String, dynamic> json) =>
      _$BookReadProgressFromJson(json);
}
