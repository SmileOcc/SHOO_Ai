import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/hos_constants.dart';
import '../../../core/pagination/hos_paged_list_state.dart';
import '../data/hos_order_repository.dart';
import '../domain/hos_order.dart';

final ordersPagedProvider = AutoDisposeAsyncNotifierProvider<OrdersPagedNotifier,
    SHOPagedListState<SHOOrderSummary>>(OrdersPagedNotifier.new);

class OrdersPagedNotifier
    extends AutoDisposeAsyncNotifier<SHOPagedListState<SHOOrderSummary>> {
  @override
  Future<SHOPagedListState<SHOOrderSummary>> build() => _fetchPage(1);

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = AsyncData(await _fetchPage(1, refreshing: true));
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || !current.hasMore || current.isLoadingMore) return;

    state = AsyncData(current.copyWith(isLoadingMore: true));
    try {
      final repo = ref.read(orderRepositoryProvider);
      final nextPage = current.page + 1;
      final page = await repo.getOrdersPage(
        page: nextPage,
        pageSize: SHOAppConstants.listPageSize,
      );
      state = AsyncData(
        current.copyWith(
          items: [...current.items, ...page.items],
          page: nextPage,
          hasMore: page.hasMore,
          isLoadingMore: false,
        ),
      );
    } catch (error, stack) {
      state = AsyncError(error, stack);
    }
  }

  Future<SHOPagedListState<SHOOrderSummary>> _fetchPage(
    int page, {
    bool refreshing = false,
  }) async {
    final repo = ref.read(orderRepositoryProvider);
    final result = await repo.getOrdersPage(
      page: page,
      pageSize: SHOAppConstants.listPageSize,
    );
    return SHOPagedListState(
      items: result.items,
      page: page,
      hasMore: result.hasMore,
      isRefreshing: refreshing,
    );
  }
}
