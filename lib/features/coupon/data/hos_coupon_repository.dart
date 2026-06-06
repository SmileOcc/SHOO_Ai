import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/hos_coupon.dart';
import 'hos_coupon_api.dart';

final couponRepositoryProvider = Provider<SHOCouponRepository>((ref) {
  return SHOCouponRepository(ref.watch(couponApiProvider));
});

class SHOCouponRepository {
  SHOCouponRepository(this._api);

  final SHOCouponApi _api;

  Future<List<SHOCoupon>> getCoupons() => _api.fetchCoupons();
}
