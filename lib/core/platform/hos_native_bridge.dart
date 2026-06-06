import 'package:flutter/services.dart';

import '../logging/hos_logger.dart';
import 'hos_channel_names.dart';
import 'hos_native_bridge_exception.dart';
import 'hos_native_type_caster.dart';

/// MethodChannel 统一调用层：泛型调用 + 统一错误处理 + 日志。
///
/// ```dart
/// final version = await SHONativeBridge.call<String>(
///   method: 'getPlatformVersion',
/// );
/// await SHONativeBridge.invoke(method: 'ping');
/// ```
abstract final class SHONativeBridge {
  static final Map<String, MethodChannel> _channels = {};

  static MethodChannel channel([String name = SHOChannelNames.nativeBridge]) {
    return _channels.putIfAbsent(name, () => MethodChannel(name));
  }

  /// 泛型调用，原生返回 `null` 时抛 [SHONativeBridgeException]。
  static Future<T> call<T>({
    required String method,
    String channelName = SHOChannelNames.nativeBridge,
    Map<String, dynamic>? args,
  }) async {
    final result = await _invoke(channelName: channelName, method: method, args: args);
    if (result == null) {
      throw SHONativeBridgeException(
        channel: channelName,
        method: method,
        message: 'Native returned null',
        code: 'null_result',
      );
    }
    try {
      return SHONativeTypeCaster.cast<T>(result);
    } catch (e, st) {
      SHOAppLogger.error('NativeBridge cast failed: $channelName.$method', e, st);
      throw SHONativeBridgeException(
        channel: channelName,
        method: method,
        message: 'Failed to cast result to $T: $e',
        code: 'cast_error',
        details: result,
      );
    }
  }

  /// 允许原生返回 `null`（适用于可空返回类型）。
  static Future<T?> callNullable<T>({
    required String method,
    String channelName = SHOChannelNames.nativeBridge,
    Map<String, dynamic>? args,
  }) async {
    final result = await _invoke(channelName: channelName, method: method, args: args);
    if (result == null) return null;
    return SHONativeTypeCaster.cast<T>(result);
  }

  /// 无返回值调用（原生可 success(null)）。
  static Future<void> invoke({
    required String method,
    String channelName = SHOChannelNames.nativeBridge,
    Map<String, dynamic>? args,
  }) async {
    await _invoke(channelName: channelName, method: method, args: args);
  }

  static Future<dynamic> _invoke({
    required String channelName,
    required String method,
    Map<String, dynamic>? args,
  }) async {
    try {
      SHOAppLogger.debug('NativeBridge → $channelName.$method');
      return await channel(channelName).invokeMethod<dynamic>(method, args);
    } on PlatformException catch (e) {
      final ex = SHONativeBridgeException(
        channel: channelName,
        method: method,
        message: e.message ?? 'Unknown platform error',
        code: e.code,
        details: e.details,
      );
      SHOAppLogger.warn('$ex');
      throw ex;
    } on MissingPluginException catch (e) {
      final ex = SHONativeBridgeException(
        channel: channelName,
        method: method,
        message: e.message ?? 'No native implementation registered',
        code: 'missing_plugin',
      );
      SHOAppLogger.warn('$ex');
      throw ex;
    }
  }
}
