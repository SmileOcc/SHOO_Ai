import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';

import '../config/hos_config.dart';
import '../logging/hos_logger.dart';
import 'hos_mock_dynamic.dart';
import 'hos_mock_order_store.dart';
import 'hos_mock_route_registry.dart';

/// 拦截 Dio 请求并返回本地 JSON Mock 数据。
class SHOMockInterceptor extends Interceptor {
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final config = SHOAppConfig.instance;
    final apiPrefix = _extractApiPrefix(options.uri.path);
    final path = options.uri.path.replaceFirst(apiPrefix, '');

    final entry = SHOMockRouteRegistry.match(options.method, path);
    if (entry == null) {
      SHOAppLogger.warn('Mock route not found: ${options.method} $path');
      handler.reject(
        DioException(
          requestOptions: options,
          response: Response(
            requestOptions: options,
            statusCode: 404,
            data: {'code': 404, 'message': 'Mock route not found: $path'},
          ),
          type: DioExceptionType.badResponse,
        ),
      );
      return;
    }

    await Future<void>.delayed(config.mockNetworkDelay);

    try {
      if (entry.method == 'GET' && entry.path == '/orders/{id}') {
        final orderId = mockPathParam(entry.path, path, 'id');
        final cached = orderId == null ? null : SHOMockOrderStore.get(orderId);
        if (cached != null) {
          SHOAppLogger.debug('Mock hit', '${options.method} $path → order store');
          handler.resolve(
            Response(
              requestOptions: options,
              statusCode: 200,
              data: {'code': 0, 'message': 'ok', 'data': cached},
            ),
          );
          return;
        }
      }

      final raw = await rootBundle.loadString(entry.asset);
      final envelope = jsonDecode(raw) as Map<String, dynamic>;

      Map<String, dynamic>? catalogEnvelope;
      Map<String, dynamic>? reviewsCatalogEnvelope;
      if (entry.path == '/products/{id}') {
        catalogEnvelope = envelope;
      } else if (entry.path == '/products/{id}/reviews') {
        reviewsCatalogEnvelope = envelope;
      }

      final data = applyMockDynamic(
        envelope,
        routePath: entry.path,
        requestPath: path,
        query: options.queryParameters,
        catalogEnvelope: catalogEnvelope,
        reviewsCatalogEnvelope: reviewsCatalogEnvelope,
      );

      final statusCode = (data['code'] as int?) == 404 ? 404 : 200;

      if (entry.method == 'POST' && entry.path == '/orders') {
        final orderData = data['data'];
        if (orderData is Map<String, dynamic>) {
          SHOMockOrderStore.putPending(orderData);
        }
      }

      if (entry.method == 'POST' && entry.path == '/orders/{id}/pay') {
        final orderId = mockPathParam(entry.path, path, 'id');
        if (orderId != null) SHOMockOrderStore.markPaid(orderId);
      }

      SHOAppLogger.debug('Mock hit', '${options.method} $path → ${entry.asset}');
      if (statusCode == 404) {
        handler.reject(
          DioException(
            requestOptions: options,
            response: Response(
              requestOptions: options,
              statusCode: statusCode,
              data: data,
            ),
            type: DioExceptionType.badResponse,
          ),
        );
        return;
      }

      handler.resolve(
        Response(requestOptions: options, statusCode: statusCode, data: data),
      );
    } catch (error, stack) {
      SHOAppLogger.error('Mock asset load failed', error, stack);
      handler.reject(
        DioException(
          requestOptions: options,
          error: error,
          type: DioExceptionType.unknown,
        ),
      );
    }
  }

  String _extractApiPrefix(String fullPath) {
    final index = fullPath.indexOf('/api/');
    if (index == -1) return '';
    final rest = fullPath.substring(index);
    final parts = rest.split('/');
    if (parts.length >= 3) {
      return '/${parts[1]}/${parts[2]}';
    }
    return rest;
  }
}
