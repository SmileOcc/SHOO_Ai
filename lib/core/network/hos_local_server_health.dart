import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/hos_config.dart';

/// 检测本地 Mock Server（`/health`）是否可达。
abstract final class SHOLocalServerHealth {
  static Uri healthUri(String apiBaseUrl) {
    final uri = Uri.parse(apiBaseUrl);
    return Uri(
      scheme: uri.scheme,
      host: uri.host,
      port: uri.hasPort ? uri.port : null,
      path: '/health',
    );
  }

  static Future<bool> ping(String apiBaseUrl) async {
    try {
      final client = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 2),
          receiveTimeout: const Duration(seconds: 2),
        ),
      );
      final response = await client.get<dynamic>(healthUri(apiBaseUrl).toString());
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}

/// local 环境下轮询本地 server 健康状态（用于顶部提示条）。
final localServerReachableProvider = StreamProvider<bool>((ref) async* {
  final config = ref.watch(effectiveConfigProvider);
  if (!config.environment.usesLocalServer) {
    yield true;
    return;
  }

  while (true) {
    yield await SHOLocalServerHealth.ping(config.apiBaseUrl);
    await Future<void>.delayed(const Duration(seconds: 12));
  }
});
