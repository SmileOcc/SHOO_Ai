import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import 'package:shoo/core/logging/hos_logger.dart';
import 'package:shoo/core/notifications/hos_flash_sale_reminder_analytics.dart';

/// 在 [runApp] 之前初始化本地通知，确保后台/冷启动点击能收到 payload。
abstract final class SHOFlashSaleReminderBootstrap {
  static final FlutterLocalNotificationsPlugin plugin =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;
  static String? pendingLaunchPayload;
  static final List<String> pendingTapPayloads = [];

  static void Function(String payload)? tapHandler;

  /// 通知点击后通知 Service 处理 pending payload（可为 null 直到 Service 初始化）。
  static void Function()? onNotificationTapped;

  static Future<void> ensureInitialized() async {
    if (_initialized || kIsWeb) return;

    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.local);

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    await plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );

    if (Platform.isAndroid) {
      await plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    }

    if (Platform.isIOS) {
      await plugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    }

    final details = await plugin.getNotificationAppLaunchDetails();
    if (details?.didNotificationLaunchApp == true) {
      final payload = details!.notificationResponse?.payload;
      if (payload != null && payload.isNotEmpty) {
        pendingLaunchPayload = payload;
        _trackNotificationPayload(
          payload,
          receiveSource: 'cold_start',
          clickSource: 'cold_start',
        );
      }
    }

    _initialized = true;
  }

  static void _onNotificationResponse(NotificationResponse response) {
    final payload = response.payload;
    if (payload == null || payload.isEmpty) {
      SHOAppLogger.w('[FlashSaleReminder] notification tap without payload');
      return;
    }

    SHOAppLogger.i(
      '[FlashSaleReminder] notification tapped '
      '(action=${response.actionId ?? 'default'}) payload=$payload',
    );

    _trackNotificationPayload(
      payload,
      receiveSource: 'notification_tap',
      clickSource: 'notification_tap',
    );

    pendingTapPayloads.add(payload);
    if (onNotificationTapped != null) {
      onNotificationTapped!();
    } else {
      tapHandler?.call(payload);
    }
  }

  static void _trackNotificationPayload(
    String payload, {
    required String receiveSource,
    String? clickSource,
  }) {
    SHOFlashSaleReminderAnalytics.trackReceive(
      rawPayload: payload,
      source: receiveSource,
    );
    if (clickSource != null) {
      SHOFlashSaleReminderAnalytics.trackClick(
        rawPayload: payload,
        source: clickSource,
      );
    }
  }

  static List<String> drainPendingPayloads() {
    final payloads = <String>[];
    if (pendingLaunchPayload != null) {
      payloads.add(pendingLaunchPayload!);
      pendingLaunchPayload = null;
    }
    payloads.addAll(pendingTapPayloads);
    pendingTapPayloads.clear();
    return payloads;
  }
}
