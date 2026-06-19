import 'dart:async';

import 'package:flutter/services.dart';

import '../../logging/hos_logger.dart';
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

  /// 安全取消 EventChannel 订阅：忽略「无活跃 stream」的平台错误。
  static Future<void> cancelSafely(
    StreamSubscription<dynamic>? subscription,
  ) async {
    if (subscription == null) return;
    try {
      await subscription.cancel();
    } on PlatformException catch (e) {
      if (_isInactiveStreamCancelError(e)) {
        SHOAppLogger.debug(
          'NativeEventBridge: stream already inactive on cancel',
        );
        return;
      }
      rethrow;
    }
  }

  static bool _isInactiveStreamCancelError(PlatformException e) {
    final message = e.message ?? '';
    return e.code == 'error' &&
        message.contains('No active stream to cancel');
  }

  /// 收集指定条数的事件后自动结束（用于 Demo / 一次性订阅）。
  static Future<List<T>> collect<T>({
    String channelName = SHOChannelNames.nativeEvent,
    dynamic arguments,
    required T Function(dynamic event) mapper,
    int maxEvents = 3,
    Duration timeout = const Duration(seconds: 5),
  }) async {
    StreamSubscription<T>? sub;
    final events = <T>[];
    final completer = Completer<List<T>>();

    sub = broadcast<T>(
      channelName: channelName,
      arguments: arguments,
      mapper: mapper,
    ).listen(
      (event) {
        events.add(event);
        if (events.length >= maxEvents && !completer.isCompleted) {
          completer.complete(List<T>.from(events));
        }
      },
      onError: (Object error, StackTrace stackTrace) {
        if (!completer.isCompleted) {
          completer.completeError(error, stackTrace);
        }
      },
    );

    try {
      return await completer.future.timeout(timeout, onTimeout: () => events);
    } finally {
      await cancelSafely(sub);
    }
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
