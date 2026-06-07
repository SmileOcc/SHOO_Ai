/// 记录冷启动各阶段耗时（进程 → bootstrap → 首帧）。
abstract final class SHOAppStartupTimer {
  static DateTime? _processStart;
  static DateTime? _bootstrapEnd;
  static DateTime? _firstFrame;

  static void markProcessStart() {
    _processStart ??= DateTime.now();
  }

  static void markBootstrapEnd() {
    _bootstrapEnd = DateTime.now();
  }

  static void markFirstFrame() {
    _firstFrame ??= DateTime.now();
  }

  static int? get bootstrapMs {
    if (_processStart == null || _bootstrapEnd == null) return null;
    return _bootstrapEnd!.difference(_processStart!).inMilliseconds;
  }

  static int? get firstFrameMs {
    if (_processStart == null || _firstFrame == null) return null;
    return _firstFrame!.difference(_processStart!).inMilliseconds;
  }

  static int? get bootstrapToFirstFrameMs {
    if (_bootstrapEnd == null || _firstFrame == null) return null;
    return _firstFrame!.difference(_bootstrapEnd!).inMilliseconds;
  }

  static bool get hasFirstFrame => _firstFrame != null;
}
