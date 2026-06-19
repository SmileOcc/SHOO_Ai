/// SHOO 原生交互基建 — MethodChannel / EventChannel / BasicMessageChannel / Hybrid。
///
/// 目录结构：
/// - [bridge/] 基础 Channel 封装
/// - [business_event/] 支付/下载/物流等业务事件
/// - [hybrid/] S活动 混合桥（原生 ↔ Flutter）
library;

export 'bridge/hos_channel_names.dart';
export 'bridge/hos_native_bridge.dart';
export 'bridge/hos_native_bridge_exception.dart';
export 'bridge/hos_native_device_service.dart';
export 'bridge/hos_native_event_bridge.dart';
export 'bridge/hos_native_message_bridge.dart';
export 'bridge/hos_native_stream_service.dart';
export 'bridge/hos_native_type_caster.dart';
export 'business_event/hos_native_business_event.dart';
export 'business_event/hos_native_business_event_service.dart';
export 'business_event/hos_native_event_kinds.dart';
export 'hybrid/hos_hybrid_embedded_ui.dart';
export 'hybrid/hos_hybrid_bridge.dart';
export 'hybrid/hos_hybrid_bridge_installer.dart';
export 'hybrid/hos_hybrid_bridge_protocol.dart';
export 'hybrid/hos_hybrid_native_overlay_coordinator.dart';
export 'hybrid/hos_hybrid_native_overlay_provider.dart';
export 'hybrid/hos_native_host_actions.dart';
export 'hybrid/hos_native_host_bridge.dart';
export 'native_components/hos_native_components_bridge.dart';
export 'native_components/hos_native_components_protocol.dart';
