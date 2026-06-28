import 'package:dio/dio.dart';

import 'package:shoo/core/network/security/hos_crypto_service.dart';
import 'package:shoo/core/network/security/hos_encryption_policy.dart';
import 'package:shoo/core/network/security/interceptors/hos_rsa_encrypt_interceptor.dart';

/// RSA + AES 混合加密（High 等级）。
class SHOHybridEncryptInterceptor extends Interceptor {
  SHOHybridEncryptInterceptor(this._crypto);

  final SHOCryptoService _crypto;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.extra[SHORsaEncryptInterceptor.skipEncryptExtraKey] == true) {
      handler.next(options);
      return;
    }
    if (!SHOEncryptionPolicy.shouldEncryptBody(options)) {
      handler.next(options);
      return;
    }
    if (SHOEncryptionPolicy.isRsaPath(options)) {
      handler.next(options);
      return;
    }

    try {
      final envelope = await _crypto.encryptHybrid(options.data! as Object);
      options.data = envelope;
      options.headers['X-Encrypted'] = 'hybrid';
      handler.next(options);
    } catch (error, stack) {
      handler.reject(
        DioException(
          requestOptions: options,
          error: error,
          stackTrace: stack,
          message: 'Hybrid encrypt failed: $error',
        ),
      );
    }
  }
}
