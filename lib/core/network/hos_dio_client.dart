import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shoo/core/config/hos_config.dart';
import 'package:shoo/core/debug/modules/network_log/hos_debug_network_log_config_provider.dart';
import 'package:shoo/core/errors/hos_exception.dart';
import 'package:shoo/core/errors/hos_error_mapper.dart';
import 'package:shoo/core/logging/hos_remote_log_base_url.dart';
import 'package:shoo/core/logging/hos_remote_log_client.dart';
import 'package:shoo/features/auth/presentation/state/hos_auth_token_provider.dart';
import 'package:shoo/core/network/hos_mock_interceptor.dart';
import 'package:shoo/core/network/interceptors/hos_network_log_interceptor.dart';
import 'package:shoo/core/network/security/hos_crypto_service.dart';
import 'package:shoo/core/network/security/interceptors/hos_rsa_encrypt_interceptor.dart';
import 'package:shoo/core/network/security/hos_secure_dio_factory.dart';
import 'package:shoo/core/storage/secure/hos_secure_storage.dart';

final cryptoServiceProvider = Provider<SHOCryptoService>((ref) {
  return SHOCryptoService(ref.watch(secureStorageProvider));
});

final dioProvider = Provider<Dio>((ref) {
  final config = ref.watch(appConfigProvider);
  SHORemoteLogBaseUrl.setEffectiveConfig(config);
  SHORemoteLogClient.reset();

  final crypto = ref.watch(cryptoServiceProvider);

  final prepend = <Interceptor>[if (config.useMockApi) SHOMockInterceptor()];

  final append = <Interceptor>[
    if (config.isDebugPanelEnabled)
      SHONetworkLogInterceptor(() => ref.read(debugNetworkLogConfigProvider))
    else if (kDebugMode && config.enableNetworkLogging)
      LogInterceptor(requestBody: true, responseBody: true),
  ];

  final dio = SHOSecureDioFactory.create(
    baseUrl: config.apiBaseUrl,
    securityLevel: config.securityLevel,
    crypto: crypto,
    tokenReader: () => ref.read(authTokenProvider),
    skipEncryption:
        config.useMockApi || config.environment.usesLocalServer,
    prependInterceptors: prepend,
    appendInterceptors: append,
  );

  if (config.useMockApi) {
    debugPrint('Dio using SHOMockInterceptor + SHOSecureDioFactory');
  }

  return dio;
});

extension SHODioClientX on Dio {
  Future<T> getData<T>(
    String path, {
    required T Function(dynamic json) parser,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) async {
    try {
      final response = await get<dynamic>(
        path,
        queryParameters: queryParameters,
        options: headers == null ? null : Options(headers: headers),
      );
      return _parseEnvelope(response.data, parser);
    } on DioException catch (error) {
      throw mapDioError(error);
    }
  }

  Future<T> postData<T>(
    String path, {
    Object? data,
    required T Function(dynamic json) parser,
    Map<String, dynamic>? headers,
    bool skipPayloadEncrypt = false,
  }) async {
    try {
      final response = await post<dynamic>(
        path,
        data: data,
        options: Options(
          headers: headers,
          extra: skipPayloadEncrypt
              ? {SHORsaEncryptInterceptor.skipEncryptExtraKey: true}
              : null,
        ),
      );
      return _parseEnvelope(response.data, parser);
    } on DioException catch (error) {
      throw mapDioError(error);
    }
  }

  T _parseEnvelope<T>(dynamic body, T Function(dynamic json) parser) {
    if (body is! Map<String, dynamic>) {
      throw const SHOServerException('Invalid response format');
    }
    final code = body['code'] as int? ?? -1;
    if (code != 0) {
      throw SHOServerException(
        body['message'] as String? ?? 'Request failed',
        code: code,
      );
    }
    return parser(body['data']);
  }
}
