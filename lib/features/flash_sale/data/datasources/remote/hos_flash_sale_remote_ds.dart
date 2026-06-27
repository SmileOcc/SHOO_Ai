import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shoo/core/network/hos_dio_client.dart';
import 'package:shoo/features/flash_sale/domain/entities/hos_flash_sale_models.dart';

final flashSaleApiProvider = Provider<SHOFlashSaleApi>((ref) {
  return SHOFlashSaleApi(ref.watch(dioProvider));
});

class SHOFlashSaleApi {
  SHOFlashSaleApi(this._dio);

  final Dio _dio;

  Future<SHOFlashSaleCalendar> fetchCalendar({String activityId = ''}) {
    return _dio.getData<SHOFlashSaleCalendar>(
      '/flash-sale/calendar',
      queryParameters: {
        if (activityId.isNotEmpty) 'activityId': activityId,
      },
      parser: (data) =>
          SHOFlashSaleCalendar.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<SHOFlashSalePageData> fetchPage({
    required String activityId,
    required String date,
    required String sessionId,
    required SHOFlashSaleSort sort,
    required int page,
    int pageSize = 4,
  }) {
    return _dio.getData<SHOFlashSalePageData>(
      '/flash-sale/page',
      queryParameters: {
        if (activityId.isNotEmpty) 'activityId': activityId,
        'date': date,
        if (sessionId.isNotEmpty) 'sessionId': sessionId,
        'sort': _sortParam(sort),
        'page': page,
        'pageSize': pageSize,
      },
      parser: (data) =>
          SHOFlashSalePageData.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<SHOFlashSaleProductActivity> fetchProductActivity({
    required String productId,
    required String sessionId,
  }) {
    return _dio.getData<SHOFlashSaleProductActivity>(
      '/flash-sale/product-activity',
      queryParameters: {
        'productId': productId,
        'sessionId': sessionId,
      },
      parser: (data) =>
          SHOFlashSaleProductActivity.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<List<SHOFlashSaleFollow>> fetchFollows() {
    return _dio.getData<List<SHOFlashSaleFollow>>(
      '/flash-sale/follows',
      parser: (data) => (data as List<dynamic>)
          .map((e) => SHOFlashSaleFollow.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Future<void> follow({required SHOFlashSaleFollow follow}) {
    return _dio.post<void>(
      '/flash-sale/follow',
      data: follow.toJson(),
    );
  }

  Future<void> unfollow({
    required String sessionId,
    required String productId,
  }) {
    return _dio.post<void>(
      '/flash-sale/unfollow',
      data: {'sessionId': sessionId, 'productId': productId},
    );
  }

  Future<void> claimCoupon(String couponId) {
    return _dio.post<void>('/flash-sale/coupons/$couponId/claim');
  }

  String _sortParam(SHOFlashSaleSort sort) {
    switch (sort) {
      case SHOFlashSaleSort.hot:
        return 'hot';
      case SHOFlashSaleSort.priceAsc:
        return 'price_asc';
      case SHOFlashSaleSort.priceDesc:
        return 'price_desc';
      case SHOFlashSaleSort.newest:
        return 'newest';
    }
  }
}
