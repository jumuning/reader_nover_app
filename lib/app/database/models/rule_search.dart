part of 'models.dart';

@freezed
class RuleSearch with _$RuleSearch {
  const RuleSearch._();

  factory RuleSearch({
    required int id,
    required int bookSourceId,
    String? name,
    String? author,
    String? bookList,
    String? bookUrl,
    String? coverUrl,
    String? intro,
    String? kind,
    String? lastChapter,
    String? wordCount,
    String? tocUrl,
    String? checkKeyWord,
    String? updateTime,
  }) = _RuleSearch;

  factory RuleSearch.fromJson(Map<String, dynamic> json) =>
      _$RuleSearchFromJson(json);
}
