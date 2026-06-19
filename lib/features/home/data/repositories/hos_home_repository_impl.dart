import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shoo/features/home/domain/entities/hos_banner.dart';
import 'package:shoo/features/home/domain/entities/hos_product.dart';
import 'package:shoo/features/home/data/datasources/remote/hos_home_remote_ds.dart';

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
