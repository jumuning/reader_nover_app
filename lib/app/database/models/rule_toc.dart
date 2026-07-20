part of 'models.dart';

@freezed
class RuleToc with _$RuleToc {
  const RuleToc._();

  const factory RuleToc({
    required int id,
    required int bookSourceId,
    String? chapterList,
    String? chapterName,
    String? chapterUrl,
    String? nextTocUrl,
    String? preUpdateJs,
    String? formatJs,
    String? isVolume,
    String? isVip,
    String? isPay,
    String? updateTime,
  }) = _RuleToc;

  factory RuleToc.fromJson(Map<String, dynamic> json) =>
      _$RuleTocFromJson(json);
}
