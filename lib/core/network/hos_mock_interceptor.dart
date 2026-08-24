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
import 'package:shoo/core/network/hos_theme_activity_mock_dynamic.dart';

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

    if (options.method == 'GET' && path.startsWith('/regions')) {
      await Future<void>.delayed(config.mockNetworkDelay);
      try {
        final data = await _loadRegionsMock(path, options.queryParameters);
        handler.resolve(
          Response(
            requestOptions: options,
            statusCode: 200,
            data: {'code': 0, 'message': 'ok', 'data': data},
          ),
        );
      } catch (error, stack) {
        SHOAppLogger.e('Mock regions failed', error, stack);
        handler.reject(
          DioException(
            requestOptions: options,
            response: Response(
              requestOptions: options,
              statusCode: 404,
              data: {'code': 404, 'message': error.toString(), 'data': null},
            ),
            type: DioExceptionType.badResponse,
          ),
        );
      }
      return;
    }

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
      if (entry.method == 'GET' && entry.path == '/theme-activities/{activityId}') {
        final activityId =
            themeActivityIdFromPath(entry.path, path) ?? 'demo_long_banner';
        final raw = await rootBundle.loadString(
          themeActivityMockAsset(activityId),
        );
        final config = jsonDecode(raw) as Map<String, dynamic>;
        handler.resolve(
          Response(
            requestOptions: options,
            statusCode: 200,
            data: {'code': 0, 'message': 'ok', 'data': config},
          ),
        );
        return;
      }

      if (entry.method == 'GET' &&
          entry.path == '/theme-activities/{activityId}/products') {
        final productsRaw = await rootBundle.loadString(
          'assets/mock/products.json',
        );
        final productsEnvelope =
            jsonDecode(productsRaw) as Map<String, dynamic>;
        final data = resolveThemeActivityProducts(
          productsEnvelope,
          query: options.queryParameters,
        );
        handler.resolve(
          Response(
            requestOptions: options,
            statusCode: 200,
            data: data,
          ),
        );
        return;
      }

      if (entry.method == 'GET' && entry.path == '/orders') {
        SHOMockOrderStore.expireStaleOrders();
        final raw = await rootBundle.loadString(entry.asset);
        final envelope = jsonDecode(raw) as Map<String, dynamic>;
        final data = Map<String, dynamic>.from(envelope['data'] as Map);
        var items = (data['items'] as List)
            .whereType<Map<String, dynamic>>()
            .map(Map<String, dynamic>.from)
            .toList();
        final storeItems = SHOMockOrderStore.listAll();
        final seen = items.map((order) => order['id']?.toString()).toSet();
        for (final order in storeItems) {
          final id = order['id']?.toString();
          if (id == null || seen.contains(id)) continue;
          items.insert(0, order);
        }
        final status = options.queryParameters['status']?.toString();
        if (status != null && status.isNotEmpty) {
          items = items.where((order) => order['status'] == status).toList();
        }
        final page =
            int.tryParse('${options.queryParameters['page'] ?? 1}') ?? 1;
        final pageSize =
            int.tryParse('${options.queryParameters['pageSize'] ?? 20}') ?? 20;
        final start = (page - 1) * pageSize;
        final slice = items.skip(start).take(pageSize).toList();
        handler.resolve(
          Response(
            requestOptions: options,
            statusCode: 200,
            data: {
              'code': 0,
              'message': 'ok',
              'data': {
                'items': slice,
                'page': page,
                'pageSize': pageSize,
                'total': items.length,
                'hasMore': start + slice.length < items.length,
              },
            },
          ),
        );
        return;
      }

      if (entry.method == 'GET' && entry.path == '/orders/{id}') {
        SHOMockOrderStore.expireStaleOrders();
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
      if (entry.path == '/products/{id}' || entry.path == '/products/batch') {
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
            final normalizedItems = items
                .whereType<Map>()
                .map((item) => Map<String, dynamic>.from(item))
                .toList();
            final created = SHOMockOrderStore.createFromCheckout(
              items: normalizedItems,
              totalCents: (body['totalCents'] as num?)?.toInt(),
            );
            if (created == null) {
              handler.reject(
                DioException(
                  requestOptions: options,
                  response: Response(
                    requestOptions: options,
                    statusCode: 400,
                    data: {
                      'code': 400,
                      'message': 'Insufficient stock',
                      'data': null,
                    },
                  ),
                  type: DioExceptionType.badResponse,
                ),
              );
              return;
            }
            handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {'code': 0, 'message': 'ok', 'data': created},
              ),
            );
            return;
          }
        }
      }

      if (entry.method == 'POST' && entry.path == '/orders/{id}/pay') {
        SHOMockOrderStore.expireStaleOrders();
        final orderId = mockPathParam(entry.path, path, 'id');
        if (orderId != null) {
          final cached = SHOMockOrderStore.get(orderId);
          if (cached != null && cached['status'] == 'pending_payment') {
            SHOMockOrderStore.markPaid(orderId);
            handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'code': 0,
                  'message': 'ok',
                  'data': {
                    'orderId': orderId,
                    'status': 'paid',
                    'paidAt': SHOMockOrderStore.listAll().firstWhere(
                      (order) => order['id'] == orderId,
                      orElse: () => {'createdAt': ''},
                    )['createdAt'],
                    'message': 'Mock payment successful',
                  },
                },
              ),
            );
            return;
          }
        }
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

  static Future<Map<String, dynamic>> _loadRegionsMock(
    String path,
    Map<String, dynamic> query,
  ) async {
    if (path == '/regions/meta') {
      final raw = await rootBundle.loadString('assets/mock/regions/meta.json');
      return jsonDecode(raw) as Map<String, dynamic>;
    }
    if (path == '/regions/countries') {
      final raw = await rootBundle.loadString(
        'assets/mock/regions/countries.json',
      );
      return jsonDecode(raw) as Map<String, dynamic>;
    }
    if (path == '/regions/children') {
      final country = '${query['country'] ?? ''}'.toUpperCase();
      final parent = '${query['parentCode'] ?? ''}'.trim();
      final effectiveParent = parent.isEmpty ? country : parent;
      final asset =
          'assets/mock/regions/children/$country/$effectiveParent.json';
      final raw = await rootBundle.loadString(asset);
      return jsonDecode(raw) as Map<String, dynamic>;
    }
    throw StateError('Mock region route not found: $path');
  }
}
