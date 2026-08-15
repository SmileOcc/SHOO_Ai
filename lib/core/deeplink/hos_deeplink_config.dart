/// 深链 / Universal Link / App Links 域名与 Scheme 配置。
abstract final class SHODeepLinkConfig {
  static const String scheme = 'shoo';
  static const String host = 'shoo.app';
  static const String universalLinkHost = 'shoo.app';

  /// iOS Associated Domains 条目（暂不写入 entitlements，仅作配置约定）。
  /// 正式上线时在 Runner.entitlements 增加：
  /// `applinks:shoo.app` / `applinks:www.shoo.app`
  static const List<String> associatedDomains = [
    'applinks:shoo.app',
    'applinks:www.shoo.app',
  ];

  /// Android App Links / iOS Universal Link 支持的 HTTPS Host。
  static const List<String> appLinkHosts = [
    universalLinkHost,
    'www.$universalLinkHost',
  ];

  static Uri productLink(String productId) =>
      Uri.parse('https://$host/product/$productId');

  static Uri productListLink({required String leafId, required String title}) {
    final query = Uri(
      queryParameters: {'leafId': leafId, 'title': title},
    ).query;
    return Uri.parse('https://$host/category/products?$query');
  }

  static Uri ordersLink() => Uri.parse('https://$host/orders');

  static Uri profileLink() => Uri.parse('https://$host/profile');

  static Uri activityLink() => Uri.parse('https://$host/activity');

  static Uri orderLink(String orderId) =>
      Uri.parse('https://$host/orders/$orderId');

  static bool isSupportedHost(String host) {
    final lower = host.toLowerCase();
    return appLinkHosts.any((h) => h == lower);
  }

  /// 是否为 `https://shoo.app/...` App Link / Universal Link。
  static bool isAppLinkUri(Uri uri) {
    final scheme = uri.scheme.toLowerCase();
    if (scheme != 'https' && scheme != 'http') return false;
    return isSupportedHost(uri.host);
  }

  /// 是否为 `shoo://...` Custom Scheme。
  static bool isCustomSchemeUri(Uri uri) =>
      uri.scheme.toLowerCase() == scheme;
}
