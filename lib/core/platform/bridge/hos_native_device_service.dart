import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'hos_native_bridge.dart';

final nativeDeviceServiceProvider = Provider<SHONativeDeviceService>((ref) {
  return const SHONativeDeviceService();
});

/// 设备 / 平台信息 — 演示 [SHONativeBridge] 业务层用法。
class SHONativeDeviceService {
  const SHONativeDeviceService();

  Future<Map<String, dynamic>> ping() =>
      SHONativeBridge.call<Map<String, dynamic>>(method: 'ping');

  Future<String> getPlatformVersion() =>
      SHONativeBridge.call<String>(method: 'getPlatformVersion');
}
