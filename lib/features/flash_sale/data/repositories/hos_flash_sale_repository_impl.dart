import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shoo/features/flash_sale/data/datasources/remote/hos_flash_sale_remote_ds.dart';
import 'package:shoo/features/flash_sale/domain/entities/hos_flash_sale_calendar.dart';
import 'package:shoo/features/flash_sale/domain/entities/hos_flash_sale_enums.dart';
import 'package:shoo/features/flash_sale/domain/entities/hos_flash_sale_follow.dart';
import 'package:shoo/features/flash_sale/domain/entities/hos_flash_sale_page.dart';
import 'package:shoo/features/flash_sale/domain/entities/hos_flash_sale_product.dart';

final flashSaleRepositoryProvider = Provider<SHOFlashSaleRepository>((ref) {
  return SHOFlashSaleRepository(ref.watch(flashSaleApiProvider));
});

class SHOFlashSaleRepository {
  SHOFlashSaleRepository(this._api);

  final SHOFlashSaleApi _api;

  Future<SHOFlashSaleCalendar> getCalendar({String activityId = ''}) =>
      _api.fetchCalendar(activityId: activityId);

  Future<SHOFlashSalePageData> getPage({
    required String activityId,
    required String date,
    required String sessionId,
    required SHOFlashSaleSort sort,
    required int page,
    int pageSize = 4,
  }) => _api.fetchPage(
    activityId: activityId,
    date: date,
    sessionId: sessionId,
    sort: sort,
    page: page,
    pageSize: pageSize,
  );

  Future<SHOFlashSaleProductActivity> getProductActivity({
    required String productId,
    required String sessionId,
  }) => _api.fetchProductActivity(productId: productId, sessionId: sessionId);

  Future<List<SHOFlashSaleFollow>> getFollows() => _api.fetchFollows();

  Future<void> follow({required SHOFlashSaleFollow follow}) =>
      _api.follow(follow: follow);

  Future<void> unfollow({
    required String sessionId,
    required String productId,
  }) => _api.unfollow(sessionId: sessionId, productId: productId);
}
