part of 'models.dart';

@freezed
class ExploreKind with _$ExploreKind {
  const ExploreKind._();

  const factory ExploreKind({
    required String title,
    required String url,
    required int bookSourceId,
    required String bookSourceName,
  }) = _ExploreKind;

  factory ExploreKind.fromJson(Map<String, dynamic> json) =>
      _$ExploreKindFromJson(json);

  String get uniqueKey => '$bookSourceId-$url';
}
