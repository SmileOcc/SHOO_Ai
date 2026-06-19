import 'dart:io';

import 'package:shoo/core/platform/hybrid/hos_hybrid_bridge_protocol.dart';
import 'package:shoo/core/platform/bridge/hos_native_bridge.dart';
import 'package:shoo/core/platform/hybrid/hos_native_host_bridge.dart';

/// Hybrid Bridge 门面：统一 Flutter ↔ Native 混合能力入口。
abstract final class SHOHybridBridge {
  /// 应用启动时调用一次，注册 Native → Flutter Handler。
  static void install() {
    SHONativeHostBridge.install();
  }

  /// 打开 iOS S活动原生瀑布流页（Android 返回 not_implemented）。
  static Future<void> openSActivity() async {
    await SHONativeBridge.invoke(method: SHOHybridBridgeMethods.openSActivity);
  }

  /// 直接打开 S弹弹窗实验页（一般由 S活动内进入）。
  static Future<void> openDialogLab() async {
    await SHONativeBridge.invoke(method: SHOHybridBridgeMethods.openDialogLab);
  }

  static bool get isNativeActivitySupported => Platform.isIOS;
}
