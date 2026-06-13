import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../app/hos_shoo_app.dart';
import '../../config/hos_config.dart';
import '../../logging/hos_remote_log_client.dart';
import '../../logging/hos_remote_log_uploader.dart';
import '../../logging/hos_startup_config_log.dart';
import '../../storage/hos_local_storage.dart';
import '../modules/network_log/hos_debug_network_log_config_bridge.dart';
import 'hos_debug_config_repository.dart';
import 'hos_debug_prefs.dart';

/// Debug 环境切换后重建 [ProviderScope]，使 Dio / 路由等依赖新配置重新初始化。
/// SHOAppRestart 是一个 应用重启管理器，专门用于 Debug 模式下的环境热切换。
/// 它通过重建 ProviderScope 来重新初始化整个应用状态树，而无需重启应用进程
/*
核心职责
环境热切换 - 在 Debug 模式下动态切换 API 环境
Provider 树重建 - 强制重新创建所有 Provider 实例
配置刷新 - 在重建前更新所有运行时配置
用户体验 - 提供加载遮罩，避免界面闪烁
*/
class SHOAppRestart extends StatefulWidget {
  const SHOAppRestart({super.key, required this.sharedPreferences});

  final SharedPreferences sharedPreferences;

  // 提供全局静态方法 requestRestart() 供外部调用
  static void requestRestart() {
    _state?._restart();
  }

  static _SHOAppRestartState? _state;

  @override
  State<SHOAppRestart> createState() => _SHOAppRestartState();
}

class _SHOAppRestartState extends State<SHOAppRestart> {
  Key _scopeKey = UniqueKey();
  bool _restarting = false;

  @override
  void initState() {
    super.initState();
    SHOAppRestart._state = this;
  }

  @override
  void dispose() {
    if (SHOAppRestart._state == this) {
      SHOAppRestart._state = null;
    }
    super.dispose();
  }

  Future<void> _restart() async {
    if (_restarting) return; // 防止重复触发
    setState(() => _restarting = true);
    // 1. 清理资源
    await _cleanupResources();
    // 2. 刷新配置
    await prepareRuntimeAfterEnvChange(widget.sharedPreferences);
    //生命周期检查: if (!mounted) return 避免内存泄漏
    // 3. 重建 UI
    if (!mounted) return;
    setState(() {
      //强制重建: UniqueKey() 触发 Widget 树完全重建
      _scopeKey = UniqueKey();
      _restarting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    //确保文本方向一致性
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Stack(
        fit: StackFit.expand,
        children: [
          //ProviderScope 是 Riverpod 状态管理库中的核心组件
          //ProviderScope 是 Riverpod 中所有 Provider 的“生存空间”，相当于一个全局容器，存放了所有 Provider 的状态。
          //没有它，任何 ref.watch 或 ref.read 都无法工作
          ProviderScope(
            // 通过改变 key 触发重建
            key: _scopeKey,
            // 避免重复初始化 SharedPreferences
            overrides: [
              // → 替换默认实现
              // → 直接返回 widget.sharedPreferences 实例
              // → 所有依赖这个 Provider 的地方都使用同一个实例
              sharedPreferencesProvider.overrideWithValue(
                widget.sharedPreferences,
              ),
            ],
            // 编译时(全局唯一）实例不重建，内部 Widget 重建
            child: const SHOApp(),
          ),
          // 加载遮罩
          if (_restarting)
            const Positioned.fill(
              child: ColoredBox(
                color: Color(0x99000000),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _cleanupResources() async {
    // 清理网络连接
    // 清理临时文件
    // 重置缓存
  }
}

/// 环境变更后刷新静态桥接与启动配置日志（在重建 Provider 树之前调用）。
Future<void> prepareRuntimeAfterEnvChange(SharedPreferences prefs) async {
  // 1. 更新网络日志配置
  if (SHOAppConfig.instance.isDebugPanelEnabled) {
    final networkLogConfig = await SHODebugConfigRepository(
      SHOLocalStorage(prefs),
      debugEnabled: true,
    ).loadNetworkLogConfig();
    SHODebugNetworkLogConfigBridge.update(networkLogConfig);
  }
  // 2. 读取环境覆盖配置
  final envOverride = SHODebugPrefs(prefs).readEnvOverride();
  SHOStartupConfigLog.printEffective(
    base: SHOAppConfig.instance,
    envOverride: envOverride,
  );
  // 3. 打印有效配置日志
  SHORemoteLogClient.reset();
  // 4. 重置远程日志客户端
  SHORemoteLogUploader.resetWarnings();
}

/*
// ✅ 优点
child: const SHOApp()
  - 编译时创建，性能最优
  - 内存占用最小
  - 父 Widget 重建时不重建
  - 符合 Flutter 最佳实践

// ⚠️ 注意
  - Widget 必须有 const 构造函数
  - 所有参数必须是编译时常量
  - 内部状态变化时仍会重建（因为 Provider 变化）
*/

/*
// ⚠️ 缺点
child: SHOApp()
  - 运行时创建，性能稍差
  - 内存占用较大
  - 父 Widget 重建时重建
  - 不符合 Flutter 最佳实践

// ✅ 优点（极少数情况）
  - 可以传递运行时参数
  - 更灵活（但这里不需要）
*/

/*
SHOAppRestart 是一个精心设计的应用重启管理器，它通过以下技术手段实现了优雅的环境热切换：

核心设计思想
静态状态引用 - 提供全局访问点
UniqueKey 重建 - 强制重建整个 Provider 树
异步配置刷新 - 确保配置一致性
加载遮罩 - 提供良好的用户体验
*/

/*
实际执行流程:
环境切换 → ProviderScope 重建（key 改变）
              ↓
          const SHOApp() 实例不重建（复用）
              ↓
          SHOApp.build() 执行（因为 ProviderScope 变化）
              ↓
          ref.watch(routerProvider) → 新的 router
          ref.watch(themeModeProvider) → 新的 themeMode
              ↓
          MaterialApp.router 重建（因为参数变化）
              ↓
          UI 更新

*/

/*

┌─────────────────────────────────────────────────────────────┐
│                    SHOAppRestart 架构                        │
└─────────────────────────────────────────────────────────────┘

┌──────────────────┐
│  外部调用者       │
│  (环境切换)       │
└────────┬─────────┘
         │
         │ SHOAppRestart.requestRestart()
         ▼
┌─────────────────────────────────────────────────────────────┐
│                    SHOAppRestart (StatefulWidget)           │
├─────────────────────────────────────────────────────────────┤
│  静态状态管理                                                 │
│  ┌─────────────────────────────────────────────────────┐    │
│  │  static _state: _SHOAppRestartState?                │    │
│  │  static requestRestart() → _state._restart()         │    │
│  └─────────────────────────────────────────────────────┘    │
│                                                              │
│  生命周期管理                                                 │
│  ┌─────────────────────────────────────────────────────┐    │
│  │  initState() → 注册 _state                          │    │
│  │  dispose() → 清理 _state                            │    │
│  └─────────────────────────────────────────────────────┘    │
│                                                              │
│  重启逻辑                                                     │
│  ┌─────────────────────────────────────────────────────┐    │
│  │  _restart() {                                        │    │
│  │    1. 防抖检查                                       │    │
│  │    2. 显示加载遮罩                                   │    │
│  │    3. 刷新运行时配置                                 │    │
│  │    4. 重建 ProviderScope                            │    │
│  │    5. 隐藏加载遮罩                                   │    │
│  │  }                                                   │    │
│  └─────────────────────────────────────────────────────┘    │
│                                                              │
│  UI 结构                                                     │
│  ┌─────────────────────────────────────────────────────┐    │
│  │  Directionality                                     │    │
│  │    └─ Stack                                         │    │
│  │         ├─ ProviderScope (key: _scopeKey)           │    │
│  │         │    └─ SHOApp                              │    │
│  │         └─ Loading Overlay (if _restarting)         │    │
│  └─────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────┘
         │
         │ prepareRuntimeAfterEnvChange()
         ▼
┌─────────────────────────────────────────────────────────────┐
│              配置刷新流程                                     │
├─────────────────────────────────────────────────────────────┤
│  1. 更新网络日志配置 (Debug only)                            │
│  2. 读取环境覆盖设置                                         │
│  3. 打印有效配置日志                                         │
│  4. 重置远程日志客户端                                       │
└─────────────────────────────────────────────────────────────┘

*/