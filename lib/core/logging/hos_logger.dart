import 'package:flutter/foundation.dart';

/// 轻量日志工具，生产环境自动静默 debug 日志。
abstract final class SHOAppLogger {
  static void debug(String message, [Object? detail]) {
    if (kDebugMode) {
      // ignore: avoid_print
      print('[SHOO][DEBUG] $message${detail != null ? ' | $detail' : ''}');
    }
  }

  static void info(String message) {
    if (kDebugMode) {
      // ignore: avoid_print
      print('[SHOO][INFO] $message');
    }
  }

  static void warn(String message, [Object? error]) {
    // ignore: avoid_print
    print('[SHOO][WARN] $message${error != null ? ' | $error' : ''}');
  }

  static void error(String message, [Object? error, StackTrace? stack]) {
    // ignore: avoid_print
    print('[SHOO][ERROR] $message${error != null ? ' | $error' : ''}');
    if (stack != null && kDebugMode) {
      // ignore: avoid_print
      print(stack);
    }
  }
}
