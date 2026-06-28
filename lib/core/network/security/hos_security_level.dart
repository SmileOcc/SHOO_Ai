/// 网络安全等级。
enum SHOSecurityLevel {
  /// 仅 HTTPS，无额外载荷加密。
  basic,

  /// HTTPS + AES（敏感接口 RSA）。
  standard,

  /// HTTPS + RSA 包裹 AES 密钥（混合加密）。
  high,

  /// HTTPS + 国密 SM4（Demo 实现）。
  extreme,
}

extension SHOSecurityLevelX on SHOSecurityLevel {
  String get label => switch (this) {
    SHOSecurityLevel.basic => 'Basic (HTTPS)',
    SHOSecurityLevel.standard => 'Standard (AES)',
    SHOSecurityLevel.high => 'High (RSA+AES)',
    SHOSecurityLevel.extreme => 'Extreme (SM4)',
  };

  bool get requiresPayloadEncryption => this != SHOSecurityLevel.basic;
}
