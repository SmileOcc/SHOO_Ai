import 'package:dio/dio.dart';

/// 请求加密策略：登录/注册/下单走 RSA，其余走 AES（或混合/国密）。
abstract final class SHOEncryptionPolicy {
  static const rsaPaths = <String>{
    '/auth/login',
    '/auth/register',
  };

  static bool isRsaPath(RequestOptions options) {
    if (rsaPaths.contains(options.path)) return true;
    return options.method.toUpperCase() == 'POST' && options.path == '/orders';
  }

  static bool shouldEncryptBody(RequestOptions options) {
    if (options.method.toUpperCase() == 'GET') return false;
    if (options.data == null) return false;
    return true;
  }
}
