/// Debug 网络实验室配置。
class SHODebugNetworkLabConfig {
  const SHODebugNetworkLabConfig({
    this.enableCustomInterceptor = false,
    this.customHeaderKey = 'X-Debug-Custom',
    this.customHeaderValue = 'shoo-debug-lab',
    this.customDelayMs = 0,
    this.customInsertBeforeAuth = true,
  });

  final bool enableCustomInterceptor;
  final String customHeaderKey;
  final String customHeaderValue;
  final int customDelayMs;
  final bool customInsertBeforeAuth;

  SHODebugNetworkLabConfig copyWith({
    bool? enableCustomInterceptor,
    String? customHeaderKey,
    String? customHeaderValue,
    int? customDelayMs,
    bool? customInsertBeforeAuth,
  }) {
    return SHODebugNetworkLabConfig(
      enableCustomInterceptor:
          enableCustomInterceptor ?? this.enableCustomInterceptor,
      customHeaderKey: customHeaderKey ?? this.customHeaderKey,
      customHeaderValue: customHeaderValue ?? this.customHeaderValue,
      customDelayMs: customDelayMs ?? this.customDelayMs,
      customInsertBeforeAuth:
          customInsertBeforeAuth ?? this.customInsertBeforeAuth,
    );
  }
}
