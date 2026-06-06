import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/hos_dio_client.dart';
import '../domain/hos_after_sale.dart';

final afterSaleApiProvider = Provider<SHOAfterSaleApi>((ref) {
  return SHOAfterSaleApi(ref.watch(dioProvider));
});

class SHOAfterSaleApi {
  SHOAfterSaleApi(this._dio);

  final Dio _dio;

  Future<List<SHOAfterSaleRequest>> fetchRequests() {
    return _dio.getData<List<SHOAfterSaleRequest>>(
      '/after-sales',
      parser: (data) => (data as List<dynamic>)
          .map((e) => SHOAfterSaleRequest.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Future<SHOAfterSaleRequest> createRequest(SHOAfterSaleCreateRequest request) {
    return _dio.postData<SHOAfterSaleRequest>(
      '/after-sales',
      data: request.toJson(),
      parser: (data) =>
          SHOAfterSaleRequest.fromJson(data as Map<String, dynamic>),
    );
  }
}
