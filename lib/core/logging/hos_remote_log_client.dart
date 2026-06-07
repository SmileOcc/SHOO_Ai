import 'package:dio/dio.dart';

import 'hos_remote_log_base_url.dart';

/// 远程日志上报专用客户端（不走 Mock 拦截器，直连本地 server 或真实 API）。
abstract final class SHORemoteLogClient {
  static Dio? _dio;
  static String? _cachedBaseUrl;

  static Dio get instance {
    final baseUrl = SHORemoteLogBaseUrl.resolve();
    if (_dio == null || _cachedBaseUrl != baseUrl) {
      _cachedBaseUrl = baseUrl;
      _dio = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          headers: {'Content-Type': 'application/json'},
        ),
      );
    }
    return _dio!;
  }

  static void reset() {
    _dio = null;
    _cachedBaseUrl = null;
  }

}
