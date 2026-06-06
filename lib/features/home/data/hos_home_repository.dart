import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/hos_banner.dart';
import '../domain/hos_product.dart';
import 'hos_home_api.dart';

final homeRepositoryProvider = Provider<SHOHomeRepository>((ref) {
  return SHOHomeRepository(ref.watch(homeApiProvider));
});

class SHOHomeRepository {
  SHOHomeRepository(this._api);

  final SHOHomeApi _api;

  Future<List<SHOBannerItem>> getBanners() => _api.fetchBanners();

  Future<List<SHOProduct>> getRecommendedProducts() async {
    final page = await _api.fetchProducts();
    return page.items;
  }
}
