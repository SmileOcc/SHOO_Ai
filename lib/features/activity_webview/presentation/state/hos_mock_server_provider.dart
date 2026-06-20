import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shoo/core/config/hos_config.dart';
import 'package:shoo/core/network/hos_local_server_health.dart';
import 'package:shoo/features/activity_webview/data/datasources/local/hos_activity_mock_server.dart';
import 'package:shoo/features/activity_webview/data/datasources/local/hos_activity_server_urls.dart';

/// 活动 WebView 加载地址：优先 Node `server/`（:3847），否则内嵌 :8888，最后 asset 降级。
final activityMockServerUrlProvider = FutureProvider<String?>((ref) async {
  if (kIsWeb) return null;

  final config = ref.watch(effectiveConfigProvider);
  ref.keepAlive();

  final nodeUp = await SHOLocalServerHealth.ping(config.apiBaseUrl);
  if (nodeUp) {
    return SHOActivityServerUrls.nodeActivityPageUrl();
  }

  if (config.useMockApi) {
    ref.onDispose(SHOActivityMockServer.stop);
    return SHOActivityMockServer.resolveWebViewBaseUrl();
  }

  return null;
});
