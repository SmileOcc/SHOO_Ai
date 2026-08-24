import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shoo/features/coupon/data/datasources/remote/hos_coupon_remote_ds.dart';
import 'package:shoo/features/coupon/domain/entities/hos_coupon.dart';
import 'package:shoo/features/coupon/domain/repositories/hos_coupon_repository.dart';

final couponRepositoryProvider = Provider<SHOCouponRepository>((ref) {
  return SHOCouponRepositoryImpl(ref.watch(couponApiProvider));
});

class SHOCouponRepositoryImpl implements SHOCouponRepository {
  SHOCouponRepositoryImpl(this._api);

  final SHOCouponApi _api;

  @override
  Future<List<SHOCoupon>> getCoupons() => _api.fetchCoupons();

  @override
  Future<void> claimCoupon(String couponId) => _api.claimCoupon(couponId);
}
