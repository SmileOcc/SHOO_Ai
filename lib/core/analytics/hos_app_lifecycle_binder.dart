import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../logging/hos_startup_timing_log.dart';
import 'hos_analytics.dart';
import 'hos_app_startup_timer.dart';

/// 监听 App 生命周期：冷启动、进入后台、进程结束。
class SHOAppLifecycleBinder extends ConsumerStatefulWidget {
  const SHOAppLifecycleBinder({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<SHOAppLifecycleBinder> createState() =>
      _SHOAppLifecycleBinderState();
}

//WidgetsBindingObserver	Flutter 官方生命周期监听接口
// AppLifecycleListener (Flutter 3.13+)	✅ 更简洁	⚠️ 需要新版本 Flutter	新项目
class _SHOAppLifecycleBinderState extends ConsumerState<SHOAppLifecycleBinder>
    with WidgetsBindingObserver {
  static bool _launchReported = false;

  @override
  void initState() {
    super.initState();
    // ← 注册生命周期监听
    WidgetsBinding.instance.addObserver(this);
    // 在首帧渲染后执行，记录准确时间
    WidgetsBinding.instance.addPostFrameCallback((_) => _onFirstFrame());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _onFirstFrame() async {
    // ← 记录首帧渲染时间
    if (SHOAppStartupTimer.hasFirstFrame) return;
    SHOAppStartupTimer.markFirstFrame();
    await SHOStartupTimingLog.printAndTrack();
    await _reportLaunch();
  }

  Future<void> _reportLaunch() async {
    if (_launchReported) return;
    _launchReported = true;
    await SHOAnalyticsManager.instance.trackEvent(
      SHOAnalyticsRegistry.appLaunch,
      {
        'cold_start': true,
        'build_mode': kReleaseMode ? 'release' : 'debug',
      },
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // ← 处理生命周期变化
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        SHOAnalyticsManager.instance.trackEvent(
          SHOAnalyticsRegistry.appClose,
          {'reason': state.name},
        );
      case AppLifecycleState.resumed:
      case AppLifecycleState.inactive:
        break;
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
