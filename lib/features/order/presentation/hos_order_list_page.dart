import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/hos_routes.dart';
import '../../../core/theme/hos_colors.dart';
import '../../../core/theme/hos_spacing.dart';
import '../../../core/theme/hos_theme_extension.dart';
import '../../../core/utils/hos_price_formatter.dart';
import '../../../core/widgets/hos_loading_state.dart';
import '../../../core/widgets/hos_network_image.dart';
import '../../../core/widgets/hos_paged_scroll_view.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/hos_order.dart';
import 'hos_order_status_label.dart';
import 'hos_orders_paged_controller.dart';

class SHOOrderListPage extends ConsumerStatefulWidget {
  const SHOOrderListPage({super.key, this.statusFilter});

  final String? statusFilter;

  @override
  ConsumerState<SHOOrderListPage> createState() => _SHOOrderListPageState();
}

class _SHOOrderListPageState extends ConsumerState<SHOOrderListPage> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final ordersAsync = ref.watch(ordersPagedProvider);
    final filter = _parseStatusFilter(widget.statusFilter);
    final title = _titleForFilter(l10n, filter);

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ordersAsync.when(
        loading: () => const SHOAppLoadingState(
          state: SHOLoadingState.loading,
          loadingWidget: SHOAppListSkeleton(itemCount: 5, itemHeight: 120),
        ),
        error: (error, _) => SHOAppLoadingState(
          state: SHOLoadingState.error,
          message: error.toString(),
          onRetry: () => ref.invalidate(ordersPagedProvider),
        ),
        data: (paged) {
          final filtered = _filterOrders(paged.items, filter);
          if (filtered.isEmpty) {
            return SHOAppLoadingState(
              state: SHOLoadingState.empty,
              message: l10n.ordersEmpty,
              emptyIcon: Icons.receipt_long_outlined,
            );
          }

          return SHOPagedScrollView(
            controller: _scrollController,
            itemCount: filtered.length,
            onRefresh: () => ref.read(ordersPagedProvider.notifier).refresh(),
            onLoadMore: filter == null
                ? () => ref.read(ordersPagedProvider.notifier).loadMore()
                : null,
            isLoadingMore: paged.isLoadingMore,
            hasMore: filter == null && paged.hasMore,
            separatorBuilder: (_, __) => const SizedBox(height: SHOAppSpacing.md),
            itemBuilder: (context, index) =>
                _SHOOrderCard(order: filtered[index]),
          );
        },
      ),
    );
  }
}

SHOOrderStatus? _parseStatusFilter(String? raw) {
  if (raw == null || raw.isEmpty) return null;
  return switch (raw) {
    'pending_payment' => SHOOrderStatus.pendingPayment,
    'shipped' => SHOOrderStatus.shipped,
    'delivered' => SHOOrderStatus.delivered,
    _ => null,
  };
}

List<SHOOrderSummary> _filterOrders(
  List<SHOOrderSummary> orders,
  SHOOrderStatus? status,
) {
  if (status == null) return orders;
  return orders.where((o) => o.status == status).toList();
}

String _titleForFilter(AppLocalizations l10n, SHOOrderStatus? status) {
  return switch (status) {
    SHOOrderStatus.pendingPayment => l10n.ordersPendingPayment,
    SHOOrderStatus.shipped => l10n.ordersShipped,
    SHOOrderStatus.delivered => l10n.ordersReviews,
    _ => l10n.ordersTitle,
  };
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
          color: context.shoSurface,
          borderRadius: BorderRadius.circular(SHOAppSpacing.cardRadius),
          border: Border.all(color: context.shoTheme.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(order.orderNo, style: Theme.of(context).textTheme.bodySmall),
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
                    borderRadius: BorderRadius.circular(SHOAppSpacing.cardRadius),
                    child: SizedBox(
                      width: 64,
                      height: 64,
                      child: SHOAppNetworkImage(
                        url: firstItem.imageUrl,
                        fit: BoxFit.cover,
                        memCacheWidth: 128,
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
            Text(order.createdAt, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
