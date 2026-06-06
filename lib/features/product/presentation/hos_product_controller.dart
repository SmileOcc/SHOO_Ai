import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/hos_product_repository.dart';
import '../domain/hos_product_detail.dart';

final productDetailProvider =
    FutureProvider.family<SHOProductDetail, String>((ref, id) async {
  final repo = ref.watch(productRepositoryProvider);
  return repo.getDetail(id);
});
