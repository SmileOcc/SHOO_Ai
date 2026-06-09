abstract final class SHOAppRoutes {
  static const splash = '/splash';  //闪图
  static const onboarding = '/onboarding';  //引导页
  static const home = '/';
  static const category = '/category';
  static const categoryProducts = '/category/products';

  static String categoryProductsFiltered({
    required String leafId,
    required String title,
  }) {
    final query = <String, String>{
      'leafId': leafId,
      'title': title,
    };
    final encoded = query.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');
    return '$categoryProducts?$encoded';
  }
  static const cart = '/cart';
  static const profile = '/profile';
  static const profileFootprints = '/profile/footprints';
  static const profileFavorites = '/profile/favorites';
  static const profileBookshelf = '/profile/bookshelf';
  static const toolbox = '/toolbox';
  static const toolboxDownloads = '/toolbox/downloads';
  static const login = '/login';
  static const register = '/register';
  static const settings = '/settings';
  static const settingsAbout = '/settings/about';
  static const settingsCache = '/settings/cache';
  static const messages = '/messages';
  static const search = '/search';
  static const checkout = '/checkout';
  static const coupons = '/coupons';
  static const couponsSelect = '/coupons?select=1';
  static const afterSales = '/after-sales';
  static const addresses = '/addresses';
  static const addressesSelect = '/addresses?select=1';
  static const addressForm = '/addresses/form';

  static String addressEdit(String id) => '/addresses/form?id=$id';
  static const orders = '/orders';

  static String ordersFiltered(String status) => '/orders?status=$status';
  static const debug = '/debug';

  static String product(String id) => '/product/$id';

  static String productDeepLink(String id) => 'https://shoo.app/product/$id';
  static String productReviews(String id) => '/product/$id/reviews';
  static String order(String id) => '/orders/$id';
  static String orderLogistics(String id) => '/orders/$id/logistics';
  static String payment(String orderId) => '/payment/$orderId';
  static String afterSaleApply(String orderId) => '/after-sales/apply/$orderId';
  static const debugUpdate = '/debug/update';
  static const debugActivity = '/debug/activity';
  static const debugNative = '/debug/native';
  static const debugBrand = '/debug/brand';
  static const debugAnalytics = '/debug/analytics';
  static const debugNetworkLog = '/debug/network-log';

  static String debugNativeExample(String id) => '/debug/native/$id';

  static const debugRoutes = <String>[
    debug,
    debugUpdate,
    debugActivity,
    debugNative,
  ];

  static const protectedRoutes = <String>[
    messages,
    checkout,
    coupons,
    afterSales,
    addresses,
    orders,
  ];

  static const protectedPrefixes = <String>[
    '/orders/',
    '/payment/',
    '/after-sales/',
  ];

  static bool requiresAuth(String location) {
    if (protectedRoutes.contains(location)) return true;
    return protectedPrefixes.any(location.startsWith);
  }
}
