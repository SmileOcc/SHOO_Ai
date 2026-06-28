import 'package:flutter/foundation.dart';

/// SSL 证书校验（生产环境证书 Pinning Demo）。
abstract final class SHOCertificateValidator {
  static bool verify(dynamic cert, String host) {
    if (kDebugMode) return true;
    // 生产环境应校验证书指纹 / SPKI Pin
    // Demo：仅允许 shoo 相关域名
    const allowedHosts = {'api.shoo.com', 'm.shoo.com', 'api.staging.shoo.com'};
    return allowedHosts.contains(host);
  }
}
