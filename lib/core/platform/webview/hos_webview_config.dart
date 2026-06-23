/// WebView 打开模式。
enum SHOWebViewMode {
  /// 始终在应用内 WebView 打开 http/https。
  inApp,

  /// 始终在系统浏览器打开。
  systemBrowser,

  /// 由 [SHOWebViewService.shouldUseSystemBrowser] 自动判断。
  auto,
}

/// 缓存策略。
enum SHOWebViewCachePolicy { defaultPolicy, noCache, cacheFirst, cacheOnly }

/// URL 拦截类型。
enum SHOWebViewInterceptorType {
  override, // 覆盖/替换
  block, // 阻止/拦截
  navigateToNative, // 跳转到原生页面
}

/// JavaScript Channel 配置。
class SHOJavaScriptChannel {
  const SHOJavaScriptChannel({required this.name, this.onMessage});

  final String name;
  final void Function(String message)? onMessage;
}

/// URL 拦截器。
class SHOUrlInterceptor {
  const SHOUrlInterceptor({
    required this.pattern,
    this.type = SHOWebViewInterceptorType.override,
    this.handler,
  });

  final String pattern;
  final SHOWebViewInterceptorType type;
  final Future<bool> Function(String url)? handler;
}

/// Cookie 配置。
class SHOWebViewCookie {
  const SHOWebViewCookie({
    required this.name,
    required this.value,
    required this.domain,
    this.path = '/',
  });

  final String name;
  final String value;
  final String domain;
  final String path;
}

/// 通用 WebView 页面配置（对应技术方案 WebViewConfig）。
class SHOWebViewConfig {
  const SHOWebViewConfig({
    this.url = '',
    this.loadAsset,
    this.mode = SHOWebViewMode.inApp,
    this.showProgressBar = true,
    this.showAppBar = true,
    this.title,
    this.canGoBack = true,
    this.pullToRefresh = true,
    this.javascriptEnabled = true,
    this.debuggingEnabled = false,
    this.enableFlutterBridge = false,
    this.customHeaders,
    this.injectedJavaScript,
    this.cookies,
    this.interceptors,
    this.javaScriptChannels,
    this.timeout = 30000,
    this.cachePolicy = SHOWebViewCachePolicy.defaultPolicy,
  });

  final String url;
  final String? loadAsset;
  final SHOWebViewMode mode;
  final bool showProgressBar;
  final bool showAppBar;
  final String? title;
  final bool canGoBack;
  final bool pullToRefresh;
  final bool javascriptEnabled;
  final bool debuggingEnabled;
  final bool enableFlutterBridge;
  final Map<String, String>? customHeaders;
  final String? injectedJavaScript;
  final List<SHOWebViewCookie>? cookies;
  final List<SHOUrlInterceptor>? interceptors;
  final List<SHOJavaScriptChannel>? javaScriptChannels;
  final int timeout;
  final SHOWebViewCachePolicy cachePolicy;

  factory SHOWebViewConfig.simple(String url, {String? title}) {
    return SHOWebViewConfig(
      url: url,
      title: title,
      mode: SHOWebViewMode.inApp,
      interceptors: defaultInterceptors,
    );
  }

  /// 默认拦截：站内 Deep Link 跳转原生 GoRouter 页面。
  static const defaultInterceptors = <SHOUrlInterceptor>[
    SHOUrlInterceptor(
      pattern: 'shoo.app/product/',
      type: SHOWebViewInterceptorType.navigateToNative,
    ),
    SHOUrlInterceptor(
      pattern: '/product/',
      type: SHOWebViewInterceptorType.navigateToNative,
    ),
  ];

  /// 百宝箱 Web 调试页配置（本地 mock HTML）。
  factory SHOWebViewConfig.debug() {
    return SHOWebViewConfig(
      loadAsset: 'assets/webview/debug.html',
      title: 'WebView 功能调试',
      mode: SHOWebViewMode.inApp,
      pullToRefresh: true,
      debuggingEnabled: true,
      enableFlutterBridge: true,
      timeout: 30000,
      cookies: const [
        SHOWebViewCookie(
          name: 'debug_token',
          value: 'sho_debug_abc123',
          domain: 'localhost',
        ),
      ],
      interceptors: [
        SHOUrlInterceptor(
          pattern: 'old.example.com', // 匹配模式
          type: SHOWebViewInterceptorType.block, // 拦截类型
          handler: (url) async {
            print('加载url: $url');
            return false; // 允许加载
          },
        ),
        const SHOUrlInterceptor(
          pattern: '/personal',
          type: SHOWebViewInterceptorType.navigateToNative,
        ),
      ],
    );
  }

  /// 从 GoRouter query 解析（`/webview?url=...&title=...`）。
  factory SHOWebViewConfig.fromQueryParameters(Map<String, String> params) {
    return SHOWebViewConfig(
      url: params['url']?.trim() ?? '',
      title: _nullable(params['title']),
      mode: _parseMode(params['mode']),
      showProgressBar: _parseBool(
        params['showProgressBar'],
        defaultValue: true,
      ),
      showAppBar: _parseBool(params['showAppBar'], defaultValue: true),
      canGoBack: _parseBool(params['canGoBack'], defaultValue: true),
      pullToRefresh: _parseBool(params['pullToRefresh'], defaultValue: true),
      javascriptEnabled: _parseBool(
        params['javascriptEnabled'],
        defaultValue: true,
      ),
      debuggingEnabled: _parseBool(params['debugging'], defaultValue: false),
      timeout: int.tryParse(params['timeout'] ?? '') ?? 30000,
      interceptors: defaultInterceptors,
    );
  }

  static String? _nullable(String? value) {
    if (value == null || value.isEmpty) return null;
    return value;
  }

  static bool _parseBool(String? raw, {required bool defaultValue}) {
    if (raw == null || raw.isEmpty) return defaultValue;
    return raw == '1' || raw.toLowerCase() == 'true';
  }

  bool get hasContent =>
      url.trim().isNotEmpty || (loadAsset?.isNotEmpty ?? false);

  static SHOWebViewMode _parseMode(String? raw) {
    switch (raw?.toLowerCase()) {
      case 'system':
      case 'systembrowser':
        return SHOWebViewMode.systemBrowser;
      case 'auto':
        return SHOWebViewMode.auto;
      case 'inapp':
      default:
        return SHOWebViewMode.inApp;
    }
  }
}
