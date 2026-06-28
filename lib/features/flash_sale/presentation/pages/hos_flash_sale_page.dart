import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shoo/core/deeplink/hos_deeplink_navigator.dart';
import 'package:shoo/core/pages/hos_pages.dart';
import 'package:shoo/core/theme/hos_colors.dart';
import 'package:shoo/core/theme/hos_spacing.dart';
import 'package:shoo/core/utils/hos_list_utils.dart';
import 'package:shoo/core/widgets/custom_refresh/hos_custom_refresh.dart';
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
  final _refreshCtrl = SHOAppCustomRefreshController();

  @override
  String get pageName => 'flash_sale';

  @override
  Map<String, Object?> get pageAnalyticsExtra => {
    'activity_id': widget.activityId,
  };

  SHOFlashSaleController get _controller =>
      ref.read(flashSaleControllerProvider(widget.activityId).notifier);

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await _controller.initialize();
      if (mounted) _syncLoadFooter();
    });
  }

  void _syncLoadFooter() {
    final data =
        ref.read(flashSaleControllerProvider(widget.activityId)).pageData;
    if (data != null && !data.hasMore) {
      _refreshCtrl.loadNoMore();
    }
  }

  Future<void> _onRefresh() async {
    await _controller.refresh();
    if (!mounted) return;
    final state = ref.read(flashSaleControllerProvider(widget.activityId));
    if (state.error != null) {
      throw Exception(state.error);
    }
    _syncLoadFooter();
  }

  Future<void> _onLoadMore() async {
    final before =
        ref.read(flashSaleControllerProvider(widget.activityId)).pageData;
    if (before == null || !before.hasMore) {
      _refreshCtrl.loadNoMore();
      return;
    }
    final beforeLen = before.products.length;
    await _controller.loadMore();
    if (!mounted) return;
    final afterState =
        ref.read(flashSaleControllerProvider(widget.activityId));
    final after = afterState.pageData;
    if (after == null) {
      _refreshCtrl.loadFailed();
      return;
    }
    if (afterState.error != null && after.products.length == beforeLen) {
      _refreshCtrl.loadFailed();
    } else if (!after.hasMore) {
      _refreshCtrl.loadNoMore();
    } else {
      _refreshCtrl.loadCompleted();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _refreshCtrl.dispose();
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
    final products = ref
        .read(flashSaleControllerProvider(widget.activityId).notifier)
        .mergedProducts();
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
        body: SHOAppCustomRefresh(
          controller: _refreshCtrl,
          onRefresh: _onRefresh,
          onLoadMore: _onLoadMore,
          enableLoadMore: pageData?.hasMore ?? false,
          child: state.calendar == null && state.isRefreshing
              ? const Center(child: CircularProgressIndicator())
              : CustomScrollView(
                  controller: _scrollController,
                  physics: shoAppCustomRefreshScrollPhysics,
                  slivers: [
                    SHOAppCustomRefresh.headerSliver(_refreshCtrl),
                    // 日期选择栏（如果日历数据存在）
                    if (state.calendar != null)
                      SliverToBoxAdapter(
                        child: _DayTabs(
                          state: state,
                          activityId: widget.activityId,
                        ),
                      ),
                    // 场次选择栏（如果页面数据存在）
                    if (pageData != null)
                      SliverToBoxAdapter(
                        child: _SessionBar(
                          state: state,
                          activityId: widget.activityId,
                        ),
                      ),
                    // 场次倒计时（如果页面数据存在）
                    if (pageData != null)
                      SliverToBoxAdapter(
                        child: _SessionCountdown(
                          sessions: pageData.sessions,
                          selectedSessionId: state.selectedSessionId,
                        ),
                      ),
                    // 促销入口（如果有促销数据）
                    if (pageData != null && pageData.promoEntries.isNotEmpty)
                      SliverToBoxAdapter(
                        child: _PromoEntries(entries: pageData.promoEntries),
                      ),
                    // 优惠券区域（如果页面数据存在）
                    if (pageData != null)
                      SliverToBoxAdapter(
                        child: _CouponSection(
                          state: state,
                          activityId: widget.activityId,
                        ),
                      ),
                    // 排序栏
                    SliverToBoxAdapter(
                      child: _SortBar(
                        state: state,
                        activityId: widget.activityId,
                      ),
                    ),
                    // 商品列表或空状态
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
                              final isLast = index >= products.length - 1;
                              return Padding(
                                padding: EdgeInsets.only(
                                  bottom: isLast ? 0 : 8,
                                ),
                                child: SHOFlashSaleProductCard(
                                  product: products[index],
                                  activityId: widget.activityId,
                                ),
                              );
                            },
                            childCount: products.length,
                          ),
                        ),
                      ),
                    SHOAppCustomRefresh.footerSliver(
                      _refreshCtrl,
                      onLoadRetry: _onLoadMore,
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
        padding: const EdgeInsets.symmetric(
          horizontal: SHOAppSpacing.pagePadding,
        ),
        itemCount: days.length,
        separatorBuilder: (_, __) => const SizedBox(width: SHOAppSpacing.sm),
        itemBuilder: (context, index) {
          final day = days[index];
          final selected = day.date == state.selectedDate;
          return GestureDetector(
            onTap: () => ref
                .read(flashSaleControllerProvider(activityId).notifier)
                .selectDate(day.date),// 点击切换日期
            child: Container(
              width: 64,
              padding: const EdgeInsets.symmetric(vertical: SHOAppSpacing.sm),
              decoration: BoxDecoration(
                color: selected
                    ? SHOAppColors.primary
                    : SHOAppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(SHOAppSpacing.cardRadius),
                border: Border.all(
                  color: selected ? SHOAppColors.primary : SHOAppColors.border,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 日期标签（如"12月25日"）
                  Text(
                    day.label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: selected ? Colors.white : SHOAppColors.textPrimary,
                    ),
                  ),
                  // 星期（如"周三"）
                  Text(
                    day.weekday,
                    style: TextStyle(
                      fontSize: 10,
                      color: selected ? Colors.white70 : SHOAppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 2),
                  // 状态徽章（未开始/进行中/即将结束/已结束）
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

// 场次选择 Widget（横向场次栏）
class _SessionBar extends ConsumerWidget {
  const _SessionBar({required this.state, required this.activityId});

  final SHOFlashSalePageState state;
  final String activityId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 获取场次列表
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
          final isOngoing = session.status == SHOFlashSaleDayStatus.ongoing; // 是否进行中

          // 动态计算颜色
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
                .selectSession(session.id),// 点击切换场次
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
              child: Text(// 场次标签（如"10:00场"）
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

// 格式化时间显示（ISO 时间转为 HH:MM 格式）
String _formatSessionClock(String iso) {
  // 解析 ISO 时间并转为本地时间
  final dt = DateTime.tryParse(iso)?.toLocal();
  if (dt == null) return '--:--';
  final h = dt.hour.toString().padLeft(2, '0');// 小时补零
  final m = dt.minute.toString().padLeft(2, '0');// 分钟补零
  return '$h:$m';
}

/// 场次倒计时独立行：展示开始/结束时间 + 倒计时；已结束则在下方提示。
class _SessionCountdown extends StatelessWidget {
  const _SessionCountdown({
    required this.sessions,
    required this.selectedSessionId,
  });

  final List<SHOFlashSaleSession> sessions;// 场次列表
  final String selectedSessionId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // 查找选中的场次
    final session = SHOListUtils.firstWhereOrNull(
      sessions,
      (s) => s.id == selectedSessionId,
    );
    if (session == null) return const SizedBox.shrink();

    final status = session.status;
    // "开始时间: 10:00"
    final startLabel = l10n.flashSaleSessionStartAt(
      _formatSessionClock(session.startAt),
    );
    // "结束时间: 12:00"
    final endLabel = l10n.flashSaleSessionEndAt(
      _formatSessionClock(session.endAt),
    );
    final isEnded = status == SHOFlashSaleDayStatus.ended;
    // 根据状态决定倒计时目标
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
      SHOFlashSaleDayStatus.ongoing => SHOAppColors.accent.withValues(
        alpha: 0.08,
      ),
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
                // 时间范围显示
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
                    const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: SHOAppSpacing.sm,
                      ),
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
                // 倒计时组件（如果未结束）
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
          // 已结束提示
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

// 促销入口横向列表（如"限时抢购"、"新人专享"等入口图标）
class _PromoEntries extends ConsumerWidget {
  const _PromoEntries({required this.entries});

  final List<SHOFlashSalePromoEntry> entries;// 促销入口列表

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);// 用户会话信息

    return SizedBox(
      height: 88,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: SHOAppSpacing.pagePadding,
        ),
        itemCount: entries.length,
        separatorBuilder: (_, __) => const SizedBox(width: SHOAppSpacing.lg),
        itemBuilder: (context, index) {
          final entry = entries[index];
          return GestureDetector(
            onTap: () => SHODeepLinkNavigator.openLink(
              context,
              entry.deeplink,
              session: session,
            ),// 点击跳转深度链接
            child: SizedBox(
              width: 64,
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(
                      SHOAppSpacing.cardRadius,
                    ),
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

// 优惠券区域（包含标题和横向优惠券列表）
class _CouponSection extends ConsumerWidget {
  const _CouponSection({required this.state, required this.activityId});

  final SHOFlashSalePageState state;
  final String activityId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final pageData = state.pageData!;
    final coupons = state.mergedCoupons;// 合后的优惠券列表

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
              separatorBuilder: (_, __) =>
                  const SizedBox(width: SHOAppSpacing.sm),
              itemBuilder: (context, index) {
                final coupon = coupons[index];
                return _CouponTile(
                  coupon: coupon,
                  l10n: l10n,
                  onClaim: () async {
                    // 领取优惠券（如果状态为可领取）
                    if (coupon.status == SHOFlashSaleCouponStatus.claimable) {
                      await ref
                          .read(
                            flashSaleControllerProvider(activityId).notifier,
                          )
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
  const _CouponHeader({
    required this.pageData,
    required this.coupons,
    required this.l10n,
  });

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
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: SHOAppColors.textMuted,
          ),
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
    final highlight =
        coupon.status == SHOFlashSaleCouponStatus.claimable ||
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
              color: highlight ? SHOAppColors.accent : const Color(0xFFD5D5D5),
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
                  color: highlight
                      ? SHOAppColors.accent
                      : SHOAppColors.textMuted,
                ),
              ),
              Text(
                coupon.description,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10,
                  color: highlight
                      ? SHOAppColors.textSecondary
                      : SHOAppColors.textMuted,
                ),
              ),
              const Spacer(),
              Text(
                _statusLabel(coupon.status),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: highlight
                      ? SHOAppColors.accent
                      : SHOAppColors.textMuted,
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
              selected:
                  state.sort == item.$1 ||
                  (item.$1 == SHOFlashSaleSort.priceAsc &&
                      state.sort == SHOFlashSaleSort.priceDesc),
              onTap: () {
                if (item.$1 == SHOFlashSaleSort.priceAsc) {
                  final next = state.sort == SHOFlashSaleSort.priceAsc
                      ? SHOFlashSaleSort.priceDesc
                      : SHOFlashSaleSort.priceAsc;
                  ref
                      .read(flashSaleControllerProvider(activityId).notifier)
                      .selectSort(next);
                } else {
                  ref
                      .read(flashSaleControllerProvider(activityId).notifier)
                      .selectSort(item.$1);
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
