import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shoo/core/pagination/hos_paged_container.dart';

/// 扩展分页状态需实现 merge / copyWithLoadingMore。
abstract class SHOPagedMergeableContainer<T> implements SHOPagedContainer<T> {
  int get page;

  SHOPagedMergeableContainer<T> copyWithLoadingMore(bool isLoadingMore);

  SHOPagedMergeableContainer<T> mergeNextPage(
    SHOPagedMergeableContainer<T> nextPage,
  );
}

/// 带自定义分页状态（如 reviews summary）的 Family AsyncNotifier 骨架。
mixin SHOPagedMergeableFamilyAsyncNotifier<
  T,
  S extends SHOPagedMergeableContainer<T>,
  Arg
>
    on AutoDisposeFamilyAsyncNotifier<S, Arg> {
  Future<S> fetchPage(Arg arg, int page, {bool refreshing = false});

  bool shouldFetch(Arg arg) => true;

  S emptyState(Arg arg);

  @override
  Future<S> build(Arg arg) {
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
    if (current == null || !current.pagedHasMore || current.pagedIsLoadingMore) {
      return;
    }

    state = AsyncData(current.copyWithLoadingMore(true) as S);
    try {
      final nextPage = current.page + 1;
      final page = await fetchPage(arg, nextPage);
      state = AsyncData(current.mergeNextPage(page) as S);
    } catch (error, stack) {
      state = AsyncError(error, stack);
    }
  }
}
