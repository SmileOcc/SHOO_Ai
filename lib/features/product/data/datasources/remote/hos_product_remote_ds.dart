import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shoo/core/network/hos_dio_client.dart';
import 'package:shoo/features/product/domain/entities/hos_product_detail.dart';

final productApiProvider = Provider<SHOProductApi>((ref) {
  return SHOProductApi(ref.watch(dioProvider));
});

class SHOProductApi {
  SHOProductApi(this._dio);

  final Dio _dio;

  Future<SHOProductDetail> fetchProductDetail(String id) {
    return _dio.getData<SHOProductDetail>(
      '/products/$id',
      parser: (data) =>
          SHOProductDetail.fromJson(data as Map<String, dynamic>),
    );
  }
}
