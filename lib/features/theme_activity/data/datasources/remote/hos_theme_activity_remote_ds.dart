import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shoo/core/network/hos_dio_client.dart';
import 'package:shoo/features/theme_activity/domain/entities/hos_theme_activity_config.dart';
import 'package:shoo/features/theme_activity/domain/entities/hos_theme_activity_product.dart';

final themeActivityApiProvider = Provider<SHOThemeActivityApi>((ref) {
  return SHOThemeActivityApi(ref.watch(dioProvider));
});

class SHOThemeActivityApi {
  SHOThemeActivityApi(this._dio);

  final Dio _dio;

  Future<SHOThemeActivityConfig> fetchConfig(
    String activityId, {
    String? channel,
  }) {
    return _dio.getData<SHOThemeActivityConfig>(
      '/theme-activities/$activityId',
      queryParameters: {
        if (channel != null && channel.isNotEmpty) 'channel': channel,
      },
      parser: (data) =>
          SHOThemeActivityConfig.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<SHOThemeActivityProductPage> fetchProducts({
    required String activityId,
    required int page,
    required int pageSize,
    String? moduleId,
  }) {
    return _dio.getData<SHOThemeActivityProductPage>(
      '/theme-activities/$activityId/products',
      queryParameters: {
        'page': page,
        'pageSize': pageSize,
        if (moduleId != null && moduleId.isNotEmpty) 'moduleId': moduleId,
      },
      parser: (data) =>
          SHOThemeActivityProductPage.fromJson(data as Map<String, dynamic>),
    );
  }
}
