import 'package:flutter/foundation.dart';

import '../config/hos_config.dart';
import '../config/hos_environment.dart';
import '../constants/hos_constants.dart';
import 'hos_log_manager.dart';

/// 启动时输出当前有效配置（上下分隔线便于筛选）。
abstract final class SHOStartupConfigLog {
  static const _border =
      '════════════════════ SHOO CONFIG ════════════════════';

  static void printEffective({
    required SHOAppConfig base,
    SHOAppEnvironment? envOverride,
  }) {
    final env = envOverride ?? base.environment;
    final effective = base.isDebugPanelEnabled && envOverride != null
        ? base.copyWith(
            environment: envOverride,
            apiBaseUrl: SHOAppConfig.defaultApiBaseUrl(envOverride),
            useMockApi: envOverride != SHOAppEnvironment.prod &&
                !envOverride.usesLocalServer,
            enableNetworkLogging: !envOverride.isProd,
          )
        : base;

    final buffer = StringBuffer()
      ..writeln(_border)
      ..writeln('[SHOO STARTUP CONFIG]')
      ..writeln('appName: ${SHOAppConstants.appName}')
      ..writeln('version: ${SHOAppConstants.appVersion}')
      ..writeln('buildMode: ${kReleaseMode ? 'release' : 'debug'}')
      ..writeln('environment: ${env.label} (${env.badgeLabel})')
      ..writeln('envOverride: ${envOverride?.name ?? 'none'}')
      ..writeln('apiBaseUrl: ${effective.apiBaseUrl}')
      ..writeln('useMockApi: ${effective.useMockApi}')
      ..writeln('mockNetworkDelayMs: ${effective.mockNetworkDelay.inMilliseconds}')
      ..writeln('enableNetworkLogging: ${effective.enableNetworkLogging}')
      ..writeln('debugPanelEnabled: ${effective.isDebugPanelEnabled}')
      ..writeln(_border);

    final text = buffer.toString();
    // ignore: avoid_print
    print(text);
    SHOAppLogManager.instance.append('INFO', text);
  }
}
