import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/hos_page_result.dart';
import '../../../core/network/hos_dio_client.dart';
import '../../home/domain/hos_product.dart';

final searchApiProvider = Provider<SHOSearchApi>((ref) {
  return SHOSearchApi(ref.watch(dioProvider));
});

class SHOSearchApi {
  SHOSearchApi(this._dio);

  final Dio _dio;

  Future<List<String>> fetchHotKeywords() {
    return _dio.getData<List<String>>(
      '/search/hot',
      parser: (data) => (data['keywords'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );
  }

  Future<SHOPageResult<SHOProduct>> searchProducts(
    String query, {
    int page = 1,
    int pageSize = 10,
  }) {
    return _dio.getData<SHOPageResult<SHOProduct>>(
      '/search',
      queryParameters: {
        'q': query,
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
