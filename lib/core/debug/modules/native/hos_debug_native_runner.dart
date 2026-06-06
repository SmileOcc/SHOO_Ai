import 'dart:convert';

import '../../../platform/hos_channel_names.dart';
import '../../../platform/hos_native_bridge.dart';
import '../../../platform/hos_native_bridge_exception.dart';
import '../../../platform/hos_native_event_bridge.dart';
import '../../../platform/hos_native_message_bridge.dart';
import 'hos_debug_native_examples.dart';

/// 执行原生调试示例，返回可展示的文本结果。
abstract final class SHONativeDebugRunner {
  static Future<String> run(SHONativeDebugExampleId id, {String? messageInput}) async {
    return switch (id) {
      SHONativeDebugExampleId.ping => _formatJson(
          await SHONativeBridge.call<Map<String, dynamic>>(method: 'ping'),
        ),
      SHONativeDebugExampleId.platformVersion => await SHONativeBridge.call<String>(
          method: 'getPlatformVersion',
        ),
      SHONativeDebugExampleId.messageEcho => _formatJson(
          await SHONativeMessageBridge.send<Map<String, dynamic>>(
            message: {
              'text': messageInput?.trim().isNotEmpty == true
                  ? messageInput!.trim()
                  : 'hello from flutter',
              'ts': DateTime.now().millisecondsSinceEpoch,
            },
          ),
        ),
      SHONativeDebugExampleId.eventTick =>
        throw UnsupportedError('Use debugEventStream() for event examples'),
    };
  }

  static Stream<Map<String, dynamic>> debugEventStream() {
    return SHONativeEventBridge.broadcast<Map<String, dynamic>>(
      channelName: SHOChannelNames.nativeEvent,
      arguments: 'debug_tick',
      mapper: (event) => Map<String, dynamic>.from(event as Map),
    );
  }

  static String formatError(Object error) {
    if (error is SHONativeBridgeException) {
      return '${error.channel}.${error.method}\n'
          'code: ${error.code}\n'
          'message: ${error.message}\n'
          'details: ${error.details}';
    }
    return error.toString();
  }

  static String _formatJson(Map<String, dynamic> map) {
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(map);
  }
}
