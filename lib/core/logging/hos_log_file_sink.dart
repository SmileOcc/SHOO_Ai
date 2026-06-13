import 'dart:async';

import 'hos_log_manager.dart';
import 'hos_log_record.dart';
import 'hos_log_sink.dart';

/// 写入本地文件缓存（复用 [SHOAppLogManager]）。
class SHOLogFileSink implements SHOLogSink {
  SHOLogFileSink({this.id = 'file'});

  @override
  final String id;

  @override
  bool accepts(SHOLogRecord record) {
    return SHOAppLogManager.instance.shouldCacheLevel(record.level.label);
  }

  @override
  void write(SHOLogRecord record) {
    final line = record.stackTrace == null
        ? record.fullLine
        : '${record.fullLine}\n${record.stackTrace}';
    unawaited(SHOAppLogManager.instance.append(record.level.label, line));
  }
}
