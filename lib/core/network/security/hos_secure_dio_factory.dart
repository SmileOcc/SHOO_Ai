import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:shoo/core/constants/hos_constants.dart';
import 'package:shoo/core/network/interceptors/hos_auth_interceptor.dart';
import 'package:shoo/core/network/security/hos_certificate_validator.dart';
import 'package:shoo/core/network/security/hos_crypto_service.dart';
import 'package:shoo/core/network/security/hos_security_level.dart';
import 'package:shoo/core/network/security/interceptors/hos_aes_encrypt_interceptor.dart';
import 'package:shoo/core/network/security/interceptors/hos_anti_replay_interceptor.dart';
import 'package:shoo/core/network/security/interceptors/hos_error_interceptor.dart';
import 'package:shoo/core/network/security/interceptors/hos_hybrid_encrypt_interceptor.dart';
import 'package:shoo/core/network/security/interceptors/hos_retry_interceptor.dart';
import 'package:shoo/core/network/security/interceptors/hos_rsa_encrypt_interceptor.dart';
import 'package:shoo/core/network/security/interceptors/hos_sign_interceptor.dart';
import 'package:shoo/core/network/security/interceptors/hos_sm_encrypt_interceptor.dart';

/// 企业级安全 Dio 工厂类。
///
/// **核心职责：**
/// - 创建配置完整的安全 Dio 实例
/// - 根据安全级别动态配置加密拦截器
/// - 配置认证、签名、防重放等安全机制
/// - 配置证书验证和网络适配器
///
/// **拦截器执行顺序（请求方向）：**
/// 1. LogInterceptor（仅 Debug）
/// 2. SHOAuthInterceptor - Token 注入
/// 3. SHOSignInterceptor - 请求签名
/// 4. SHOAntiReplayInterceptor - 防重放保护
/// 5. SHORsaEncryptInterceptor - RSA 加密（关键路径）
/// 6. SHOAesEncryptInterceptor / SHOHybridEncryptInterceptor / SHOSmEncryptInterceptor
/// 7. SHOErrorInterceptor - 错误处理
/// 8. SHORetryInterceptor - 请求重试
///
/// **安全级别对应加密方案：**
/// | 级别 | 加密方案 |
/// |------|---------|
/// | basic | 仅 RSA（关键路径） |
/// | standard | RSA + AES |
/// | high | RSA + Hybrid（AES+RSA混合） |
/// | extreme | RSA + SM4（国密） |
class SHOSecureDioFactory {
  /// 创建安全配置的 Dio 实例。
  ///
  /// [baseUrl]: API 基础地址
  /// [securityLevel]: 安全级别（basic/standard/high/extreme）
  /// [crypto]: 加密服务实例，提供各种加密算法能力
  /// [tokenReader]: Token 读取器，用于动态获取访问令牌
  /// [skipEncryption]: 是否跳过加密（用于 Mock 模式或调试）
  /// [prependInterceptors]: 在默认拦截器之前添加的自定义拦截器
  /// [appendInterceptors]: 在默认拦截器之后添加的自定义拦截器
  static Dio create({
    required String baseUrl,
    required SHOSecurityLevel securityLevel,
    required SHOCryptoService crypto,
    required String? Function() tokenReader,
    bool skipEncryption = false,
    List<Interceptor>? prependInterceptors,
    List<Interceptor>? appendInterceptors,
  }) {
    // ========== 1. 创建基础 Dio 实例 ==========
    // 配置连接超时、接收超时、发送超时均为 15 秒
    // 设置默认请求头：Content-Type、Accept、客户端标识等
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-Client-Platform': 'flutter',
          'X-Client-Version': SHOAppConstants.appVersion,
        },
      ),
    );

    // ========== 2. 构建拦截器链 ==========
    final interceptors = <Interceptor>[
      // 前置自定义拦截器（用户传入，优先执行）
      if (prependInterceptors != null) ...prependInterceptors,

      // Debug 模式下添加日志拦截器，打印请求/响应详情
      if (kDebugMode)
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          logPrint: (obj) => debugPrint('[DIO] $obj'),
        ),

      // 认证拦截器：自动注入 Token 到请求头
      SHOAuthInterceptor(tokenReader),

      // 签名拦截器：对请求参数进行签名，防止篡改
      SHOSignInterceptor(crypto),

      // 防重放拦截器：生成唯一请求 ID，防止重复提交
      SHOAntiReplayInterceptor(crypto),
    ];

    // ========== 3. 根据安全级别配置加密拦截器 ==========
    if (!skipEncryption) {
      // RSA 加密拦截器：对关键路径（如登录、支付）进行 RSA 加密
      interceptors.add(SHORsaEncryptInterceptor(crypto));

      // 根据安全级别添加载荷加密拦截器
      if (securityLevel.requiresPayloadEncryption) {
        switch (securityLevel) {
          case SHOSecurityLevel.basic:
            // 基础级别：仅 RSA 加密关键路径，不加密普通请求
            break;
          case SHOSecurityLevel.standard:
            // 标准级别：添加 AES 加密拦截器
            interceptors.add(SHOAesEncryptInterceptor(crypto));
          case SHOSecurityLevel.high:
            // 高级别：添加 Hybrid 加密拦截器（AES + RSA 混合）
            interceptors.add(SHOHybridEncryptInterceptor(crypto));
          case SHOSecurityLevel.extreme:
            // 极高级别：添加 SM4 加密拦截器（国密算法）
            interceptors.add(SHOSmEncryptInterceptor(crypto));
        }
      }
    }

    // ========== 4. 添加后置拦截器 ==========
    interceptors.addAll([
      // 错误拦截器：统一处理网络错误、业务错误、超时等
      SHOErrorInterceptor(),

      // 重试拦截器：对失败请求进行自动重试（最多 3 次）
      SHORetryInterceptor(dio: dio),

      // 后置自定义拦截器（用户传入，最后执行）
      if (appendInterceptors != null) ...appendInterceptors,
    ]);

    // ========== 5. 注册所有拦截器 ==========
    dio.interceptors.addAll(interceptors);

    // ========== 6. 配置 HTTPS 证书验证（仅 Release 模式且非 Web） ==========
    // 在 Release 模式下，使用自定义证书验证逻辑
    // 防止中间人攻击（MITM）
    if (!kDebugMode && !kIsWeb) {
      dio.httpClientAdapter = IOHttpClientAdapter(
        createHttpClient: () {
          final client = HttpClient();
          // 自定义证书验证回调
          client.badCertificateCallback = (cert, host, port) {
            return SHOCertificateValidator.verify(cert, host);
          };
          return client;
        },
      );
    }

    return dio;
  }
}
