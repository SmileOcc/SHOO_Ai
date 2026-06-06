import 'package:flutter/material.dart';

import '../../features/home/domain/hos_product.dart';
import '../theme/hos_colors.dart';
import '../theme/hos_spacing.dart';
import '../utils/hos_price_formatter.dart';
import 'hos_network_image.dart';
import 'hos_price_text.dart';
import 'hos_promo_tag.dart';

/// 双列商品卡（Shein 风格）：图 + 促销标签 + 价格 + 评分。
///
/// ```dart
/// SHOProductCard(
///   product: item,
///   onTap: () => context.push('/product/${item.id}'),
/// )
/// ```
class SHOProductCard extends StatelessWidget {
  const SHOProductCard({
    super.key,
    required this.product,
    this.onTap,
  });

  final SHOProduct product;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 4 / 5,
            child: Stack(
              children: [
                Positioned.fill(
                  child: SHOAppNetworkImage(
                    url: product.imageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
                if (product.discountLabel.isNotEmpty)
                  Positioned(
                    left: SHOAppSpacing.xs,
                    top: SHOAppSpacing.xs,
                    child: SHOPromoTag(label: product.discountLabel),
                  ),
              ],
            ),
          ),
          const SizedBox(height: SHOAppSpacing.sm),
          Text(
            product.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: SHOAppColors.textPrimary,
                  fontSize: 11,
                  height: 1.25,
                ),
          ),
          const SizedBox(height: SHOAppSpacing.xs),
          SHOAppPriceText(
            priceCents: product.price,
            originalCents: product.originalPrice,
            size: SHOAppPriceSize.small,
          ),
          const SizedBox(height: SHOAppSpacing.xxs),
          Row(
            children: [
              const Icon(Icons.star_rounded, size: 11, color: SHOAppColors.warning),
              const SizedBox(width: 2),
              Text(
                product.rating.toStringAsFixed(1),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(width: SHOAppSpacing.sm),
              Expanded(
                child: Text(
                  SHOPriceFormatter.compactCount(product.soldCount),
                  style: Theme.of(context).textTheme.bodySmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
