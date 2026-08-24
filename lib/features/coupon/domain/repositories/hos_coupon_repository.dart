import 'package:shoo/features/coupon/domain/entities/hos_coupon.dart';

/// 优惠券仓储接口（Domain 层）。
abstract interface class SHOCouponRepository {
  Future<List<SHOCoupon>> getCoupons();

  Future<void> claimCoupon(String couponId);
}
