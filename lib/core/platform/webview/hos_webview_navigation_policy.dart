/// WebView 内链接导航策略。
enum SHOWebViewNavigationPolicy {
  /// 活动页：仅白名单域名在 WebView 内继续浏览。
  whitelist,

  /// 通用 Web：http/https 均在应用内打开（支付等特殊 scheme 仍走系统）。
  inApp,
}
