import 'package:dio/dio.dart';

import 'package:shoo/core/network/security/hos_crypto_service.dart';
import 'package:shoo/core/network/security/hos_encryption_policy.dart';

/// RSA 载荷加密（登录 / 注册 / 下单等敏感接口）。
class SHORsaEncryptInterceptor extends Interceptor {
  SHORsaEncryptInterceptor(this._crypto);

  final SHOCryptoService _crypto;

  static const skipEncryptExtraKey = 'skip_payload_encrypt';

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.extra[skipEncryptExtraKey] == true) {
      handler.next(options);
      return;
    }
    if (!SHOEncryptionPolicy.shouldEncryptBody(options)) {
      handler.next(options);
      return;
    }
    if (!SHOEncryptionPolicy.isRsaPath(options)) {
      handler.next(options);
      return;
    }

    try {
      final envelope = await _crypto.encryptRsa(options.data!);
      options.data = envelope;
      options.headers['X-Encrypted'] = 'rsa';
      handler.next(options);
    } catch (error, stack) {
      handler.reject(
        DioException(
          requestOptions: options,
          error: error,
          stackTrace: stack,
          message: 'RSA encrypt failed: $error',
        ),
      );
    }
  }
}
