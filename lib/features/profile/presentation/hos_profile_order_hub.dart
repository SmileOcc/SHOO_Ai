import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/hos_routes.dart';
import '../../../core/auth/hos_auth_guard.dart';
import '../../../core/theme/hos_colors.dart';
import '../../../core/theme/hos_spacing.dart';
import '../../../core/theme/hos_theme_extension.dart';
import '../../../core/widgets/hos_profile_badge.dart';
import '../../../core/widgets/hos_profile_section_card.dart';
import '../../../l10n/app_localizations.dart';
import '../../order/domain/hos_order.dart';
import 'hos_profile_controller.dart';

class SHOProfileOrderHub extends ConsumerWidget {
  const SHOProfileOrderHub({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = context.shoTheme;
    final stats = ref.watch(profileQuickStatsProvider);
    final countsAsync = ref.watch(profileOrderCountsProvider);

    int countFor(SHOOrderStatus status) =>
        countsAsync.maybeWhen(data: (m) => m[status] ?? 0, orElse: () => 0);

    void openOrders(String? statusFilter) {
      if (!SHOAuthGuard.requireAuth(context, ref)) return;
      if (statusFilter == null) {
        context.push(SHOAppRoutes.orders);
      } else {
        context.push(SHOAppRoutes.ordersFiltered(statusFilter));
      }
    }

    return SHOProfileSectionCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: SHOAppSpacing.lg,
              vertical: SHOAppSpacing.lg,
            ),
            child: Row(
              children: [
                _StatChip(
                  label: l10n.profileFootprints,
                  count: stats.footprints,
                  onTap: () {
                    if (!SHOAuthGuard.requireAuth(context, ref)) return;
                    context.push(SHOAppRoutes.profileFootprints);
                  },
                ),
                _StatChip(
                  label: l10n.profileFavorites,
                  count: stats.favorites,
                  onTap: () {
                    if (!SHOAuthGuard.requireAuth(context, ref)) return;
                    context.push(SHOAppRoutes.profileFavorites);
                  },
                ),
                _StatChip(
                  label: l10n.profileFollowing,
                  count: stats.following,
                  onTap: () => context.go(SHOAppRoutes.category),
                ),
                _DiscoverChip(
                  label: l10n.profileDiscover,
                  badge: stats.showDiscoverBadge ? l10n.profileDiscoverBadge : null,
                  onTap: () => context.go(SHOAppRoutes.home),
                ),
              ],
            ),
          ),
          Divider(height: SHOProfileSectionCard.borderWidth, color: theme.divider),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: SHOAppSpacing.md),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        _OrderEntry(
                          icon: Icons.account_balance_wallet_outlined,
                          label: l10n.ordersPendingPayment,
                          badge: countFor(SHOOrderStatus.pendingPayment),
                          onTap: () => openOrders('pending_payment'),
                        ),
                        _OrderEntry(
                          icon: Icons.local_shipping_outlined,
                          label: l10n.ordersShipped,
                          badge: countFor(SHOOrderStatus.shipped),
                          onTap: () => openOrders('shipped'),
                        ),
                        _OrderEntry(
                          icon: Icons.inventory_2_outlined,
                          label: l10n.ordersToUse,
                          badge: countFor(SHOOrderStatus.paid),
                          onTap: () => openOrders('paid'),
                        ),
                        _OrderEntry(
                          icon: Icons.chat_bubble_outline,
                          label: l10n.ordersReviews,
                          badge: countFor(SHOOrderStatus.delivered),
                          onTap: () => openOrders('delivered'),
                        ),
                        _OrderEntry(
                          icon: Icons.replay_circle_filled_outlined,
                          label: l10n.ordersAfterSalesShort,
                          onTap: () {
                            if (!SHOAuthGuard.requireAuth(context, ref)) return;
                            context.push(SHOAppRoutes.afterSales);
                          },
                        ),
                      ],
                    ),
                  ),
                  VerticalDivider(
                    width: SHOProfileSectionCard.borderWidth,
                    color: theme.divider,
                  ),
                  SizedBox(
                    width: 56,
                    child: InkWell(
                      onTap: () => openOrders(null),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            l10n.ordersAllShort,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(height: SHOAppSpacing.xs),
                          DecoratedBox(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: theme.border,
                                width: SHOProfileSectionCard.borderWidth,
                              ),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.all(4),
                              child: Icon(Icons.chevron_right, size: 16),
                            ),
                          ),
                        ],
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

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.label,
    required this.count,
    required this.onTap,
  });

  final String label;
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(SHOAppSpacing.sm),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            if (count > 0) ...[
              const SizedBox(width: 4),
              SHOProfileBadge(text: count > 99 ? '99+' : '$count', compact: true),
            ],
          ],
        ),
      ),
    );
  }
}

class _DiscoverChip extends StatelessWidget {
  const _DiscoverChip({
    required this.label,
    required this.onTap,
    this.badge,
  });

  final String label;
  final String? badge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(SHOAppSpacing.sm),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            if (badge != null) ...[
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: SHOAppColors.accent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  badge!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    height: 1.1,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _OrderEntry extends StatelessWidget {
  const _OrderEntry({
    required this.icon,
    required this.label,
    required this.onTap,
    this.badge = 0,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final int badge;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(SHOAppSpacing.sm),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(icon, size: 22),
                if (badge > 0)
                  Positioned(
                    right: -8,
                    top: -6,
                    child: SHOProfileBadge(
                      text: badge > 9 ? '9+' : '$badge',
                    ),
                  ),
              ],
            ),
            const SizedBox(height: SHOAppSpacing.xs),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
