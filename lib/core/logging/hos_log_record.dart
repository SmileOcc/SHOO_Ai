import 'hos_log_level.dart';

/// 单条日志记录，传递给各输出器。
class SHOLogRecord {
  const SHOLogRecord({
    required this.level,
    required this.message,
    required this.timestamp,
    this.module,
    this.error,
    this.stackTrace,
  });

  final SHOLogLevel level;
  final String message;
  final DateTime timestamp;
  final String? module;
  final Object? error;
  final StackTrace? stackTrace;

  /// 项目统一前缀，例如 `[SHOO][INFO][AuthService]`。
  String get prefix {
    final modulePart =
        module == null || module!.isEmpty ? '' : '[$module]';
    return '[SHOO][${level.label}]$modulePart';
  }

  String get body {
    if (error == null) return message;
    return '$message | $error';
  }

  String get fullLine => '$prefix $body';
}
