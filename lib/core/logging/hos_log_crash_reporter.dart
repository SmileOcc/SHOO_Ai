/// Crashlytics / Sentry 等崩溃上报抽象接口（与具体 SDK 解耦）。
abstract interface class SHOLogCrashReporter {
  /// 上报 error 级别日志；实现方自行对接 Firebase / Sentry 等。
  Future<void> report({
    required String message,
    Object? error,
    StackTrace? stackTrace,
    String? module,
  });
}

/// 默认空实现，生产环境可替换为真实上报器。
class SHONoopCrashReporter implements SHOLogCrashReporter {
  const SHONoopCrashReporter();

  @override
  Future<void> report({
    required String message,
    Object? error,
    StackTrace? stackTrace,
    String? module,
  }) async {}
}
