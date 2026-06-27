import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:shoo/app/router/hos_routes.dart';
import 'package:shoo/core/navigation/hos_payment_flow_navigation.dart';
import 'package:shoo/core/pages/hos_pages.dart';
import 'package:shoo/core/theme/hos_colors.dart';
import 'package:shoo/core/theme/hos_spacing.dart';
import 'package:shoo/core/utils/hos_price_formatter.dart';
import 'package:shoo/core/widgets/hos_button.dart';
import 'package:shoo/core/widgets/hos_network_image.dart';
import 'package:shoo/l10n/app_localizations.dart';
import 'package:shoo/features/order/domain/entities/hos_order.dart';
import 'package:shoo/features/order/presentation/state/hos_order_controller.dart';
import 'package:shoo/features/order/presentation/widgets/hos_order_status_label.dart';

bool _canApplyAfterSale(SHOOrderStatus status) =>
    status == SHOOrderStatus.shipped ||
    status == SHOOrderStatus.delivered ||
    status == SHOOrderStatus.paid;

class SHOOrderDetailPage extends SHODataPage<SHOOrderDetail> {
  const SHOOrderDetailPage({
    super.key,
    required this.orderId,
    this.skipPaymentFlowOnPop = false,
  });

  final String orderId;
  final bool skipPaymentFlowOnPop;

  @override
  SHODataPageState<SHOOrderDetail, SHOOrderDetailPage> createState() =>
      _SHOOrderDetailPageState();
}

class _SHOOrderDetailPageState
    extends SHODataPageState<SHOOrderDetail, SHOOrderDetailPage> {
  @override
  ProviderListenable<AsyncValue<SHOOrderDetail>> get dataProvider =>
      orderDetailProvider(widget.orderId);

  @override
  void invalidateData(WidgetRef ref) =>
      ref.invalidate(orderDetailProvider(widget.orderId));

  @override
  String get pageName => 'order_detail';

  @override
  Map<String, Object?> get pageAnalyticsExtra => {
        'order_id': widget.orderId,
        if (widget.skipPaymentFlowOnPop) 'skip_payment_flow_on_pop': true,
      };

  @override
  void onPageResumeVisible(WidgetRef ref) {
    super.onPageResumeVisible(ref);
    ref.invalidate(orderDetailProvider(widget.orderId));
  }

  void _handleBack(BuildContext context) {
    if (widget.skipPaymentFlowOnPop) {
      popOrderDetailPastPaymentFlow(GoRouter.of(context));
      return;
    }
    if (context.canPop()) context.pop();
  }

  @override
  PreferredSizeWidget? buildPageAppBar(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return AppBar(
      title: Text(l10n.orderDetailTitle),
      leading: widget.skipPaymentFlowOnPop
          ? BackButton(onPressed: () => _handleBack(context))
          : null,
    );
  }

  @override
  SHOAppShellPage buildShell(
    BuildContext context,
    WidgetRef ref, {
    required PreferredSizeWidget? appBar,
    required Widget body,
  }) {
    return SHOAppShellPage(
      appBar: appBar,
      body: body,
      canPop: !widget.skipPaymentFlowOnPop,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && widget.skipPaymentFlowOnPop) {
          popOrderDetailPastPaymentFlow(GoRouter.of(context));
        }
      },
    );
  }

  @override
  Widget buildContent(
    BuildContext context,
    WidgetRef ref,
    SHOOrderDetail detail,
  ) {
    final l10n = AppLocalizations.of(context);

    return ListView(
      padding: const EdgeInsets.all(SHOAppSpacing.pagePadding),
      children: [
        _SHOInfoRow(
          label: l10n.orderNoLabel,
          value: detail.orderNo,
        ),
        _SHOInfoRow(
          label: l10n.orderStatusLabel,
          value: shoOrderStatusLabel(context, detail.status),
        ),
        _SHOInfoRow(
          label: l10n.orderCreatedAtLabel,
          value: detail.createdAt,
        ),
        if (detail.shippingAddress.isNotEmpty) ...[
          const SizedBox(height: SHOAppSpacing.md),
          Text(
            l10n.orderShippingAddress,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: SHOAppSpacing.xs),
          Text(
            detail.shippingAddress,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 13,
                ),
          ),
        ],
        const SizedBox(height: SHOAppSpacing.xl),
        Text(
          l10n.orderItemsTitle,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: SHOAppSpacing.md),
        ...detail.items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: SHOAppSpacing.md),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius:
                      BorderRadius.circular(SHOAppSpacing.cardRadius),
                  child: SizedBox(
                    width: 72,
                    height: 72,
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
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontSize: 13,
                            ),
                      ),
                      if (item.variantLabel.isNotEmpty)
                        Text(
                          item.variantLabel,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      Text(
                        'x${item.quantity}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
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
        const Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.orderTotalLabel,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            Text(
              priceFormatter.formatCents(detail.totalCents),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: SHOAppColors.primary,
                  ),
            ),
          ],
        ),
        if (detail.hasLogistics) ...[
          const SizedBox(height: SHOAppSpacing.xl),
          SHOAppButton(
            label: l10n.logisticsTrackAction,
            isExpanded: true,
            onPressed: () =>
                context.push(SHOAppRoutes.orderLogistics(widget.orderId)),
          ),
        ],
        if (_canApplyAfterSale(detail.status)) ...[
          const SizedBox(height: SHOAppSpacing.md),
          SHOAppButton(
            label: l10n.afterSaleApplyAction,
            isExpanded: true,
            variant: SHOAppButtonVariant.outline,
            onPressed: () =>
                context.push(SHOAppRoutes.afterSaleApply(widget.orderId)),
          ),
        ],
      ],
    );
  }
}

class _SHOInfoRow extends StatelessWidget {
  const _SHOInfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: SHOAppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 13,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
