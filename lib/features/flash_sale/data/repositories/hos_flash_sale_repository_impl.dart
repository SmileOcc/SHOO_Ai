import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shoo/features/flash_sale/data/datasources/remote/hos_flash_sale_remote_ds.dart';
import 'package:shoo/features/flash_sale/domain/entities/hos_flash_sale_models.dart';

final flashSaleRepositoryProvider = Provider<SHOFlashSaleRepository>((ref) {
  return SHOFlashSaleRepository(ref.watch(flashSaleApiProvider));
});

class SHOFlashSaleRepository {
  SHOFlashSaleRepository(this._api);

  final SHOFlashSaleApi _api;

  Future<SHOFlashSaleCalendar> getCalendar() => _api.fetchCalendar();

  Future<SHOFlashSalePageData> getPage({
    required String date,
    required String sessionId,
    required SHOFlashSaleSort sort,
    required int page,
    int pageSize = 4,
  }) =>
      _api.fetchPage(
        date: date,
        sessionId: sessionId,
        sort: sort,
        page: page,
        pageSize: pageSize,
      );

  Future<SHOFlashSaleProductActivity> getProductActivity({
    required String productId,
    required String sessionId,
  }) =>
      _api.fetchProductActivity(productId: productId, sessionId: sessionId);

  Future<List<SHOFlashSaleFollow>> getFollows() => _api.fetchFollows();

  Future<void> follow({required SHOFlashSaleFollow follow}) =>
      _api.follow(follow: follow);

  Future<void> unfollow({
    required String sessionId,
    required String productId,
  }) =>
      _api.unfollow(sessionId: sessionId, productId: productId);

  Future<void> claimCoupon(String couponId) => _api.claimCoupon(couponId);
}
