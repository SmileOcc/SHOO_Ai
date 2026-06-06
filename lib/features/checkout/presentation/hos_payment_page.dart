import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/hos_routes.dart';
import '../../../core/theme/hos_colors.dart';
import '../../../core/theme/hos_spacing.dart';
import '../../../core/widgets/hos_button.dart';
import '../../../l10n/app_localizations.dart';
import '../../cart/presentation/hos_cart_controller.dart';
import '../../order/presentation/hos_order_controller.dart';
import '../data/hos_checkout_api.dart';

class SHOPaymentPage extends ConsumerStatefulWidget {
  const SHOPaymentPage({super.key, required this.orderId});

  final String orderId;

  @override
  ConsumerState<SHOPaymentPage> createState() => _SHOPaymentPageState();
}

class _SHOPaymentPageState extends ConsumerState<SHOPaymentPage> {
  bool _paying = false;
  bool _paid = false;

  Future<void> _pay() async {
    setState(() => _paying = true);
    try {
      await Future<void>.delayed(const Duration(seconds: 2));
      await ref.read(checkoutApiProvider).payOrder(widget.orderId);
      await ref.read(cartProvider.notifier).removeSelected();
      ref.invalidate(ordersProvider);
      if (mounted) setState(() => _paid = true);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _paying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.paymentTitle)),
      body: Padding(
        padding: const EdgeInsets.all(SHOAppSpacing.pagePadding),
        child: Column(
          children: [
            const SizedBox(height: SHOAppSpacing.xxxl),
            Icon(
              _paid ? Icons.check_circle_rounded : Icons.account_balance_wallet_outlined,
              size: 72,
              color: _paid ? SHOAppColors.success : SHOAppColors.primary,
            ),
            const SizedBox(height: SHOAppSpacing.xl),
            Text(
              _paid ? l10n.paymentSuccessTitle : l10n.paymentMockTitle,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: SHOAppSpacing.md),
            Text(
              _paid ? l10n.paymentSuccessMessage : l10n.paymentMockHint,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            if (!_paid) ...[
              const Spacer(),
              SHOAppButton(
                label: l10n.paymentPayNow,
                isExpanded: true,
                isLoading: _paying,
                onPressed: _paying ? null : _pay,
              ),
            ] else ...[
              const Spacer(),
              SHOAppButton(
                label: l10n.paymentViewOrder,
                isExpanded: true,
                onPressed: () => context.go(SHOAppRoutes.order(widget.orderId)),
              ),
              const SizedBox(height: SHOAppSpacing.md),
              SHOAppButton(
                label: l10n.paymentContinueShopping,
                isExpanded: true,
                variant: SHOAppButtonVariant.outline,
                onPressed: () => context.go(SHOAppRoutes.home),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
