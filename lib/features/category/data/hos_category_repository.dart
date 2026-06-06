import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/hos_category.dart';
import 'hos_category_api.dart';

final categoryRepositoryProvider = Provider<SHOCategoryRepository>((ref) {
  return SHOCategoryRepository(ref.watch(categoryApiProvider));
});

class SHOCategoryRepository {
  SHOCategoryRepository(this._api);

  final SHOCategoryApi _api;

  Future<List<SHOCategoryItem>> getCategories() => _api.fetchCategories();
}
