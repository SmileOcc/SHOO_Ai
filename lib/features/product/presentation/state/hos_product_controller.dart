import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shoo/features/product/data/repositories/hos_product_repository_impl.dart';
import 'package:shoo/features/product/domain/entities/hos_product_detail.dart';

final productDetailProvider =
    FutureProvider.family<SHOProductDetail, String>((ref, id) async {
  final repo = ref.watch(productRepositoryProvider);
  return repo.getDetail(id);
});
