import 'package:flutter/services.dart';

import '../logging/hos_logger.dart';
import 'hos_channel_names.dart';
import 'hos_native_bridge_exception.dart';
import 'hos_native_type_caster.dart';

/// BasicMessageChannel：高频小数据双向通信，延迟低于 MethodChannel。
///
/// Dart → Native 单向发送：
/// ```dart
/// await SHONativeMessageBridge.send<int>(message: 1);
/// ```
abstract final class SHONativeMessageBridge {
  static final Map<String, BasicMessageChannel<dynamic>> _channels = {};

  static BasicMessageChannel<dynamic> channel([
    String name = SHOChannelNames.nativeMessage,
  ]) {
    return _channels.putIfAbsent(
      name,
      () => BasicMessageChannel<dynamic>(name, const StandardMessageCodec()),
    );
  }

  static Future<T> send<T>({
    required dynamic message,
    String channelName = SHOChannelNames.nativeMessage,
  }) async {
    try {
      final reply = await channel(channelName).send(message);
      if (reply == null) {
        throw SHONativeBridgeException(
          channel: channelName,
          method: 'send',
          message: 'Native returned null reply',
          code: 'null_result',
        );
      }
      return SHONativeTypeCaster.cast<T>(reply);
    } on PlatformException catch (e) {
      throw SHONativeBridgeException(
        channel: channelName,
        method: 'send',
        message: e.message ?? 'Message channel error',
        code: e.code,
        details: e.details,
      );
    }
  }

  /// 注册 Dart 端消息处理器（原生可主动发消息到 Flutter）。
  static void setHandler({
    String channelName = SHOChannelNames.nativeMessage,
    required Future<dynamic> Function(dynamic message)? handler,
  }) {
    channel(channelName).setMessageHandler(handler);
    SHOAppLogger.debug('NativeMessageBridge handler set: $channelName');
  }
}
