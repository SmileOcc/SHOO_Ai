import 'package:shoo/app/router/hos_routes.dart';
import 'package:shoo/core/deeplink/hos_deeplink_action_type.dart';
import 'package:shoo/core/deeplink/hos_deeplink_config.dart';
import 'package:shoo/core/deeplink/hos_deeplink_link_kind.dart';
import 'package:shoo/core/deeplink/hos_deeplink_mapper.dart';
import 'package:shoo/core/deeplink/hos_deeplink_target.dart';

/// 将 Deep Link 字符串解析为带鉴权标记的导航目标。
abstract final class SHODeepLinkResolver {
  static SHODeepLinkTarget? resolveLink(String link) {
    final trimmed = link.trim();
    if (trimmed.isEmpty) return null;

    final uri = SHODeepLinkMapper.parseLink(trimmed);
    if (uri == null) return null;

    return resolveUri(uri, rawLink: trimmed);
  }

  static SHODeepLinkTarget? resolveUri(Uri uri, {String? rawLink}) {
    final appPath = SHODeepLinkMapper.toAppPath(uri);
    if (appPath == null || appPath.isEmpty) return null;

    final type = _actionTypeFromUri(uri, appPath);
    final requiresAuth = _requiresAuth(type, appPath);

    return SHODeepLinkTarget(
      type: type,
      appPath: appPath,
      requiresAuth: requiresAuth,
      linkKind: linkKindOf(uri),
      rawLink: rawLink ?? uri.toString(),
    );
  }

  static bool isDeepLink(String url) => resolveLink(url) != null;

  /// 识别链接形态：App Link / Custom Scheme / 应用内路径。
  static SHODeepLinkLinkKind linkKindOf(Uri uri) {
    if (SHODeepLinkConfig.isAppLinkUri(uri)) {
      return SHODeepLinkLinkKind.appLink;
    }
    if (SHODeepLinkConfig.isCustomSchemeUri(uri)) {
      return SHODeepLinkLinkKind.customScheme;
    }
    return SHODeepLinkLinkKind.inAppPath;
  }

  static SHODeepLinkActionType _actionTypeFromUri(Uri uri, String appPath) {
    final segments = _segments(uri);
    if (segments.isEmpty) return SHODeepLinkActionType.home;

    switch (segments.first) {
      case 'product':
        return SHODeepLinkActionType.productDetail;
      case 'category':
        if (segments.length >= 2 && segments[1] == 'products') {
          return SHODeepLinkActionType.productList;
        }
        return SHODeepLinkActionType.category;
      case 'orders':
        return segments.length >= 2
            ? SHODeepLinkActionType.orderDetail
            : SHODeepLinkActionType.orders;
      case 'payment':
        return SHODeepLinkActionType.payment;
      case 'after-sales':
        return SHODeepLinkActionType.afterSales;
      case 'search':
        return SHODeepLinkActionType.search;
      case 'login':
        return SHODeepLinkActionType.login;
      case 'cart':
        return SHODeepLinkActionType.cart;
      case 'profile':
        return SHODeepLinkActionType.profile;
      case 'checkout':
        return SHODeepLinkActionType.checkout;
      case 'coupons':
        return SHODeepLinkActionType.coupons;
      case 'activity':
        return SHODeepLinkActionType.activity;
      case 'webview':
        return SHODeepLinkActionType.webview;
      case 'flash-sale':
        return SHODeepLinkActionType.flashSale;
      case 'new-arrivals':
        return SHODeepLinkActionType.newArrivals;
      case 'trending':
        return SHODeepLinkActionType.trending;
      default:
        if (appPath.startsWith(SHOAppRoutes.webview)) {
          return SHODeepLinkActionType.webview;
        }
        return SHODeepLinkActionType.unknown;
    }
  }

  static List<String> _segments(Uri uri) {
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

  static bool _requiresAuth(SHODeepLinkActionType type, String appPath) {
    const authTypes = {
      SHODeepLinkActionType.orders,
      SHODeepLinkActionType.orderDetail,
      SHODeepLinkActionType.payment,
      SHODeepLinkActionType.afterSales,
      SHODeepLinkActionType.checkout,
      SHODeepLinkActionType.coupons,
    };
    if (authTypes.contains(type)) return true;

    final pathOnly = Uri.parse(appPath).path;
    if (SHOAppRoutes.requiresAuth(pathOnly)) return true;
    return SHOAppRoutes.protectedPrefixes.any(pathOnly.startsWith);
  }
}
