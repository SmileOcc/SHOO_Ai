import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/hos_page_result.dart';
import '../../../core/network/hos_dio_client.dart';
import '../../home/domain/hos_product.dart';
import '../domain/hos_category.dart';

final categoryApiProvider = Provider<SHOCategoryApi>((ref) {
  return SHOCategoryApi(ref.watch(dioProvider));
});

class SHOCategoryApi {
  SHOCategoryApi(this._dio);

  final Dio _dio;

  Future<List<SHOCategoryItem>> fetchCategories() {
    return _dio.getData<List<SHOCategoryItem>>(
      '/categories',
      parser: (data) => normalizeCategoryItems(
            (data as List<dynamic>)
                .map(
                  (e) => parseCategoryItemFromJson(
                    Map<String, dynamic>.from(e as Map),
                  ),
                )
                .toList(),
          ),
    );
  }

  Future<SHOPageResult<SHOProduct>> fetchProductsByCategory({
    required String categoryId,
    int page = 1,
    int pageSize = 20,
  }) {
    return _dio.getData<SHOPageResult<SHOProduct>>(
      '/products',
      queryParameters: {
        'categoryId': categoryId,
        'page': page,
        'pageSize': pageSize,
      },
      parser: (data) => SHOPageResult.fromJson(
        data as Map<String, dynamic>,
        (json) => SHOProduct.fromJson(json as Map<String, dynamic>),
      ),
    );
  }
}
