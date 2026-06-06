import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/hos_constants.dart';
import 'hos_environment.dart';

/// 全局运行时配置，启动时通过 [SHOAppConfig.init] 初始化。
///
/// 发布包：`kReleaseMode == true` 时 Debug 面板强制关闭，不读取调试配置。
class SHOAppConfig {
  SHOAppConfig({
    required this.environment,
    required this.apiBaseUrl,
    required this.useMockApi,
    required this.mockNetworkDelay,
    required this.enableNetworkLogging,
    required this.isDebugPanelEnabled,
  });

  final SHOAppEnvironment environment;
  final String apiBaseUrl;
  final bool useMockApi;
  final Duration mockNetworkDelay;
  final bool enableNetworkLogging;
  final bool isDebugPanelEnabled;

  static late SHOAppConfig instance;

  /// Release 包禁用 Debug 面板；可通过 `--dart-define=DISABLE_DEBUG_PANEL=true` 强制关闭。
  static bool _resolveDebugPanelEnabled() {
    const forceDisable =
        bool.fromEnvironment('DISABLE_DEBUG_PANEL', defaultValue: false);
    if (kReleaseMode || forceDisable) return false;
    return true;
  }

  static Future<void> init() async {
    const envRaw = String.fromEnvironment('ENV', defaultValue: 'dev');
    const useMockRaw = String.fromEnvironment('USE_MOCK_API', defaultValue: 'true');
    const apiBaseUrlRaw = String.fromEnvironment('API_BASE_URL', defaultValue: '');
    const mockDelayMs = int.fromEnvironment('MOCK_DELAY_MS', defaultValue: 600);

    final environment = SHOAppEnvironment.fromString(envRaw);
    final useMockApi = useMockRaw.toLowerCase() == 'true';
    final apiBaseUrl = apiBaseUrlRaw.isNotEmpty
        ? apiBaseUrlRaw
        : defaultApiBaseUrl(environment);

    instance = SHOAppConfig(
      environment: environment,
      apiBaseUrl: apiBaseUrl,
      useMockApi: useMockApi,
      mockNetworkDelay: Duration(milliseconds: mockDelayMs),
      enableNetworkLogging: !environment.isProd,
      isDebugPanelEnabled: _resolveDebugPanelEnabled(),
    );
  }

  static String defaultApiBaseUrl(SHOAppEnvironment env) => switch (env) {
        SHOAppEnvironment.dev => SHOAppConstants.defaultDevApiBaseUrl,
        SHOAppEnvironment.staging => SHOAppConstants.defaultStagingApiBaseUrl,
        SHOAppEnvironment.prod => SHOAppConstants.defaultProdApiBaseUrl,
      };

  SHOAppConfig copyWith({
    SHOAppEnvironment? environment,
    String? apiBaseUrl,
    bool? useMockApi,
    Duration? mockNetworkDelay,
    bool? enableNetworkLogging,
    bool? isDebugPanelEnabled,
  }) {
    return SHOAppConfig(
      environment: environment ?? this.environment,
      apiBaseUrl: apiBaseUrl ?? this.apiBaseUrl,
      useMockApi: useMockApi ?? this.useMockApi,
      mockNetworkDelay: mockNetworkDelay ?? this.mockNetworkDelay,
      enableNetworkLogging: enableNetworkLogging ?? this.enableNetworkLogging,
      isDebugPanelEnabled: isDebugPanelEnabled ?? this.isDebugPanelEnabled,
    );
  }

  @override
  String toString() =>
      'SHOAppConfig(env=${environment.label}, mock=$useMockApi, api=$apiBaseUrl, debug=$isDebugPanelEnabled)';
}

/// 运行时有效配置（Debug 面板可切换环境，仅 debug 模式生效）。
final effectiveConfigProvider = Provider<SHOAppConfig>((ref) {
  final base = SHOAppConfig.instance;
  if (!base.isDebugPanelEnabled) return base;

  final override = ref.watch(runtimeEnvOverrideProvider);
  if (override == null) return base;

  return base.copyWith(
    environment: override,
    apiBaseUrl: SHOAppConfig.defaultApiBaseUrl(override),
    useMockApi: override != SHOAppEnvironment.prod,
    enableNetworkLogging: !override.isProd,
  );
});

/// Debug 面板环境覆盖（Release 包不读取、不写入）。
final runtimeEnvOverrideProvider = StateProvider<SHOAppEnvironment?>((ref) => null);

final appConfigProvider = Provider<SHOAppConfig>((ref) => ref.watch(effectiveConfigProvider));
