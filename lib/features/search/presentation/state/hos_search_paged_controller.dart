import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shoo/core/constants/hos_constants.dart';
import 'package:shoo/core/pagination/hos_paged_family_async_notifier.dart';
import 'package:shoo/core/pagination/hos_paged_list_state.dart';
import 'package:shoo/features/home/domain/entities/hos_product.dart';
import 'package:shoo/features/search/data/repositories/hos_search_repository_impl.dart';

final searchPagedProvider =
    AutoDisposeAsyncNotifierProviderFamily<
      SearchPagedNotifier,
      SHOPagedListState<SHOProduct>,
      String
    >(SearchPagedNotifier.new);

class SearchPagedNotifier
    extends AutoDisposeFamilyAsyncNotifier<SHOPagedListState<SHOProduct>, String>
    with SHOPagedFamilyAsyncNotifier<SHOProduct, String> {
  @override
  bool shouldFetch(String arg) => arg.trim().isNotEmpty;

  @override
  Future<SHOPagedListState<SHOProduct>> fetchPage(
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
