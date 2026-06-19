import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shoo/features/product/domain/entities/hos_product_detail.dart';
import 'package:shoo/features/product/data/datasources/remote/hos_product_remote_ds.dart';

final productRepositoryProvider = Provider<SHOProductRepository>((ref) {
  return SHOProductRepository(ref.watch(productApiProvider));
});

class SHOProductRepository {
  SHOProductRepository(this._api);

  final SHOProductApi _api;

  Future<SHOProductDetail> getDetail(String id) => _api.fetchProductDetail(id);
}
