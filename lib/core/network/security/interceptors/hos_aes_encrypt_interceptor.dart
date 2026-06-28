import 'package:dio/dio.dart';

import 'package:shoo/core/network/security/hos_crypto_service.dart';
import 'package:shoo/core/network/security/hos_encryption_policy.dart';
import 'package:shoo/core/network/security/interceptors/hos_rsa_encrypt_interceptor.dart';

/// AES 载荷加密（Standard 等级；RSA 路径单独处理）。
class SHOAesEncryptInterceptor extends Interceptor {
  SHOAesEncryptInterceptor(this._crypto);

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
      final envelope = await _crypto.encryptAes(options.data! as Object);
      options.data = envelope;
      options.headers['X-Encrypted'] = 'aes';
      handler.next(options);
    } catch (error, stack) {
      handler.reject(
        DioException(
          requestOptions: options,
          error: error,
          stackTrace: stack,
          message: 'AES encrypt failed: $error',
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
    if (data is Map<String, dynamic> && data['algorithm'] == 'aes') {
      try {
        response.data = await _crypto.decryptAes(data);
      } catch (_) {
        // 服务端未加密响应时保持原样
      }
    }
    handler.next(response);
  }
}
