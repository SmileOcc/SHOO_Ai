import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/hos_dio_client.dart';
import '../domain/hos_coupon.dart';

final couponApiProvider = Provider<SHOCouponApi>((ref) {
  return SHOCouponApi(ref.watch(dioProvider));
});

class SHOCouponApi {
  SHOCouponApi(this._dio);

  final Dio _dio;

  Future<List<SHOCoupon>> fetchCoupons() {
    return _dio.getData<List<SHOCoupon>>(
      '/coupons',
      parser: (data) => (data as List<dynamic>)
          .map((e) => SHOCoupon.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
