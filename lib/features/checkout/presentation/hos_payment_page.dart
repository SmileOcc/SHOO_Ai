import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/hos_routes.dart';
import '../../../core/analytics/hos_analytics.dart';
import '../../../core/theme/hos_colors.dart';
import '../../../core/theme/hos_spacing.dart';
import '../../../core/theme/hos_theme_extension.dart';
import '../../../core/utils/hos_price_formatter.dart';
import '../../../core/widgets/hos_button.dart';
import '../../../core/widgets/hos_loading_state.dart';
import '../../../core/widgets/hos_network_image.dart';
import '../../../l10n/app_localizations.dart';
import '../../cart/presentation/hos_cart_controller.dart';
import '../../order/domain/hos_order.dart';
import '../../order/presentation/hos_order_controller.dart';
import '../data/hos_checkout_api.dart';
import '../domain/hos_payment_method.dart';
import '../../../core/navigation/hos_payment_flow_navigation.dart';
import 'hos_payment_dialog.dart';

class SHOPaymentPage extends ConsumerStatefulWidget {
  const SHOPaymentPage({
    super.key,
    required this.orderId,
    this.fromCartStack = false,
    this.initialOrder,
  });

  final String orderId;
  final bool fromCartStack;
  final SHOOrderDetail? initialOrder;

  @override
  ConsumerState<SHOPaymentPage> createState() => _SHOPaymentPageState();
}

class _SHOPaymentPageState extends ConsumerState<SHOPaymentPage> {
  bool _paid = false;
  bool _paymentTracked = false;
  SHOOrderDetail? _cashierOrder;
  SHOOrderDetail? _successOrder;

  @override
  void initState() {
    super.initState();
    _cashierOrder = widget.initialOrder;
  }

  bool _shouldShowCashier(SHOOrderDetail order) {
    return !_paid && order.status == SHOOrderStatus.pendingPayment;
  }

  Future<void> _trackPaymentSuccess(SHOOrderDetail detail) async {
    if (_paymentTracked) return;
    _paymentTracked = true;
    await SHOAnalyticsManager.instance.trackEvent(
      SHOAnalyticsRegistry.paymentSuccess,
      {
        'order_id': widget.orderId,
        'amount': detail.totalCents / 100.0,
      },
    );
  }

  void _returnToCart() {
    if (!mounted) return;
    context.pop();
    if (context.canPop()) context.pop();
  }

  void _continueShopping() {
    if (!mounted) return;
    context.pop();
    if (context.canPop()) context.pop();
    if (widget.fromCartStack && context.canPop()) {
      context.pop();
    }
  }

  /// 直接 push 订单详情（保持收银台→详情的转场动画）；返回时由详情页跳过收银台/确认订单。
  void _viewOrder() {
    context.push(
      SHOAppRoutes.order(widget.orderId),
      extra: SHOOrderDetailExtras.fromPaymentSuccess,
    );
  }

  Future<void> _openPaymentDialog(
    SHOOrderDetail order,
    SHOPaymentMethod method,
  ) async {
    final result = await SHOPaymentDialog.show(
      context,
      method: method,
      amountCents: order.totalCents,
      orderNo: order.orderNo,
    );
    if (!mounted || result == null) return;

    if (result == SHOPaymentDialogResult.cancelled) {
      _returnToCart();
      return;
    }

    try {
      await ref.read(checkoutApiProvider).payOrder(widget.orderId);
      await ref.read(cartProvider.notifier).removeSelected();
      ref.invalidate(ordersProvider);
      ref.invalidate(orderDetailProvider(widget.orderId));
      if (!mounted) return;
      setState(() {
        _paid = true;
        _successOrder = order.copyWith(status: SHOOrderStatus.paid);
      });
      await _trackPaymentSuccess(_successOrder!);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final orderAsync = ref.watch(orderDetailProvider(widget.orderId));

    if (_paid) {
      final order = _successOrder ?? orderAsync.valueOrNull ?? _cashierOrder;
      if (order == null) {
        return Scaffold(
          appBar: AppBar(title: Text(l10n.paymentTitle)),
          body: const SHOAppLoadingState(state: SHOLoadingState.loading),
        );
      }
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.paymentTitle),
          automaticallyImplyLeading: false,
        ),
        body: _PaymentSuccessView(
          order: order,
          onViewOrder: _viewOrder,
          onContinueShopping: _continueShopping,
        ),
      );
    }

    final cashierOrder = _cashierOrder ??
        (orderAsync.valueOrNull != null &&
                orderAsync.valueOrNull!.status == SHOOrderStatus.pendingPayment
            ? orderAsync.valueOrNull
            : null);

    if (cashierOrder != null && _shouldShowCashier(cashierOrder)) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.paymentTitle)),
        body: _PaymentCashierView(
          order: cashierOrder,
          onSelectMethod: (method) => _openPaymentDialog(cashierOrder, method),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.paymentTitle)),
      body: orderAsync.when(
        loading: () =>
            const SHOAppLoadingState(state: SHOLoadingState.loading),
        error: (error, _) => Center(child: Text(error.toString())),
        data: (order) {
          if (_shouldShowCashier(order)) {
            return _PaymentCashierView(
              order: order,
              onSelectMethod: (method) => _openPaymentDialog(order, method),
            );
          }
          return _PaymentSuccessView(
            order: order,
            onViewOrder: _viewOrder,
            onContinueShopping: _continueShopping,
          );
        },
      ),
    );
  }
}

class _PaymentCashierView extends StatelessWidget {
  const _PaymentCashierView({
    required this.order,
    required this.onSelectMethod,
  });

  final SHOOrderDetail order;
  final ValueChanged<SHOPaymentMethod> onSelectMethod;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return ListView(
      padding: const EdgeInsets.all(SHOAppSpacing.pagePadding),
      children: [
        _OrderSummaryCard(order: order),
        const SizedBox(height: SHOAppSpacing.xl),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(SHOAppSpacing.lg),
          decoration: BoxDecoration(
            color: SHOAppColors.primary.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(SHOAppSpacing.cardRadius),
            border: Border.all(color: context.shoTheme.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.paymentAmountDue,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: context.shoTheme.textSecondary,
                    ),
              ),
              const SizedBox(height: SHOAppSpacing.xs),
              Text(
                priceFormatter.formatCents(order.totalCents),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: SHOAppColors.sale,
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(height: SHOAppSpacing.xl),
        Text(
          l10n.paymentMethodsTitle,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: SHOAppSpacing.md),
        ...kPaymentMethods.map(
          (method) => Padding(
            padding: const EdgeInsets.only(bottom: SHOAppSpacing.sm),
            child: _PaymentMethodTile(
              method: method,
              onTap: () => onSelectMethod(method),
            ),
          ),
        ),
      ],
    );
  }
}

class _OrderSummaryCard extends StatelessWidget {
  const _OrderSummaryCard({required this.order});

  final SHOOrderDetail order;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(SHOAppSpacing.lg),
      decoration: BoxDecoration(
        color: context.shoTheme.surfaceMuted,
        borderRadius: BorderRadius.circular(SHOAppSpacing.cardRadius),
        border: Border.all(color: context.shoTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.paymentOrderInfo,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: SHOAppSpacing.sm),
          Text(
            '${l10n.orderNoLabel}: ${order.orderNo}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          if (order.shippingAddress.isNotEmpty) ...[
            const SizedBox(height: SHOAppSpacing.xs),
            Text(
              order.shippingAddress,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: context.shoTheme.textSecondary,
                  ),
            ),
          ],
          const SizedBox(height: SHOAppSpacing.md),
          Text(
            l10n.orderItemsTitle,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: SHOAppSpacing.sm),
          ...order.items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: SHOAppSpacing.sm),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius:
                        BorderRadius.circular(SHOAppSpacing.cardRadius),
                    child: SizedBox(
                      width: 48,
                      height: 48,
                      child: SHOAppNetworkImage(
                        url: item.imageUrl,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: SHOAppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Text(
                          'x${item.quantity}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: context.shoTheme.textMuted,
                              ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    priceFormatter.formatCents(item.price * item.quantity),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w700,
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

class _PaymentMethodTile extends StatelessWidget {
  const _PaymentMethodTile({
    required this.method,
    required this.onTap,
  });

  final SHOPaymentMethod method;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Material(
      color: context.shoTheme.surfaceMuted,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: SHOAppSpacing.lg,
            vertical: SHOAppSpacing.md,
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: method.tint.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(method.icon, color: method.tint, size: 22),
              ),
              const SizedBox(width: SHOAppSpacing.md),
              Expanded(
                child: Text(
                  method.label(l10n),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: context.shoTheme.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaymentSuccessView extends StatelessWidget {
  const _PaymentSuccessView({
    required this.order,
    required this.onViewOrder,
    required this.onContinueShopping,
  });

  final SHOOrderDetail order;
  final VoidCallback onViewOrder;
  final VoidCallback onContinueShopping;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.all(SHOAppSpacing.pagePadding),
      child: Column(
        children: [
          const SizedBox(height: SHOAppSpacing.xxxl),
          const Icon(
            Icons.check_circle_rounded,
            size: 72,
            color: SHOAppColors.success,
          ),
          const SizedBox(height: SHOAppSpacing.xl),
          Text(
            l10n.paymentSuccessTitle,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: SHOAppSpacing.md),
          Text(
            l10n.paymentSuccessMessage,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: SHOAppSpacing.lg),
          Text(
            priceFormatter.formatCents(order.totalCents),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: SHOAppColors.sale,
                ),
          ),
          const Spacer(),
          SHOAppButton(
            label: l10n.paymentViewOrder,
            isExpanded: true,
            onPressed: onViewOrder,
          ),
          const SizedBox(height: SHOAppSpacing.md),
          SHOAppButton(
            label: l10n.paymentContinueShopping,
            isExpanded: true,
            variant: SHOAppButtonVariant.outline,
            onPressed: onContinueShopping,
          ),
        ],
      ),
    );
  }
}
