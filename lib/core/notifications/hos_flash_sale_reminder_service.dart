import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import 'package:shoo/core/notifications/hos_push_notification_service.dart';
import 'package:shoo/features/flash_sale/domain/entities/hos_flash_sale_models.dart';

class SHOFlashSaleReminderPayload {
  const SHOFlashSaleReminderPayload({
    required this.sessionId,
    required this.productId,
    required this.title,
    required this.imageUrl,
    required this.sessionStartAt,
  });

  final String sessionId;
  final String productId;
  final String title;
  final String imageUrl;
  final String sessionStartAt;
}

final flashSaleReminderPopupProvider =
    StateProvider<SHOFlashSaleReminderPayload?>((ref) => null);

final flashSaleReminderServiceProvider = Provider<SHOFlashSaleReminderService>(
  (ref) => SHOFlashSaleReminderService(ref),
);

/// T-5min 本地通知 + 前台弹窗调度；Push 走 [SHOPushNotificationService]。
class SHOFlashSaleReminderService {
  SHOFlashSaleReminderService(this._ref);

  final Ref _ref;
  final _local = FlutterLocalNotificationsPlugin();
  var _initialized = false;
  Timer? _foregroundTimer;
  final _firedKeys = <String>{};

  static const _channelId = 'flash_sale_reminder';
  static const _lead = Duration(minutes: 5);

  Future<void> initialize() async {
    if (_initialized) return;
    if (kIsWeb) return;

    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.local);

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    await _local.initialize(
      const InitializationSettings(android: android, iOS: ios),
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    if (Platform.isAndroid) {
      await _local
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    }

    _initialized = true;
    _startForegroundWatcher();
    await _ref.read(pushNotificationServiceProvider).initialize();
  }

  void _onNotificationTap(NotificationResponse response) {
    final payload = response.payload;
    if (payload == null || payload.isEmpty) return;
    final parts = payload.split('|');
    if (parts.length < 2) return;
    _ref.read(flashSaleReminderPopupProvider.notifier).state =
        SHOFlashSaleReminderPayload(
      sessionId: parts[0],
      productId: parts[1],
      title: parts.length > 2 ? parts[2] : '',
      imageUrl: parts.length > 3 ? parts[3] : '',
      sessionStartAt: parts.length > 4 ? parts[4] : '',
    );
  }

  void _startForegroundWatcher() {
    _foregroundTimer?.cancel();
    _foregroundTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _checkForegroundReminders();
    });
  }

  Future<void> _checkForegroundReminders() async {
    // Foreground polling handled by host reading follows; lightweight noop here.
  }

  int _notificationId(String sessionId, String productId) =>
      '$sessionId:$productId'.hashCode & 0x7fffffff;

  String _key(String sessionId, String productId) => '$sessionId:$productId';

  Future<void> scheduleReminder(SHOFlashSaleFollow follow) async {
    await initialize();
    final start = DateTime.tryParse(follow.sessionStartAt)?.toLocal();
    if (start == null) return;
    final fireAt = start.subtract(_lead);
    if (fireAt.isBefore(DateTime.now())) return;

    final payload =
        '${follow.sessionId}|${follow.productId}|${follow.title}|${follow.imageUrl}|${follow.sessionStartAt}';

    await _local.zonedSchedule(
      _notificationId(follow.sessionId, follow.productId),
      '即将开抢',
      follow.title,
      tz.TZDateTime.from(fireAt, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          '抢购提醒',
          channelDescription: '开抢前 5 分钟提醒',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: payload,
    );

    await _ref.read(pushNotificationServiceProvider).scheduleRemoteReminder(
          follow: follow,
          fireAt: fireAt,
        );
  }

  Future<void> cancelReminder({
    required String sessionId,
    required String productId,
  }) async {
    await initialize();
    await _local.cancel(_notificationId(sessionId, productId));
    _firedKeys.remove(_key(sessionId, productId));
    await _ref.read(pushNotificationServiceProvider).cancelRemoteReminder(
          sessionId: sessionId,
          productId: productId,
        );
  }

  Future<void> rescheduleAll(List<SHOFlashSaleFollow> follows) async {
    await initialize();
    await _local.cancelAll();
    _firedKeys.clear();
    for (final follow in follows) {
      await scheduleReminder(follow);
    }
  }

  /// 前台轮询：若到达 T-5min 且未弹过，返回 payload。
  SHOFlashSaleReminderPayload? pollForegroundPopup(SHOFlashSaleFollow follow) {
    final start = DateTime.tryParse(follow.sessionStartAt)?.toLocal();
    if (start == null) return null;
    final now = DateTime.now();
    final windowStart = start.subtract(_lead);
    final windowEnd = start;
    if (now.isBefore(windowStart) || now.isAfter(windowEnd)) return null;

    final key = _key(follow.sessionId, follow.productId);
    if (_firedKeys.contains(key)) return null;
    _firedKeys.add(key);

    return SHOFlashSaleReminderPayload(
      sessionId: follow.sessionId,
      productId: follow.productId,
      title: follow.title,
      imageUrl: follow.imageUrl,
      sessionStartAt: follow.sessionStartAt,
    );
  }

  void dispose() {
    _foregroundTimer?.cancel();
  }
}
