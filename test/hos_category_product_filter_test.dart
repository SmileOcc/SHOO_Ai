import 'package:flutter_test/flutter_test.dart';
import 'package:shoo/features/category/presentation/hos_category_controller.dart';
import 'package:shoo/features/category/presentation/hos_category_product_filter.dart';
import 'package:shoo/features/category/presentation/hos_category_sort.dart';
import 'package:shoo/features/home/domain/hos_product.dart';

SHOProduct _product(String id, int price) => SHOProduct(
      id: id,
      title: id,
      imageUrl: '',
      price: price,
      originalPrice: price,
      rating: 4.5,
    );

void main() {
  test('filters products by price range', () {
    final products = [
      _product('a', 100),
      _product('b', 200),
      _product('c', 300),
    ];

    final result = applyCategoryProductFilters(
      products,
      sort: SHOCategorySort.all,
      filter: const SHOCategoryProductFilter(minPrice: 150, maxPrice: 250),
    );

    expect(result.map((p) => p.id).toList(), ['b']);
  });

  test('sorts products by price high to low', () {
    final products = [
      _product('a', 100),
      _product('b', 300),
      _product('c', 200),
    ];

    final result = applyCategoryProductFilters(
      products,
      sort: SHOCategorySort.all,
      filter: const SHOCategoryProductFilter(
        priceSort: SHOCategoryPriceSort.highToLow,
      ),
    );

    expect(result.map((p) => p.id).toList(), ['b', 'c', 'a']);
  });

  test('price range validation requires max greater than min', () {
    expect(
      isCategoryProductPriceRangeValid(minPrice: 100, maxPrice: 200),
      isTrue,
    );
    expect(
      isCategoryProductPriceRangeValid(minPrice: 200, maxPrice: 100),
      isFalse,
    );
    expect(
      isCategoryProductPriceRangeValid(minPrice: 100, maxPrice: 100),
      isFalse,
    );
  });
}
