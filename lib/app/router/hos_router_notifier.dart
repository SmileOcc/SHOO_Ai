import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/config/hos_config.dart';
import '../../features/auth/presentation/hos_session_provider.dart';
import 'hos_routes.dart';

final routerNotifierProvider = Provider<SHORouterNotifier>((ref) {
  final notifier = SHORouterNotifier(ref);
  ref.onDispose(notifier.dispose);
  return notifier;
});

class SHORouterNotifier extends ChangeNotifier {
  SHORouterNotifier(this._ref) {
    _ref.listen(sessionProvider, (_, __) => notifyListeners());
  }

  final Ref _ref;

  String? redirect(BuildContext context, GoRouterState state) {
    final session = _ref.read(sessionProvider);
    if (session.isRestoring) return null;

    final location = state.matchedLocation;

    if (SHOAppRoutes.debugRoutes.contains(location) &&
        !SHOAppConfig.instance.isDebugPanelEnabled) {
      return SHOAppRoutes.home;
    }

    final loggingIn = location == SHOAppRoutes.login || location == SHOAppRoutes.register;

    if (!session.isAuthenticated && SHOAppRoutes.requiresAuth(location)) {
      final redirectUri = Uri.encodeComponent(state.uri.toString());
      return '${SHOAppRoutes.login}?redirect=$redirectUri';
    }

    if (session.isAuthenticated && loggingIn) {
      return SHOAppRoutes.profile;
    }

    return null;
  }
}
