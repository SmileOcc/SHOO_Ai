import 'package:shoo/core/config/hos_config.dart';
import 'package:shoo/app/router/hos_routes.dart';

/// 认证相关 redirect 判断。
String? shoAuthRedirect({
  required bool isAuthenticated,
  required bool isRestoring,
  required String matchedLocation,
  required String fullUri,
}) {
  if (isRestoring) return null;

  if (SHOAppRoutes.debugRoutes.contains(matchedLocation) &&
      !SHOAppConfig.instance.isDebugPanelEnabled) {
    return SHOAppRoutes.home;
  }

  final loggingIn =
      matchedLocation == SHOAppRoutes.login || matchedLocation == SHOAppRoutes.register;

  if (!isAuthenticated && SHOAppRoutes.requiresAuth(matchedLocation)) {
    final redirectUri = Uri.encodeComponent(fullUri);
    return '${SHOAppRoutes.login}?redirect=$redirectUri';
  }

  if (isAuthenticated && loggingIn) return null;

  return null;
}
