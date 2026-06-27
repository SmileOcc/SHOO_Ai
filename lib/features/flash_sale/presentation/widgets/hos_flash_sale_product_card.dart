import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shoo/app/router/hos_routes.dart';
import 'package:shoo/core/auth/hos_auth_guard.dart';
import 'package:shoo/core/feedback/hos_toast.dart';
import 'package:shoo/core/theme/hos_colors.dart';
import 'package:shoo/core/theme/hos_spacing.dart';
import 'package:shoo/core/theme/hos_theme_extension.dart';
import 'package:shoo/core/widgets/hos_profile_section_card.dart';
import 'package:shoo/core/widgets/hos_button.dart';
import 'package:shoo/core/widgets/hos_price_text.dart';
import 'package:shoo/core/widgets/hos_promo_badge.dart';
import 'package:shoo/features/flash_sale/domain/entities/hos_flash_sale_models.dart';
import 'package:shoo/features/flash_sale/presentation/state/hos_checkout_activity_provider.dart';
import 'package:shoo/features/flash_sale/presentation/state/hos_flash_sale_controller.dart';
import 'package:shoo/features/flash_sale/presentation/widgets/hos_sku_chip_row.dart';
import 'package:shoo/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

class SHOFlashSaleProductCard extends ConsumerWidget {
  const SHOFlashSaleProductCard({
    super.key,
    required this.product,
    required this.activityId,
  });

  final SHOFlashSaleProduct product;
  final String activityId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final controller =
        ref.read(flashSaleControllerProvider(activityId).notifier);

    return Material(
      color: context.shoSurface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(SHOProfileSectionCard.radius),
        side: BorderSide(
          color: context.shoTheme.border,
          width: SHOProfileSectionCard.borderWidth,
        ),
      ),
      child: InkWell(
        onTap: () => context.push(
          '${SHOAppRoutes.product(product.id)}?sessionId=${Uri.encodeComponent(product.sessionId)}',
        ),
        borderRadius: BorderRadius.circular(SHOProfileSectionCard.radius),
        child: Padding(
          padding: const EdgeInsets.all(SHOAppSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ProductImage(product: product),
              const SizedBox(width: SHOAppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: SHOAppSpacing.xs),
                    SHOSkuChipRow(
                      attributes: product.skuAttributes,
                      initialMaxLines: 1,
                    ),
                    const SizedBox(height: SHOAppSpacing.xs),
                    SHOPromoBadgeWrap(
                      tags: product.badgeTags,
                      enabled: product.status == SHOFlashSaleProductStatus.ongoing,
                    ),
                    const SizedBox(height: SHOAppSpacing.sm),
                    Row(
                      children: [
                        Expanded(
                          child: SHOAppPriceText(
                            priceCents: product.displayPrice,
                            originalCents:
                                product.status == SHOFlashSaleProductStatus.ongoing
                                    ? product.originalPrice
                                    : null,
                            size: SHOAppPriceSize.small,
                            showOriginal:
                                product.status == SHOFlashSaleProductStatus.ongoing,
                          ),
                        ),
                        Text(
                          product.stock <= 0
                              ? l10n.flashSaleSoldOut
                              : l10n.flashSaleStockLeft(product.stock),
                          style: TextStyle(
                            fontSize: 11,
                            color: product.stock <= 0
                                ? SHOAppColors.textMuted
                                : SHOAppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: SHOAppSpacing.sm),
                    _ActionRow(
                      product: product,
                      onFollow: () async {
                        if (!SHOAuthGuard.requireAuth(context, ref)) return;
                        await controller.toggleFollow(product);
                      },
                      onBuy: () => _handleBuy(context, ref, product, l10n),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleBuy(
    BuildContext context,
    WidgetRef ref,
    SHOFlashSaleProduct product,
    AppLocalizations l10n,
  ) {
    if (product.status == SHOFlashSaleProductStatus.notStarted) {
      context.showToast(l10n.flashSaleNotStartedHint);
      return;
    }
    if (!product.canPurchase) {
      context.showToast(
        product.stock <= 0 ? l10n.flashSaleSoldOutHint : l10n.flashSaleEndedHint,
      );
      return;
    }
    final line = buildCheckoutActivityLine(product);
    if (line != null) {
      setCheckoutActivityLine(ref, line);
    }
    context.push(
      '${SHOAppRoutes.product(product.id)}?sessionId=${Uri.encodeComponent(product.sessionId)}',
    );
  }
}

class _ProductImage extends StatelessWidget {
  const _ProductImage({required this.product});

  final SHOFlashSaleProduct product;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 96,
      height: 96,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(SHOAppSpacing.cardRadius),
            child: CachedNetworkImage(
              imageUrl: product.imageUrl,
              width: 96,
              height: 96,
              fit: BoxFit.cover,
            ),
          ),
          if (product.primaryBadgeType != null &&
              product.primaryPromoLabel != null)
            Positioned(
              left: 0,
              top: 0,
              child: SHOPromoBadge(
                type: product.primaryBadgeType!,
                label: product.primaryPromoLabel!,
                preset: SHOPromoBadgePreset.cornerOnImage,
                enabled: product.status == SHOFlashSaleProductStatus.ongoing ||
                    product.status == SHOFlashSaleProductStatus.notStarted,
              ),
            ),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.product,
    required this.onFollow,
    required this.onBuy,
  });

  final SHOFlashSaleProduct product;
  final VoidCallback onFollow;
  final VoidCallback onBuy;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (product.status == SHOFlashSaleProductStatus.notStarted) {
      return Row(
        children: [
          Expanded(
            child: SHOAppButton(
              label: product.isFollowed ? l10n.flashSaleFollowed : l10n.flashSaleFollow,
              variant: SHOAppButtonVariant.outline,
              size: SHOAppButtonSize.sm,
              onPressed: onFollow,
            ),
          ),
          const SizedBox(width: SHOAppSpacing.sm),
          Expanded(
            child: SHOAppButton(
              label: l10n.flashSaleBuyNow,
              size: SHOAppButtonSize.sm,
              onPressed: null,
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        SHOAppButton(
          label: product.isFollowed ? l10n.flashSaleFollowed : l10n.flashSaleFollow,
          variant: SHOAppButtonVariant.outline,
          size: SHOAppButtonSize.sm,
          onPressed: (product.canFollow || product.isFollowed) ? onFollow : null,
        ),
        const SizedBox(width: SHOAppSpacing.sm),
        Expanded(
          child: SHOAppButton(
            label: l10n.flashSaleBuyNow,
            size: SHOAppButtonSize.sm,
            onPressed: product.canPurchase ? onBuy : null,
          ),
        ),
      ],
    );
  }
}
