import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/hos_coupon_repository.dart';
import '../domain/hos_coupon.dart';

final couponsProvider = FutureProvider<List<SHOCoupon>>((ref) async {
  final repo = ref.watch(couponRepositoryProvider);
  return repo.getCoupons();
});

/// 结算页选中的优惠券 ID。
final selectedCouponIdProvider = StateProvider<String?>((ref) => null);

final selectedCouponProvider = Provider<SHOCoupon?>((ref) {
  final couponId = ref.watch(selectedCouponIdProvider);
  if (couponId == null) return null;
  final couponsAsync = ref.watch(couponsProvider);
  return couponsAsync.whenOrNull(
    data: (list) {
      final matches = list.where((c) => c.id == couponId);
      return matches.isEmpty ? null : matches.first;
    },
  );
});
