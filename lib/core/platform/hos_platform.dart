/// SHOO 原生交互基建 — MethodChannel / EventChannel / BasicMessageChannel。
///
/// | 场景 | 推荐 |
/// |------|------|
/// | 偶尔调用原生 | [SHONativeBridge] |
/// | 持续变化数据 | [SHONativeEventBridge] + [SHONativeStreamService] |
/// | 高频小数据双向 | [SHONativeMessageBridge] |
/// | 二进制大数据 | MethodChannel + `Uint8List`（StandardMessageCodec） |
///
/// Channel 名统一在 [SHOChannelNames]；错误统一为 [SHONativeBridgeException]。
library;

export 'hos_channel_names.dart';
export 'hos_native_bridge.dart';
export 'hos_native_bridge_exception.dart';
export 'hos_native_device_service.dart';
export 'hos_native_event_bridge.dart';
export 'hos_native_message_bridge.dart';
export 'hos_native_stream_service.dart';
export 'hos_native_type_caster.dart';
export 'hos_native_event_kinds.dart';
export 'hos_native_business_event.dart';
export 'hos_native_business_event_service.dart';
