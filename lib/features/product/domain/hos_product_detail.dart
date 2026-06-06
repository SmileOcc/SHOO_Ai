import 'package:freezed_annotation/freezed_annotation.dart';

part 'hos_product_detail.freezed.dart';
part 'hos_product_detail.g.dart';

@freezed
class SHOProductDetail with _$SHOProductDetail {
  const factory SHOProductDetail({
    required String id,
    required String title,
    required String imageUrl,
    required List<String> images,
    required int price,
    required int originalPrice,
    @Default('') String discountLabel,
    required double rating,
    @Default(0) int soldCount,
    @Default('') String description,
    @Default(0) int reviewCount,
  }) = _SHOProductDetail;

  factory SHOProductDetail.fromJson(Map<String, dynamic> json) =>
      _$SHOProductDetailFromJson(json);
}
