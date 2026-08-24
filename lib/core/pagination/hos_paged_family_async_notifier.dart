import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shoo/core/pagination/hos_paged_list_state.dart';

/// 通用分页 Family AsyncNotifier：封装 refresh / loadMore 骨架。
mixin SHOPagedFamilyAsyncNotifier<T, Arg>
    on AutoDisposeFamilyAsyncNotifier<SHOPagedListState<T>, Arg> {
  Future<SHOPagedListState<T>> fetchPage(
    Arg arg,
    int page, {
    bool refreshing = false,
  });

  bool shouldFetch(Arg arg) => true;

  SHOPagedListState<T> emptyState(Arg arg) => const SHOPagedListState();

  @override
  Future<SHOPagedListState<T>> build(Arg arg) {
    if (!shouldFetch(arg)) {
      return Future.value(emptyState(arg));
    }
    return fetchPage(arg, 1);
  }

  Future<void> refresh(Arg arg) async {
    state = const AsyncLoading();
    state = AsyncData(await fetchPage(arg, 1, refreshing: true));
  }

  Future<void> loadMore(Arg arg) async {
    final current = state.valueOrNull;
    if (current == null || !current.hasMore || current.isLoadingMore) return;

    state = AsyncData(current.copyWith(isLoadingMore: true));
    try {
      final nextPage = current.page + 1;
      final page = await fetchPage(arg, nextPage);
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
}
