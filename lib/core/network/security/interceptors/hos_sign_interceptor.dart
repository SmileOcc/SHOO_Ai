import 'package:dio/dio.dart';

import 'package:shoo/core/network/security/hos_crypto_service.dart';

/// 请求签名（HMAC-SHA256 防篡改）。
class SHOSignInterceptor extends Interceptor {
  SHOSignInterceptor(this._crypto);

  final SHOCryptoService _crypto;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final nonce = _crypto.generateNonce();
      final signature = await _crypto.signRequest(
        method: options.method,
        path: options.path,
        timestamp: timestamp,
        nonce: nonce,
        body: options.data,
      );
      options.headers['X-Timestamp'] = timestamp;
      options.headers['X-Nonce'] = nonce;
      options.headers['X-Signature'] = signature;
      handler.next(options);
    } catch (error, stack) {
      handler.reject(
        DioException(
          requestOptions: options,
          error: error,
          stackTrace: stack,
          message: 'Sign failed: $error',
        ),
      );
    }
  }
}
