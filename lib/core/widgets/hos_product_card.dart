import 'package:flutter/material.dart';

import '../../features/home/domain/hos_product.dart';
import '../theme/hos_colors.dart';
import '../theme/hos_spacing.dart';
import '../theme/hos_theme_extension.dart';
import '../utils/hos_price_formatter.dart';
import 'hos_network_image.dart';
import 'hos_price_text.dart';
import 'hos_promo_tag.dart';
import 'hos_profile_section_card.dart';

/// 双列商品卡：圆角卡片 + 图 + 标题 + 价格 + 评分。
class SHOProductCard extends StatelessWidget {
  const SHOProductCard({
    super.key,
    required this.product,
    this.onTap,
  });

  final SHOProduct product;
  final VoidCallback? onTap;

  static const double cornerRadius = SHOProfileSectionCard.radius;

  /// 双列网格宽高比（宽/高）。略降低以容纳两行标题 + 价格 + 评分。
  static const double gridChildAspectRatio = 0.66;

  static const double _titleFontSize = 11;
  static const double _titleLineHeight = 1.25;
  static const int _titleMaxLines = 2;
  static const double _titleBlockHeight =
      _titleFontSize * _titleLineHeight * _titleMaxLines;

  @override
  Widget build(BuildContext context) {
    final theme = context.shoTheme;

    return GestureDetector(
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: context.shoSurface,
          borderRadius: BorderRadius.circular(cornerRadius),
          border: Border.all(
            color: theme.border,
            width: SHOProfileSectionCard.borderWidth,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(cornerRadius),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AspectRatio(
                aspectRatio: 1,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    SHOAppNetworkImage(
                      url: product.imageUrl,
                      fit: BoxFit.cover,
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
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    SHOAppSpacing.md,
                    SHOAppSpacing.sm,
                    SHOAppSpacing.md,
                    SHOAppSpacing.sm,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: _titleBlockHeight,
                        child: Text(
                          product.title,
                          maxLines: _titleMaxLines,
                          overflow: TextOverflow.ellipsis,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: SHOAppColors.textPrimary,
                                    fontSize: _titleFontSize,
                                    height: _titleLineHeight,
                                  ),
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
                          const Icon(
                            Icons.star_rounded,
                            size: 11,
                            color: SHOAppColors.warning,
                          ),
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
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
