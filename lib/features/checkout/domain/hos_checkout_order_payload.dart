import 'package:shoo/core/pricing/hos_full_reduction.dart';
import 'package:shoo/features/cart/domain/entities/hos_cart.dart';

/// 结算下单请求体字段，与 API `CreateOrderItemDto` 对齐。
abstract final class SHOCheckoutOrderPayload {
  static Map<String, dynamic> itemFromCart({
    required SHOCartItem item,
    SHOCheckoutActivityLine? activityLine,
  }) {
    final variant = item.variantLabel.trim();
    return {
      'productId': item.productId,
      'title': item.title,
      'imageUrl': item.imageUrl,
      'price': activityLine?.unitPriceCents ?? item.effectiveUnitCents,
      'quantity': item.quantity,
      if (variant.isNotEmpty) 'variantLabel': variant,
    };
  }
}
