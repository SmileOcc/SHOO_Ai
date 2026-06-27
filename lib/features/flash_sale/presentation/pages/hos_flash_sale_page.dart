import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shoo/core/analytics/hos_page_analytics.dart';
import 'package:shoo/core/pages/hos_pages.dart';
import 'package:shoo/core/deeplink/hos_deeplink_navigator.dart';
import 'package:shoo/core/theme/hos_colors.dart';
import 'package:shoo/core/theme/hos_spacing.dart';
import 'package:shoo/core/widgets/hos_pull_refresh.dart';
import 'package:shoo/core/widgets/hos_promo_badge.dart';
import 'package:shoo/features/auth/presentation/state/hos_session_provider.dart';
import 'package:shoo/features/flash_sale/domain/entities/hos_flash_sale_models.dart';
import 'package:shoo/features/flash_sale/domain/hos_flash_sale_activities.dart';
import 'package:shoo/features/flash_sale/presentation/state/hos_flash_sale_controller.dart';
import 'package:shoo/features/flash_sale/presentation/state/hos_flash_sale_follow_controller.dart';
import 'package:shoo/features/flash_sale/presentation/widgets/hos_flash_sale_countdown.dart';
import 'package:shoo/features/flash_sale/presentation/widgets/hos_flash_sale_product_card.dart';
import 'package:shoo/l10n/app_localizations.dart';

class SHOFlashSalePage extends ConsumerStatefulWidget {
  const SHOFlashSalePage({super.key, required this.activityId});

  final String activityId;

  @override
  ConsumerState<SHOFlashSalePage> createState() => _SHOFlashSalePageState();
}

class _SHOFlashSalePageState extends ConsumerState<SHOFlashSalePage>
    with SHOPageRouteAnalyticsMixin, SHOAppPageMixin, SHOAppTrackedPageMixin {
  final _scrollController = ScrollController();

  @override
  String get pageName => 'flash_sale';

  @override
  Map<String, Object?> get pageAnalyticsExtra => {
        'activity_id': widget.activityId,
      };

  // 获取闪购控制器（通过 ref.read 获取 notifier）
  SHOFlashSaleController get _controller =>
      ref.read(flashSaleControllerProvider(widget.activityId).notifier);

  @override
  void initState() {
    super.initState();
    // 使用 Future.microtask 延迟执行初始化，避免在构建期间修改状态
    Future.microtask(_controller.initialize);
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _controller.loadMore();
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
    // 监听闪购状态（自动响应状态变化重建 UI）
    final state = ref.watch(flashSaleControllerProvider(widget.activityId));
    // 监听关注状态（用于更新商品关注按钮）
    ref.watch(flashSaleFollowControllerProvider);
    // 获取合并后的商品列表
    final products =
        ref.read(flashSaleControllerProvider(widget.activityId).notifier).mergedProducts();
    // 获取页面数据
    final pageData = state.pageData;

    return buildTrackedPage(
      Scaffold(
      appBar: AppBar(
        title: Text(
          SHOFlashSaleActivities.titleFor(widget.activityId),
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: SHOAppPullRefresh(
        onRefresh: _controller.refresh,
        child: state.calendar == null && state.isRefreshing
            ? const Center(child: CircularProgressIndicator())
            : CustomScrollView(
                controller: _scrollController,
                physics: SHOAppPullRefresh.scrollPhysics,
                slivers: [
                  if (state.calendar != null)
                    SliverToBoxAdapter(
                      child: _DayTabs(state: state, activityId: widget.activityId),
                    ),
                  if (pageData != null)
                    SliverToBoxAdapter(
                      child: _SessionBar(state: state, activityId: widget.activityId),
                    ),
                  if (pageData != null)
                    SliverToBoxAdapter(
                      child: _SessionCountdown(
                        sessions: pageData.sessions,
                        selectedSessionId: state.selectedSessionId,
                      ),
                    ),
                  if (pageData != null && pageData.promoEntries.isNotEmpty)
                    SliverToBoxAdapter(child: _PromoEntries(entries: pageData.promoEntries)),
                  if (pageData != null)
                    SliverToBoxAdapter(
                      child: _CouponSection(
                        state: state,
                        activityId: widget.activityId,
                      ),
                    ),
                  SliverToBoxAdapter(
                    child: _SortBar(state: state, activityId: widget.activityId),
                  ),
                  if (products.isEmpty && !state.isRefreshing)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(child: Text(l10n.noData)),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverList(
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
                            final isLast = index >= products.length - 1;
                            return Padding(
                              padding: EdgeInsets.only(bottom: isLast ? 0 : 8),
                              child: SHOFlashSaleProductCard(
                                product: products[index],
                                activityId: widget.activityId,
                              ),
                            );
                          },
                          childCount: products.length + (state.isLoadingMore ? 1 : 0),
                        ),
                      ),
                    ),
                ],
              ),
      ),
    ),
    onRetry: _controller.refresh,
    );
  }
}

class _DayTabs extends ConsumerWidget {
  const _DayTabs({required this.state, required this.activityId});

  final SHOFlashSalePageState state;
  final String activityId;

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
            onTap: () => ref
                .read(flashSaleControllerProvider(activityId).notifier)
                .selectDate(day.date),
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
      case SHOFlashSaleDayStatus.ending:
        return l10n.flashSaleSessionEnding;
      case SHOFlashSaleDayStatus.ended:
        return l10n.flashSaleStatusEnded;
    }
  }
}

class _SessionBar extends ConsumerWidget {
  const _SessionBar({required this.state, required this.activityId});

  final SHOFlashSalePageState state;
  final String activityId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessions = state.pageData?.sessions ?? [];
    if (sessions.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 42,
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
          final isEnded = session.status == SHOFlashSaleDayStatus.ended;
          final isOngoing = session.status == SHOFlashSaleDayStatus.ongoing;

          final bgColor = selected
              ? SHOAppColors.primary
              : isOngoing
                  ? SHOAppColors.accent.withValues(alpha: 0.08)
                  : SHOAppColors.surfaceMuted;
          final textColor = selected
              ? Colors.white
              : isEnded
                  ? SHOAppColors.textMuted
                  : isOngoing
                      ? SHOAppColors.accent
                      : SHOAppColors.textPrimary;
          final borderColor = selected
              ? SHOAppColors.primary
              : isOngoing
                  ? SHOAppColors.accent.withValues(alpha: 0.4)
                  : SHOAppColors.border;

          return GestureDetector(
            onTap: () => ref
                .read(flashSaleControllerProvider(activityId).notifier)
                .selectSession(session.id),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: SHOAppSpacing.md,
                vertical: SHOAppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: borderColor),
              ),
              child: Text(
                session.label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

String _formatSessionClock(String iso) {
  final dt = DateTime.tryParse(iso)?.toLocal();
  if (dt == null) return '--:--';
  final h = dt.hour.toString().padLeft(2, '0');
  final m = dt.minute.toString().padLeft(2, '0');
  return '$h:$m';
}

/// 场次倒计时独立行：展示开始/结束时间 + 倒计时；已结束则在下方提示。
class _SessionCountdown extends StatelessWidget {
  const _SessionCountdown({
    required this.sessions,
    required this.selectedSessionId,
  });

  final List<SHOFlashSaleSession> sessions;
  final String selectedSessionId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final session = sessions.cast<SHOFlashSaleSession?>().firstWhere(
          (s) => s!.id == selectedSessionId,
          orElse: () => null,
        );
    if (session == null) return const SizedBox.shrink();

    final status = session.status;
    final startLabel = l10n.flashSaleSessionStartAt(_formatSessionClock(session.startAt));
    final endLabel = l10n.flashSaleSessionEndAt(_formatSessionClock(session.endAt));
    final isEnded = status == SHOFlashSaleDayStatus.ended;

    String? targetIso;
    String countdownPrefix;
    Color accentColor;

    switch (status) {
      case SHOFlashSaleDayStatus.notStarted:
        targetIso = session.startAt;
        countdownPrefix = l10n.flashSaleCountdownStartsIn;
        accentColor = const Color(0xFF1565C0);
      case SHOFlashSaleDayStatus.ongoing:
        targetIso = session.endAt;
        countdownPrefix = l10n.flashSaleCountdownEndsIn;
        accentColor = SHOAppColors.accent;
      case SHOFlashSaleDayStatus.ending:
        targetIso = session.endAt;
        countdownPrefix = l10n.flashSaleCountdownEndsIn;
        accentColor = const Color(0xFFE65100);
      case SHOFlashSaleDayStatus.ended:
        targetIso = null;
        countdownPrefix = l10n.flashSaleCountdownEnded;
        accentColor = SHOAppColors.textMuted;
    }

    final bgColor = switch (status) {
      SHOFlashSaleDayStatus.notStarted => const Color(0xFFE3F2FD),
      SHOFlashSaleDayStatus.ongoing => SHOAppColors.accent.withValues(alpha: 0.08),
      SHOFlashSaleDayStatus.ending => const Color(0xFFFFF3E0),
      SHOFlashSaleDayStatus.ended => const Color(0xFFF0F0F0),
    };

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        SHOAppSpacing.pagePadding,
        0,
        SHOAppSpacing.pagePadding,
        SHOAppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: SHOAppSpacing.xl,
              vertical: SHOAppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(SHOAppSpacing.cardRadius),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      startLabel,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: status == SHOFlashSaleDayStatus.notStarted
                            ? const Color(0xFF1565C0)
                            : SHOAppColors.textSecondary,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: SHOAppSpacing.sm),
                      child: Text(
                        '—',
                        style: TextStyle(
                          fontSize: 12,
                          color: SHOAppColors.textMuted,
                        ),
                      ),
                    ),
                    Text(
                      endLabel,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: status == SHOFlashSaleDayStatus.ended
                            ? SHOAppColors.textMuted
                            : SHOAppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                if (targetIso != null) ...[
                  const SizedBox(height: SHOAppSpacing.sm),
                  SHOFlashSaleCountdown(
                    targetIso: targetIso,
                    prefix: countdownPrefix,
                    accentColor: accentColor,
                  ),
                ],
              ],
            ),
          ),
          if (isEnded) ...[
            const SizedBox(height: SHOAppSpacing.xs),
            Text(
              l10n.flashSaleSessionActivityEnded,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: SHOAppColors.textMuted,
              ),
            ),
          ],
        ],
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
  const _CouponSection({required this.state, required this.activityId});

  final SHOFlashSalePageState state;
  final String activityId;

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
          _CouponHeader(pageData: pageData, coupons: coupons, l10n: l10n),
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
                          .read(flashSaleControllerProvider(activityId).notifier)
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
  const _CouponHeader({required this.pageData, required this.coupons, required this.l10n});

  final SHOFlashSalePageData pageData;
  final List<SHOFlashSaleCoupon> coupons;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final hasClaimable = coupons.any(
      (c) => c.status == SHOFlashSaleCouponStatus.claimable,
    );

    switch (pageData.claimPhase) {
      case SHOFlashSaleClaimPhase.beforeClaim:
        if (hasClaimable) {
          return Text(
            l10n.flashSaleCouponClaiming,
            style: const TextStyle(fontWeight: FontWeight.w700),
          );
        }
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
        if (hasClaimable) {
          return Text(
            l10n.flashSaleCouponClaiming,
            style: const TextStyle(fontWeight: FontWeight.w700),
          );
        }
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
      opacity: highlight ? 1 : 0.7,
      child: GestureDetector(
        onTap: canTap ? onClaim : null,
        child: Container(
          width: 140,
          padding: const EdgeInsets.all(SHOAppSpacing.md),
          decoration: BoxDecoration(
            color: highlight
                ? SHOAppColors.accent.withValues(alpha: 0.08)
                : const Color(0xFFE8E8E8),
            borderRadius: BorderRadius.circular(SHOAppSpacing.cardRadius),
            border: Border.all(
              color: highlight
                  ? SHOAppColors.accent
                  : const Color(0xFFD5D5D5),
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
                style: TextStyle(
                  fontSize: 10,
                  color: highlight ? SHOAppColors.textSecondary : SHOAppColors.textMuted,
                ),
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
  const _SortBar({required this.state, required this.activityId});

  final SHOFlashSalePageState state;
  final String activityId;

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
                  ref.read(flashSaleControllerProvider(activityId).notifier).selectSort(next);
                } else {
                  ref.read(flashSaleControllerProvider(activityId).notifier).selectSort(item.$1);
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
