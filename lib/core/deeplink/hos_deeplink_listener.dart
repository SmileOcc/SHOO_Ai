import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:shoo/core/analytics/hos_analytics_manager.dart';
import 'package:shoo/core/analytics/hos_analytics_registry.dart';
import 'package:shoo/core/deeplink/hos_deeplink_navigator.dart';
import 'package:shoo/app/router/hos_router.dart';
import 'package:shoo/core/deeplink/hos_deeplink_resolver.dart';
import 'package:shoo/core/logging/hos_logger.dart';
import 'package:shoo/features/auth/presentation/state/hos_session_provider.dart';

final deepLinkListenerProvider = Provider<SHODeepLinkListener>((ref) {
  final router = ref.watch(routerProvider);
  final listener = SHODeepLinkListener(router, ref);
  listener.start();
  ref.onDispose(listener.dispose);
  return listener;
});

/// 监听系统深链并导航到 go_router 路径。
class SHODeepLinkListener {
  SHODeepLinkListener(this._router, this._ref);

  final GoRouter _router;
  final Ref _ref;
  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _subscription;
  bool _started = false;

  void start() {
    if (_started) return;
    _started = true;

    _appLinks.getInitialLink().then(
          (uri) => _navigate(uri, source: 'initial_link'),
        );
    _subscription = _appLinks.uriLinkStream.listen(
      (uri) => _navigate(uri, source: 'stream'),
    );
    SHOAppLogger.info('Deep link listener started');
  }

  void _navigate(Uri? uri, {required String source}) {
    if (uri == null) return;

    final target = SHODeepLinkResolver.resolveUri(uri);
    unawaited(
      SHOAnalyticsManager.instance.trackEvent(
        SHOAnalyticsRegistry.deeplinkReceive,
        {
          'uri': uri.toString(),
          'app_path': target?.appPath ?? '',
          'action_type': target?.type.name ?? 'unsupported',
          'source': source,
          'supported': target != null,
        },
      ),
    );

    if (target == null) {
      SHOAppLogger.warn('Unsupported deep link: $uri');
      return;
    }

    final session = _ref.read(sessionProvider);
    SHODeepLinkNavigator.navigate(_router, target, session: session);
  }

  void dispose() {
    _subscription?.cancel();
    _subscription = null;
    _started = false;
  }
}
