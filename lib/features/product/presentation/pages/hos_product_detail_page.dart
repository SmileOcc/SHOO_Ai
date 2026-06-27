import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:shoo/app/router/hos_routes.dart';
import 'package:shoo/core/auth/hos_auth_guard.dart';
import 'package:shoo/core/feedback/hos_toast.dart';
import 'package:shoo/core/share/hos_share_panel.dart';
import 'package:shoo/core/share/hos_share_service.dart';
import 'package:shoo/core/theme/hos_colors.dart';
import 'package:shoo/core/theme/hos_spacing.dart';
import 'package:shoo/core/theme/hos_theme_extension.dart';
import 'package:shoo/core/utils/hos_async_value_ui.dart';
import 'package:shoo/core/widgets/hos_app_loading.dart';
import 'package:shoo/core/widgets/hos_banner_carousel.dart';
import 'package:shoo/core/widgets/hos_button.dart';
import 'package:shoo/core/widgets/hos_circle_overlay_button.dart';
import 'package:shoo/core/widgets/hos_error_view.dart';
import 'package:shoo/core/widgets/hos_price_text.dart';
import 'package:shoo/core/widgets/hos_promo_badge.dart';
import 'package:shoo/core/widgets/hos_promo_tag.dart';
import 'package:shoo/core/widgets/hos_skeleton_box.dart';
import 'package:shoo/l10n/app_localizations.dart';
import 'package:shoo/features/cart/presentation/state/hos_cart_badge_provider.dart';
import 'package:shoo/features/cart/presentation/widgets/hos_sku_sheet.dart';
import 'package:shoo/features/home/domain/entities/hos_banner.dart';
import 'package:shoo/features/review/presentation/state/hos_review_controller.dart';
import 'package:shoo/features/review/presentation/widgets/hos_review_tile.dart';
import 'package:shoo/features/product/domain/entities/hos_product_detail.dart';
import 'package:shoo/features/profile/presentation/state/hos_profile_controller.dart';
import 'package:shoo/features/product/presentation/state/hos_product_controller.dart';
import 'package:shoo/features/product/presentation/state/hos_product_footprint_recorder.dart';
import 'package:shoo/features/product/presentation/state/hos_product_view_reporter.dart';
import 'package:shoo/features/profile/domain/entities/hos_profile_activity_product.dart';
import 'package:shoo/features/flash_sale/domain/entities/hos_flash_sale_models.dart';
import 'package:shoo/features/flash_sale/presentation/state/hos_checkout_activity_provider.dart';
import 'package:shoo/features/flash_sale/presentation/state/hos_flash_sale_controller.dart';

class SHOProductDetailPage extends ConsumerWidget {
  const SHOProductDetailPage({
    super.key,
    required this.productId,
    this.sessionId,
  });

  final String productId;
  final String? sessionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final detailAsync = ref.watch(productDetailProvider(productId));
    final reviewsAsync = ref.watch(productReviewsProvider(productId));
    final activityAsync = sessionId != null && sessionId!.isNotEmpty
        ? ref.watch(
            flashSaleProductActivityProvider(
              (productId: productId, sessionId: sessionId!),
            ),
          )
        : null;
    final topInset = MediaQuery.paddingOf(context).top;
    final heroHeight = 360.0 + topInset;

    void handleBack() {
      if (context.canPop()) {
        context.pop();
      } else {
        context.go(SHOAppRoutes.home);
      }
    }

    return Stack(
      children: [
        SHOProductViewReporter(productId: productId),
        detailAsync.whenWidget(
      loading: _SHOProductDetailSkeleton(heroHeight: heroHeight),
      error: (error, _) => _SHOProductDetailError(
        message: error.toString(),
        onBack: handleBack,
        onRetry: () => ref.invalidate(productDetailProvider(productId)),
      ),
      data: (detail) {
        final activity = activityAsync?.maybeWhen(
          data: (value) => value,
          orElse: () => null,
        );
        final displayPrice = activity?.displayPrice ?? detail.price;
        final showActivityPrice = activity?.showActivityPrice ?? false;
        final originalPrice = showActivityPrice
            ? activity!.originalPrice
            : detail.originalPrice;

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

        return Stack(
          children: [
            SHOProductFootprintRecorder(detail: detail),
            AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light,
          child: Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            body: Stack(
              children: [
                CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Stack(
                        children: [
                          SHOBannerCarousel(
                            banners: banners,
                            height: heroHeight,
                            edgeToEdge: true,
                            showTitleOverlay: false,
                            showIndicators: banners.length > 1,
                            autoPlay: false,
                          ),
                          if (activity?.overlayLabel != null)
                            Positioned(
                              left: 0,
                              right: 0,
                              bottom: 0,
                              child: SHOPromoBadge(
                                type: SHOPromoBadgeType.status,
                                label: activity!.overlayLabel!,
                                preset: SHOPromoBadgePreset.overlayBanner,
                                enabled: activity.status ==
                                    SHOFlashSaleProductStatus.ongoing,
                              ),
                            ),
                          if (activity?.primaryBadgeType != null &&
                              activity?.primaryPromoLabel != null)
                            Positioned(
                              left: SHOAppSpacing.pagePadding,
                              top: topInset + SHOAppSpacing.sm,
                              child: SHOPromoBadge(
                                type: activity!.primaryBadgeType!,
                                label: activity.primaryPromoLabel!,
                                preset: SHOPromoBadgePreset.cornerOnImage,
                                enabled: activity.status ==
                                        SHOFlashSaleProductStatus.ongoing ||
                                    activity.status ==
                                        SHOFlashSaleProductStatus.notStarted,
                              ),
                            ),
                        ],
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.all(SHOAppSpacing.pagePadding),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          if (detail.discountLabel.isNotEmpty && activity == null)
                            SHOPromoTag(label: detail.discountLabel),
                          if (detail.discountLabel.isNotEmpty && activity == null)
                            const SizedBox(height: SHOAppSpacing.sm),
                          if (activity != null && activity.promoTags.isNotEmpty) ...[
                            SHOPromoBadgeWrap(
                              tags: activity.promoTags
                                  .map((t) => t.toBadgeData())
                                  .toList(),
                              enabled: activity.status ==
                                  SHOFlashSaleProductStatus.ongoing,
                            ),
                            const SizedBox(height: SHOAppSpacing.sm),
                          ],
                          Text(
                            detail.title,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                          const SizedBox(height: SHOAppSpacing.md),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Expanded(
                                child: SHOAppPriceText(
                                  priceCents: displayPrice,
                                  originalCents: showActivityPrice ? originalPrice : detail.originalPrice,
                                  showOriginal: showActivityPrice ||
                                      detail.originalPrice > detail.price,
                                ),
                              ),
                              if (activity != null &&
                                  activity.primaryBadgeType != null &&
                                  activity.primaryPromoLabel != null)
                                SHOPromoBadge(
                                  type: activity.primaryBadgeType!,
                                  label: activity.primaryPromoLabel!,
                                  preset: SHOPromoBadgePreset.priceInline,
                                  enabled: activity.status ==
                                      SHOFlashSaleProductStatus.ongoing,
                                ),
                            ],
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
                          const SizedBox(height: 88),
                        ]),
                      ),
                    ),
                  ],
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: _SHOProductDetailTopBar(
                    product: detail,
                    onBack: handleBack,
                  ),
                ),
              ],
            ),
            bottomNavigationBar: _SHOProductDetailFooter(
              cartCount: ref.watch(cartBadgeCountProvider),
              onCustomerService: () =>
                  SHOAppToast.info(l10n.productCustomerServiceHint),
              onCart: () {
                if (!SHOAuthGuard.requireAuth(context, ref)) return;
                context.push(SHOAppRoutes.cartStack);
              },
              onAddToBag: () {
                if (!SHOAuthGuard.requireAuth(context, ref)) return;
                SHOSkuSheet.show(context, detail, ref: ref);
              },
              onBuyNow: () {
                if (!SHOAuthGuard.requireAuth(context, ref)) return;
                final activityLine = activity != null
                    ? buildCheckoutActivityLineFromActivity(
                        productId: productId,
                        activity: activity,
                      )
                    : null;
                SHOSkuSheet.show(
                  context,
                  detail,
                  ref: ref,
                  intent: SHOSkuSheetIntent.buyNow,
                  checkoutActivityLine: activityLine,
                );
              },
            ),
          ),
        ),
          ],
        );
      },
    ),
      ],
    );
  }
}

class _SHOProductDetailTopBar extends ConsumerStatefulWidget {
  const _SHOProductDetailTopBar({
    required this.product,
    required this.onBack,
  });

  final SHOProductDetail product;
  final VoidCallback onBack;

  @override
  ConsumerState<_SHOProductDetailTopBar> createState() =>
      _SHOProductDetailTopBarState();
}

class _SHOProductDetailTopBarState extends ConsumerState<_SHOProductDetailTopBar> {
  final _shareCardKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final share = ref.read(shareServiceProvider);
    final link = share.productLink(widget.product.id);

    return Stack(
      clipBehavior: Clip.hardEdge,
      children: [
        Offstage(
          offstage: true,
          child: SHOShareService.offscreenShareCard(
            cardKey: _shareCardKey,
            product: widget.product,
          ),
        ),
        SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: SHOAppSpacing.pagePadding,
              vertical: SHOAppSpacing.sm,
            ),
            child: Row(
              children: [
                SHOCircleOverlayButton(
                  icon: Icons.arrow_back_ios_new_rounded,
                  tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                  onPressed: widget.onBack,
                ),
                const Spacer(),
                SHOCircleOverlayButton(
                  icon: ref
                          .watch(profileActivityProvider)
                          .favorites
                          .contains(widget.product.id)
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  tooltip: l10n.profileFavorites,
                  onPressed: () async {
                    final added = await ref
                        .read(profileActivityProvider.notifier)
                        .toggleFavorite(
                          widget.product.id,
                          cache: widget.product.toActivityCache(),
                        );
                    if (!context.mounted) return;
                    SHOAppToast.success(
                      added
                          ? l10n.profileFavoriteAdded
                          : l10n.profileFavoriteRemoved,
                    );
                  },
                ),
                const SizedBox(width: SHOAppSpacing.sm),
                SHOCircleOverlayButton(
                  icon: Icons.ios_share_rounded,
                  tooltip: l10n.sharePanelTitle,
                  onPressed: () => SHOSharePanel.show(
                    context,
                    ref,
                    title: widget.product.title,
                    link: link,
                    product: widget.product,
                    cardKey: _shareCardKey,
                  ),
                ),
                const SizedBox(width: SHOAppSpacing.sm),
                Builder(
                  builder: (buttonContext) => SHOCircleOverlayButton(
                    icon: Icons.more_horiz_rounded,
                    tooltip: l10n.productMore,
                    onPressed: () => _showMoreMenu(
                      buttonContext,
                      context,
                      ref,
                      widget.product,
                      link,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showMoreMenu(
    BuildContext buttonContext,
    BuildContext pageContext,
    WidgetRef ref,
    SHOProductDetail product,
    String link,
  ) {
    final l10n = AppLocalizations.of(pageContext);
    final box = buttonContext.findRenderObject() as RenderBox?;
    final anchor = box?.localToGlobal(Offset.zero) ?? Offset.zero;
    final size = box?.size ?? Size.zero;

    showMenu<String>(
      context: pageContext,
      position: RelativeRect.fromLTRB(
        anchor.dx - 80,
        anchor.dy + size.height + 4,
        anchor.dx + size.width,
        anchor.dy,
      ),
      items: [
        PopupMenuItem(
          value: 'share',
          child: Text(l10n.sharePanelTitle),
        ),
        PopupMenuItem(
          value: 'copy',
          child: Text(l10n.shareCopyLink),
        ),
      ],
    ).then((value) {
      if (!pageContext.mounted) return;
      if (value == 'share') {
        SHOSharePanel.show(
          pageContext,
          ref,
          title: product.title,
          link: link,
          product: product,
          cardKey: _shareCardKey,
        );
      } else if (value == 'copy') {
        Clipboard.setData(ClipboardData(text: link));
        SHOAppToast.success(l10n.shareLinkCopied);
      }
    });
  }
}

class _SHOProductDetailFooter extends StatelessWidget {
  const _SHOProductDetailFooter({
    required this.cartCount,
    required this.onCustomerService,
    required this.onCart,
    required this.onAddToBag,
    required this.onBuyNow,
  });

  final int cartCount;
  final VoidCallback onCustomerService;
  final VoidCallback onCart;
  final VoidCallback onAddToBag;
  final VoidCallback onBuyNow;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.shoTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.shoSurface,
        border: Border(top: BorderSide(color: theme.border)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: SHOAppSpacing.pagePadding,
            vertical: SHOAppSpacing.sm,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SHOFooterIconAction(
                icon: Icons.headset_mic_outlined,
                label: l10n.productCustomerService,
                onPressed: onCustomerService,
              ),
              const SizedBox(width: SHOAppSpacing.xs),
              SHOFooterIconAction(
                icon: Icons.shopping_bag_outlined,
                label: l10n.productCartShort,
                badge: cartCount,
                onPressed: onCart,
              ),
              const SizedBox(width: SHOAppSpacing.sm),
              Expanded(
                child: SHOAppButton(
                  label: l10n.productAddToBag,
                  variant: SHOAppButtonVariant.outline,
                  size: SHOAppButtonSize.sm,
                  onPressed: onAddToBag,
                ),
              ),
              const SizedBox(width: SHOAppSpacing.sm),
              Expanded(
                child: SHOAppButton(
                  label: l10n.productBuyNow,
                  variant: SHOAppButtonVariant.accent,
                  size: SHOAppButtonSize.sm,
                  onPressed: onBuyNow,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SHOProductDetailSkeleton extends StatelessWidget {
  const _SHOProductDetailSkeleton({required this.heroHeight});

  final double heroHeight;

  @override
  Widget build(BuildContext context) {
    final theme = context.shoTheme;
    const actionSize = 36.0;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          ListView(
            physics: const NeverScrollableScrollPhysics(),
            children: [
              SizedBox(
                height: heroHeight,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    const SHOSkeletonBox(),
                    Center(
                      child: SHOAppLoading(size: 80),
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(SHOAppSpacing.pagePadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SHOSkeletonBox(height: 18, width: 72),
                    SizedBox(height: SHOAppSpacing.sm),
                    SHOSkeletonBox(height: 22, width: double.infinity),
                    SizedBox(height: SHOAppSpacing.md),
                    SHOSkeletonBox(height: 20, width: 140),
                    SizedBox(height: SHOAppSpacing.sm),
                    SHOSkeletonBox(height: 14, width: 100),
                    SizedBox(height: SHOAppSpacing.xl),
                    SHOSkeletonBox(height: 16, width: 80),
                    SizedBox(height: SHOAppSpacing.sm),
                    SHOSkeletonBox(height: 14, width: double.infinity),
                    SizedBox(height: SHOAppSpacing.xs),
                    SHOSkeletonBox(height: 14, width: double.infinity),
                    SizedBox(height: SHOAppSpacing.xs),
                    SHOSkeletonBox(height: 14, width: 220),
                    SizedBox(height: SHOAppSpacing.xl),
                    SHOSkeletonBox(height: 16, width: 64),
                    SizedBox(height: SHOAppSpacing.md),
                    SHOSkeletonBox(height: 88),
                  ],
                ),
              ),
              const SizedBox(height: 88),
            ],
          ),
          const SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: SHOAppSpacing.pagePadding,
                vertical: SHOAppSpacing.sm,
              ),
              child: Row(
                children: [
                  SHOSkeletonBox(
                    width: actionSize,
                    height: actionSize,
                    borderRadius: BorderRadius.all(Radius.circular(actionSize / 2)),
                  ),
                  Spacer(),
                  SHOSkeletonBox(
                    width: actionSize,
                    height: actionSize,
                    borderRadius: BorderRadius.all(Radius.circular(actionSize / 2)),
                  ),
                  SizedBox(width: SHOAppSpacing.sm),
                  SHOSkeletonBox(
                    width: actionSize,
                    height: actionSize,
                    borderRadius: BorderRadius.all(Radius.circular(actionSize / 2)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          color: context.shoSurface,
          border: Border(top: BorderSide(color: theme.border)),
        ),
        child: const SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: SHOAppSpacing.pagePadding,
              vertical: SHOAppSpacing.sm,
            ),
            child: Row(
              children: [
                SHOSkeletonBox(width: 40, height: 40),
                SizedBox(width: SHOAppSpacing.xs),
                SHOSkeletonBox(width: 40, height: 40),
                SizedBox(width: SHOAppSpacing.sm),
                Expanded(child: SHOSkeletonBox(height: 36)),
                SizedBox(width: SHOAppSpacing.sm),
                Expanded(child: SHOSkeletonBox(height: 36)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SHOProductDetailError extends StatelessWidget {
  const _SHOProductDetailError({
    required this.message,
    required this.onBack,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onBack;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: onBack,
        ),
        title: Text(l10n.productDetailTitle),
      ),
      body: SHOAppErrorView(
        message: message,
        onRetry: onRetry,
      ),
    );
  }
}
