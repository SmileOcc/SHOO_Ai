import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/hos_routes.dart';
import '../../../core/theme/hos_colors.dart';
import '../../../core/theme/hos_spacing.dart';
import '../../../core/utils/hos_price_formatter.dart';
import '../../../core/widgets/hos_loading_state.dart';
import '../../../core/widgets/hos_network_image.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/hos_order.dart';
import 'hos_order_controller.dart';
import 'hos_order_status_label.dart';

class SHOOrderListPage extends ConsumerWidget {
  const SHOOrderListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final ordersAsync = ref.watch(ordersProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.ordersTitle)),
      body: ordersAsync.whenLoadingState(
        onRetry: () => ref.invalidate(ordersProvider),
        empty: (orders) => orders.isEmpty,
        data: (orders) => ListView.separated(
          padding: const EdgeInsets.all(SHOAppSpacing.pagePadding),
          itemCount: orders.length,
          separatorBuilder: (_, __) => const SizedBox(height: SHOAppSpacing.md),
          itemBuilder: (context, index) =>
              _SHOOrderCard(order: orders[index]),
        ),
      ),
    );
  }
}

class _SHOOrderCard extends StatelessWidget {
  const _SHOOrderCard({required this.order});

  final SHOOrderSummary order;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final firstItem = order.items.isNotEmpty ? order.items.first : null;

    return InkWell(
      onTap: () => context.push(SHOAppRoutes.order(order.id)),
      borderRadius: BorderRadius.circular(SHOAppSpacing.cardRadius),
      child: Container(
        padding: const EdgeInsets.all(SHOAppSpacing.lg),
        decoration: BoxDecoration(
          color: SHOAppColors.surface,
          borderRadius: BorderRadius.circular(SHOAppSpacing.cardRadius),
          border: Border.all(color: SHOAppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  order.orderNo,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  shoOrderStatusLabel(context, order.status),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: SHOAppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
            const SizedBox(height: SHOAppSpacing.md),
            if (firstItem != null)
              Row(
                children: [
                  ClipRRect(
                    borderRadius:
                        BorderRadius.circular(SHOAppSpacing.cardRadius),
                    child: SizedBox(
                      width: 64,
                      height: 64,
                      child: SHOAppNetworkImage(
                        url: firstItem.imageUrl,
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
                          firstItem.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontSize: 13,
                              ),
                        ),
                        if (order.items.length > 1)
                          Text(
                            l10n.orderMoreItems(order.items.length - 1),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                      ],
                    ),
                  ),
                  Text(
                    priceFormatter.formatCents(order.totalCents),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ],
              ),
            const SizedBox(height: SHOAppSpacing.sm),
            Text(
              order.createdAt,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
