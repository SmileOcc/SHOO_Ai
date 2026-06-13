import 'hos_log_record.dart';

/// 日志输出器抽象接口（控制台 / 文件 / 远程等均可实现）。
abstract interface class SHOLogSink {
  String get id;

  /// 是否处理该级别（可在实现内二次过滤）。
  bool accepts(SHOLogRecord record) => true;

  void write(SHOLogRecord record);
}
