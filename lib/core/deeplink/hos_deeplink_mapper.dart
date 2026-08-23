import 'package:shoo/app/router/hos_routes.dart';
import 'package:shoo/core/deeplink/hos_deeplink_config.dart';

/// 将外部 URI（Custom Scheme / Universal Link）映射为 go_router 路径。
abstract final class SHODeepLinkMapper {
  /// 归一化链接字符串为 [Uri]（保留 query）。
  ///
  /// 支持：
  /// - `https://shoo.app/...` / `shoo://...`
  /// - `shoo.app/category/products?leafId=...`（无 scheme 的 host 形式）
  /// - `/category/products?leafId=...` 或 `category/products?leafId=...`
  static Uri? parseLink(String link) {
    final trimmed = link.trim();
    if (trimmed.isEmpty) return null;

    if (trimmed.startsWith('http://') ||
        trimmed.startsWith('https://') ||
        trimmed.startsWith('${SHODeepLinkConfig.scheme}://')) {
      return Uri.tryParse(trimmed);
    }

    if (trimmed.startsWith('/')) {
      return Uri.tryParse(trimmed);
    }

    final hostCandidate = trimmed.split('/').first.split('?').first;
    if (SHODeepLinkConfig.isSupportedHost(hostCandidate)) {
      return Uri.tryParse('https://$trimmed');
    }

    return Uri.tryParse('/$trimmed');
  }

  /// 活动弹窗 / Banner 等 in-app 链接，如 `/flash-sale`、`/product/p-1`。
  static String? linkToAppPath(String link) {
    final uri = parseLink(link);
    if (uri == null) return null;
    return toAppPath(uri);
  }

  static String? toAppPath(Uri uri) {
    final segments = _pathSegments(uri);
    if (segments.isEmpty) {
      return _isAppUri(uri) ? SHOAppRoutes.home : null;
    }

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
        return SHOAppRoutes.orders;
      case 'category':
        if (segments.length >= 2 && segments[1] == 'products') {
          final leafId = uri.queryParameters['leafId'] ?? '';
          final title = uri.queryParameters['title'] ?? '商品列表';
          return SHOAppRoutes.categoryProductsFiltered(
            leafId: leafId,
            title: title,
          );
        }
        return SHOAppRoutes.category;
      case 'activity':
        return SHOAppRoutes.activity;
      case 'webview':
        final url = uri.queryParameters['url'];
        if (url != null && url.isNotEmpty) {
          final title = uri.queryParameters['title'];
          return SHOAppRoutes.webviewFor(url, title: title);
        }
        return null;
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
        final activityId = uri.queryParameters['activityId'];
        if (activityId != null && activityId.isNotEmpty) {
          return SHOAppRoutes.flashSaleFor(activityId: activityId);
        }
        return SHOAppRoutes.flashSale;
      case 'theme-activity':
        if (segments.length >= 2) {
          return SHOAppRoutes.themeActivityFor(
            segments[1],
            channel: uri.queryParameters['channel'],
          );
        }
        return SHOAppRoutes.toolboxThemeActivity;
      case 'new-arrivals':
        return '${SHOAppRoutes.search}?q=new%20arrivals';
      case 'trending':
        return '${SHOAppRoutes.search}?q=trending';
      case 'cart':
        return SHOAppRoutes.cart;
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

  /// 是否为应用内可识别的 URI（shoo.app / shoo:// / 相对路径）。
  static bool _isAppUri(Uri uri) {
    if (uri.scheme.isEmpty) return true;
    if (uri.scheme == SHODeepLinkConfig.scheme) return true;
    if (uri.scheme == 'https' || uri.scheme == 'http') {
      return SHODeepLinkConfig.isSupportedHost(uri.host);
    }
    return false;
  }
}
