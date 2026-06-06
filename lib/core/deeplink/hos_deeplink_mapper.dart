import '../../app/router/hos_routes.dart';
import 'hos_deeplink_config.dart';

/// 将外部 URI（Custom Scheme / Universal Link）映射为 go_router 路径。
abstract final class SHODeepLinkMapper {
  /// 活动弹窗 / Banner 等 in-app 链接，如 `/flash-sale`、`/product/p-1`。
  static String? linkToAppPath(String link) {
    final trimmed = link.trim();
    if (trimmed.isEmpty) return null;
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return toAppPath(Uri.parse(trimmed));
    }
    final path = trimmed.startsWith('/') ? trimmed : '/$trimmed';
    return toAppPath(Uri(path: path));
  }

  static String? toAppPath(Uri uri) {
    final segments = _pathSegments(uri);
    if (segments.isEmpty) return SHOAppRoutes.home;

    switch (segments.first) {
      case 'product':
        if (segments.length >= 2) {
          final id = segments[1];
          if (segments.length >= 3 && segments[2] == 'reviews') {
            return SHOAppRoutes.productReviews(id);
          }
          return SHOAppRoutes.product(id);
        }
      case 'orders':
        if (segments.length >= 2) {
          final id = segments[1];
          if (segments.length >= 3 && segments[2] == 'logistics') {
            return SHOAppRoutes.orderLogistics(id);
          }
          return SHOAppRoutes.order(id);
        }
      case 'payment':
        if (segments.length >= 2) {
          return SHOAppRoutes.payment(segments[1]);
        }
      case 'after-sales':
        if (segments.length >= 3 && segments[1] == 'apply') {
          return SHOAppRoutes.afterSaleApply(segments[2]);
        }
        return SHOAppRoutes.afterSales;
      case 'search':
        final q = uri.queryParameters['q'];
        return q == null ? SHOAppRoutes.search : '${SHOAppRoutes.search}?q=$q';
      case 'login':
        final redirect = uri.queryParameters['redirect'];
        if (redirect != null && redirect.isNotEmpty) {
          return '${SHOAppRoutes.login}?redirect=$redirect';
        }
        return SHOAppRoutes.login;
      case 'flash-sale':
        return '${SHOAppRoutes.search}?q=flash%20sale';
      case 'new-arrivals':
        return '${SHOAppRoutes.search}?q=new%20arrivals';
      case 'trending':
        return '${SHOAppRoutes.search}?q=trending';
      case 'cart':
        return SHOAppRoutes.cart;
      case 'category':
        return SHOAppRoutes.category;
      case 'profile':
        return SHOAppRoutes.profile;
      case 'checkout':
        return SHOAppRoutes.checkout;
      case 'coupons':
        return uri.queryParameters['select'] == '1'
            ? SHOAppRoutes.couponsSelect
            : SHOAppRoutes.coupons;
    }

    return null;
  }

  static List<String> _pathSegments(Uri uri) {
    if (uri.scheme.isEmpty) {
      return uri.pathSegments.where((s) => s.isNotEmpty).toList();
    }
    if (uri.scheme == SHODeepLinkConfig.scheme) {
      final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
      final host = uri.host;
      if (host.isNotEmpty && host != 'open') {
        return [host, ...segments];
      }
      return segments;
    }
    if (uri.scheme == 'https' || uri.scheme == 'http') {
      if (!SHODeepLinkConfig.isSupportedHost(uri.host)) return [];
      return uri.pathSegments.where((s) => s.isNotEmpty).toList();
    }
    return [];
  }
}
