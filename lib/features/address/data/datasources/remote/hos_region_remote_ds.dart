import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shoo/core/network/hos_dio_client.dart';
import 'package:shoo/features/address/domain/entities/hos_region_node.dart';

final regionApiProvider = Provider<SHORegionApi>((ref) {
  return SHORegionApi(ref.watch(dioProvider));
});

class SHORegionApi {
  SHORegionApi(this._dio);

  final Dio _dio;

  Future<List<SHORegionCountryConfig>> fetchMetaCountries() async {
    final meta = await _dio.getData<Map<String, dynamic>>(
      '/regions/meta',
      parser: (data) => data as Map<String, dynamic>,
    );
    final countries = meta['countries'] as List<dynamic>? ?? [];
    return countries
        .whereType<Map<String, dynamic>>()
        .map(SHORegionCountryConfig.fromJson)
        .toList();
  }

  Future<List<SHORegionNode>> fetchCountries() {
    return _dio.getData<List<SHORegionNode>>(
      '/regions/countries',
      parser: (data) {
        final map = data as Map<String, dynamic>;
        return (map['items'] as List<dynamic>? ?? [])
            .whereType<Map<String, dynamic>>()
            .map(SHORegionNode.fromJson)
            .toList();
      },
    );
  }

  Future<SHORegionChildrenResult> fetchChildren({
    required String countryCode,
    String? parentCode,
  }) {
    return _dio.getData<SHORegionChildrenResult>(
      '/regions/children',
      queryParameters: {
        'country': countryCode,
        if (parentCode != null && parentCode.isNotEmpty)
          'parentCode': parentCode,
      },
      parser: (data) =>
          SHORegionChildrenResult.fromJson(data as Map<String, dynamic>),
    );
  }
}
