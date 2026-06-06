abstract final class SHOAppRoutes {
  static const splash = '/splash';
  static const onboarding = '/onboarding';
  static const home = '/';
  static const category = '/category';
  static const cart = '/cart';
  static const profile = '/profile';
  static const login = '/login';
  static const register = '/register';
  static const settings = '/settings';
  static const messages = '/messages';
  static const search = '/search';
  static const orders = '/orders';
  static const debug = '/debug';

  static String product(String id) => '/product/$id';
  static String productReviews(String id) => '/product/$id/reviews';
  static String order(String id) => '/orders/$id';
  static String orderLogistics(String id) => '/orders/$id/logistics';
  static const debugUpdate = '/debug/update';
  static const debugActivity = '/debug/activity';

  static const debugRoutes = <String>[
    debug,
    debugUpdate,
    debugActivity,
  ];

  static const protectedRoutes = <String>[
    settings,
    messages,
  ];

  static bool requiresAuth(String location) {
    return protectedRoutes.contains(location);
  }
}
