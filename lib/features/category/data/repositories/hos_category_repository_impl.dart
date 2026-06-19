import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shoo/features/home/domain/entities/hos_product.dart';
import 'package:shoo/core/models/hos_page_result.dart';
import 'package:shoo/features/category/domain/entities/hos_category.dart';
import 'package:shoo/features/category/data/datasources/remote/hos_category_remote_ds.dart';

final categoryRepositoryProvider = Provider<SHOCategoryRepository>((ref) {
  return SHOCategoryRepository(ref.watch(categoryApiProvider));
});

class SHOCategoryRepository {
  SHOCategoryRepository(this._api);

  final SHOCategoryApi _api;

  Future<List<SHOCategoryItem>> getCategories() => _api.fetchCategories();

  Future<SHOPageResult<SHOProduct>> getProductsByCategory({
    required String categoryId,
    int page = 1,
    int pageSize = 20,
  }) =>
      _api.fetchProductsByCategory(
        categoryId: categoryId,
        page: page,
        pageSize: pageSize,
      );
}
