part of 'models.dart';

@freezed
class RuleContent with _$RuleContent {
  const RuleContent._();

  const factory RuleContent({
    required int id,
    required int bookSourceId,
    String? content,
    String? nextContentUrl,
    String? replaceRegex,
    String? title,
    String? webJs,
    String? sourceRegex,
    String? imageStyle,
    String? imageDecode,
    String? payAction,
  }) = _RuleContent;

  factory RuleContent.fromJson(Map<String, dynamic> json) =>
      _$RuleContentFromJson(json);
}
