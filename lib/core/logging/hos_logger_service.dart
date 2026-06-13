import 'dart:async';

import 'hos_log_console_sink.dart';
import 'hos_log_crash_reporter.dart';
import 'hos_log_file_sink.dart';
import 'hos_log_level.dart';
import 'hos_log_record.dart';
import 'hos_log_sink.dart';

/// 日志引擎单例：级别过滤、输出器分发、错误上报。
class SHOLoggerService {
  SHOLoggerService._();

  static final SHOLoggerService instance = SHOLoggerService._();

  static const _defaultBrand = 'SHOO';

  SHOLogLevel _minLevel = SHOLogLevel.debug;
  SHOLogCrashReporter _crashReporter = const SHONoopCrashReporter();
  final List<SHOLogSink> _sinks = [
    SHOLogConsoleSink(),
    SHOLogFileSink(),
  ];

  SHOLogLevel get minLevel => _minLevel;
  List<SHOLogSink> get sinks => List.unmodifiable(_sinks);
  SHOLogCrashReporter get crashReporter => _crashReporter;

  /// 运行时调整最低输出级别（如测试环境设为 [SHOLogLevel.warn]）。
  void setMinLevel(SHOLogLevel level) => _minLevel = level;

  void setCrashReporter(SHOLogCrashReporter reporter) {
    _crashReporter = reporter;
  }

  void addSink(SHOLogSink sink) {
    if (_sinks.any((s) => s.id == sink.id)) return;
    _sinks.add(sink);
  }

  void removeSink(String sinkId) {
    _sinks.removeWhere((s) => s.id == sinkId);
  }

  void log(
    SHOLogLevel level,
    String message, {
    String? module,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (level < _minLevel) return;

    final record = SHOLogRecord(
      level: level,
      message: message,
      timestamp: DateTime.now(),
      module: module,
      error: error,
      stackTrace: stackTrace,
    );

    for (final sink in _sinks) {
      if (!sink.accepts(record)) continue;
      sink.write(record);
    }

    if (level == SHOLogLevel.error) {
      unawaited(
        _crashReporter.report(
          message: message,
          error: error,
          stackTrace: stackTrace,
          module: module,
        ),
      );
    }
  }

  /// 供扩展自定义输出器时复用前缀格式。
  static String formatPrefix({
    required SHOLogLevel level,
    String? module,
    String brand = _defaultBrand,
  }) {
    final modulePart =
        module == null || module.isEmpty ? '' : '[$module]';
    return '[$brand][${level.label}]$modulePart';
  }
}

/// 模块化 Logger：绑定模块名后输出带 `[模块名]` 前缀。
class SHOLogger {
  const SHOLogger(this.module);

  final String module;

  void d(String message, [Object? detail]) =>
      _log(SHOLogLevel.debug, message, detail: detail);

  void i(String message, [Object? detail]) =>
      _log(SHOLogLevel.info, message, detail: detail);

  void w(String message, [Object? error]) =>
      _log(SHOLogLevel.warn, message, error: error);

  void e(String message, [Object? error, StackTrace? stack]) => _log(
        SHOLogLevel.error,
        message,
        error: error,
        stackTrace: stack,
      );

  void _log(
    SHOLogLevel level,
    String message, {
    Object? detail,
    Object? error,
    StackTrace? stackTrace,
  }) {
    SHOLoggerService.instance.log(
      level,
      message,
      module: module,
      error: error ?? detail,
      stackTrace: stackTrace,
    );
  }
}
