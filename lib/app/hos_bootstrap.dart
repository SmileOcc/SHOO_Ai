import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/analytics/hos_app_startup_timer.dart';
import '../core/config/hos_config.dart';
import '../core/debug/core/hos_app_restart.dart';
import '../core/feedback/hos_global_error.dart';
import '../core/logging/hos_log_manager.dart';
import '../core/logging/hos_logger.dart';
import '../core/storage/hos_image_cache_manager.dart';

Future<void> bootstrap() async {
  // 运行 Zone 捕获未处理的异步错误
  await runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    SHOAppStartupTimer.markProcessStart();

    await SHOAppConfig.init();
    await SHOAppLogManager.instance.init();
    await SHOImageCacheManager.ensureReady();
    CachedNetworkImageProvider.defaultCacheManager =
        SHOImageCacheManager.instance;

    final previousPlatformErrorHandler = PlatformDispatcher.instance.onError;
    PlatformDispatcher.instance.onError = (error, stack) {
      if (SHOImageCacheManager.isReadonlyDbError(error)) {
        unawaited(
          SHOImageCacheManager.recoverFromReadonlyError(error: error),
        );
        return true;
      }
      SHOAppLogger.error('Uncaught platform error', error, stack);
      SHOGlobalError.report(error);
      return previousPlatformErrorHandler?.call(error, stack) ?? true;
    };

    final previousFlutterErrorHandler = FlutterError.onError;
    FlutterError.onError = (details) {
      if (kDebugMode) {
        FlutterError.presentError(details);
      }
      SHOAppLogger.error(
        'Flutter framework error',
        details.exception,
        details.stack,
      );
      if (!details.silent) {
        SHOGlobalError.report(details.exception);
      }
      previousFlutterErrorHandler?.call(details);
    };

    final sharedPreferences = await SharedPreferences.getInstance();
    await prepareRuntimeAfterEnvChange(sharedPreferences);
    SHOAppStartupTimer.markBootstrapEnd();

    runApp(SHOAppRestart(sharedPreferences: sharedPreferences));
  }, (error, stack) {
    // 所有未捕获的异步异常都会走到这里
    SHOAppLogger.e('全局捕获到异常: $error');
    SHOAppLogger.e('堆栈: $stack');

    SHOAppLogger.error('Uncaught zone error', error, stack);
    SHOGlobalError.report(error);
  }) ?? Future<void>.value();
}

/**
 * 
 ┌─────────────────────────────────────────────────────────────┐
│                    应用启动流程                               │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
              ┌───────────────────────────────┐
              │  WidgetsFlutterBinding       │
              │  确保框架绑定初始化             │
              └───────────────────────────────┘
                              │
                              ▼
              ┌───────────────────────────────┐
              │  SHOAppStartupTimer           │
              │  标记进程启动时间点            │
              └───────────────────────────────┘
                              │
                              ▼
              ┌───────────────────────────────┐
              │  SHOAppConfig.init()          │
              │  初始化应用配置                │
              └───────────────────────────────┘
                              │
                              ▼
              ┌───────────────────────────────┐
              │  SHOAppLogManager.init()      │
              │  初始化日志系统                │
              └───────────────────────────────┘
                              │
                              ▼
              ┌───────────────────────────────┐
              │  SHOImageCacheManager         │
              │  预热图片缓存管理器            │
              └───────────────────────────────┘
                              │
                              ▼
              ┌───────────────────────────────┐
              │  全局错误处理器                │
              │  捕获并恢复特定错误             │
              └───────────────────────────────┘
                              │
                              ▼
              ┌───────────────────────────────┐
              │  SharedPreferences            │
              │  初始化持久化存储              │
              └───────────────────────────────┘
                              │
                              ▼
              ┌───────────────────────────────┐
              │  prepareRuntimeAfterEnvChange │
              │  准备运行时环境                │
              └───────────────────────────────┘
                              │
                              ▼
              ┌───────────────────────────────┐
              │  标记 Bootstrap 结束          │
              └───────────────────────────────┘
                              │
                              ▼
              ┌───────────────────────────────┐
              │  runApp(SHOAppRestart)        │
              │  启动应用                     │
              └───────────────────────────────┘
                              │
                              ▼
              ┌───────────────────────────────┐
              │  首帧渲染完成                 │
              │  (由 SHOAppLifecycleBinder   │
              │   监听并记录)                 │
              └───────────────────────────────┘

总结
这个 bootstrap() 函数体现了以下设计原则:

单一职责: 每个初始化步骤只负责一件事
依赖倒置: 先初始化基础设施,再初始化依赖组件
错误恢复: 主动处理错误,而非被动记录
性能监控: 全流程性能追踪
开发体验: 支持 Debug 模式下的环境热切换

 */
