import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/hos_page_result.dart';
import '../../../core/network/hos_dio_client.dart';
import '../domain/hos_banner.dart';
import '../domain/hos_product.dart';

final homeApiProvider = Provider<SHOHomeApi>((ref) {
  return SHOHomeApi(ref.watch(dioProvider));
});

class SHOHomeApi {
  SHOHomeApi(this._dio);

  final Dio _dio;

  Future<List<SHOBannerItem>> fetchBanners() {
    return _dio.getData<List<SHOBannerItem>>(
      '/banners',
      parser: (data) => (data as List<dynamic>)
          .map((e) => SHOBannerItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Future<SHOPageResult<SHOProduct>> fetchProducts({int page = 1}) {
    return _dio.getData<SHOPageResult<SHOProduct>>(
      '/products',
      parser: (data) => SHOPageResult.fromJson(
        data as Map<String, dynamic>,
        (json) => SHOProduct.fromJson(json as Map<String, dynamic>),
      ),
    );
  }
}
