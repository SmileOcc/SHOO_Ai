import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/hos_constants.dart';
import '../../../core/pagination/hos_paged_list_state.dart';
import '../../home/domain/hos_product.dart';
import '../data/hos_search_repository.dart';

final searchPagedProvider = AutoDisposeAsyncNotifierProviderFamily<
    SearchPagedNotifier, SHOPagedListState<SHOProduct>, String>(
  SearchPagedNotifier.new,
);

class SearchPagedNotifier
    extends AutoDisposeFamilyAsyncNotifier<SHOPagedListState<SHOProduct>, String> {
  @override
  Future<SHOPagedListState<SHOProduct>> build(String arg) {
    if (arg.trim().isEmpty) {
      return Future.value(const SHOPagedListState());
    }
    return _fetchPage(arg, 1);
  }

  Future<void> refresh(String query) async {
    state = const AsyncLoading();
    state = AsyncData(await _fetchPage(query, 1, refreshing: true));
  }

  Future<void> loadMore(String query) async {
    final current = state.valueOrNull;
    if (current == null || !current.hasMore || current.isLoadingMore) return;

    state = AsyncData(current.copyWith(isLoadingMore: true));
    try {
      final repo = ref.read(searchRepositoryProvider);
      final nextPage = current.page + 1;
      final page = await repo.searchPage(
        query,
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

  Future<SHOPagedListState<SHOProduct>> _fetchPage(
    String query,
    int page, {
    bool refreshing = false,
  }) async {
    final repo = ref.read(searchRepositoryProvider);
    final result = await repo.searchPage(
      query,
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
