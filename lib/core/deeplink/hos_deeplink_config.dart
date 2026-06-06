/// 深链 / Universal Link 域名与 Scheme 配置。
abstract final class SHODeepLinkConfig {
  static const String scheme = 'shoo';
  static const String host = 'shoo.app';
  static const String universalLinkHost = 'shoo.app';

  static Uri productLink(String productId) =>
      Uri.parse('https://$host/product/$productId');

  static Uri orderLink(String orderId) => Uri.parse('https://$host/orders/$orderId');

  static bool isSupportedHost(String host) {
    return host == universalLinkHost || host == 'www.$universalLinkHost';
  }
}
