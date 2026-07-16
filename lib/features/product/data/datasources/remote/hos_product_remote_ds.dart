import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shoo/core/network/hos_dio_client.dart';
import 'package:shoo/features/product/domain/entities/hos_product_batch.dart';
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
      parser: (data) => SHOProductDetail.fromJson(data as Map<String, dynamic>),
    );
  }

  /// 按 productId / skuId 批量查询当前价与库存（购物车对账）。
  Future<SHOProductBatchResult> fetchProductBatch({
    required List<String> productIds,
    List<String> skuIds = const [],
  }) {
    final ids = productIds.where((id) => id.isNotEmpty).toSet().toList();
    final skus = skuIds.where((id) => id.isNotEmpty).toSet().toList();
    return _dio.getData<SHOProductBatchResult>(
      '/products/batch',
      queryParameters: {
        'ids': ids.join(','),
        if (skus.isNotEmpty) 'skuIds': skus.join(','),
      },
      parser: (data) =>
          SHOProductBatchResult.fromJson(data as Map<String, dynamic>),
    );
  }
}
