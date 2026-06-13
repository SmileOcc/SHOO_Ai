/// 日志级别（数值越大越严重）。
enum SHOLogLevel {
  debug(0, 'DEBUG'),
  info(1, 'INFO'),
  warn(2, 'WARN'),
  error(3, 'ERROR');

  const SHOLogLevel(this.value, this.label);

  /// 供 `dart:developer` [log] 使用的级别映射。
  final int value;
  final String label;

  bool operator >=(SHOLogLevel other) => value >= other.value;
  bool operator <(SHOLogLevel other) => value < other.value;
}
