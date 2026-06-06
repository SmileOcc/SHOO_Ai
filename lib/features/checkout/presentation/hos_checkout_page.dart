import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/hos_routes.dart';
import '../../../core/pricing/hos_price_calculator.dart';
import '../../../core/theme/hos_colors.dart';
import '../../../core/theme/hos_spacing.dart';
import '../../../core/utils/hos_price_formatter.dart';
import '../../../core/widgets/hos_button.dart';
import '../../../core/widgets/hos_loading_state.dart';
import '../../../core/widgets/hos_network_image.dart';
import '../../../core/widgets/hos_price_breakdown.dart';
import '../../../features/auth/presentation/hos_session_provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../address/domain/hos_address.dart';
import '../../address/presentation/hos_address_controller.dart';
import '../../cart/presentation/hos_cart_controller.dart';
import '../../coupon/domain/hos_coupon.dart';
import '../../coupon/presentation/hos_coupon_controller.dart';
import '../data/hos_checkout_api.dart';

class SHOCheckoutPage extends ConsumerStatefulWidget {
  const SHOCheckoutPage({super.key});

  @override
  ConsumerState<SHOCheckoutPage> createState() => _SHOCheckoutPageState();
}

class _SHOCheckoutPageState extends ConsumerState<SHOCheckoutPage> {
  bool _submitting = false;
  SHOAddress? _pickedAddress;
  String? _pickedCouponId;

  Future<void> _pickAddress() async {
    final result = await context.push<SHOAddress>(SHOAppRoutes.addressesSelect);
    if (result != null && mounted) {
      setState(() => _pickedAddress = result);
    }
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

    final address =
        _pickedAddress ?? ref.read(selectedAddressProvider).valueOrNull;
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

    setState(() => _submitting = true);
    try {
      final order = await ref.read(checkoutApiProvider).createOrder(
            addressId: address.id,
            couponId: coupon != null &&
                    SHOPriceCalculator.couponIneligibleReason(
                          subtotalCents: ref.read(cartProvider).selectedTotalCents,
                          coupon: coupon,
                        ) ==
                        null
                ? couponId
                : null,
            items: items
                .map(
                  (i) => {
                    'productId': i.productId,
                    'quantity': i.quantity,
                    'variantLabel': i.variantLabel,
                  },
                )
                .toList(),
          );
      if (mounted) {
        context.push(SHOAppRoutes.payment(order.id));
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
    final breakdown = SHOPriceCalculator.calculateOrderPrice(
      subtotalCents: cart.selectedTotalCents,
      coupon: selectedCoupon,
    );

    if (items.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.checkoutTitle)),
        body: const SHOAppLoadingState(state: SHOLoadingState.empty),
      );
    }

    return Scaffold(
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
                color: SHOAppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(SHOAppSpacing.cardRadius),
              ),
              child: addressAsync.when(
                loading: () => Text(l10n.loading),
                error: (_, __) => Text(l10n.loadFailed),
                data: (address) {
                  final display = _pickedAddress ?? address;
                  if (display == null) {
                    return Text(l10n.checkoutAddAddress);
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${display.name}  ${display.phone}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: SHOAppSpacing.xs),
                      Text(
                        display.fullLine,
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
                color: SHOAppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(SHOAppSpacing.cardRadius),
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
                    priceFormatter.formatCents(item.price * item.quantity),
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
    );
  }
}
