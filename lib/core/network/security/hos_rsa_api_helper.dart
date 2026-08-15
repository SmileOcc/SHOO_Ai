import 'package:shoo/core/config/hos_config.dart';
import 'package:shoo/core/network/security/hos_crypto_service.dart';

/// 敏感接口 RSA 加密辅助（登录 / 注册 / 下单）。
abstract final class SHORsaApiHelper {
  static Future<({Object body, Map<String, dynamic> headers})> prepareRsaPost({
    required SHOAppConfig config,
    required SHOCryptoService crypto,
    required Object plainBody,
  }) async {
    // Mock 与本地 Platform API（Nest）均不解密 RSA，发送明文。
    if (config.useMockApi || config.environment.usesLocalServer) {
      return (body: plainBody, headers: <String, dynamic>{});
    }
    final envelope = await crypto.encryptRsa(plainBody);
    return (body: envelope, headers: <String, dynamic>{'X-Encrypted': 'rsa'});
  }
}
