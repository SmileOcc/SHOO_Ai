import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:shoo/features/auth/presentation/state/hos_session_provider.dart';
import 'guards/hos_auth_redirect.dart';
import 'guards/hos_maintenance_redirect.dart';
import 'guards/hos_onboarding_redirect.dart';

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
    final location = state.matchedLocation;

    return shoMaintenanceRedirect(
          maintenanceEnabled: false,
          matchedLocation: location,
        ) ??
        shoOnboardingRedirect(
          onboardingCompleted: true,
          matchedLocation: location,
        ) ??
        shoAuthRedirect(
          isAuthenticated: session.isAuthenticated,
          isRestoring: session.isRestoring,
          matchedLocation: location,
          fullUri: state.uri.toString(),
        );
  }
}
