import '../../home/domain/hos_product.dart';
import '../../product/domain/hos_product_detail.dart';
import '../data/hos_profile_activity_storage.dart';

/// 足迹/收藏列表项：商品信息 + 是否仍有效。
class SHOProfileActivityProduct {
  const SHOProfileActivityProduct({
    required this.product,
    required this.available,
  });

  final SHOProduct product;
  final bool available;

  String get id => product.id;

  static SHOProfileActivityProduct fromDetail({
    required SHOProductDetail detail,
    required bool available,
  }) {
    return SHOProfileActivityProduct(
      available: available,
      product: SHOProduct(
        id: detail.id,
        title: detail.title,
        imageUrl: detail.imageUrl,
        price: detail.price,
        originalPrice: detail.originalPrice,
        discountLabel: detail.discountLabel,
        rating: detail.rating,
        soldCount: detail.soldCount,
      ),
    );
  }

  static SHOProfileActivityProduct fromCache({
    required String productId,
    required SHOProfileProductCache cache,
    required bool available,
  }) {
    return SHOProfileActivityProduct(
      available: available,
      product: SHOProduct(
        id: productId,
        title: cache.title,
        imageUrl: cache.imageUrl,
        price: cache.price,
        originalPrice: cache.originalPrice,
        rating: cache.rating,
        soldCount: cache.soldCount,
      ),
    );
  }
}

extension SHOProductDetailActivityX on SHOProductDetail {
  SHOProfileProductCache toActivityCache() => SHOProfileProductCache(
        title: title,
        imageUrl: imageUrl,
        price: price,
        originalPrice: originalPrice,
        rating: rating,
        soldCount: soldCount,
      );
}
