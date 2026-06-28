import 'package:flutter/services.dart';
import 'package:shoo/core/logging/hos_logger.dart';
import 'package:shoo/core/platform/bridge/hos_channel_names.dart';
import 'package:shoo/core/platform/hybrid/hos_native_host_actions.dart';

/// Native → Flutter 宿主通道：Dart 端注册 Handler。
abstract final class SHONativeHostBridge {
  static final MethodChannel _channel = MethodChannel(
    SHOChannelNames.nativeHost,
  );
  static var _installed = false;

  static void install() {
    if (_installed) return;
    _installed = true;
    _channel.setMethodCallHandler(_onMethodCall);
    SHOAppLogger.i('SHONativeHostBridge installed');
  }

  static Future<dynamic> _onMethodCall(MethodCall call) async {
    SHOAppLogger.d('NativeHost ← ${call.method}');
    try {
      return await SHONativeHostActions.handle(call);
    } catch (error, stack) {
      SHOAppLogger.e('NativeHost handler failed: ${call.method}', error, stack);
      rethrow;
    }
  }
}
