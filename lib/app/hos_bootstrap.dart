import 'dart:async';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/analytics/hos_app_startup_timer.dart';
import '../core/config/hos_config.dart';
import '../core/debug/core/hos_app_restart.dart';
import '../core/logging/hos_log_manager.dart';
import '../core/storage/hos_image_cache_manager.dart';

Future<void> bootstrap() async {
  // 确保 Flutter 框架绑定已初始化
  WidgetsFlutterBinding.ensureInitialized();
  //标记进程启动时间点,用于性能监控
  SHOAppStartupTimer.markProcessStart();

  //初始化应用配置(环境变量、API 地址、Mock 设置等)
  await SHOAppConfig.init();
  //初始化日志系统,支持本地缓存和远程上报
  await SHOAppLogManager.instance.init();
  //预热图片缓存管理器
  await SHOImageCacheManager.ensureReady();
  //置全局图片缓存管理器
  CachedNetworkImageProvider.defaultCacheManager =
      SHOImageCacheManager.instance;

  //捕获全局平台错误
  final previousPlatformErrorHandler = PlatformDispatcher.instance.onError;
  //特殊处理图片缓存的只读数据库错误
  PlatformDispatcher.instance.onError = (error, stack) {
    if (SHOImageCacheManager.isReadonlyDbError(error)) {
      unawaited(
        //特殊处理图片缓存的只读数据库错误
        SHOImageCacheManager.recoverFromReadonlyError(error: error),
      );
      return true;
    }
    return previousPlatformErrorHandler?.call(error, stack) ?? false;
  };

  //初始化 SharedPreferences(持久化存储)
  final sharedPreferences = await SharedPreferences.getInstance();
  //准备运行时环境(环境切换、配置刷新等)
  await prepareRuntimeAfterEnvChange(sharedPreferences);
  //标记 Bootstrap 阶段结束
  SHOAppStartupTimer.markBootstrapEnd();

  //环境重建: SHOAppRestart 支持在 Debug 模式下重建 Provider 树
  //状态保持: SharedPreferences 作为参数传递,避免重复初始化
  //✅ 热重启: Debug 模式下支持环境切换后自动重建
  //✅ 状态共享: SharedPreferences 实例在整个应用生命周期中共享
  runApp(SHOAppRestart(sharedPreferences: sharedPreferences));
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
