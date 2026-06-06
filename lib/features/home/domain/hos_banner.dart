import 'package:freezed_annotation/freezed_annotation.dart';

part 'hos_banner.freezed.dart';
part 'hos_banner.g.dart';

@freezed
class SHOBannerItem with _$SHOBannerItem {
  const factory SHOBannerItem({
    required String id,
    required String imageUrl,
    required String link,
    required String title,
  }) = _SHOBannerItem;

  factory SHOBannerItem.fromJson(Map<String, dynamic> json) =>
      _$SHOBannerItemFromJson(json);
}
