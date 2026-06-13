import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

import 'hos_log_level.dart';
import 'hos_log_record.dart';
import 'hos_log_sink.dart';

/// 基于 `dart:developer.log()` 的控制台输出器（原生平台友好）。
class SHOLogConsoleSink implements SHOLogSink {
  SHOLogConsoleSink({this.id = 'console'});

  @override
  final String id;

  @override
  bool accepts(SHOLogRecord record) {
    if (kReleaseMode &&
        (record.level == SHOLogLevel.debug || record.level == SHOLogLevel.info)) {
      return false;
    }
    return true;
  }

  @override
  void write(SHOLogRecord record) {
    developer.log(
      record.body,
      name: record.prefix,
      time: record.timestamp,
      level: _developerLevel(record.level),
      error: record.error,
      stackTrace: record.stackTrace,
    );
  }

  int _developerLevel(SHOLogLevel level) => switch (level) {
        SHOLogLevel.debug => 500,
        SHOLogLevel.info => 800,
        SHOLogLevel.warn => 900,
        SHOLogLevel.error => 1000,
      };
}
