import 'package:flutter/services.dart';

import '../logging/hos_logger.dart';
import 'hos_channel_names.dart';
import 'hos_native_bridge_exception.dart';

/// EventChannel 统一封装：原生主动推送，避免 Timer 轮询 MethodChannel。
///
/// ```dart
/// final stream = SHONativeEventBridge.broadcast<Map<String, dynamic>>(
///   channelName: SHOChannelNames.nativeEvent,
///   mapper: (e) => Map<String, dynamic>.from(e as Map),
/// );
/// ```
abstract final class SHONativeEventBridge {
  static final Map<String, EventChannel> _channels = {};

  static EventChannel channel([String name = SHOChannelNames.nativeEvent]) {
    return _channels.putIfAbsent(name, () => EventChannel(name));
  }

  static Stream<T> broadcast<T>({
    String channelName = SHOChannelNames.nativeEvent,
    dynamic arguments,
    required T Function(dynamic event) mapper,
    void Function(Object error, StackTrace stackTrace)? onError,
  }) {
    return channel(channelName)
        .receiveBroadcastStream(arguments)
        .map(mapper)
        .handleError((Object error, StackTrace stackTrace) {
      SHOAppLogger.warn('NativeEventBridge stream error [$channelName]: $error');
      if (onError != null) {
        onError(error, stackTrace);
        return;
      }
      if (error is PlatformException) {
        throw SHONativeBridgeException(
          channel: channelName,
          method: 'stream',
          message: error.message ?? 'Event stream error',
          code: error.code,
          details: error.details,
        );
      }
      throw error;
    });
  }
}
