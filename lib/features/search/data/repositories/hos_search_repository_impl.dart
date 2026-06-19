import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shoo/core/models/hos_page_result.dart';
import 'package:shoo/features/home/domain/entities/hos_product.dart';
import 'package:shoo/features/search/data/datasources/remote/hos_search_remote_ds.dart';

final searchRepositoryProvider = Provider<SHOSearchRepository>((ref) {
  return SHOSearchRepository(ref.watch(searchApiProvider));
});

class SHOSearchRepository {
  SHOSearchRepository(this._api);

  final SHOSearchApi _api;

  Future<List<String>> getHotKeywords() => _api.fetchHotKeywords();

  Future<List<SHOProduct>> search(String query) async {
    final page = await searchPage(query);
    return page.items;
  }

  Future<SHOPageResult<SHOProduct>> searchPage(
    String query, {
    int page = 1,
    int pageSize = 10,
  }) {
    if (query.trim().isEmpty) {
      return Future.value(
        const SHOPageResult(items: [], page: 1, hasMore: false),
      );
    }
    return _api.searchProducts(query.trim(), page: page, pageSize: pageSize);
  }
}
