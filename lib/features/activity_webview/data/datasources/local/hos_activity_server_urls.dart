import 'package:flutter/foundation.dart';

import 'package:shoo/core/constants/hos_constants.dart';

/// 活动页在 Node 本地 Mock Server（:3847）上的地址。
abstract final class SHOActivityServerUrls {
  static String get _host {
    if (kIsWeb) return '127.0.0.1';
    if (defaultTargetPlatform == TargetPlatform.android) return '10.0.2.2';
    return '127.0.0.1';
  }

  static int get port {
    const fromEnv = String.fromEnvironment(
      'LOCAL_SERVER_PORT',
      defaultValue: '',
    );
    final parsed = int.tryParse(fromEnv);
    return parsed ?? SHOAppConstants.localMockServerPort;
  }

  /// 活动 H5：`http://127.0.0.1:3847/activity`
  static String nodeActivityPageUrl() => 'http://$_host:$port/activity';
}
