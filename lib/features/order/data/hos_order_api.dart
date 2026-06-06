import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/hos_page_result.dart';
import '../../../core/network/hos_dio_client.dart';
import '../domain/hos_order.dart';

final orderApiProvider = Provider<SHOOrderApi>((ref) {
  return SHOOrderApi(ref.watch(dioProvider));
});

class SHOOrderApi {
  SHOOrderApi(this._dio);

  final Dio _dio;

  Future<SHOPageResult<SHOOrderSummary>> fetchOrders({
    int page = 1,
    int pageSize = 10,
  }) {
    return _dio.getData<SHOPageResult<SHOOrderSummary>>(
      '/orders',
      queryParameters: {'page': page, 'pageSize': pageSize},
      parser: (data) => SHOPageResult.fromJson(
        data as Map<String, dynamic>,
        (json) => SHOOrderSummary.fromJson(json as Map<String, dynamic>),
      ),
    );
  }

  Future<SHOOrderDetail> fetchOrderDetail(String id) {
    return _dio.getData<SHOOrderDetail>(
      '/orders/$id',
      parser: (data) => SHOOrderDetail.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<SHOLogisticsTrack> fetchLogistics(String orderId) {
    return _dio.getData<SHOLogisticsTrack>(
      '/orders/$orderId/logistics',
      parser: (data) =>
          SHOLogisticsTrack.fromJson(data as Map<String, dynamic>),
    );
  }
}
