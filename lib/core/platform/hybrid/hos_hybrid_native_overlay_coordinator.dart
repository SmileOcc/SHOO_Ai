import 'dart:async';

import 'package:shoo/core/logging/hos_logger.dart';
import 'package:shoo/core/platform/bridge/hos_native_bridge.dart';
import 'package:shoo/core/platform/hybrid/hos_hybrid_bridge_protocol.dart';

/// 原生 Nav Push [HybridFlutterRouteViewController] 时的会话协调。
abstract final class SHOHybridNativeOverlayCoordinator {
  static var _embeddedMode = false;
  static var _syncingPop = false;
  static String? _returnRoute;

  static bool get isEmbeddedMode => _embeddedMode;

  static String? get returnRoute => _returnRoute;

  /// 记录进入嵌入页前的 Flutter 路由（如百宝箱），嵌入退出时恢复。
  static void beginEmbeddedPush({
    required String targetRoute,
    required String returnRoute,
  }) {
    _embeddedMode = true;
    _syncingPop = false;
    _returnRoute = returnRoute;
    SHOAppLogger.d('HybridEmbedded: go $targetRoute, return=$returnRoute');
  }

  static void abandonSession() {
    _embeddedMode = false;
    _syncingPop = false;
    _returnRoute = null;
  }

  static bool isHybridBusinessRoute(String location) {
    return _overlayRoutePrefixes.any(location.startsWith);
  }

  /// 嵌入会话结束：恢复进入前的路由，并 Pop 原生 Flutter 容器。
  static Future<void> exitEmbedded({required String currentLocation}) async {
    if (!_embeddedMode || _syncingPop) return;

    _syncingPop = true;
    final restore = _returnRoute;
    _embeddedMode = false;
    _returnRoute = null;

    SHOAppLogger.d('HybridEmbedded: exit at $currentLocation → $restore');
    try {
      await SHONativeBridge.invoke(
        method: SHOHybridBridgeMethods.popHybridPage,
      );
    } catch (error) {
      SHOAppLogger.w('HybridEmbedded native pop failed: $error', error);
    } finally {
      _syncingPop = false;
    }
  }

  /// Flutter 返回导致离开混合业务路由时，同步 Pop 原生容器。
  static Future<void> onEmbeddedRouteLeft(String location) async {
    if (!_embeddedMode || _syncingPop) return;
    if (isHybridBusinessRoute(location)) return;
    await exitEmbedded(currentLocation: location);
  }

  /// 用户滑动/点击原生返回导致 Flutter 容器被 Pop。
  static void onNativeHybridFlutterPopped() {
    if (!_embeddedMode) return;
    _embeddedMode = false;
    _returnRoute = null;
    SHOAppLogger.d('HybridEmbedded: native popped flutter container');
  }

  static const _overlayRoutePrefixes = <String>[
    '/category/products',
    '/cart',
    '/checkout',
    '/payment/',
    '/product/',
    '/address',
    '/coupon',
    '/after-sale',
  ];
}
