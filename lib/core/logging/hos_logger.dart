import 'hos_log_crash_reporter.dart';
import 'hos_log_level.dart';
import 'hos_log_sink.dart';
import 'hos_logger_service.dart';

/// SHOO 全局日志入口（基于 `dart:developer.log` + 可扩展 Sink）。
///
/// ## 快速使用
///
/// ```dart
/// // 全局简短调用
/// SHOAppLogger.i('App started');
/// SHOAppLogger.w('Token expiring soon');
/// SHOAppLogger.e('Payment failed', error, stack);
///
/// // 模块化
/// final authLog = SHOAppLogger.module('AuthService');
/// authLog.d('Checking session');
/// authLog.i('User logged in: $userId');
///
/// // 运行时只显示 warn 以上
/// SHOAppLogger.setMinLevel(SHOLogLevel.warn);
///
/// // 接入 Sentry / Crashlytics（实现 [SHOLogCrashReporter]）
/// SHOAppLogger.setCrashReporter(MySentryReporter());
///
/// // 自定义输出器（如写入独立文件）
/// SHOAppLogger.addSink(MyCustomFileSink());
/// ```
///
/// ## Release 行为
///
/// - `debug` / `info`：控制台自动屏蔽；文件缓存遵循 [SHOAppLogManager] 规则
/// - `warn` / `error`：所有模式保留；`error` 自动调用 [SHOLogCrashReporter]
abstract final class SHOAppLogger {
  static SHOLoggerService get _engine => SHOLoggerService.instance;

  // ── 配置 ──────────────────────────────────────────────

  static void setMinLevel(SHOLogLevel level) => _engine.setMinLevel(level);

  static void setCrashReporter(SHOLogCrashReporter reporter) =>
      _engine.setCrashReporter(reporter);

  static void addSink(SHOLogSink sink) => _engine.addSink(sink);

  static void removeSink(String sinkId) => _engine.removeSink(sinkId);

  static SHOLogger module(String name) => SHOLogger(name);

  // ── 简短全局 API（无模块名）────────────────────────────

  static void d(String message, [Object? detail]) =>
      _engine.log(SHOLogLevel.debug, message, error: detail);

  static void i(String message, [Object? detail]) =>
      _engine.log(SHOLogLevel.info, message, error: detail);

  static void w(String message, [Object? error]) =>
      _engine.log(SHOLogLevel.warn, message, error: error);

  static void e(String message, [Object? error, StackTrace? stack]) =>
      _engine.log(
        SHOLogLevel.error,
        message,
        error: error,
        stackTrace: stack,
      );

  // ── 兼容旧 API（逐步迁移到 d/i/w/e 或 module）──────────

  static void debug(String message, [Object? detail]) => d(message, detail);

  static void info(String message) => i(message);

  static void warn(String message, [Object? error]) => w(message, error);

  static void error(String message, [Object? error, StackTrace? stack]) =>
      e(message, error, stack);
}
