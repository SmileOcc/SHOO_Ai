import 'package:go_router/go_router.dart';

import '../../app/router/hos_routes.dart';
import 'presentation/hos_onboarding_page.dart';
import 'presentation/hos_splash_page.dart';

List<RouteBase> shoSplashRoutes() => [
      GoRoute(
        path: SHOAppRoutes.splash,
        builder: (context, state) => const SHOSplashPage(),
      ),
      GoRoute(
        path: SHOAppRoutes.onboarding,
        builder: (context, state) => const SHOOnboardingPage(),
      ),
    ];
