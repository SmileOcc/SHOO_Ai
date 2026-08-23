import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shoo/core/feedback/hos_toast.dart';
import 'package:shoo/core/theme/hos_colors.dart';
import 'package:shoo/core/theme/hos_spacing.dart';
import 'package:shoo/features/theme_activity/domain/entities/hos_theme_coupon_status.dart';
import 'package:shoo/features/theme_activity/presentation/analytics/hos_theme_activity_tracking_scope.dart';
import 'package:shoo/features/theme_activity/presentation/navigation/hos_theme_activity_link_handler.dart';
import 'package:shoo/features/theme_activity/presentation/state/hos_theme_activity_controller.dart';
import 'package:shoo/features/theme_activity/presentation/style/hos_module_style.dart';
import 'package:shoo/features/theme_activity/presentation/widgets/hos_theme_horizontal_strip.dart';

class SHOThemeCouponModule extends ConsumerStatefulWidget {
  const SHOThemeCouponModule({
    super.key,
    required this.raw,
    required this.style,
  });

  final Map<String, dynamic> raw;
  final Map<String, dynamic> style;

  @override
  ConsumerState<SHOThemeCouponModule> createState() =>
      _SHOThemeCouponModuleState();
}

class _SHOThemeCouponModuleState extends ConsumerState<SHOThemeCouponModule> {
  Future<void> _claim(
    SHOThemeActivityController controller, {
    required String couponId,
    String? channel,
    String? moduleId,
  }) async {
    try {
      await controller.claimCoupon(
        couponId: couponId,
        channel: channel,
        moduleId: moduleId,
      );
      if (!mounted) return;
      SHOAppToast.show('领取成功', type: SHOToastType.success);
    } catch (error) {
      if (!mounted) return;
      final message = error is DioException &&
              error.type == DioExceptionType.connectionError
          ? '无法连接服务器，请确认 API 已启动（:8080）'
          : '领取失败';
      SHOAppToast.show(message, type: SHOToastType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final raw = widget.raw;
    final style = widget.style;
    final items = raw['items'];
    if (items is! List || items.isEmpty) return const SizedBox.shrink();

    final scope = SHOThemeActivityTrackingScope.maybeOf(context);
    final activityId = scope?.activityId;
    if (activityId == null || activityId.isEmpty) {
      return const SizedBox.shrink();
    }

    final pageState = ref.watch(themeActivityControllerProvider(activityId));
    final controller =
        ref.read(themeActivityControllerProvider(activityId).notifier);
    final layout = raw['layout'] as String? ?? 'horizontalScroll';
    final highlight = parseThemeColor(
      style['highlightColor'] as String?,
      fallback: SHOAppColors.sale,
    );
    final moduleId = raw['moduleId'] as String?;

    void onButtonTap(Map<String, dynamic> item) {
      final couponId = item['couponId'] as String? ?? '';
      final status = resolveThemeCouponStatus(
        item: item,
        claimedCouponIds: pageState.claimedCouponIds,
      );
      final link = item['link'] as String?;

      if (status.canClaim) {
        if (couponId.isNotEmpty) {
          _claim(
            controller,
            couponId: couponId,
            channel: scope?.channel,
            moduleId: moduleId,
          );
        }
        return;
      }

      if (status.canUseLink && link != null && link.isNotEmpty) {
        SHOThemeActivityLinkHandler.open(
          context,
          link,
          moduleId: moduleId,
          itemId: couponId,
        );
        return;
      }

      if (link != null && link.isNotEmpty) {
        SHOThemeActivityLinkHandler.open(
          context,
          link,
          moduleId: moduleId,
          itemId: couponId,
        );
      }
    }

    if (layout == 'grid') {
      final columns = (raw['columns'] as int? ?? 2).clamp(1, 3);
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 2.4,
        ),
        itemBuilder: (context, index) {
          final item = items[index];
          if (item is! Map<String, dynamic>) return const SizedBox.shrink();
          final couponId = item['couponId'] as String? ?? '';
          final status = resolveThemeCouponStatus(
            item: item,
            claimedCouponIds: pageState.claimedCouponIds,
          );
          return _CouponCard(
            item: item,
            status: status,
            isClaiming: pageState.claimingCouponIds.contains(couponId),
            highlight: highlight,
            onTap: () => onButtonTap(item),
          );
        },
      );
    }

    return SHOThemeHorizontalStrip(
      height: 118,
      padding: const EdgeInsets.symmetric(horizontal: SHOAppSpacing.md),
      children: [
        for (var index = 0; index < items.length; index++) ...[
          if (index > 0) const SizedBox(width: 8),
          SizedBox(
            width: 232,
            child: Builder(
              builder: (context) {
                final item = items[index];
                if (item is! Map<String, dynamic>) {
                  return const SizedBox.shrink();
                }
                final couponId = item['couponId'] as String? ?? '';
                final status = resolveThemeCouponStatus(
                  item: item,
                  claimedCouponIds: pageState.claimedCouponIds,
                );
                return _CouponCard(
                  item: item,
                  status: status,
                  isClaiming: pageState.claimingCouponIds.contains(couponId),
                  highlight: highlight,
                  onTap: () => onButtonTap(item),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}

class _CouponCard extends StatelessWidget {
  const _CouponCard({
    required this.item,
    required this.status,
    required this.onTap,
    this.isClaiming = false,
    this.highlight,
  });

  final Map<String, dynamic> item;
  final SHOThemeCouponStatus status;
  final bool isClaiming;
  final Color? highlight;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final amount = item['amount'];
    final title = item['title'] as String? ?? '';
    final condition = item['condition'] as String? ?? '';
    final buttonText = themeCouponButtonText(item, status);
    final statusLabel = themeCouponStatusLabel(status);
    final accent = highlight ?? SHOAppColors.sale;
    final highlightCard =
        status == SHOThemeCouponStatus.claimable ||
        status == SHOThemeCouponStatus.claimed;
    final canTap = !status.isDisabled && !isClaiming;

    return Opacity(
      opacity: highlightCard ? 1 : 0.72,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: highlightCard
                ? accent.withValues(alpha: 0.45)
                : const Color(0xFFD5D5D5),
          ),
          color: highlightCard
              ? accent.withValues(alpha: 0.06)
              : const Color(0xFFF3F4F6),
        ),
        child: Stack(
          children: [
            if (status == SHOThemeCouponStatus.claimed)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: accent,
                    ),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Text(
                    amount == null ? '' : '¥$amount',
                    style: TextStyle(
                      color: highlightCard ? accent : SHOAppColors.textMuted,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: highlightCard
                                ? null
                                : SHOAppColors.textMuted,
                          ),
                        ),
                        if (condition.isNotEmpty)
                          Text(
                            condition,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        if (status == SHOThemeCouponStatus.claimable &&
                            statusLabel.isNotEmpty)
                          Text(
                            statusLabel,
                            style: TextStyle(
                              fontSize: 11,
                              color: accent,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                  ),
                  isClaiming
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: accent,
                          ),
                        )
                      : TextButton(
                          onPressed: canTap ? onTap : null,
                          child: Text(buttonText),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
