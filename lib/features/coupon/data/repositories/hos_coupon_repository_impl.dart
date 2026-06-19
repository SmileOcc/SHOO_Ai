import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shoo/features/coupon/domain/entities/hos_coupon.dart';
import 'package:shoo/features/coupon/data/datasources/remote/hos_coupon_remote_ds.dart';

final couponRepositoryProvider = Provider<SHOCouponRepository>((ref) {
  return SHOCouponRepository(ref.watch(couponApiProvider));
});

class SHOCouponRepository {
  SHOCouponRepository(this._api);

  final SHOCouponApi _api;

  Future<List<SHOCoupon>> getCoupons() => _api.fetchCoupons();
}
