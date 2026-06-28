import 'package:shoo/app/router/hos_routes.dart';

/// 将 H5 / Deep Link URL 映射为 GoRouter 路径。
abstract final class SHOWebViewRouteMapper {
  static String? toAppRoute(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return null;

    if (uri.scheme == 'https' && uri.host == 'shoo.app') {
      return _mapPath(uri.path);
    }

    if (uri.scheme.isEmpty || uri.host.isEmpty) {
      return _mapPath(uri.path.isNotEmpty ? uri.path : url);
    }

    return null;
  }

  static String? _mapPath(String path) {
    final segments = path
        .split('/')
        .where((s) => s.isNotEmpty)
        .toList(growable: false);
    if (segments.isEmpty) return null;

    if (segments.length >= 2 && segments[0] == 'product') {
      return SHOAppRoutes.product(segments[1]);
    }
    if (segments.length == 1 && segments[0] == 'activity') {
      return SHOAppRoutes.activity;
    }
    if (path.startsWith('/orders/') && segments.length >= 2) {
      return SHOAppRoutes.order(segments[1]);
    }
    // 个人中心映射：/personal → /profile
    if (segments.length == 1 && segments[0] == 'personal') {
      return SHOAppRoutes.profile;
    }
    if (path.startsWith('/')) return path;
    return null;
  }
}
