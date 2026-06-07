/// Debug 网络日志配置（仅 Debug 包生效）。
class SHODebugNetworkLogConfig {
  const SHODebugNetworkLogConfig({
    this.enabled = true,
    this.logRequestParams = true,
    this.logResponseParams = true,
    this.filterPathsEnabled = false,
    this.pathFilters = '',
    this.useMockRemoteLog = true,
  });

  final bool enabled;
  final bool logRequestParams;
  final bool logResponseParams;
  final bool filterPathsEnabled;
  final String pathFilters;

  /// true：Mock 远程上报（仅本地模拟）；false：POST 到真实 API（本地 server）。
  final bool useMockRemoteLog;

  List<String> get parsedPathFilters => pathFilters
      .split(RegExp(r'[,\n]'))
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList();

  SHODebugNetworkLogConfig copyWith({
    bool? enabled,
    bool? logRequestParams,
    bool? logResponseParams,
    bool? filterPathsEnabled,
    String? pathFilters,
    bool? useMockRemoteLog,
  }) {
    return SHODebugNetworkLogConfig(
      enabled: enabled ?? this.enabled,
      logRequestParams: logRequestParams ?? this.logRequestParams,
      logResponseParams: logResponseParams ?? this.logResponseParams,
      filterPathsEnabled: filterPathsEnabled ?? this.filterPathsEnabled,
      pathFilters: pathFilters ?? this.pathFilters,
      useMockRemoteLog: useMockRemoteLog ?? this.useMockRemoteLog,
    );
  }

  Map<String, dynamic> toJson() => {
        'enabled': enabled,
        'logRequestParams': logRequestParams,
        'logResponseParams': logResponseParams,
        'filterPathsEnabled': filterPathsEnabled,
        'pathFilters': pathFilters,
        'useMockRemoteLog': useMockRemoteLog,
      };

  factory SHODebugNetworkLogConfig.fromJson(Map<String, dynamic> json) {
    return SHODebugNetworkLogConfig(
      enabled: json['enabled'] as bool? ?? true,
      logRequestParams: json['logRequestParams'] as bool? ?? true,
      logResponseParams: json['logResponseParams'] as bool? ?? true,
      filterPathsEnabled: json['filterPathsEnabled'] as bool? ?? false,
      pathFilters: json['pathFilters'] as String? ?? '',
      useMockRemoteLog: json['useMockRemoteLog'] as bool? ?? false,
    );
  }
}
