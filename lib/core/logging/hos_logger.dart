import 'package:flutter/foundation.dart';

import 'hos_log_manager.dart';

/// 轻量日志工具；开发包缓存全部级别，正式包不缓存 DEBUG。
abstract final class SHOAppLogger {
  static void debug(String message, [Object? detail]) {
    final text = detail != null ? '$message | $detail' : message;
    if (kDebugMode) {
      // ignore: avoid_print
      print('[SHOO][DEBUG] $text');
    }
    SHOAppLogManager.instance.append('DEBUG', text);
  }

  static void info(String message) {
    if (kDebugMode) {
      // ignore: avoid_print
      print('[SHOO][INFO] $message');
    }
    SHOAppLogManager.instance.append('INFO', message);
  }

  static void warn(String message, [Object? error]) {
    final text = error != null ? '$message | $error' : message;
    // ignore: avoid_print
    print('[SHOO][WARN] $text');
    SHOAppLogManager.instance.append('WARN', text);
  }

  static void error(String message, [Object? error, StackTrace? stack]) {
    final text = error != null ? '$message | $error' : message;
    // ignore: avoid_print
    print('[SHOO][ERROR] $text');
    if (stack != null && kDebugMode) {
      // ignore: avoid_print
      print(stack);
    }
    SHOAppLogManager.instance.append('ERROR', text);
    if (stack != null) {
      SHOAppLogManager.instance.append('ERROR', stack.toString());
    }
  }
}
