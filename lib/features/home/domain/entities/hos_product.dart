import 'package:freezed_annotation/freezed_annotation.dart';

part 'hos_product.freezed.dart';
part 'hos_product.g.dart';

@freezed
class SHOProduct with _$SHOProduct {
  const factory SHOProduct({
    required String id,
    required String title,
    required String imageUrl,
    required int price,
    required int originalPrice,
    @Default('') String discountLabel,
    required double rating,
    @Default(0) int soldCount,
    @Default('') String categoryId,
  }) = _SHOProduct;

  factory SHOProduct.fromJson(Map<String, dynamic> json) =>
      _$SHOProductFromJson(json);
}
