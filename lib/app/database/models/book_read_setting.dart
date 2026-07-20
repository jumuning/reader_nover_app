part of 'models.dart';

/// 阅读设置
@freezed
class BookReadSetting with _$BookReadSetting {
  const BookReadSetting._();

  const factory BookReadSetting({
    required int id,
    required DateTime updateTime,
    double? fontSize,
    double? fontHeight,
    double? wordSpacing,
    double? letterSpacing,
    String? fontFamily,
  }) = _BookReadSetting;
}
