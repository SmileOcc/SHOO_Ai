import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/hos_category_repository.dart';
import '../domain/hos_category.dart';

final categoriesProvider = FutureProvider<List<SHOCategoryItem>>((ref) async {
  return ref.watch(categoryRepositoryProvider).getCategories();
});
