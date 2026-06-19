import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import 'package:shoo/app/router/hos_router_keys.dart';
import 'package:shoo/app/router/hos_routes.dart';
import 'package:shoo/core/logging/hos_logger.dart';
import 'package:shoo/core/analytics/hos_analytics_manager.dart';
import 'package:shoo/core/widgets/hos_dialog.dart';
import 'package:shoo/core/platform/hybrid/hos_hybrid_bridge_protocol.dart';
import 'package:shoo/core/platform/hybrid/hos_hybrid_native_overlay_coordinator.dart';
import 'package:shoo/core/platform/bridge/hos_native_device_service.dart';
import 'package:shoo/core/platform/bridge/hos_native_event_bridge.dart';
import 'package:shoo/core/platform/bridge/hos_native_message_bridge.dart';

/// 处理 Native → Flutter 的宿主能力（导航、弹窗、Channel 学习示例）。
abstract final class SHONativeHostActions {
  static const _device = SHONativeDeviceService();

  static Future<dynamic> handle(MethodCall call) async {
    final args = _asMap(call.arguments);
    return switch (call.method) {
      SHOHybridBridgeMethods.navigate => _navigate(args),
      SHOHybridBridgeMethods.showDialog => _showDialog(args),
      SHOHybridBridgeMethods.runMethodChannelDemo => _runMethodChannelDemo(),
      SHOHybridBridgeMethods.runMessageChannelDemo =>
        _runMessageChannelDemo(args),
      SHOHybridBridgeMethods.runEventChannelDemo => _runEventChannelDemo(args),
      SHOHybridBridgeMethods.abandonNativeOverlaySession => _abandonNativeOverlaySession(),
      SHOHybridBridgeMethods.onHybridFlutterPopped => _onHybridFlutterPopped(),
      SHOHybridBridgeMethods.trackNativeAnalytics => _trackNativeAnalytics(args),
      _ => throw PlatformException(
          code: 'not_implemented',
          message: 'Unknown host method: ${call.method}',
        ),
    };
  }

  static Map<String, dynamic> _asMap(dynamic raw) {
    if (raw is Map) {
      return raw.map((k, v) => MapEntry(k.toString(), v));
    }
    return const {};
  }

  static BuildContext? get _context => rootNavigatorKey.currentContext;

  static GoRouter? get _router {
    final ctx = _context;
    if (ctx == null) return null;
    return GoRouter.maybeOf(ctx);
  }

  static Future<Map<String, dynamic>> _navigate(Map<String, dynamic> args) async {
    final route = args['route'] as String? ?? '';
    if (route.isEmpty) {
      return {'ok': false, 'error': 'route is empty'};
    }

    final router = _router;
    if (router == null) {
      return {'ok': false, 'error': 'GoRouter not ready'};
    }

    final embedded = args['embedded'] == true;
    if (embedded) {
      final returnRoute = router.state.matchedLocation;
      SHOHybridNativeOverlayCoordinator.beginEmbeddedPush(
        targetRoute: route,
        returnRoute: returnRoute,
      );
      FocusManager.instance.primaryFocus?.unfocus();
      router.go(route);
      return {'ok': true, 'route': route, 'embedded': true};
    }

    await router.push(route);
    return {'ok': true, 'route': route};
  }

  static Future<Map<String, dynamic>> _onHybridFlutterPopped() async {
    final router = _router;
    final restore = SHOHybridNativeOverlayCoordinator.returnRoute;

    SHOHybridNativeOverlayCoordinator.onNativeHybridFlutterPopped();

    if (router != null && restore != null && restore.isNotEmpty) {
      router.go(restore);
    }
    return {'ok': true};
  }

  static Future<Map<String, dynamic>> _showDialog(
    Map<String, dynamic> args,
  ) async {
    final ctx = _context;
    if (ctx == null) {
      return {'ok': false, 'action': 'error', 'error': 'context not ready'};
    }

    final kind = args['kind'] as String? ?? SHOHybridDialogKind.alert;
    final title = args['title'] as String? ?? 'Dialog';
    final message = args['message'] as String?;

    switch (kind) {
      case SHOHybridDialogKind.confirm:
        final confirmed = await SHOAppDialog.confirm(
          ctx,
          title: title,
          message: message,
          confirmLabel: args['confirmLabel'] as String? ?? '确认',
          cancelLabel: args['cancelLabel'] as String? ?? '取消',
          isDestructive: args['destructive'] == true,
        );
        return {
          'ok': true,
          'kind': kind,
          'action': confirmed ? 'confirm' : 'cancel',
        };
      case SHOHybridDialogKind.bottomSheet:
        final action = await SHOAppDialog.showBottomSheet<String>(
          ctx,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: Text(title),
                  subtitle: message != null ? Text(message) : null,
                ),
                ListTile(
                  leading: const Icon(Icons.share_outlined),
                  title: const Text('分享'),
                  onTap: () => Navigator.pop(ctx, 'share'),
                ),
                ListTile(
                  leading: const Icon(Icons.flag_outlined),
                  title: const Text('举报'),
                  onTap: () => Navigator.pop(ctx, 'report'),
                ),
                ListTile(
                  title: const Text('取消'),
                  onTap: () => Navigator.pop(ctx, 'cancel'),
                ),
              ],
            ),
          ),
        );
        return {
          'ok': true,
          'kind': kind,
          'action': action ?? 'dismiss',
        };
      case SHOHybridDialogKind.actionSheet:
        final action = await showModalBottomSheet<String>(
          context: ctx,
          builder: (sheetCtx) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(title: Text(title)),
                ListTile(
                  title: const Text('选项 A'),
                  onTap: () => Navigator.pop(sheetCtx, 'option_a'),
                ),
                ListTile(
                  title: const Text('选项 B'),
                  onTap: () => Navigator.pop(sheetCtx, 'option_b'),
                ),
                ListTile(
                  title: const Text('取消'),
                  onTap: () => Navigator.pop(sheetCtx, 'cancel'),
                ),
              ],
            ),
          ),
        );
        return {
          'ok': true,
          'kind': kind,
          'action': action ?? 'dismiss',
        };
      case SHOHybridDialogKind.alert:
      default:
        await SHOAppDialog.alert(
          ctx,
          title: title,
          message: message,
          okLabel: args['okLabel'] as String? ?? '知道了',
        );
        return {'ok': true, 'kind': kind, 'action': 'ok'};
    }
  }

  static Future<Map<String, dynamic>> _abandonNativeOverlaySession() async {
    SHOHybridNativeOverlayCoordinator.abandonSession();
    return {'ok': true};
  }

  static Future<Map<String, dynamic>> _trackNativeAnalytics(
    Map<String, dynamic> args,
  ) async {
    final eventKey = args['eventKey'] as String? ?? 'native_component_demo';
    final rawParams = args['params'];
    final params = <String, Object?>{};
    if (rawParams is Map) {
      for (final entry in rawParams.entries) {
        params[entry.key.toString()] = entry.value;
      }
    }
    await SHOAnalyticsManager.instance.track(eventKey, params, validate: false);
    return {
      'ok': true,
      'eventKey': eventKey,
      'params': params,
      'trackedAt': DateTime.now().millisecondsSinceEpoch,
    };
  }

  static Future<Map<String, dynamic>> _runMethodChannelDemo() async {
    final ping = await _device.ping();
    final version = await _device.getPlatformVersion();
    return {
      'ok': true,
      'demo': 'method_channel',
      'ping': ping,
      'platformVersion': version,
    };
  }

  static Future<Map<String, dynamic>> _runMessageChannelDemo(
    Map<String, dynamic> args,
  ) async {
    final text = args['text'] as String? ?? 'hello from native_host';
    final reply = await SHONativeMessageBridge.send<Map<String, dynamic>>(
      message: {'text': text, 'ts': DateTime.now().millisecondsSinceEpoch},
    );
    return {'ok': true, 'demo': 'basic_message', 'reply': reply};
  }

  static Future<Map<String, dynamic>> _runEventChannelDemo(
    Map<String, dynamic> args,
  ) async {
    final maxTicks = (args['ticks'] as int?) ?? 3;
    try {
      final events = await SHONativeEventBridge.collect<Map<String, dynamic>>(
        arguments: 'debug_tick',
        mapper: (e) => Map<String, dynamic>.from(e as Map),
        maxEvents: maxTicks,
      );
      return {
        'ok': true,
        'demo': 'event_channel',
        'received': events.length,
        'lastEvent': events.isEmpty ? null : events.last,
        if (events.length < maxTicks) 'timeout': true,
      };
    } catch (error, stack) {
      SHOAppLogger.error('Event demo failed', error, stack);
      return {'ok': false, 'error': error.toString()};
    }
  }

  static String productListRoute() {
    return SHOAppRoutes.categoryProductsFiltered(
      leafId: 'c1-g1-l1',
      title: 'T-Shirts',
    );
  }

  static String cartRoute() => SHOAppRoutes.cartStack;
}
