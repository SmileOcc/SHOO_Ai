import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shoo/app/router/hos_router.dart';
import 'package:shoo/core/platform/hybrid/hos_hybrid_native_overlay_coordinator.dart';

/// 嵌入模式下监听 go_router：离开混合业务栈时恢复路由并 Pop 原生容器。
final hybridOverlayRouteListenerProvider = Provider<void>((ref) {
  final router = ref.watch(routerProvider);

  void onRouteChanged() {
    final location = router.state.matchedLocation;
    if (SHOHybridNativeOverlayCoordinator.isEmbeddedMode &&
        !SHOHybridNativeOverlayCoordinator.isHybridBusinessRoute(location)) {
      final restore = SHOHybridNativeOverlayCoordinator.returnRoute;
      if (restore != null && restore.isNotEmpty && restore != location) {
        router.go(restore);
      }
    }
    unawaited(
      SHOHybridNativeOverlayCoordinator.onEmbeddedRouteLeft(location),
    );
  }

  router.routerDelegate.addListener(onRouteChanged);
  ref.onDispose(() => router.routerDelegate.removeListener(onRouteChanged));
});
