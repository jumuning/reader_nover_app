part of 'models.dart';

@freezed
class BookSource with _$BookSource {
  const BookSource._();

  const factory BookSource({
    required int id,
    required String bookSourceName,
    String? bookSourceGroup,
    String? bookSourceComment,
    required String bookSourceUrl,
    int? customOrder,
    String? bookUrlPattern,
    int? bookSourceType,
    @Default(false) bool enabled,
    bool? enabledCookieJar,
    bool? enabledExplore,
    String? header,
    String? loginUrl,
    String? lastUpdateTime,
    String? exploreUrl,
    String? searchUrl,
    int? weight,
    bool? isEnabled,
    String? concurrentRate,
    int? respondTime,
    String? loginUi,
    String? loginCheckJs,
    String? coverDecodeJs,
    String? variableComment,
    String? exploreScreen,
  }) = _BookSource;

  factory BookSource.fromJson(Map<String, dynamic> json) =>
      _$BookSourceFromJson(json);
}
