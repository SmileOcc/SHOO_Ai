# SHOO 生产级 Logger

基于 `dart:developer.log()`，统一前缀 `[SHOO][LEVEL][Module]`。

## 架构

```
SHOAppLogger (全局入口 d/i/w/e)
    └── SHOLoggerService (单例)
            ├── minLevel 运行时过滤
            ├── SHOLogConsoleSink   → developer.log()
            ├── SHOLogFileSink      → SHOAppLogManager 本地文件
            └── SHOLogCrashReporter → Sentry / Crashlytics（抽象）
```

## 快速使用

```dart
import 'package:shoo/core/logging/hos_logging.dart';

// 全局
SHOAppLogger.i('App started');
SHOAppLogger.w('Slow network', timeoutException);
SHOAppLogger.e('Checkout failed', error, stack);

// 模块化
final log = SHOAppLogger.module('AuthService');
log.d('Validating token');
log.i('Session restored');
log.e('Login failed', error, stack);
```

## Release 策略

| 级别 | Debug 控制台 | Release 控制台 | 文件缓存 | Crash 上报 |
|------|-------------|----------------|----------|------------|
| debug | ✅ | ❌ | Debug 包 ✅ | ❌ |
| info | ✅ | ❌ | ✅ | ❌ |
| warn | ✅ | ✅ | ✅ | ❌ |
| error | ✅ | ✅ | ✅ | ✅ |

## 运行时调级

```dart
// 测试包只看 warn 以上
SHOAppLogger.setMinLevel(SHOLogLevel.warn);
```

## 接入 Sentry（示例）

```dart
class SentryCrashReporter implements SHOLogCrashReporter {
  @override
  Future<void> report({
    required String message,
    Object? error,
    StackTrace? stackTrace,
    String? module,
  }) async {
    await Sentry.captureException(
      error ?? Exception(message),
      stackTrace: stackTrace,
      hint: Hint.withMap({'module': module, 'message': message}),
    );
  }
}

// bootstrap 中
SHOAppLogger.setCrashReporter(SentryCrashReporter());
```

## 自定义文件输出器

```dart
class DailyFileSink implements SHOLogSink {
  @override
  String get id => 'daily_file';

  @override
  void write(SHOLogRecord record) {
    // 写入自定义路径，注意异步与轮转
    File('/path/${record.timestamp.day}.log')
        .writeAsStringSync('${record.fullLine}\n', mode: FileMode.append);
  }
}

SHOAppLogger.addSink(DailyFileSink());
```

## 输出格式示例

```
[SHOO][INFO] App started
[SHOO][DEBUG][AuthService] Checking session
[SHOO][ERROR][PaymentService] Charge failed | DioException(...)
```
