import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/hos_dio_client.dart';
import '../../order/domain/hos_order.dart';
import '../domain/hos_payment_result.dart';

final checkoutApiProvider = Provider<SHOCheckoutApi>((ref) {
  return SHOCheckoutApi(ref.watch(dioProvider));
});

class SHOCheckoutApi {
  SHOCheckoutApi(this._dio);

  final Dio _dio;

  Future<SHOOrderDetail> createOrder({
    required String addressId,
    required List<Map<String, dynamic>> items,
    String? couponId,
  }) {
    return _dio.postData<SHOOrderDetail>(
      '/orders',
      data: {
        'addressId': addressId,
        'items': items,
        if (couponId != null) 'couponId': couponId,
      },
      parser: (data) => SHOOrderDetail.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<SHOPaymentResult> payOrder(String orderId) {
    return _dio.postData<SHOPaymentResult>(
      '/orders/$orderId/pay',
      parser: (data) => SHOPaymentResult.fromJson(data as Map<String, dynamic>),
    );
  }
}
