import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:shoo/core/config/hos_config.dart';
import 'package:shoo/core/logging/hos_logger.dart';
import 'package:shoo/core/network/hos_flash_sale_mock_dynamic.dart';
import 'package:shoo/core/network/hos_mock_dynamic.dart';
import 'package:shoo/core/network/hos_mock_flash_sale_follow_store.dart';
import 'package:shoo/core/network/hos_mock_order_store.dart';
import 'package:shoo/core/network/hos_mock_route_registry.dart';

/// 拦截 Dio 请求并返回本地 JSON Mock 数据。
class SHOMockInterceptor extends Interceptor {
  static Map<String, dynamic>? _requestBodyMap(dynamic body) {
    if (body is Map<String, dynamic>) return body;
    if (body is Map) return Map<String, dynamic>.from(body);
    return null;
  }

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
      SHOAppLogger.w('Mock route not found: ${options.method} $path');
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
          SHOAppLogger.d('Mock hit', '${options.method} $path → order store');
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
      Map<String, dynamic>? flashSaleCatalogEnvelope;
      if (entry.path == '/products/{id}') {
        catalogEnvelope = envelope;
        final fsRaw = await rootBundle.loadString(
          'assets/mock/flash_sale_catalog.json',
        );
        flashSaleCatalogEnvelope = jsonDecode(fsRaw) as Map<String, dynamic>;
      } else if (entry.path == '/products/{id}/reviews') {
        reviewsCatalogEnvelope = envelope;
        final fsRaw = await rootBundle.loadString(
          'assets/mock/flash_sale_catalog.json',
        );
        flashSaleCatalogEnvelope = jsonDecode(fsRaw) as Map<String, dynamic>;
      }

      final data = applyMockDynamic(
        envelope,
        routePath: entry.path,
        requestPath: path,
        query: options.queryParameters,
        catalogEnvelope: catalogEnvelope,
        reviewsCatalogEnvelope: reviewsCatalogEnvelope,
        flashSaleCatalogEnvelope: flashSaleCatalogEnvelope,
      );

      final statusCode = (data['code'] as int?) == 404 ? 404 : 200;

      if (entry.method == 'POST' && entry.path == '/flash-sale/follow') {
        final body = _requestBodyMap(options.data);
        if (body != null) {
          SHOMockFlashSaleFollowStore.upsert(body);
        }
        handler.resolve(
          Response(
            requestOptions: options,
            statusCode: 200,
            data: {
              'code': 0,
              'message': 'ok',
              'data': {'success': true},
            },
          ),
        );
        return;
      }

      if (entry.method == 'POST' && entry.path == '/flash-sale/unfollow') {
        final body = _requestBodyMap(options.data);
        if (body != null) {
          SHOMockFlashSaleFollowStore.remove(
            sessionId: body['sessionId']?.toString() ?? '',
            productId: body['productId']?.toString() ?? '',
          );
        }
        handler.resolve(
          Response(
            requestOptions: options,
            statusCode: 200,
            data: {
              'code': 0,
              'message': 'ok',
              'data': {'success': true},
            },
          ),
        );
        return;
      }

      if (entry.method == 'POST' && entry.path == '/orders') {
        final body = _requestBodyMap(options.data);
        if (body != null) {
          final fsRaw = await rootBundle.loadString(
            'assets/mock/flash_sale_catalog.json',
          );
          final fsCatalog = jsonDecode(fsRaw) as Map<String, dynamic>;
          final items = body['items'];
          if (items is List) {
            final validation = validateFlashSaleCheckoutItems(fsCatalog, items);
            if (validation != null) {
              handler.reject(
                DioException(
                  requestOptions: options,
                  response: Response(
                    requestOptions: options,
                    statusCode: 400,
                    data: validation,
                  ),
                  type: DioExceptionType.badResponse,
                ),
              );
              return;
            }
          }
        }
      }

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

      SHOAppLogger.d('Mock hit', '${options.method} $path → ${entry.asset}');
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
      SHOAppLogger.e('Mock asset load failed', error, stack);
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
