import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/hos_config.dart';
import '../modules/activity/hos_debug_activity_config_provider.dart';
import '../modules/update/hos_debug_update_config_provider.dart';

/// 调试覆盖开关门禁：仅当 Debug 包且用户显式开启覆盖时才走调试配置。
abstract final class SHODebugOverrideGate {
  static bool get _debugBuild => SHOAppConfig.instance.isDebugPanelEnabled;

  /// 版本更新是否使用调试配置（否则走 API 正常校验）。
  static bool isUpdateOverrideActive(Ref ref) {
    if (!_debugBuild) return false;
    return ref.read(debugUpdateConfigProvider).overrideEnabled;
  }

  /// 活动广告是否使用调试配置（否则走 API 正常拉取）。
  static bool isActivityOverrideActive(Ref ref) {
    if (!_debugBuild) return false;
    return ref.read(debugActivityConfigProvider).overrideEnabled;
  }
}
