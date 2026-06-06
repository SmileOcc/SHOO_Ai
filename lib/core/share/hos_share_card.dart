import 'package:flutter/material.dart';

import '../../features/product/domain/hos_product_detail.dart';
import '../deeplink/hos_deeplink_config.dart';
import '../theme/hos_colors.dart';
import '../theme/hos_spacing.dart';
import '../widgets/hos_network_image.dart';
import '../widgets/hos_price_text.dart';

/// 商品分享卡片（用于生成分享图）。
class SHOShareProductCard extends StatelessWidget {
  const SHOShareProductCard({
    super.key,
    required this.product,
    this.width = 320,
  });

  final SHOProductDetail product;
  final double width;

  @override
  Widget build(BuildContext context) {
    final imageUrl = product.images.isNotEmpty ? product.images.first : product.imageUrl;

    return Container(
      width: width,
      decoration: BoxDecoration(
        color: SHOAppColors.surface,
        borderRadius: BorderRadius.circular(SHOAppSpacing.cardRadius),
        border: Border.all(color: SHOAppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(SHOAppSpacing.cardRadius),
            ),
            child: AspectRatio(
              aspectRatio: 1,
              child: SHOAppNetworkImage(url: imageUrl),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(SHOAppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: SHOAppColors.textPrimary,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: SHOAppSpacing.sm),
                SHOAppPriceText(
                  priceCents: product.price,
                  originalCents: product.originalPrice,
                  size: SHOAppPriceSize.large,
                ),
                const SizedBox(height: SHOAppSpacing.md),
                Row(
                  children: [
                    const Icon(Icons.star_rounded, size: 14, color: SHOAppColors.warning),
                    const SizedBox(width: 4),
                    Text(
                      product.rating.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 12,
                        color: SHOAppColors.textMuted,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'SHOO',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: SHOAppColors.primary.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: SHOAppSpacing.xs),
                Text(
                  SHODeepLinkConfig.productLink(product.id).toString(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10,
                    color: SHOAppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
