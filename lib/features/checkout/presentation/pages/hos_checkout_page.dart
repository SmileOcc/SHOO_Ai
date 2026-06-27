import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:shoo/app/router/hos_routes.dart';
import 'package:shoo/core/analytics/hos_analytics.dart';
import 'package:shoo/core/analytics/hos_page_analytics.dart';
import 'package:shoo/core/pages/hos_pages.dart';
import 'package:shoo/core/pricing/hos_full_reduction.dart';
import 'package:shoo/core/pricing/hos_price_calculator.dart';
import 'package:shoo/core/theme/hos_spacing.dart';
import 'package:shoo/core/theme/hos_theme_extension.dart';
import 'package:shoo/core/utils/hos_price_formatter.dart';
import 'package:shoo/core/widgets/hos_button.dart';
import 'package:shoo/core/widgets/hos_loading_state.dart';
import 'package:shoo/core/widgets/hos_network_image.dart';
import 'package:shoo/core/widgets/hos_price_breakdown.dart';
import 'package:shoo/features/auth/presentation/state/hos_session_provider.dart';
import 'package:shoo/l10n/app_localizations.dart';
import 'package:shoo/features/address/presentation/state/hos_address_controller.dart';
import 'package:shoo/features/cart/domain/entities/hos_cart.dart';
import 'package:shoo/features/cart/presentation/state/hos_cart_controller.dart';
import 'package:shoo/features/coupon/domain/entities/hos_coupon.dart';
import 'package:shoo/features/coupon/presentation/state/hos_coupon_controller.dart';
import 'package:shoo/features/checkout/data/datasources/remote/hos_checkout_remote_ds.dart';
import 'package:shoo/features/flash_sale/presentation/state/hos_checkout_activity_provider.dart';

class SHOCheckoutPage extends ConsumerStatefulWidget {
  const SHOCheckoutPage({super.key});

  @override
  ConsumerState<SHOCheckoutPage> createState() => _SHOCheckoutPageState();
}

class _SHOCheckoutPageState extends ConsumerState<SHOCheckoutPage>
    with SHOPageRouteAnalyticsMixin, SHOAppPageMixin, SHOAppTrackedPageMixin {
  bool _submitting = false;
  bool _checkoutTracked = false;
  String? _pickedCouponId;

  @override
  String get pageName => 'checkout';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _reportCheckoutStart());
  }

  Future<void> _reportCheckoutStart() async {
    if (_checkoutTracked) return;
    final cart = ref.read(cartProvider);
    final items = cart.selectedItems;
    if (items.isEmpty) return;
    _checkoutTracked = true;
    await SHOAnalyticsManager.instance.trackEvent(
      SHOAnalyticsRegistry.checkoutStart,
      {
        'item_count': items.length,
        'amount': cart.selectedTotalCents / 100.0,
      },
    );
  }

  Future<void> _pickAddress() async {
    await context.push(SHOAppRoutes.addressesSelect);
  }

  Future<void> _pickCoupon() async {
    final result = await context.push<String>(SHOAppRoutes.couponsSelect);
    if (result == null || !mounted) return;
    setState(() {
      _pickedCouponId = result.isEmpty ? null : result;
    });
  }

  Future<void> _placeOrder() async {
    final l10n = AppLocalizations.of(context);
    final session = ref.read(sessionProvider);
    if (!session.isAuthenticated) {
      context.push('${SHOAppRoutes.login}?redirect=${Uri.encodeComponent(SHOAppRoutes.checkout)}');
      return;
    }

    final address = ref.read(selectedAddressProvider).valueOrNull;
    if (address == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.checkoutNoAddress)),
      );
      return;
    }

    final items = ref.read(cartProvider).selectedItems;
    if (items.isEmpty) return;

    final couponId = _pickedCouponId ?? ref.read(selectedCouponIdProvider);
    final coupon = _resolveCoupon(couponId);

    final activityLines = ref.read(checkoutActivityLinesProvider);
    final subtotal = _subtotalCents(items, activityLines);
    final activitySaved = _activitySavedCents(items, activityLines);
    final fullReductionTiers = mergedFullReductionTiers(activityLines);

    setState(() => _submitting = true);
    try {
      final order = await ref.read(checkoutApiProvider).createOrder(
            addressId: address.id,
            couponId: coupon != null &&
                    SHOPriceCalculator.couponIneligibleReason(
                          subtotalCents: subtotal,
                          coupon: coupon,
                        ) ==
                        null
                ? couponId
                : null,
            items: items
                .map(
                  (i) {
                    final line = activityLines[i.productId];
                    return {
                      'productId': i.productId,
                      'quantity': i.quantity,
                      'variantLabel': i.variantLabel,
                      if (line != null) ...{
                        'sessionId': line.sessionId,
                        'unitPriceCents': line.unitPriceCents,
                      },
                    };
                  },
                )
                .toList(),
          );
      if (mounted) {
        final fromCartStack =
            GoRouterState.of(context).uri.queryParameters['fromCartStack'] ==
                '1';
        context.push(
          SHOAppRoutes.payment(order.id, fromCartStack: fromCartStack),
          extra: order,
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  SHOCoupon? _resolveCoupon(String? couponId) {
    if (couponId == null) return null;
    final coupons = ref.read(couponsProvider).valueOrNull ?? [];
    final matches = coupons.where((c) => c.id == couponId);
    return matches.isEmpty ? null : matches.first;
  }

  SHOCoupon? _displayCoupon() {
    return _resolveCoupon(_pickedCouponId ?? ref.read(selectedCouponIdProvider));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cart = ref.watch(cartProvider);
    final items = cart.selectedItems;
    final addressAsync = ref.watch(selectedAddressProvider);
    final selectedCoupon = _displayCoupon();
    final activityLines = ref.watch(checkoutActivityLinesProvider);
    final subtotal = _subtotalCents(items, activityLines);
    final activitySaved = _activitySavedCents(items, activityLines);
    final breakdown = SHOPriceCalculator.calculateOrderPrice(
      subtotalCents: subtotal,
      coupon: selectedCoupon,
      fullReductionTiers: mergedFullReductionTiers(activityLines),
      activitySavedCents: activitySaved,
    );

    if (items.isEmpty) {
      return buildTrackedPage(
        Scaffold(
        appBar: AppBar(title: Text(l10n.checkoutTitle)),
        body: const SHOAppLoadingState(state: SHOLoadingState.empty),
        ),
      );
    }

    return buildTrackedPage(
      Scaffold(
      appBar: AppBar(title: Text(l10n.checkoutTitle)),
      body: ListView(
        padding: const EdgeInsets.all(SHOAppSpacing.pagePadding),
        children: [
          Text(
            l10n.checkoutAddressSection,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: SHOAppSpacing.md),
          InkWell(
            onTap: _pickAddress,
            borderRadius: BorderRadius.circular(SHOAppSpacing.cardRadius),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(SHOAppSpacing.lg),
              decoration: BoxDecoration(
                color: context.shoTheme.surfaceMuted,
                borderRadius: BorderRadius.circular(SHOAppSpacing.cardRadius),
                border: Border.all(color: context.shoTheme.border),
              ),
              child: addressAsync.when(
                loading: () => Text(l10n.loading),
                error: (_, __) => Text(l10n.loadFailed),
                data: (address) {
                  if (address == null) {
                    return Text(l10n.checkoutAddAddress);
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${address.name}  ${address.phone}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: SHOAppSpacing.xs),
                      Text(
                        address.fullLine,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: SHOAppSpacing.xl),
          Text(
            l10n.checkoutCouponSection,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: SHOAppSpacing.md),
          InkWell(
            onTap: _pickCoupon,
            borderRadius: BorderRadius.circular(SHOAppSpacing.cardRadius),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(SHOAppSpacing.lg),
              decoration: BoxDecoration(
                color: context.shoTheme.surfaceMuted,
                borderRadius: BorderRadius.circular(SHOAppSpacing.cardRadius),
                border: Border.all(color: context.shoTheme.border),
              ),
              child: Row(
                children: [
                  const Icon(Icons.local_offer_outlined, size: 20),
                  const SizedBox(width: SHOAppSpacing.md),
                  Expanded(
                    child: Text(
                      selectedCoupon?.title ?? l10n.couponSelectHint,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontSize: 13,
                          ),
                    ),
                  ),
                  const Icon(Icons.chevron_right, size: 18),
                ],
              ),
            ),
          ),
          const SizedBox(height: SHOAppSpacing.xl),
          Text(
            l10n.orderItemsTitle,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: SHOAppSpacing.md),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: SHOAppSpacing.md),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(SHOAppSpacing.cardRadius),
                    child: SizedBox(
                      width: 56,
                      height: 56,
                      child: SHOAppNetworkImage(url: item.imageUrl, fit: BoxFit.cover),
                    ),
                  ),
                  const SizedBox(width: SHOAppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.title, style: Theme.of(context).textTheme.bodySmall),
                        Text('x${item.quantity}', style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  ),
                  Text(
                    priceFormatter.formatCents(
                      (activityLines[item.productId]?.unitPriceCents ?? item.price) *
                          item.quantity,
                    ),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
              ),
            ),
          ),
          SHOPriceBreakdownView(breakdown: breakdown),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(SHOAppSpacing.pagePadding),
          child: SHOAppButton(
            label: l10n.checkoutPlaceOrder,
            isExpanded: true,
            isLoading: _submitting,
            onPressed: _submitting ? null : _placeOrder,
          ),
        ),
      ),
    ),
    );
  }

  int _subtotalCents(
    List<SHOCartItem> items,
    Map<String, SHOCheckoutActivityLine> activityLines,
  ) {
    var total = 0;
    for (final item in items) {
      final line = activityLines[item.productId];
      final unit = line?.unitPriceCents ?? item.price;
      total += unit * item.quantity;
    }
    return total;
  }

  int _activitySavedCents(
    List<SHOCartItem> items,
    Map<String, SHOCheckoutActivityLine> activityLines,
  ) {
    var saved = 0;
    for (final item in items) {
      final line = activityLines[item.productId];
      if (line == null) continue;
      if (line.originalUnitPriceCents <= line.unitPriceCents) continue;
      saved += (line.originalUnitPriceCents - line.unitPriceCents) * item.quantity;
    }
    return saved;
  }
}
