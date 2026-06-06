import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/hos_dio_client.dart';
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
      parser: (data) => (data as List<dynamic>)
          .map((e) => SHOCategoryItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
