import 'package:flutter/foundation.dart';

import 'package:shoo/features/activity_webview/data/datasources/local/hos_activity_mock_server_stub.dart'
    if (dart.library.io) 'package:shoo/features/activity_webview/data/datasources/local/hos_activity_mock_server_io.dart'
    as impl;

/// 活动页本地 Mock Server（:8888）门面；Web 平台为 stub。
abstract final class SHOActivityMockServer {
  static Future<String?> ensureStarted() => impl.ensureActivityMockServerStarted();

  static Future<void> stop() => impl.stopActivityMockServer();

  /// WebView 加载用的活动页根地址（已处理 Android 模拟器 10.0.2.2）。
  static Future<String?> resolveWebViewBaseUrl() async {
    if (kIsWeb) return null;
    final started = await ensureStarted();
    if (started == null) return null;
    return started;
  }
}
