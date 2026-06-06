import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/hos_product_detail.dart';
import 'hos_product_api.dart';

final productRepositoryProvider = Provider<SHOProductRepository>((ref) {
  return SHOProductRepository(ref.watch(productApiProvider));
});

class SHOProductRepository {
  SHOProductRepository(this._api);

  final SHOProductApi _api;

  Future<SHOProductDetail> getDetail(String id) => _api.fetchProductDetail(id);
}
