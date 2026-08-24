import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shoo/core/constants/hos_constants.dart';
import 'package:shoo/core/pagination/hos_paged_family_async_notifier.dart';
import 'package:shoo/core/pagination/hos_paged_list_state.dart';
import 'package:shoo/features/order/data/repositories/hos_order_repository_impl.dart';
import 'package:shoo/features/order/domain/entities/hos_order.dart';
import 'package:shoo/features/order/presentation/widgets/hos_order_list_tabs.dart';

final ordersPagedProvider =
    AutoDisposeAsyncNotifierProviderFamily<
      OrdersPagedNotifier,
      SHOPagedListState<SHOOrderSummary>,
      SHOOrderListTab
    >(OrdersPagedNotifier.new);

class OrdersPagedNotifier
    extends
        AutoDisposeFamilyAsyncNotifier<
          SHOPagedListState<SHOOrderSummary>,
          SHOOrderListTab
        >
    with SHOPagedFamilyAsyncNotifier<SHOOrderSummary, SHOOrderListTab> {
  @override
  Future<SHOPagedListState<SHOOrderSummary>> fetchPage(
    SHOOrderListTab tab,
    int page, {
    bool refreshing = false,
  }) async {
    final repo = ref.read(orderRepositoryProvider);
    final result = await repo.getOrdersPage(
      page: page,
      pageSize: SHOAppConstants.listPageSize,
      status: tab.statusFilter,
    );
    return SHOPagedListState(
      items: result.items,
      page: page,
      hasMore: result.hasMore,
      isRefreshing: refreshing,
    );
  }
}
