/// Platform Channel 名称常量，统一前缀避免拼写错误。
abstract final class SHOChannelNames {
  static const String prefix = 'com.shoo.shoo';

  /// 通用 MethodChannel（业务方法调用）
  static const String nativeBridge = '$prefix/native_bridge';

  /// 通用 EventChannel（原生主动推送的连续事件）
  static const String nativeEvent = '$prefix/native_event';

  /// 通用 BasicMessageChannel（高频双向小数据 / 低延迟）
  static const String nativeMessage = '$prefix/native_message';

  /// 二进制大数据专用（图片帧、音频块等，StandardMessageCodec 支持 Uint8List）
  static const String nativeBinary = '$prefix/native_binary';
}
