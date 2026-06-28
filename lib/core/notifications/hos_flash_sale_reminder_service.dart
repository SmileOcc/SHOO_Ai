import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import 'package:shoo/app/router/hos_router.dart';
import 'package:shoo/app/router/hos_routes.dart';
import 'package:shoo/core/logging/hos_logger.dart';
import 'package:shoo/core/notifications/hos_flash_sale_reminder_analytics.dart';
import 'package:shoo/core/notifications/hos_flash_sale_reminder_bootstrap.dart';
import 'package:shoo/core/notifications/hos_flash_sale_reminder_nav.dart';
import 'package:shoo/core/notifications/hos_push_notification_service.dart';
import 'package:shoo/features/flash_sale/domain/entities/hos_flash_sale_models.dart';

class SHOFlashSaleReminderPayload {
  const SHOFlashSaleReminderPayload({
    required this.sessionId,
    required this.productId,
    required this.title,
    required this.imageUrl,
    required this.sessionStartAt,
    this.activityId,
  });

  final String sessionId;
  final String productId;
  final String title;
  final String imageUrl;
  final String sessionStartAt;
  final String? activityId;
}

final flashSaleReminderPopupProvider =
    StateProvider<SHOFlashSaleReminderPayload?>((ref) => null);

/// App 是否处于前台（resumed）。
final appInForegroundProvider = StateProvider<bool>((ref) {
  final state = WidgetsBinding.instance.lifecycleState;
  return state == null || state == AppLifecycleState.resumed;
});

final flashSaleReminderServiceProvider = Provider<SHOFlashSaleReminderService>(
  (ref) => SHOFlashSaleReminderService(ref),
);

/// T-5min 本地通知 + 前台弹窗调度；Push 走 [SHOPushNotificationService]。
class SHOFlashSaleReminderService {
  SHOFlashSaleReminderService(this._ref);

  final Ref _ref;
  var _initialized = false;
  Timer? _foregroundTimer;
  final _firedKeys = <String>{};
  SHOFlashSaleReminderPayload? _pendingNotificationPayload;
  var _navigationAttempts = 0;

  static const _channelId = 'flash_sale_reminder';
  static const _lead = Duration(minutes: 5);
  static const _maxNavigationAttempts = 150;

  FlutterLocalNotificationsPlugin get _local =>
      SHOFlashSaleReminderBootstrap.plugin;

  Future<void> initialize() async {
    if (_initialized) return;
    if (kIsWeb) return;

    await SHOFlashSaleReminderBootstrap.ensureInitialized();
    SHOFlashSaleReminderBootstrap.tapHandler = _handleNotificationPayload;
    SHOFlashSaleReminderBootstrap.onNotificationTapped = _onNotificationTapped;

    _initialized = true;
    if (!SHOFlashSaleReminderBootstrap.isTestMode) {
      _startForegroundWatcher();
    }
    await _ref.read(pushNotificationServiceProvider).initialize();
    _drainBootstrapPendingPayloads();
  }

  void _handleNotificationPayload(String raw) {
    final payload = SHOFlashSaleReminderNav.parsePayload(raw);
    if (payload == null) {
      SHOAppLogger.w('[FlashSaleReminder] invalid payload: $raw');
      return;
    }
    openFromNotification(payload);
  }

  void _onNotificationTapped() {
    _drainBootstrapPendingPayloads();
    _tryNavigatePending();
  }

  void _drainBootstrapPendingPayloads() {
    for (final raw in SHOFlashSaleReminderBootstrap.drainPendingPayloads()) {
      _handleNotificationPayload(raw);
    }
  }

  /// 点击/冷启动通知：直接进入活动页，不弹窗。
  void openFromNotification(SHOFlashSaleReminderPayload payload) {
    SHOAppLogger.i(
      '[FlashSaleReminder] openFromNotification '
      'activity=${payload.activityId ?? '(default)'} product=${payload.productId}',
    );
    _ref.read(flashSaleReminderPopupProvider.notifier).state = null;
    _pendingNotificationPayload = payload;
    _navigationAttempts = 0;
    _tryNavigatePending();
  }

  /// 前台 T-5min 轮询：展示弹窗。
  void showForegroundPopup(
    SHOFlashSaleReminderPayload payload, {
    String trigger = 'foreground_poll',
  }) {
    SHOFlashSaleReminderAnalytics.trackPopupShow(
      payload: payload,
      trigger: trigger,
    );
    _ref.read(flashSaleReminderPopupProvider.notifier).state = payload;
  }

  void flushPendingNavigation() {
    _drainBootstrapPendingPayloads();
    _tryNavigatePending();
  }

  void processPendingNotificationTaps() {
    _drainBootstrapPendingPayloads();
    _tryNavigatePending();
  }

  void _tryNavigatePending() {
    final payload = _pendingNotificationPayload;
    if (payload == null) return;

    final lifecycle = WidgetsBinding.instance.lifecycleState;
    if (lifecycle != null && lifecycle != AppLifecycleState.resumed) {
      SHOAppLogger.d(
        '[FlashSaleReminder] defer navigation until resumed (state=$lifecycle)',
      );
      return;
    }

    if (!_ref.exists(routerProvider)) {
      _retryNavigate();
      return;
    }

    final router = _ref.read(routerProvider);
    if (router.state.matchedLocation == SHOAppRoutes.splash) {
      _retryNavigate();
      return;
    }

    _pendingNotificationPayload = null;
    _navigationAttempts = 0;
    final route = SHOFlashSaleReminderNav.routeFor(payload);
    SHOAppLogger.i('[FlashSaleReminder] navigating to $route');
    SHOFlashSaleReminderNav.openActivity(router, payload);
  }

  void _retryNavigate() {
    if (_pendingNotificationPayload == null) return;
    _navigationAttempts++;
    if (_navigationAttempts > _maxNavigationAttempts) {
      final payload = _pendingNotificationPayload;
      _pendingNotificationPayload = null;
      _navigationAttempts = 0;
      if (payload != null && _ref.exists(routerProvider)) {
        SHOFlashSaleReminderNav.openActivity(_ref.read(routerProvider), payload);
      }
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _tryNavigatePending());
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
        '${follow.sessionId}|${follow.productId}|${follow.title}|${follow.imageUrl}|${follow.sessionStartAt}|';

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
    if (!_ref.read(appInForegroundProvider)) return null;

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
    if (SHOFlashSaleReminderBootstrap.tapHandler == _handleNotificationPayload) {
      SHOFlashSaleReminderBootstrap.tapHandler = null;
    }
    if (SHOFlashSaleReminderBootstrap.onNotificationTapped == _onNotificationTapped) {
      SHOFlashSaleReminderBootstrap.onNotificationTapped = null;
    }
  }

  /// Debug：立即展示抢购提醒弹窗。
  void showDebugPopup(SHOFlashSaleReminderPayload payload) {
    showForegroundPopup(payload, trigger: 'debug');
  }

  /// Debug：延时后展示本地通知与前台弹窗。
  Future<void> scheduleDebugReminder({
    required SHOFlashSaleReminderPayload payload,
    required Duration delay,
  }) async {
    await initialize();
    final fireAt = DateTime.now().add(delay);
    final notificationPayload =
        '${payload.sessionId}|${payload.productId}|${payload.title}|${payload.imageUrl}|${payload.sessionStartAt}|${payload.activityId ?? ''}';

    await _local.zonedSchedule(
      _notificationId('debug', payload.productId),
      '即将开抢',
      payload.title,
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
      payload: notificationPayload,
    );

    Future.delayed(delay, () {
      if (!_ref.exists(flashSaleReminderPopupProvider)) return;
      if (!_ref.read(appInForegroundProvider)) return;
      showForegroundPopup(payload);
    });
  }
}
