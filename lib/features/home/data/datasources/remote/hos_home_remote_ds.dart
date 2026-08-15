import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shoo/core/models/hos_page_result.dart';
import 'package:shoo/core/network/hos_dio_client.dart';
import 'package:shoo/features/home/domain/entities/hos_banner.dart';
import 'package:shoo/features/home/domain/entities/hos_home_config.dart';
import 'package:shoo/features/home/domain/entities/hos_product.dart';

final homeApiProvider = Provider<SHOHomeApi>((ref) {
  return SHOHomeApi(ref.watch(dioProvider));
});

class SHOHomeApi {
  SHOHomeApi(this._dio);

  final Dio _dio;

  Future<List<SHOBannerItem>> fetchBanners() {
    return _dio.getData<List<SHOBannerItem>>(
      '/banners',
      parser: (data) => (data as List<dynamic>)
          .map((e) => SHOBannerItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Future<SHOPageResult<SHOProduct>> fetchProducts({
    int page = 1,
    int pageSize = 50,
    String? categoryId,
  }) {
    return _dio.getData<SHOPageResult<SHOProduct>>(
      '/products',
      queryParameters: {
        'page': page,
        'pageSize': pageSize,
        if (categoryId != null && categoryId.isNotEmpty)
          'categoryId': categoryId,
      },
      parser: (data) => SHOPageResult.fromJson(
        data as Map<String, dynamic>,
        (json) => SHOProduct.fromJson(json as Map<String, dynamic>),
      ),
    );
  }

  Future<List<SHOProduct>> fetchProductsBatch(List<String> ids) {
    final cleaned = ids.where((id) => id.isNotEmpty).toList();
    if (cleaned.isEmpty) {
      return Future.value(const []);
    }
    return _dio.getData<List<SHOProduct>>(
      '/products/batch',
      queryParameters: {'ids': cleaned.join(',')},
      parser: (data) {
        final map = data as Map<String, dynamic>;
        final items = map['items'] as List<dynamic>? ?? const [];
        return items
            .map((e) => SHOProduct.fromJson(e as Map<String, dynamic>))
            .toList();
      },
    );
  }

  Future<List<SHOHomeQuickEntry>> fetchQuickEntries() {
    return _dio.getData<List<SHOHomeQuickEntry>>(
      '/marketing/home-quick-entries',
      parser: (data) {
        final rawItems = _extractItems(data);
        return [
          for (final item in rawItems) SHOHomeQuickEntry.fromJson(item),
        ];
      },
    );
  }

  Future<SHOHomeFeedConfig> fetchFeedConfig() {
    return _dio.getData<SHOHomeFeedConfig>(
      '/marketing/home-feed-config',
      parser: (data) {
        if (data is Map<String, dynamic>) {
          return SHOHomeFeedConfig.fromJson(data);
        }
        if (data is Map) {
          return SHOHomeFeedConfig.fromJson(Map<String, dynamic>.from(data));
        }
        return SHOHomeFeedConfig.fallback;
      },
    );
  }
}

List<Map<String, dynamic>> _extractItems(dynamic data) {
  dynamic items = data;
  if (data is Map) {
    items = data['items'];
  }
  if (items is! List) return const [];
  return [
    for (final item in items)
      if (item is Map<String, dynamic>)
        item
      else if (item is Map)
        Map<String, dynamic>.from(item),
  ];
}
