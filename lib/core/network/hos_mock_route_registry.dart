/// Mock API 路由注册表，新增接口只需注册一行。
///
/// ```dart
/// SHOMockRouteRegistry.register(
///   method: 'GET',
///   path: '/products/{id}',
///   asset: 'assets/mock/product_detail.json',
/// );
/// ```
class SHOMockRouteEntry {
  const SHOMockRouteEntry({
    required this.method,
    required this.path,
    required this.asset,
  });

  final String method;
  final String path;
  final String asset;
}

abstract final class SHOMockRouteRegistry {
  static final List<SHOMockRouteEntry> _routes = [
    const SHOMockRouteEntry(method: 'GET', path: '/banners', asset: 'assets/mock/banners.json'),
    const SHOMockRouteEntry(method: 'GET', path: '/products', asset: 'assets/mock/products.json'),
    const SHOMockRouteEntry(method: 'GET', path: '/categories', asset: 'assets/mock/categories.json'),
    const SHOMockRouteEntry(method: 'POST', path: '/auth/login', asset: 'assets/mock/auth_login.json'),
    const SHOMockRouteEntry(method: 'GET', path: '/auth/profile', asset: 'assets/mock/auth_profile.json'),
    const SHOMockRouteEntry(method: 'GET', path: '/products/{id}', asset: 'assets/mock/product_catalog.json'),
    const SHOMockRouteEntry(method: 'GET', path: '/cart', asset: 'assets/mock/cart.json'),
    const SHOMockRouteEntry(method: 'GET', path: '/messages', asset: 'assets/mock/messages.json'),
    const SHOMockRouteEntry(method: 'GET', path: '/marketing/activity-popup', asset: 'assets/mock/activity_popup.json'),
    const SHOMockRouteEntry(method: 'GET', path: '/app/version', asset: 'assets/mock/app_version.json'),
    const SHOMockRouteEntry(method: 'GET', path: '/search/hot', asset: 'assets/mock/search_hot.json'),
    const SHOMockRouteEntry(method: 'GET', path: '/search', asset: 'assets/mock/search.json'),
    const SHOMockRouteEntry(method: 'GET', path: '/products/{id}/reviews', asset: 'assets/mock/product_reviews_catalog.json'),
    const SHOMockRouteEntry(method: 'GET', path: '/coupons', asset: 'assets/mock/coupons.json'),
    const SHOMockRouteEntry(method: 'GET', path: '/after-sales', asset: 'assets/mock/after_sales.json'),
    const SHOMockRouteEntry(method: 'POST', path: '/after-sales', asset: 'assets/mock/after_sale_create.json'),
    const SHOMockRouteEntry(method: 'GET', path: '/addresses', asset: 'assets/mock/addresses.json'),
    const SHOMockRouteEntry(method: 'POST', path: '/orders', asset: 'assets/mock/order_create.json'),
    const SHOMockRouteEntry(method: 'POST', path: '/orders/{id}/pay', asset: 'assets/mock/payment_success.json'),
    const SHOMockRouteEntry(method: 'GET', path: '/orders', asset: 'assets/mock/orders.json'),
    const SHOMockRouteEntry(method: 'GET', path: '/orders/{id}', asset: 'assets/mock/order_detail.json'),
    const SHOMockRouteEntry(method: 'GET', path: '/orders/{id}/logistics', asset: 'assets/mock/order_logistics.json'),
  ];

  static void register(SHOMockRouteEntry entry) => _routes.add(entry);

  static List<SHOMockRouteEntry> get routes => List.unmodifiable(_routes);

  static SHOMockRouteEntry? match(String method, String path) {
    for (final route in _routes.reversed) {
      if (!_methodMatch(route.method, method)) continue;
      if (_pathMatch(route.path, path)) return route;
    }
    return null;
  }

  static bool _methodMatch(String expected, String actual) =>
      expected.toUpperCase() == actual.toUpperCase();

  static bool _pathMatch(String pattern, String path) {
    if (pattern == path) return true;
    if (!pattern.contains('{')) return false;

    final patternParts = pattern.split('/');
    final pathParts = path.split('/');
    if (patternParts.length != pathParts.length) return false;

    for (var i = 0; i < patternParts.length; i++) {
      final pp = patternParts[i];
      if (pp.startsWith('{') && pp.endsWith('}')) continue;
      if (pp != pathParts[i]) return false;
    }
    return true;
  }
}
