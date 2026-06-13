/// Debug 调试基建 — 按模块拆分。
///
/// ```
/// debug/
/// ├── core/          # 门禁、连点入口、配置仓库
/// ├── panel/         # 调试主面板
/// └── modules/
///     ├── activity/  # 活动弹窗调试
///     ├── update/    # 版本更新调试
///     └── native/    # 原生 Channel 调试
/// ```
library;

export 'core/hos_debug_config_repository.dart';
export 'core/hos_debug_flow_status_banner.dart';
export 'core/hos_debug_override_gate.dart';
export 'core/hos_debug_tap_detector.dart';
export 'modules/activity/hos_debug_activity_config.dart';
export 'modules/activity/hos_debug_activity_config_page.dart';
export 'modules/activity/hos_debug_activity_config_provider.dart';
export 'modules/feedback/hos_debug_feedback_page.dart';
export 'modules/native/hos_debug_native_example_page.dart';
export 'modules/native/hos_debug_native_hub_page.dart';
export 'modules/update/hos_debug_update_config.dart';
export 'modules/update/hos_debug_update_config_page.dart';
export 'modules/update/hos_debug_update_config_provider.dart';
export 'panel/hos_debug_panel_page.dart';
