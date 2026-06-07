/**
 * Mirrors lib/core/network/hos_mock_route_registry.dart
 * More specific paths must appear AFTER generic ones (matcher iterates reversed).
 */
export const routes = [
  { method: 'GET', path: '/banners', file: 'banners.json' },
  { method: 'GET', path: '/products', file: 'products.json' },
  { method: 'GET', path: '/categories', file: 'categories.json' },
  { method: 'POST', path: '/auth/login', file: 'auth_login.json' },
  { method: 'GET', path: '/auth/profile', file: 'auth_profile.json' },
  { method: 'GET', path: '/products/{id}', file: 'product_catalog.json' },
  { method: 'GET', path: '/cart', file: 'cart.json' },
  { method: 'GET', path: '/messages', file: 'messages.json' },
  { method: 'GET', path: '/marketing/activity-popup', file: 'activity_popup.json' },
  { method: 'GET', path: '/app/version', file: 'app_version.json' },
  { method: 'GET', path: '/search/hot', file: 'search_hot.json' },
  { method: 'GET', path: '/search', file: 'search.json' },
  { method: 'GET', path: '/products/{id}/reviews', file: 'product_reviews_catalog.json' },
  { method: 'GET', path: '/coupons', file: 'coupons.json' },
  { method: 'GET', path: '/after-sales', file: 'after_sales.json' },
  { method: 'POST', path: '/after-sales', file: 'after_sale_create.json' },
  { method: 'GET', path: '/addresses', file: 'addresses.json' },
  { method: 'POST', path: '/orders', file: 'order_create.json' },
  { method: 'POST', path: '/orders/{id}/pay', file: 'payment_success.json' },
  { method: 'GET', path: '/orders', file: 'orders.json' },
  { method: 'GET', path: '/orders/{id}', file: 'order_detail.json' },
  { method: 'GET', path: '/orders/{id}/logistics', file: 'order_logistics.json' },
];

function methodMatch(expected, actual) {
  return expected.toUpperCase() === actual.toUpperCase();
}

function pathMatch(pattern, requestPath) {
  if (pattern === requestPath) return true;
  if (!pattern.includes('{')) return false;

  const patternParts = pattern.split('/');
  const pathParts = requestPath.split('/');
  if (patternParts.length !== pathParts.length) return false;

  for (let i = 0; i < patternParts.length; i++) {
    const segment = patternParts[i];
    if (segment.startsWith('{') && segment.endsWith('}')) continue;
    if (segment !== pathParts[i]) return false;
  }
  return true;
}

export function matchRoute(method, requestPath) {
  const path = requestPath.split('?')[0];
  for (let i = routes.length - 1; i >= 0; i--) {
    const route = routes[i];
    if (!methodMatch(route.method, method)) continue;
    if (pathMatch(route.path, path)) return route;
  }
  return null;
}
