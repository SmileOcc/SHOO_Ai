import 'package:dio/dio.dart';

import 'package:shoo/core/network/security/hos_crypto_service.dart';
import 'package:shoo/core/network/security/hos_encryption_policy.dart';
import 'package:shoo/core/network/security/interceptors/hos_rsa_encrypt_interceptor.dart';

/// 国密 SM4 加密（Extreme 等级 Demo）。
class SHOSmEncryptInterceptor extends Interceptor {
  SHOSmEncryptInterceptor(this._crypto);

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
      final envelope = await _crypto.encryptSm4(options.data! as Object);
      options.data = envelope;
      options.headers['X-Encrypted'] = 'sm4';
      handler.next(options);
    } catch (error, stack) {
      handler.reject(
        DioException(
          requestOptions: options,
          error: error,
          stackTrace: stack,
          message: 'SM encrypt failed: $error',
        ),
      );
    }
  }

  @override
  Future<void> onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) async {
    final data = response.data;
    if (data is Map<String, dynamic> && data['algorithm'] == 'sm4') {
      try {
        response.data = await _crypto.decryptSm4(data);
      } catch (_) {}
    }
    handler.next(response);
  }
}
