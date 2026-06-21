import 'package:dio/dio.dart';

import 'package:shoo/core/network/security/hos_crypto_service.dart';

/// 防重放：时间戳 + Nonce（签名由 [SHOSignInterceptor] 统一处理）。
class SHOAntiReplayInterceptor extends Interceptor {
  SHOAntiReplayInterceptor(this._crypto);

  final SHOCryptoService _crypto;

  static const _maxSkewMs = 5 * 60 * 1000;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers.putIfAbsent(
      'X-Request-Id',
      () => _crypto.generateNonce(),
    );
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final timestamp = response.requestOptions.headers['X-Timestamp']?.toString();
    if (timestamp != null) {
      final requestTime = int.tryParse(timestamp);
      if (requestTime != null) {
        final skew = DateTime.now().millisecondsSinceEpoch - requestTime;
        if (skew.abs() > _maxSkewMs) {
          handler.reject(
            DioException(
              requestOptions: response.requestOptions,
              response: response,
              message: 'Request timestamp skew too large (anti-replay)',
            ),
          );
          return;
        }
      }
    }
    handler.next(response);
  }
}
