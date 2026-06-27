import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:shoo/app/router/hos_routes.dart';
import 'package:shoo/core/pagination/hos_paged_list_state.dart';
import 'package:shoo/core/theme/hos_colors.dart';
import 'package:shoo/core/theme/hos_spacing.dart';
import 'package:shoo/core/theme/hos_theme_extension.dart';
import 'package:shoo/core/utils/hos_price_formatter.dart';
import 'package:shoo/core/pages/hos_pages.dart';
import 'package:shoo/core/widgets/hos_network_image.dart';
import 'package:shoo/l10n/app_localizations.dart';
import 'package:shoo/features/order/domain/entities/hos_order.dart';
import 'package:shoo/features/order/presentation/widgets/hos_order_list_tabs.dart';
import 'package:shoo/features/order/presentation/widgets/hos_order_status_label.dart';
import 'package:shoo/features/order/presentation/state/hos_orders_paged_controller.dart';

class SHOOrderListPage extends ConsumerStatefulWidget {
  const SHOOrderListPage({super.key, this.statusFilter});

  final String? statusFilter;

  @override
  ConsumerState<SHOOrderListPage> createState() => _SHOOrderListPageState();
}

class _SHOOrderListPageState extends ConsumerState<SHOOrderListPage>
    with SingleTickerProviderStateMixin, SHOPageRouteAnalyticsMixin, SHOAppPageMixin, SHOAppTrackedPageMixin {
  late final TabController _tabController;

  static const _tabs = SHOOrderListTab.values;

  @override
  String get pageName => 'order_list';

  @override
  Map<String, Object?> get pageAnalyticsExtra => {
        if (widget.statusFilter != null) 'status_filter': widget.statusFilter,
      };

  @override
  void initState() {
    super.initState();
    final initial = SHOOrderListTab.fromStatusQuery(widget.statusFilter);
    _tabController = TabController(
      length: _tabs.length,
      vsync: this,
      initialIndex: _tabs.indexOf(initial),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return buildTrackedPage(
      Scaffold(
      appBar: AppBar(
        title: Text(l10n.ordersTitle),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          dividerHeight: 0,
          labelColor: Theme.of(context).colorScheme.onSurface,
          unselectedLabelColor: context.shoTheme.textSecondary,
          labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          unselectedLabelStyle:
              const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
          indicator: const UnderlineTabIndicator(
            borderSide: BorderSide(color: SHOAppColors.accent, width: 3),
          ),
          tabs: _tabs.map((tab) => Tab(text: tab.label(l10n))).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _tabs
            .map(
              (tab) => SHOTabKeepAlivePage(
                child: SHOOrderListTabPage(tab: tab),
              ),
            )
            .toList(),
      ),
    ),
    );
  }
}

class SHOOrderListTabPage extends SHOPagedDataPage<SHOOrderSummary> {
  const SHOOrderListTabPage({super.key, required this.tab});

  final SHOOrderListTab tab;

  @override
  SHOPagedDataPageState<SHOOrderSummary, SHOPagedListState<SHOOrderSummary>,
      SHOOrderListTabPage> createState() => _SHOOrderListTabPageState();
}

class _SHOOrderListTabPageState extends SHOPagedDataPageState<SHOOrderSummary,
    SHOPagedListState<SHOOrderSummary>, SHOOrderListTabPage> {
  final _scrollController = ScrollController();

  @override
  bool get embedInParentShell => true;

  @override
  bool get reportContentReadyLoadTime => false;

  @override
  String get pageName => 'order_list_tab';

  @override
  Map<String, Object?> get pageAnalyticsExtra => {
        'tab': widget.tab.name,
      };

  @override
  ProviderListenable<AsyncValue<SHOPagedListState<SHOOrderSummary>>>
      get pagedProvider => ordersPagedProvider;

  @override
  ScrollController? get scrollController => _scrollController;

  @override
  bool get enableLoadMore => widget.tab == SHOOrderListTab.all;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void refreshPaged(WidgetRef ref) =>
      ref.read(ordersPagedProvider.notifier).refresh();

  @override
  void loadMorePaged(WidgetRef ref) =>
      ref.read(ordersPagedProvider.notifier).loadMore();

  @override
  SHOPagedListState<SHOOrderSummary> transformPaged(
    SHOPagedListState<SHOOrderSummary> paged,
  ) {
    return paged.copyWith(
      items: filterOrdersByTab(paged.items, widget.tab),
    );
  }

  @override
  String? emptyMessage(BuildContext context) =>
      AppLocalizations.of(context).ordersEmpty;

  @override
  IconData? get emptyIcon => Icons.receipt_long_outlined;

  @override
  IndexedWidgetBuilder? get separatorBuilder =>
      (_, __) => const SizedBox(height: SHOAppSpacing.md);

  @override
  Widget buildPagedItem(
    BuildContext context,
    WidgetRef ref,
    SHOOrderSummary item,
    int index,
  ) {
    return _SHOOrderCard(order: item);
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
