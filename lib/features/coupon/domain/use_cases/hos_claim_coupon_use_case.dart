import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shoo/features/coupon/domain/repositories/hos_coupon_repository.dart';
import 'package:shoo/features/coupon/data/repositories/hos_coupon_repository_impl.dart';

final claimCouponUseCaseProvider = Provider<SHOClaimCouponUseCase>((ref) {
  return SHOClaimCouponUseCase(ref.watch(couponRepositoryProvider));
});

class SHOClaimCouponUseCase {
  SHOClaimCouponUseCase(this._repository);

  final SHOCouponRepository _repository;

  Future<void> call(String couponId) => _repository.claimCoupon(couponId);
}
