import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shoo/core/pages/hos_pages.dart';
import 'package:shoo/core/pricing/hos_price_calculator.dart';
import 'package:shoo/core/theme/hos_colors.dart';
import 'package:shoo/core/theme/hos_spacing.dart';
import 'package:shoo/core/utils/hos_price_formatter.dart';
import 'package:shoo/core/widgets/hos_promo_tag.dart';
import 'package:shoo/l10n/app_localizations.dart';
import 'package:shoo/features/cart/presentation/state/hos_cart_controller.dart';
import 'package:shoo/features/coupon/domain/entities/hos_coupon.dart';
import 'package:shoo/features/coupon/presentation/state/hos_coupon_controller.dart';

class SHOCouponListPage extends SHOSelectorPage<SHOCoupon> {
  const SHOCouponListPage({super.key, required super.selectMode});

  @override
  SHOSelectorPageState<SHOCoupon, SHOCouponListPage> createState() =>
      _SHOCouponListPageState();
}

class _SHOCouponListPageState
    extends SHOSelectorPageState<SHOCoupon, SHOCouponListPage> {
  @override
  ProviderListenable<AsyncValue<List<SHOCoupon>>> get dataProvider =>
      couponsProvider;

  @override
  void invalidateData(WidgetRef ref) => ref.invalidate(couponsProvider);

  @override
  String get pageName => 'coupon_list';

  @override
  bool isEmptyData(List<SHOCoupon> data) => data.isEmpty;

  @override
  PreferredSizeWidget? buildPageAppBar(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return AppBar(
      title: Text(
        selectorTitle(
          selectTitle: l10n.couponSelectTitle,
          listTitle: l10n.couponListTitle,
        ),
      ),
    );
  }

  @override
  Widget buildContent(
    BuildContext context,
    WidgetRef ref,
    List<SHOCoupon> coupons,
  ) {
    final selectedId = ref.watch(selectedCouponIdProvider);
    final subtotal = ref.watch(cartProvider).selectedTotalCents;

    return ListView.separated(
      padding: const EdgeInsets.all(SHOAppSpacing.pagePadding),
      itemCount: coupons.length + (widget.selectMode ? 1 : 0),
      separatorBuilder: (_, __) => const SizedBox(height: SHOAppSpacing.md),
      itemBuilder: (context, index) {
        if (widget.selectMode && index == 0) {
          return _SHONoCouponTile(
            selected: selectedId == null,
            onTap: () {
              ref.read(selectedCouponIdProvider.notifier).state = null;
              popSelectResult('');
            },
          );
        }
        final coupon = coupons[widget.selectMode ? index - 1 : index];
        final ineligible = SHOPriceCalculator.couponIneligibleReason(
          subtotalCents: subtotal,
          coupon: coupon,
        );
        final selected = selectedId == coupon.id;

        return _SHOCouponTile(
          coupon: coupon,
          selected: selected,
          ineligible: ineligible,
          onTap: widget.selectMode && ineligible == null
              ? () {
                  ref.read(selectedCouponIdProvider.notifier).state = coupon.id;
                  popSelectResult(coupon.id);
                }
              : null,
        );
      },
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
                  selected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
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
