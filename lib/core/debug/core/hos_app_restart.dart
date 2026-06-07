import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../config/hos_config.dart';
import '../../logging/hos_remote_log_client.dart';
import '../../logging/hos_remote_log_uploader.dart';
import '../../logging/hos_startup_config_log.dart';
import '../../storage/hos_local_storage.dart';
import '../modules/network_log/hos_debug_network_log_config_bridge.dart';
import 'hos_debug_config_repository.dart';
import 'hos_debug_prefs.dart';
import '../../../app/hos_shoo_app.dart';

/// Debug 环境切换后重建 [ProviderScope]，使 Dio / 路由等依赖新配置重新初始化。
class SHOAppRestart extends StatefulWidget {
  const SHOAppRestart({super.key, required this.sharedPreferences});

  final SharedPreferences sharedPreferences;

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
    if (_restarting) return;
    setState(() => _restarting = true);
    await prepareRuntimeAfterEnvChange(widget.sharedPreferences);
    if (!mounted) return;
    setState(() {
      _scopeKey = UniqueKey();
      _restarting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ProviderScope(
            key: _scopeKey,
            overrides: [
              sharedPreferencesProvider.overrideWithValue(widget.sharedPreferences),
            ],
            child: const SHOApp(),
          ),
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
}

/// 环境变更后刷新静态桥接与启动配置日志（在重建 Provider 树之前调用）。
Future<void> prepareRuntimeAfterEnvChange(SharedPreferences prefs) async {
  if (SHOAppConfig.instance.isDebugPanelEnabled) {
    final networkLogConfig = await SHODebugConfigRepository(
      SHOLocalStorage(prefs),
      debugEnabled: true,
    ).loadNetworkLogConfig();
    SHODebugNetworkLogConfigBridge.update(networkLogConfig);
  }
  final envOverride = SHODebugPrefs(prefs).readEnvOverride();
  SHOStartupConfigLog.printEffective(
    base: SHOAppConfig.instance,
    envOverride: envOverride,
  );
  SHORemoteLogClient.reset();
  SHORemoteLogUploader.resetWarnings();
}
