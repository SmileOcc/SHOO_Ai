import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/hos_routes.dart';
import '../../../core/auth/hos_auth_guard.dart';
import '../../../core/share/hos_share_panel.dart';
import '../../../core/theme/hos_colors.dart';
import '../../../core/theme/hos_spacing.dart';
import '../../../core/theme/hos_theme_extension.dart';
import '../../../core/utils/hos_price_formatter.dart';
import '../../../core/widgets/hos_empty_state.dart';
import '../../../core/widgets/hos_product_card.dart';
import '../../../core/widgets/hos_profile_section_card.dart';
import '../../../core/widgets/hos_skeleton_box.dart';
import '../../../l10n/app_localizations.dart';
import '../../coupon/domain/hos_coupon.dart';
import '../../coupon/presentation/hos_coupon_controller.dart';
import '../../home/presentation/hos_home_controller.dart';
import 'hos_profile_controller.dart';

const _productGridGap = SHOAppSpacing.lg;

class SHOProfileServiceHub extends ConsumerWidget {
  const SHOProfileServiceHub({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    final items = [
      _ServiceItem(
        icon: Icons.confirmation_number_outlined,
        label: l10n.profileServiceCoupons,
        color: SHOAppColors.accent,
        onTap: () {
          if (!SHOAuthGuard.requireAuth(context, ref)) return;
          context.push(SHOAppRoutes.coupons);
        },
      ),
      _ServiceItem(
        icon: Icons.support_agent_outlined,
        label: l10n.profileServiceAfterSale,
        color: const Color(0xFF4A90E2),
        onTap: () {
          if (!SHOAuthGuard.requireAuth(context, ref)) return;
          context.push(SHOAppRoutes.afterSales);
        },
      ),
      _ServiceItem(
        icon: Icons.share_outlined,
        label: l10n.profileServiceShare,
        color: const Color(0xFF7B61FF),
        onTap: () => SHOSharePanel.show(
          context,
          ref,
          title: l10n.appName,
          link: 'https://shoo.app',
        ),
      ),
      _ServiceItem(
        icon: Icons.mail_outline,
        label: l10n.profileServiceMessages,
        color: const Color(0xFFFF8A3D),
        onTap: () => context.push(SHOAppRoutes.messages),
      ),
      _ServiceItem(
        icon: Icons.search,
        label: l10n.profileServiceSearch,
        color: const Color(0xFF2DBE7E),
        onTap: () => context.push(SHOAppRoutes.search),
      ),
    ];

    return SHOProfileSectionCard(
      padding: const EdgeInsets.symmetric(
        horizontal: SHOAppSpacing.sm,
        vertical: SHOAppSpacing.md,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final columns = items.length <= 5 ? items.length : 5;
          final itemWidth = constraints.maxWidth / columns;
          const rowGap = SHOAppSpacing.md;

          return Wrap(
            spacing: 0,
            runSpacing: rowGap,
            children: [
              for (final item in items)
                SizedBox(
                  width: itemWidth,
                  child: _ServiceEntryButton(item: item),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _ServiceEntryButton extends StatelessWidget {
  const _ServiceEntryButton({required this.item});

  final _ServiceItem item;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: item.onTap,
      borderRadius: BorderRadius.circular(SHOAppSpacing.cardRadius),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: SHOAppSpacing.xs),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: item.color.withValues(alpha: 0.22),
              child: Icon(item.icon, color: item.color, size: 20),
            ),
            const SizedBox(height: SHOAppSpacing.sm),
            Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    height: 1.1,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceItem {
  const _ServiceItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
}

class SHOProfileCouponStrip extends ConsumerWidget {
  const SHOProfileCouponStrip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final couponsAsync = ref.watch(couponsProvider);

    return SHOProfileSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                l10n.profileCouponCenter,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  if (!SHOAuthGuard.requireAuth(context, ref)) return;
                  context.push(SHOAppRoutes.coupons);
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(l10n.profileCouponMore),
                    Icon(
                      Icons.chevron_right,
                      size: 18,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: SHOAppSpacing.sm),
          couponsAsync.when(
            loading: () => const SizedBox(
              height: 92,
              child: SHOSkeletonBox(height: 92),
            ),
            error: (_, __) => const SizedBox.shrink(),
            data: (coupons) {
              if (coupons.isEmpty) return const SizedBox.shrink();
              return SizedBox(
                height: 92,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: coupons.length.clamp(0, 6),
                  separatorBuilder: (_, __) =>
                      const SizedBox(width: SHOAppSpacing.md),
                  itemBuilder: (context, index) =>
                      _CouponTicketCard(coupon: coupons[index]),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _CouponTicketCard extends StatelessWidget {
  const _CouponTicketCard({required this.coupon});

  final SHOCoupon coupon;

  @override
  Widget build(BuildContext context) {
    final amount = coupon.type == SHOCouponType.fixed
        ? priceFormatter.formatCents(coupon.discountCents)
        : '${coupon.discountPercent}%';

    return Container(
      width: 148,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF0F2), Color(0xFFFFE4E8)],
        ),
        border: Border.all(
          color: SHOAppColors.accent.withValues(alpha: 0.35),
          width: SHOProfileSectionCard.borderWidth,
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 58,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  amount,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: SHOAppColors.accent,
                        fontWeight: FontWeight.w900,
                        height: 1,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  '券',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: SHOAppColors.accent,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
          ),
          Container(
            width: 1,
            margin: const EdgeInsets.symmetric(vertical: 10),
            child: CustomPaint(
              painter: _DashedLinePainter(color: SHOAppColors.accent.withValues(alpha: 0.35)),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    coupon.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                        ),
                  ),
                  const Spacer(),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: SHOAppColors.accent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        child: Text(
                          AppLocalizations.of(context).profileCouponClaim,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  _DashedLinePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    const dash = 3.0;
    var y = 0.0;
    while (y < size.height) {
      canvas.drawLine(Offset(0, y), Offset(0, y + dash), paint);
      y += dash * 2;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedLinePainter oldDelegate) =>
      oldDelegate.color != color;
}

class SHOProfileFeedTabBar extends StatelessWidget implements PreferredSizeWidget {
  const SHOProfileFeedTabBar({
    super.key,
    required this.controller,
  });

  final TabController controller;

  @override
  Size get preferredSize => const Size.fromHeight(44);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: TabBar(
        controller: controller,
        isScrollable: false,
        dividerHeight: 0,
        indicatorSize: TabBarIndicatorSize.label,
        labelColor: Theme.of(context).colorScheme.onSurface,
        unselectedLabelColor: context.shoTheme.textSecondary,
        labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
        indicator: const UnderlineTabIndicator(
          borderSide: BorderSide(color: SHOAppColors.accent, width: 3),
          insets: EdgeInsets.symmetric(horizontal: 18),
        ),
        tabs: [
          Tab(text: l10n.profileTabGuessYouLike),
          Tab(text: l10n.profileTabMyFavorites),
          Tab(text: l10n.profileTabMyReviews),
        ],
      ),
    );
  }
}

final _feedGridDelegate = SliverGridDelegateWithFixedCrossAxisCount(
  crossAxisCount: 2,
  mainAxisSpacing: _productGridGap,
  crossAxisSpacing: _productGridGap,
  childAspectRatio: SHOProductCard.gridChildAspectRatio,
);

Widget buildProfileFeedSliver(
  WidgetRef ref,
  BuildContext context,
  SHOProfileFeedTab tab,
) {
    if (tab == SHOProfileFeedTab.reviews) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: _ReviewsPromptWrapper(),
      );
    }

    if (tab == SHOProfileFeedTab.favorites) {
      final favoritesAsync = ref.watch(profileFavoriteActivityProductsProvider);
      return favoritesAsync.when(
        loading: () => SliverGrid(
          gridDelegate: _feedGridDelegate,
          delegate: SliverChildBuilderDelegate(
            (_, __) => const SHOSkeletonBox(height: 220),
            childCount: 4,
          ),
        ),
        error: (error, _) => SliverToBoxAdapter(
          child: SHOEmptyState(
            title: error.toString(),
            onAction: () => ref.invalidate(profileFavoriteActivityProductsProvider),
          ),
        ),
        data: (items) {
          if (items.isEmpty) {
            return SliverFillRemaining(
              hasScrollBody: false,
              child: SHOEmptyState(
                title: AppLocalizations.of(context).profileFavoritesEmpty,
                actionLabel: AppLocalizations.of(context).cartEmptyAction,
                onAction: () => context.go(SHOAppRoutes.home),
              ),
            );
          }
          return SliverGrid(
            gridDelegate: _feedGridDelegate,
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final item = items[index];
                final product = item.product;
                return Opacity(
                  opacity: item.available ? 1 : 0.45,
                  child: SHOProductCard(
                    product: product,
                    onTap: item.available
                        ? () => context.push(SHOAppRoutes.product(product.id))
                        : null,
                  ),
                );
              },
              childCount: items.length,
            ),
          );
        },
      );
    }

    final feedAsync = ref.watch(homeFeedProvider);
    return feedAsync.when(
      loading: () => SliverGrid(
        gridDelegate: _feedGridDelegate,
        delegate: SliverChildBuilderDelegate(
          (_, __) => const SHOSkeletonBox(height: 220),
          childCount: 4,
        ),
      ),
      error: (error, _) => SliverToBoxAdapter(
        child: SHOEmptyState(
          title: error.toString(),
          onAction: () => ref.invalidate(homeFeedProvider),
        ),
      ),
      data: (feed) => SliverGrid(
        gridDelegate: _feedGridDelegate,
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final product = feed.products[index];
            return SHOProductCard(
              product: product,
              onTap: () => context.push(SHOAppRoutes.product(product.id)),
            );
          },
          childCount: feed.products.length,
        ),
      ),
    );
}

class _ReviewsPromptWrapper extends ConsumerWidget {
  const _ReviewsPromptWrapper();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: SHOAppSpacing.xxxl),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.profileReviewsHint,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: SHOAppSpacing.md),
            OutlinedButton(
              onPressed: () {
                if (!SHOAuthGuard.requireAuth(context, ref)) return;
                context.push(SHOAppRoutes.ordersFiltered('delivered'));
              },
              child: Text(l10n.ordersReviews),
            ),
          ],
        ),
      ),
    );
  }
}
