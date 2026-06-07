import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../home/domain/hos_product.dart';
import '../../../core/models/hos_page_result.dart';
import '../domain/hos_category.dart';
import 'hos_category_api.dart';

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
