import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shoo/core/logging/hos_logger.dart';
import 'package:shoo/core/network/hos_dio_client.dart';
import 'package:shoo/features/flash_sale/domain/entities/hos_flash_sale_follow.dart';

final pushNotificationServiceProvider = Provider<SHOPushNotificationService>(
  (ref) => SHOPushNotificationService(ref.watch(dioProvider)),
);

/// Push 抽象层：Mock 注册 token + 远程提醒占位；接入 FCM/APNs 时替换实现。
class SHOPushNotificationService {
  SHOPushNotificationService(this._dio);

  final Dio _dio;
  String? _token;

  Future<void> initialize() async {
    if (kIsWeb) return;
    _token = await _resolveDeviceToken();
    if (_token == null || _token!.isEmpty) {
      SHOAppLogger.i('Push: FCM/APNs 未配置，使用本地通知降级');
      return;
    }
    try {
      await _dio.post<void>(
        '/push/register',
        data: {
          'token': _token,
          'platform': Platform.isIOS ? 'apns' : 'android',
        },
      );
      SHOAppLogger.i('Push: token registered (mock)');
    } catch (error) {
      SHOAppLogger.w('Push: token register failed', error);
    }
  }

  Future<String?> _resolveDeviceToken() async {
    // 接入 firebase_messaging 后在此返回 FCM token / APNs device token。
    return 'mock-device-token-${Platform.operatingSystem}';
  }

  Future<void> scheduleRemoteReminder({
    required SHOFlashSaleFollow follow,
    required DateTime fireAt,
  }) async {
    if (_token == null) return;
    try {
      await _dio.post<void>(
        '/push/flash-sale/reminder',
        data: {
          'token': _token,
          'sessionId': follow.sessionId,
          'productId': follow.productId,
          'fireAt': fireAt.toUtc().toIso8601String(),
        },
      );
    } catch (_) {
      // Mock 可选路由，失败不影响本地通知。
    }
  }

  Future<void> cancelRemoteReminder({
    required String sessionId,
    required String productId,
  }) async {
    if (_token == null) return;
    try {
      await _dio.post<void>(
        '/push/flash-sale/cancel',
        data: {'token': _token, 'sessionId': sessionId, 'productId': productId},
      );
    } catch (_) {}
  }
}
