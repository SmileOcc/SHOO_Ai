import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/hos_config.dart';
import '../errors/hos_exception.dart';
import '../errors/hos_error_mapper.dart';
import '../logging/hos_logger.dart';
import '../../features/auth/presentation/hos_auth_token_provider.dart';
import 'hos_auth_interceptor.dart';
import 'hos_mock_interceptor.dart';

final dioProvider = Provider<Dio>((ref) {
  final config = ref.watch(appConfigProvider);

  final dio = Dio(
    BaseOptions(
      baseUrl: config.apiBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  if (config.useMockApi) {
    dio.interceptors.add(SHOMockInterceptor());
    SHOAppLogger.info('Dio using SHOMockInterceptor');
  }

  dio.interceptors.add(
    SHOAuthInterceptor(() => ref.read(authTokenProvider)),
  );

  if (kDebugMode && config.enableNetworkLogging) {
    dio.interceptors.add(
      LogInterceptor(requestBody: true, responseBody: true),
    );
  }

  return dio;
});

extension SHODioClientX on Dio {
  Future<T> getData<T>(
    String path, {
    required T Function(dynamic json) parser,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await get<dynamic>(path, queryParameters: queryParameters);
      return _parseEnvelope(response.data, parser);
    } on DioException catch (error) {
      throw mapDioError(error);
    }
  }

  Future<T> postData<T>(
    String path, {
    Object? data,
    required T Function(dynamic json) parser,
  }) async {
    try {
      final response = await post<dynamic>(path, data: data);
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
