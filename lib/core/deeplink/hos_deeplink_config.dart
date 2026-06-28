/// 深链 / Universal Link 域名与 Scheme 配置。
abstract final class SHODeepLinkConfig {
  static const String scheme = 'shoo';
  static const String host = 'shoo.app';
  static const String universalLinkHost = 'shoo.app';

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
    return host == universalLinkHost || host == 'www.$universalLinkHost';
  }
}
