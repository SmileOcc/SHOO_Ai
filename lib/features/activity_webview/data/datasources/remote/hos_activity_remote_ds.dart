import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shoo/core/network/hos_dio_client.dart';
import 'package:shoo/features/activity_webview/domain/entities/hos_activity_config.dart';
import 'package:shoo/features/activity_webview/domain/entities/hos_activity_detail.dart';

final activityApiProvider = Provider<SHOActivityApi>(
  (ref) => SHOActivityApi(ref.watch(dioProvider)),
);

class SHOActivityApi {
  const SHOActivityApi(this._dio);

  final Dio _dio;

  Future<SHOActivityConfig> fetchActivityConfig() {
    return _dio.getData(
      '/activity/data',
      parser: (json) => SHOActivityConfig.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<SHOActivityUserStatus> checkUserStatus() {
    return _dio.getData(
      '/activity/user/check',
      parser: (json) =>
          SHOActivityUserStatus.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<SHOActivityDetail> fetchActivityDetail() {
    return _dio.getData(
      '/activity/detail',
      parser: (json) => SHOActivityDetail.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<SHOActivityLevel3Detail> fetchActivityLevel3Detail() {
    return _dio.getData(
      '/activity/detail/level3',
      parser: (json) =>
          SHOActivityLevel3Detail.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<List<int>> downloadImageBytes(String url) async {
    final response = await _dio.get<List<int>>(
      url,
      options: Options(responseType: ResponseType.bytes),
    );
    return response.data ?? const [];
  }
}
