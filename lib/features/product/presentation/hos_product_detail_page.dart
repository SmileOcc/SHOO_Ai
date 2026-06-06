import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/hos_routes.dart';
import '../../../core/theme/hos_colors.dart';
import '../../../core/theme/hos_spacing.dart';
import '../../../core/utils/hos_async_value_ui.dart';
import '../../../core/widgets/hos_banner_carousel.dart';
import '../../../core/widgets/hos_button.dart';
import '../../../core/widgets/hos_error_view.dart';
import '../../../core/widgets/hos_price_text.dart';
import '../../../core/widgets/hos_promo_tag.dart';
import '../../../core/widgets/hos_skeleton_box.dart';
import '../../../l10n/app_localizations.dart';
import '../../home/domain/hos_banner.dart';
import '../../cart/presentation/hos_sku_sheet.dart';
import '../../review/presentation/hos_review_controller.dart';
import '../../review/presentation/hos_review_tile.dart';
import 'hos_product_controller.dart';

class SHOProductDetailPage extends ConsumerWidget {
  const SHOProductDetailPage({super.key, required this.productId});

  final String productId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final detailAsync = ref.watch(productDetailProvider(productId));
    final reviewsAsync = ref.watch(productReviewsProvider(productId));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.productDetailTitle)),
      body: detailAsync.whenWidget(
        loading: const _SHOProductDetailSkeleton(),
        error: (error, _) => SHOAppErrorView(
          message: error.toString(),
          onRetry: () => ref.invalidate(productDetailProvider(productId)),
        ),
        data: (detail) {
          final banners = detail.images
              .map(
                (url) => SHOBannerItem(
                  id: url,
                  imageUrl: url,
                  link: '',
                  title: detail.title,
                ),
              )
              .toList();

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    SHOBannerCarousel(banners: banners, height: 360),
                    Padding(
                      padding: const EdgeInsets.all(SHOAppSpacing.pagePadding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (detail.discountLabel.isNotEmpty)
                            SHOPromoTag(label: detail.discountLabel),
                          if (detail.discountLabel.isNotEmpty)
                            const SizedBox(height: SHOAppSpacing.sm),
                          Text(
                            detail.title,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                          const SizedBox(height: SHOAppSpacing.md),
                          SHOAppPriceText(
                            priceCents: detail.price,
                            originalCents: detail.originalPrice,
                          ),
                          const SizedBox(height: SHOAppSpacing.sm),
                          Row(
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                size: 16,
                                color: SHOAppColors.warning,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${detail.rating.toStringAsFixed(1)} · ${detail.soldCount} sold',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                          const SizedBox(height: SHOAppSpacing.xl),
                          Text(
                            l10n.productDescriptionTitle,
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                          const SizedBox(height: SHOAppSpacing.sm),
                          Text(
                            detail.description,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontSize: 13,
                                  height: 1.5,
                                ),
                          ),
                          const SizedBox(height: SHOAppSpacing.xl),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                l10n.reviewsTitle,
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w800,
                                    ),
                              ),
                              TextButton(
                                onPressed: () => context.push(
                                  SHOAppRoutes.productReviews(productId),
                                ),
                                child: Text(l10n.reviewsViewAll),
                              ),
                            ],
                          ),
                          reviewsAsync.when(
                            loading: () => const SHOSkeletonBox(height: 120),
                            error: (_, __) => const SizedBox.shrink(),
                            data: (summary) {
                              if (summary.items.isEmpty) {
                                return Text(
                                  l10n.reviewsEmpty,
                                  style: Theme.of(context).textTheme.bodySmall,
                                );
                              }
                              return Column(
                                children: summary.items
                                    .take(2)
                                    .map((r) => SHOReviewTile(review: r))
                                    .toList(),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.all(SHOAppSpacing.pagePadding),
                  child: SHOAppButton(
                    label: l10n.productAddToBag,
                    isExpanded: true,
                    onPressed: () => SHOSkuSheet.show(context, detail),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SHOProductDetailSkeleton extends StatelessWidget {
  const _SHOProductDetailSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(SHOAppSpacing.pagePadding),
      children: const [
        SHOSkeletonBox(height: 360),
        SizedBox(height: SHOAppSpacing.lg),
        SHOSkeletonBox(height: 24, width: 200),
        SizedBox(height: SHOAppSpacing.md),
        SHOSkeletonBox(height: 16, width: 120),
        SizedBox(height: SHOAppSpacing.xl),
        SHOSkeletonBox(height: 80),
      ],
    );
  }
}
