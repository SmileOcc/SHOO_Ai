import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shoo/core/deeplink/hos_deeplink_navigator.dart';
import 'package:shoo/core/theme/hos_colors.dart';
import 'package:shoo/core/theme/hos_spacing.dart';
import 'package:shoo/core/widgets/hos_promo_badge.dart';
import 'package:shoo/features/auth/presentation/state/hos_session_provider.dart';
import 'package:shoo/features/flash_sale/domain/entities/hos_flash_sale_models.dart';
import 'package:shoo/features/flash_sale/presentation/state/hos_flash_sale_controller.dart';
import 'package:shoo/features/flash_sale/presentation/state/hos_flash_sale_follow_controller.dart';
import 'package:shoo/features/flash_sale/presentation/widgets/hos_flash_sale_countdown.dart';
import 'package:shoo/features/flash_sale/presentation/widgets/hos_flash_sale_product_card.dart';
import 'package:shoo/l10n/app_localizations.dart';

class SHOFlashSalePage extends ConsumerStatefulWidget {
  const SHOFlashSalePage({super.key});

  @override
  ConsumerState<SHOFlashSalePage> createState() => _SHOFlashSalePageState();
}

class _SHOFlashSalePageState extends ConsumerState<SHOFlashSalePage> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(flashSaleControllerProvider.notifier).initialize());
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(flashSaleControllerProvider.notifier).loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(flashSaleControllerProvider);
    ref.watch(flashSaleFollowControllerProvider);
    final products =
        ref.read(flashSaleControllerProvider.notifier).mergedProducts();
    final pageData = state.pageData;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.flashSaleTitle,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(flashSaleControllerProvider.notifier).refresh(),
        child: state.calendar == null && state.isRefreshing
            ? const Center(child: CircularProgressIndicator())
            : CustomScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  if (state.calendar != null)
                    SliverToBoxAdapter(child: _DayTabs(state: state)),
                  if (pageData != null)
                    SliverToBoxAdapter(child: _SessionBar(state: state)),
                  if (pageData != null && pageData.promoEntries.isNotEmpty)
                    SliverToBoxAdapter(child: _PromoEntries(entries: pageData.promoEntries)),
                  if (pageData != null)
                    SliverToBoxAdapter(child: _CouponSection(state: state)),
                  SliverToBoxAdapter(child: _SortBar(state: state)),
                  if (products.isEmpty && !state.isRefreshing)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(child: Text(l10n.noData)),
                    )
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (index >= products.length) {
                            return state.isLoadingMore
                                ? const Padding(
                                    padding: EdgeInsets.all(SHOAppSpacing.xl),
                                    child: Center(child: CircularProgressIndicator()),
                                  )
                                : const SizedBox.shrink();
                          }
                          return SHOFlashSaleProductCard(product: products[index]);
                        },
                        childCount: products.length + (state.isLoadingMore ? 1 : 0),
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}

class _DayTabs extends ConsumerWidget {
  const _DayTabs({required this.state});

  final SHOFlashSalePageState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final days = state.calendar!.days;

    return SizedBox(
      height: 72,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: SHOAppSpacing.pagePadding),
        itemCount: days.length,
        separatorBuilder: (_, __) => const SizedBox(width: SHOAppSpacing.sm),
        itemBuilder: (context, index) {
          final day = days[index];
          final selected = day.date == state.selectedDate;
          return GestureDetector(
            onTap: () => ref.read(flashSaleControllerProvider.notifier).selectDate(day.date),
            child: Container(
              width: 64,
              padding: const EdgeInsets.symmetric(vertical: SHOAppSpacing.sm),
              decoration: BoxDecoration(
                color: selected ? SHOAppColors.primary : SHOAppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(SHOAppSpacing.cardRadius),
                border: Border.all(
                  color: selected ? SHOAppColors.primary : SHOAppColors.border,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    day.label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: selected ? Colors.white : SHOAppColors.textPrimary,
                    ),
                  ),
                  Text(
                    day.weekday,
                    style: TextStyle(
                      fontSize: 10,
                      color: selected ? Colors.white70 : SHOAppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 2),
                  SHOPromoBadge(
                    type: SHOPromoBadgeType.status,
                    label: _dayStatusLabel(day.status, l10n),
                    preset: SHOPromoBadgePreset.wrapTag,
                    enabled: day.status != SHOFlashSaleDayStatus.ended,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _dayStatusLabel(SHOFlashSaleDayStatus status, AppLocalizations l10n) {
    switch (status) {
      case SHOFlashSaleDayStatus.notStarted:
        return l10n.flashSaleStatusNotStarted;
      case SHOFlashSaleDayStatus.ongoing:
        return l10n.flashSaleStatusOngoing;
      case SHOFlashSaleDayStatus.ended:
        return l10n.flashSaleStatusEnded;
    }
  }
}

class _SessionBar extends ConsumerWidget {
  const _SessionBar({required this.state});

  final SHOFlashSalePageState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessions = state.pageData?.sessions ?? [];
    if (sessions.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(
          SHOAppSpacing.pagePadding,
          SHOAppSpacing.sm,
          SHOAppSpacing.pagePadding,
          SHOAppSpacing.sm,
        ),
        itemCount: sessions.length,
        separatorBuilder: (_, __) => const SizedBox(width: SHOAppSpacing.sm),
        itemBuilder: (context, index) {
          final session = sessions[index];
          final selected = session.id == state.selectedSessionId;
          return ChoiceChip(
            label: Text(session.label),
            selected: selected,
            onSelected: (_) =>
                ref.read(flashSaleControllerProvider.notifier).selectSession(session.id),
          );
        },
      ),
    );
  }
}

class _PromoEntries extends ConsumerWidget {
  const _PromoEntries({required this.entries});

  final List<SHOFlashSalePromoEntry> entries;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);

    return SizedBox(
      height: 88,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: SHOAppSpacing.pagePadding),
        itemCount: entries.length,
        separatorBuilder: (_, __) => const SizedBox(width: SHOAppSpacing.lg),
        itemBuilder: (context, index) {
          final entry = entries[index];
          return GestureDetector(
            onTap: () => SHODeepLinkNavigator.openLink(
              context,
              entry.deeplink,
              session: session,
            ),
            child: SizedBox(
              width: 64,
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(SHOAppSpacing.cardRadius),
                    child: CachedNetworkImage(
                      imageUrl: entry.iconUrl,
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: SHOAppSpacing.xs),
                  Text(
                    entry.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 10),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CouponSection extends ConsumerWidget {
  const _CouponSection({required this.state});

  final SHOFlashSalePageState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final pageData = state.pageData!;
    final coupons = state.mergedCoupons;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        SHOAppSpacing.pagePadding,
        SHOAppSpacing.sm,
        SHOAppSpacing.pagePadding,
        SHOAppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CouponHeader(pageData: pageData, l10n: l10n),
          const SizedBox(height: SHOAppSpacing.sm),
          SizedBox(
            height: 88,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: coupons.length,
              separatorBuilder: (_, __) => const SizedBox(width: SHOAppSpacing.sm),
              itemBuilder: (context, index) {
                final coupon = coupons[index];
                return _CouponTile(
                  coupon: coupon,
                  l10n: l10n,
                  onClaim: () async {
                    if (coupon.status == SHOFlashSaleCouponStatus.claimable) {
                      await ref
                          .read(flashSaleControllerProvider.notifier)
                          .claimCoupon(coupon.id);
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CouponHeader extends StatelessWidget {
  const _CouponHeader({required this.pageData, required this.l10n});

  final SHOFlashSalePageData pageData;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    switch (pageData.claimPhase) {
      case SHOFlashSaleClaimPhase.beforeClaim:
        return Text(
          l10n.flashSaleCouponNotStarted,
          style: const TextStyle(fontWeight: FontWeight.w700),
        );
      case SHOFlashSaleClaimPhase.claiming:
        if (pageData.claimCountdownTarget != null) {
          return SHOFlashSaleCountdown(
            targetIso: pageData.claimCountdownTarget!,
            prefix: l10n.flashSaleCouponCountdownPrefix,
          );
        }
        return Text(l10n.flashSaleCouponClaiming);
      case SHOFlashSaleClaimPhase.afterClaim:
        return Text(
          l10n.flashSaleCouponExpired,
          style: const TextStyle(fontWeight: FontWeight.w700, color: SHOAppColors.textMuted),
        );
    }
  }
}

class _CouponTile extends StatelessWidget {
  const _CouponTile({
    required this.coupon,
    required this.l10n,
    required this.onClaim,
  });

  final SHOFlashSaleCoupon coupon;
  final AppLocalizations l10n;
  final VoidCallback onClaim;

  @override
  Widget build(BuildContext context) {
    final highlight = coupon.status == SHOFlashSaleCouponStatus.claimable ||
        coupon.status == SHOFlashSaleCouponStatus.notStarted;
    final canTap = coupon.status == SHOFlashSaleCouponStatus.claimable;

    return Opacity(
      opacity: highlight ? 1 : 0.55,
      child: GestureDetector(
        onTap: canTap ? onClaim : null,
        child: Container(
          width: 140,
          padding: const EdgeInsets.all(SHOAppSpacing.md),
          decoration: BoxDecoration(
            color: highlight
                ? SHOAppColors.accent.withValues(alpha: 0.08)
                : SHOAppColors.surfaceMuted,
            borderRadius: BorderRadius.circular(SHOAppSpacing.cardRadius),
            border: Border.all(
              color: highlight ? SHOAppColors.accent : SHOAppColors.border,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                coupon.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: highlight ? SHOAppColors.accent : SHOAppColors.textMuted,
                ),
              ),
              Text(
                coupon.description,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 10, color: SHOAppColors.textSecondary),
              ),
              const Spacer(),
              Text(
                _statusLabel(coupon.status),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: highlight ? SHOAppColors.accent : SHOAppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _statusLabel(SHOFlashSaleCouponStatus status) {
    switch (status) {
      case SHOFlashSaleCouponStatus.notStarted:
        return l10n.flashSaleCouponStatusNotStarted;
      case SHOFlashSaleCouponStatus.claimable:
        return l10n.flashSaleCouponStatusClaimable;
      case SHOFlashSaleCouponStatus.claimed:
        return l10n.flashSaleCouponStatusClaimed;
      case SHOFlashSaleCouponStatus.soldOut:
        return l10n.flashSaleCouponStatusSoldOut;
      case SHOFlashSaleCouponStatus.expired:
        return l10n.flashSaleCouponStatusExpired;
    }
  }
}

class _SortBar extends ConsumerWidget {
  const _SortBar({required this.state});

  final SHOFlashSalePageState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final items = [
      (SHOFlashSaleSort.hot, l10n.flashSaleSortHot),
      (SHOFlashSaleSort.priceAsc, l10n.flashSaleSortPrice),
      (SHOFlashSaleSort.newest, l10n.flashSaleSortNewest),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: SHOAppSpacing.pagePadding,
        vertical: SHOAppSpacing.sm,
      ),
      child: Row(
        children: [
          for (final item in items) ...[
            _SortChip(
              label: item.$2,
              selected: state.sort == item.$1 ||
                  (item.$1 == SHOFlashSaleSort.priceAsc &&
                      state.sort == SHOFlashSaleSort.priceDesc),
              onTap: () {
                if (item.$1 == SHOFlashSaleSort.priceAsc) {
                  final next = state.sort == SHOFlashSaleSort.priceAsc
                      ? SHOFlashSaleSort.priceDesc
                      : SHOFlashSaleSort.priceAsc;
                  ref.read(flashSaleControllerProvider.notifier).selectSort(next);
                } else {
                  ref.read(flashSaleControllerProvider.notifier).selectSort(item.$1);
                }
              },
            ),
            const SizedBox(width: SHOAppSpacing.sm),
          ],
        ],
      ),
    );
  }
}

class _SortChip extends StatelessWidget {
  const _SortChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        label,
        style: TextStyle(
          fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
          color: selected ? SHOAppColors.accent : SHOAppColors.textSecondary,
        ),
      ),
    );
  }
}
