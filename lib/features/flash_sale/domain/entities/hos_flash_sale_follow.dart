import 'package:freezed_annotation/freezed_annotation.dart';

import 'hos_flash_sale_enums.dart';

part 'hos_flash_sale_follow.freezed.dart';
part 'hos_flash_sale_follow.g.dart';

@freezed
class SHOFlashSaleFollow with _$SHOFlashSaleFollow {
  const factory SHOFlashSaleFollow({
    required String id,
    required String sessionId,
    required String productId,
    required String title,
    required String imageUrl,
    required String sessionStartAt,
    @Default(SHOFlashSaleProductStatus.notStarted)
    SHOFlashSaleProductStatus status,
  }) = _SHOFlashSaleFollow;

  factory SHOFlashSaleFollow.fromJson(Map<String, dynamic> json) =>
      _$SHOFlashSaleFollowFromJson(json);
}