import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/hos_routes.dart';
import '../../../core/analytics/hos_analytics.dart';
import '../../../core/feedback/hos_toast.dart';
import '../../../core/platform/hos_native_business_event.dart';
import '../../../core/platform/hos_native_business_event_service.dart';
import '../../../core/theme/hos_colors.dart';
import '../../../core/theme/hos_spacing.dart';
import '../../../core/widgets/hos_button.dart';
import '../../../l10n/app_localizations.dart';
import '../../cart/presentation/hos_cart_controller.dart';
import '../../order/domain/hos_order.dart';
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
  bool _polling = false;
  bool _paymentTracked = false;
  Timer? _pollTimer;
  int _pollAttempts = 0;
  StreamSubscription<SHONativeBusinessEvent>? _nativePaymentSub;
  String? _nativeStatusMessage;

  static const _maxPollAttempts = 8;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkExistingPayment());
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _nativePaymentSub?.cancel();
    super.dispose();
  }

  void _listenNativePayment() {
    _nativePaymentSub?.cancel();
    _nativePaymentSub = ref
        .read(nativeBusinessEventServiceProvider)
        .watchPayment(orderId: widget.orderId)
        .listen((event) {
      if (!mounted) return;
      if (event.message != null) {
        setState(() => _nativeStatusMessage = event.message);
      }
      if (event.status == 'success') {
        setState(() {
          _paid = true;
          _nativeStatusMessage = null;
        });
        _stopPolling();
        ref.invalidate(ordersProvider);
        _trackPaymentSuccess();
      }
    });
  }

  Future<void> _checkExistingPayment() async {
    try {
      final detail = await ref.read(orderDetailProvider(widget.orderId).future);
      if (!mounted) return;
      if (_isPaidStatus(detail.status)) {
        setState(() => _paid = true);
        _trackPaymentSuccess();
      }
    } catch (_) {}
  }

  Future<void> _trackPaymentSuccess() async {
    if (_paymentTracked) return;
    _paymentTracked = true;
    try {
      final detail = await ref.read(orderDetailProvider(widget.orderId).future);
      await SHOAnalyticsManager.instance.trackEvent(
        SHOAnalyticsRegistry.paymentSuccess,
        {
          'order_id': widget.orderId,
          'amount': detail.totalCents / 100.0,
        },
      );
    } catch (_) {}
  }

  bool _isPaidStatus(SHOOrderStatus status) {
    return status == SHOOrderStatus.paid ||
        status == SHOOrderStatus.shipped ||
        status == SHOOrderStatus.delivered;
  }

  Future<void> _pay() async {
    if (_paying || _paid) return;

    setState(() => _paying = true);
    _listenNativePayment();
    try {
      await Future<void>.delayed(const Duration(seconds: 2));
      await ref.read(checkoutApiProvider).payOrder(widget.orderId);
      await ref.read(cartProvider.notifier).removeSelected();
      ref.invalidate(ordersProvider);
      if (!mounted) return;
      setState(() => _paid = true);
      await _trackPaymentSuccess();
      SHOAppToast.success(AppLocalizations.of(context).paymentSuccessTitle);
      _startPolling();
    } catch (error) {
      if (mounted) {
        SHOAppToast.error(error.toString());
      }
    } finally {
      if (mounted) setState(() => _paying = false);
    }
  }

  void _startPolling() {
    if (_polling) return;
    _polling = true;
    _pollAttempts = 0;
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 2), (_) async {
      _pollAttempts++;
      try {
        final detail = await ref.read(orderDetailProvider(widget.orderId).future);
        if (_isPaidStatus(detail.status) && mounted) {
          setState(() => _paid = true);
          _stopPolling();
        }
      } catch (_) {}
      if (_pollAttempts >= _maxPollAttempts) {
        _stopPolling();
      }
    });
  }

  void _stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
    _polling = false;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final canPay = !_paying && !_paid;

    return PopScope(
      canPop: !_paying,
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.paymentTitle)),
        body: Padding(
          padding: const EdgeInsets.all(SHOAppSpacing.pagePadding),
          child: Column(
            children: [
              const SizedBox(height: SHOAppSpacing.xxxl),
              Icon(
                _paid
                    ? Icons.check_circle_rounded
                    : Icons.account_balance_wallet_outlined,
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
              if (_polling || _nativeStatusMessage != null) ...[
                const SizedBox(height: SHOAppSpacing.lg),
                Text(
                  _nativeStatusMessage ?? l10n.paymentPollingStatus,
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ],
              if (!_paid) ...[
                const Spacer(),
                SHOAppButton(
                  label: l10n.paymentPayNow,
                  isExpanded: true,
                  isLoading: _paying,
                  onPressed: canPay ? _pay : null,
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
      ),
    );
  }
}
