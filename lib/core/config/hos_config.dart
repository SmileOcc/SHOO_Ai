import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shoo/app/root/hos_runtime_env_provider.dart';
import 'package:shoo/core/config/hos_environment.dart';
import 'package:shoo/core/constants/hos_constants.dart';
import 'package:shoo/core/network/security/hos_security_level.dart';

/// 全局运行时配置类，管理应用的核心配置参数。
///
/// **设计要点：**
/// - 采用单例模式，通过 [SHOAppConfig.instance] 全局访问
/// - 启动时通过 [init] 方法初始化，支持通过 `--dart-define` 传递参数
/// - Release 模式下自动禁用 Debug 面板和网络日志
/// - 支持运行时动态切换环境（仅 Debug 模式）
///
/// **配置参数来源优先级：**
/// 1. 命令行参数（--dart-define）
/// 2. 环境默认值
/// 3. 硬编码常量
class SHOAppConfig {
  /// 创建配置实例
  ///
  /// [environment]: 当前运行环境（dev/local/staging/prod）
  /// [apiBaseUrl]: API 请求基础地址
  /// [useMockApi]: 是否启用 Mock API（绕过真实接口）
  /// [mockNetworkDelay]: Mock 数据的模拟网络延迟
  /// [enableNetworkLogging]: 是否打印网络请求日志
  /// [isDebugPanelEnabled]: 是否启用 Debug 面板
  /// [securityLevel]: 安全级别配置
  SHOAppConfig({
    required this.environment,
    required this.apiBaseUrl,
    required this.useMockApi,
    required this.mockNetworkDelay,
    required this.enableNetworkLogging,
    required this.isDebugPanelEnabled,
    required this.securityLevel,
  });

  /// 当前运行环境（开发/本地/预发/生产）
  final SHOAppEnvironment environment;

  /// API 请求基础 URL
  final String apiBaseUrl;

  /// 是否启用 Mock API（用于前端独立开发）
  final bool useMockApi;

  /// Mock 数据的模拟网络延迟（模拟真实网络响应时间）
  final Duration mockNetworkDelay;

  /// 是否打印网络请求日志（请求/响应详情）
  final bool enableNetworkLogging;

  /// 是否启用 Debug 面板（包含环境切换、日志查看等调试功能）
  final bool isDebugPanelEnabled;

  /// 安全级别（basic/standard/high），决定加密、签名等安全策略
  final SHOSecurityLevel securityLevel;

  /// 全局单例实例，应用启动后初始化
  static late SHOAppConfig instance;

  /// 解析 Debug 面板是否启用
  ///
  /// **禁用条件（满足任一）：**
  /// - Release 模式（kReleaseMode == true）
  /// - 命令行参数 `--dart-define=DISABLE_DEBUG_PANEL=true`
  ///
  /// **设计意图：** 防止 Release 包中意外暴露调试功能
  static bool _resolveDebugPanelEnabled() {
    // 从命令行获取强制禁用标志
    const forceDisable = bool.fromEnvironment(
      'DISABLE_DEBUG_PANEL',
      defaultValue: false,
    );
    // Release 模式或强制禁用时返回 false
    if (kReleaseMode || forceDisable) return false;
    return true;
  }

  /// 初始化全局配置（应用启动时调用）
  ///
  /// **支持的命令行参数：**
  /// - `--dart-define=ENV=dev|local|staging|prod` - 指定运行环境
  /// - `--dart-define=USE_MOCK_API=true|false` - 是否启用 Mock
  /// - `--dart-define=API_BASE_URL=https://xxx` - 自定义 API 地址
  /// - `--dart-define=MOCK_DELAY_MS=600` - Mock 延迟（毫秒）
  /// - `--dart-define=SECURITY_LEVEL=basic|standard|high` - 安全级别
  /// - `--dart-define=DISABLE_DEBUG_PANEL=true` - 强制禁用 Debug 面板
  static Future<void> init() async {
    // 1. 从命令行参数读取配置（带默认值）
    const envRaw = String.fromEnvironment('ENV', defaultValue: '');
    const useMockRaw = String.fromEnvironment(
      'USE_MOCK_API',
      defaultValue: 'true',
    );
    const apiBaseUrlRaw = String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: '',
    );
    const mockDelayMs = int.fromEnvironment('MOCK_DELAY_MS', defaultValue: 600);
    const securityRaw = String.fromEnvironment(
      'SECURITY_LEVEL',
      defaultValue: 'standard',
    );

    // 2. 解析环境枚举 （显示环境 prod)
    final environment = envRaw.isEmpty
        ? (kReleaseMode ? SHOAppEnvironment.prod : SHOAppEnvironment.dev)
        : SHOAppEnvironment.fromString(envRaw);
    
    // 3. 确定是否使用 Mock（local 环境强制使用真实接口）
    final useMockApi = environment.usesLocalServer
        ? false
        : useMockRaw.toLowerCase() == 'true';

    // 4. 确定 API 地址（优先使用命令行参数，否则使用环境默认值）
    final apiBaseUrl = apiBaseUrlRaw.isNotEmpty
        ? apiBaseUrlRaw
        : defaultApiBaseUrl(environment);

    // 5. 解析安全级别
    final securityLevel = _resolveSecurityLevel(securityRaw, environment);

    // 6. 创建单例实例
    instance = SHOAppConfig(
      environment: environment,
      apiBaseUrl: apiBaseUrl,
      useMockApi: useMockApi,
      mockNetworkDelay: Duration(milliseconds: mockDelayMs),
      enableNetworkLogging: !environment.isProd, // 生产环境禁用日志
      isDebugPanelEnabled: _resolveDebugPanelEnabled(),
      securityLevel: securityLevel,
    );
  }

  /// 解析安全级别配置
  ///
  /// [raw]: 命令行传入的字符串值
  /// [environment]: 当前环境
  ///
  /// **解析逻辑：**
  /// 1. 优先使用命令行传入的值
  /// 2. 解析失败时，生产环境默认 standard，其他环境默认 basic
  static SHOSecurityLevel _resolveSecurityLevel(
    String raw,
    SHOAppEnvironment environment,
  ) {
    // 查找匹配的枚举值
    final parsed = SHOSecurityLevel.values
        .where((e) => e.name == raw)
        .firstOrNull;
    if (parsed != null) return parsed;

    // 默认策略：生产环境使用标准安全级别，开发环境使用基础级别
    return environment.isProd
        ? SHOSecurityLevel.standard
        : SHOSecurityLevel.basic;
  }

  /// 根据环境获取默认 API 基础 URL
  ///
  /// 使用 switch expression 实现环境与 URL 的映射
  static String defaultApiBaseUrl(SHOAppEnvironment env) => switch (env) {
    SHOAppEnvironment.dev => SHOAppConstants.defaultDevApiBaseUrl,
    SHOAppEnvironment.local => SHOAppConstants.defaultLocalApiBaseUrl,
    SHOAppEnvironment.staging => SHOAppConstants.defaultStagingApiBaseUrl,
    SHOAppEnvironment.prod => SHOAppConstants.defaultProdApiBaseUrl,
  };

  /// 创建配置副本，支持部分字段修改
  ///
  /// 用于 Debug 面板切换环境时创建临时配置
  SHOAppConfig copyWith({
    SHOAppEnvironment? environment,
    String? apiBaseUrl,
    bool? useMockApi,
    Duration? mockNetworkDelay,
    bool? enableNetworkLogging,
    bool? isDebugPanelEnabled,
    SHOSecurityLevel? securityLevel,
  }) {
    return SHOAppConfig(
      environment: environment ?? this.environment,
      apiBaseUrl: apiBaseUrl ?? this.apiBaseUrl,
      useMockApi: useMockApi ?? this.useMockApi,
      mockNetworkDelay: mockNetworkDelay ?? this.mockNetworkDelay,
      enableNetworkLogging: enableNetworkLogging ?? this.enableNetworkLogging,
      isDebugPanelEnabled: isDebugPanelEnabled ?? this.isDebugPanelEnabled,
      securityLevel: securityLevel ?? this.securityLevel,
    );
  }

  /// 返回配置的字符串表示（便于日志输出）
  @override
  String toString() =>
      'SHOAppConfig(env=${environment.label}, mock=$useMockApi, api=$apiBaseUrl, debug=$isDebugPanelEnabled)';
}

/// 运行时有效配置 Provider（支持 Debug 面板动态切换）
///
/// **工作机制：**
/// 1. 如果 Debug 面板未启用，直接返回基础配置
/// 2. 如果 Debug 面板已启用，监听 [runtimeEnvOverrideProvider]
/// 3. 当用户在 Debug 面板切换环境时，自动生成新的配置
///
/// **注意：** 运行时切换仅在 Debug 模式下生效，Release 模式始终使用启动时的配置
final effectiveConfigProvider = Provider<SHOAppConfig>((ref) {
  // 获取基础配置
  final base = SHOAppConfig.instance;

  // Debug 面板未启用时，直接返回基础配置
  if (!base.isDebugPanelEnabled) return base;

  // 监听运行时环境覆盖（Debug 面板切换）
  final override = ref.watch(runtimeEnvOverrideProvider);

  // 没有覆盖时返回基础配置
  if (override == null) return base;

  // 根据覆盖的环境生成新配置
  return base.copyWith(
    environment: override,
    apiBaseUrl: SHOAppConfig.defaultApiBaseUrl(override),
    useMockApi: override != SHOAppEnvironment.prod && !override.usesLocalServer,
    enableNetworkLogging: !override.isProd,
  );
});

/// 应用配置 Provider（便捷访问入口）
///
/// 直接返回 [effectiveConfigProvider] 的值，提供统一的配置访问点
final appConfigProvider = Provider<SHOAppConfig>(
  (ref) => ref.watch(effectiveConfigProvider),
);
