import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/pricing/hos_price_calculator.dart';
import '../../../core/theme/hos_colors.dart';
import '../../../core/theme/hos_spacing.dart';
import '../../../core/utils/hos_price_formatter.dart';
import '../../../core/widgets/hos_loading_state.dart';
import '../../../core/widgets/hos_promo_tag.dart';
import '../../../l10n/app_localizations.dart';
import '../../cart/presentation/hos_cart_controller.dart';
import '../domain/hos_coupon.dart';
import 'hos_coupon_controller.dart';

class SHOCouponListPage extends ConsumerWidget {
  const SHOCouponListPage({super.key, this.selectMode = false});

  final bool selectMode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final couponsAsync = ref.watch(couponsProvider);
    final selectedId = ref.watch(selectedCouponIdProvider);
    final subtotal = ref.watch(cartProvider).selectedTotalCents;

    return Scaffold(
      appBar: AppBar(
        title: Text(selectMode ? l10n.couponSelectTitle : l10n.couponListTitle),
      ),
      body: couponsAsync.whenLoadingState(
        onRetry: () => ref.invalidate(couponsProvider),
        empty: (list) => list.isEmpty,
        data: (coupons) => ListView.separated(
          padding: const EdgeInsets.all(SHOAppSpacing.pagePadding),
          itemCount: coupons.length + (selectMode ? 1 : 0),
          separatorBuilder: (_, __) => const SizedBox(height: SHOAppSpacing.md),
          itemBuilder: (context, index) {
            if (selectMode && index == 0) {
              return _SHONoCouponTile(
                selected: selectedId == null,
                onTap: () {
                  ref.read(selectedCouponIdProvider.notifier).state = null;
                  context.pop();
                },
              );
            }
            final coupon = coupons[selectMode ? index - 1 : index];
            final ineligible = SHOPriceCalculator.couponIneligibleReason(
              subtotalCents: subtotal,
              coupon: coupon,
            );
            final selected = selectedId == coupon.id;

            return _SHOCouponTile(
              coupon: coupon,
              selected: selected,
              ineligible: ineligible,
              onTap: selectMode && ineligible == null
                  ? () {
                      ref.read(selectedCouponIdProvider.notifier).state = coupon.id;
                      context.pop();
                    }
                  : null,
            );
          },
        ),
      ),
    );
  }
}

class _SHONoCouponTile extends StatelessWidget {
  const _SHONoCouponTile({required this.selected, required this.onTap});

  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        selected ? Icons.radio_button_checked : Icons.radio_button_off,
        size: 20,
      ),
      title: Text(l10n.couponNone),
      onTap: onTap,
    );
  }
}

class _SHOCouponTile extends StatelessWidget {
  const _SHOCouponTile({
    required this.coupon,
    required this.selected,
    required this.ineligible,
    this.onTap,
  });

  final SHOCoupon coupon;
  final bool selected;
  final String? ineligible;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final disabled = !coupon.isAvailable || ineligible != null;

    final discountLabel = switch (coupon.type) {
      SHOCouponType.fixed => priceFormatter.formatCents(coupon.discountCents),
      SHOCouponType.percent => '-${coupon.discountPercent}%',
    };

    return Opacity(
      opacity: disabled ? 0.5 : 1,
      child: InkWell(
        onTap: disabled ? null : onTap,
        borderRadius: BorderRadius.circular(SHOAppSpacing.cardRadius),
        child: Container(
          padding: const EdgeInsets.all(SHOAppSpacing.lg),
          decoration: BoxDecoration(
            border: Border.all(
              color: selected ? SHOAppColors.primary : SHOAppColors.border,
              width: selected ? 1.5 : 1,
            ),
            borderRadius: BorderRadius.circular(SHOAppSpacing.cardRadius),
          ),
          child: Row(
            children: [
              if (onTap != null) ...[
                Icon(
                  selected ? Icons.radio_button_checked : Icons.radio_button_off,
                  size: 20,
                ),
                const SizedBox(width: SHOAppSpacing.md),
              ],
              SHOPromoTag(label: discountLabel),
              const SizedBox(width: SHOAppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      coupon.title,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                    ),
                    if (coupon.description.isNotEmpty)
                      Text(
                        coupon.description,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    if (coupon.minOrderCents > 0)
                      Text(
                        l10n.couponMinOrder(
                          priceFormatter.formatCents(coupon.minOrderCents),
                        ),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    if (ineligible == 'min_order')
                      Text(
                        l10n.couponNotEligible,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: SHOAppColors.error,
                            ),
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
}
