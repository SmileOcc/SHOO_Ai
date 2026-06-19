import 'dart:io';

import 'package:shoo/core/platform/bridge/hos_native_bridge.dart';
import 'package:shoo/core/platform/native_components/hos_native_components_protocol.dart';

/// 原生组件库门面（地图 / WebView / 支付等）。
abstract final class SHONativeComponentsBridge {
  static bool get isSupported => Platform.isIOS;

  /// 打开原生组件瀑布流 Hub。
  static Future<void> openHub() async {
    await SHONativeBridge.invoke(method: SHONativeComponentsMethods.openHub);
  }

  /// 直接运行指定原生组件 Demo。
  static Future<Map<String, dynamic>> runModule(String moduleId) async {
    final result = await SHONativeBridge.call<Map<String, dynamic>>(
      method: SHONativeComponentsMethods.runModule,
      args: {'module': moduleId},
    );
    return result;
  }
}
