import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../home/domain/hos_product.dart';
import '../data/hos_category_repository.dart';
import '../domain/hos_category.dart';
import 'hos_category_sort.dart';

final categoriesProvider = FutureProvider<List<SHOCategoryItem>>((ref) async {
  final items = await ref.watch(categoryRepositoryProvider).getCategories();
  return normalizeCategoryItems(items);
});

final selectedCategoryIndexProvider = StateProvider<int>((ref) => 0);

final categorySortProvider =
    StateProvider<SHOCategorySort>((ref) => SHOCategorySort.all);

enum SHOCategoryPriceSort {
  defaultSort,
  highToLow,
  lowToHigh,
}

class SHOCategoryProductFilter {
  const SHOCategoryProductFilter({
    this.minPrice,
    this.maxPrice,
    this.priceSort = SHOCategoryPriceSort.defaultSort,
  });

  final int? minPrice;
  final int? maxPrice;
  final SHOCategoryPriceSort priceSort;

  bool get hasActiveFilter =>
      minPrice != null ||
      maxPrice != null ||
      priceSort != SHOCategoryPriceSort.defaultSort;

  SHOCategoryProductFilter copyWith({
    int? Function()? minPrice,
    int? Function()? maxPrice,
    SHOCategoryPriceSort? priceSort,
  }) {
    return SHOCategoryProductFilter(
      minPrice: minPrice != null ? minPrice() : this.minPrice,
      maxPrice: maxPrice != null ? maxPrice() : this.maxPrice,
      priceSort: priceSort ?? this.priceSort,
    );
  }
}

final categoryProductFilterProvider = StateProvider<SHOCategoryProductFilter>(
  (ref) => const SHOCategoryProductFilter(),
);

final categoryProductFilterPanelOpenProvider = StateProvider<bool>((ref) => false);

final categoryAppBarTitleProvider = Provider<String>((ref) {
  final categoriesAsync = ref.watch(categoriesProvider);
  final index = ref.watch(selectedCategoryIndexProvider);

  return categoriesAsync.maybeWhen(
    data: (items) {
      if (items.isEmpty) return '';
      final safeIndex = index.clamp(0, items.length - 1);
      return items[safeIndex].name;
    },
    orElse: () => '',
  );
});

final categoryProductsProvider =
    FutureProvider.family<List<SHOProduct>, String>((ref, categoryId) async {
  final repo = ref.watch(categoryRepositoryProvider);
  final first = await repo.getProductsByCategory(
    categoryId: categoryId,
    page: 1,
    pageSize: 100,
  );

  if (!first.hasMore) return first.items;

  final all = [...first.items];
  var page = 2;
  var hasMore = first.hasMore;
  while (hasMore) {
    final next = await repo.getProductsByCategory(
      categoryId: categoryId,
      page: page,
      pageSize: 100,
    );
    all.addAll(next.items);
    hasMore = next.hasMore;
    page++;
  }
  return all;
});
