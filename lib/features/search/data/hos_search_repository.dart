import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../home/domain/hos_product.dart';
import 'hos_search_api.dart';

final searchRepositoryProvider = Provider<SHOSearchRepository>((ref) {
  return SHOSearchRepository(ref.watch(searchApiProvider));
});

class SHOSearchRepository {
  SHOSearchRepository(this._api);

  final SHOSearchApi _api;

  Future<List<String>> getHotKeywords() => _api.fetchHotKeywords();

  Future<List<SHOProduct>> search(String query) async {
    if (query.trim().isEmpty) return [];
    final page = await _api.searchProducts(query.trim());
    return page.items;
  }
}
