import 'package:flutter/material.dart';

import 'hos_hybrid_native_overlay_coordinator.dart';

/// 嵌入原生 Nav 时的 Flutter UI 适配（隐藏 Flutter AppBar，使用原生返回栏）。
abstract final class SHOHybridEmbeddedUi {
  static bool get usesNativeNavBar =>
      SHOHybridNativeOverlayCoordinator.isEmbeddedMode;

  /// 嵌入模式下返回 null，由 iOS 透明顶栏承担标题与返回。
  static PreferredSizeWidget? appBar(PreferredSizeWidget? bar) {
    return usesNativeNavBar ? null : bar;
  }

  /// 为原生顶栏（安全区 + 44pt）预留顶部间距。
  static Widget padBody(BuildContext context, Widget child) {
    if (!usesNativeNavBar) return child;
    final top = MediaQuery.paddingOf(context).top + kToolbarHeight;
    return Padding(
      padding: EdgeInsets.only(top: top),
      child: child,
    );
  }
}
