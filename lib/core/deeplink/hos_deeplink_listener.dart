import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../logging/hos_logger.dart';
import 'hos_deeplink_mapper.dart';
import '../../app/router/hos_router.dart';

final deepLinkListenerProvider = Provider<SHODeepLinkListener>((ref) {
  final router = ref.watch(routerProvider);
  final listener = SHODeepLinkListener(router);
  listener.start();
  ref.onDispose(listener.dispose);
  return listener;
});

/// 监听系统深链并导航到 go_router 路径。
class SHODeepLinkListener {
  SHODeepLinkListener(this._router);

  final GoRouter _router;
  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _subscription;
  bool _started = false;

  void start() {
    if (_started) return;
    _started = true;

    _appLinks.getInitialLink().then(_navigate);
    _subscription = _appLinks.uriLinkStream.listen(_navigate);
    SHOAppLogger.info('Deep link listener started');
  }

  void _navigate(Uri? uri) {
    if (uri == null) return;
    final path = SHODeepLinkMapper.toAppPath(uri);
    if (path == null) {
      SHOAppLogger.warn('Unsupported deep link: $uri');
      return;
    }
    SHOAppLogger.info('Deep link → $path');
    _router.go(path);
  }

  void dispose() {
    _subscription?.cancel();
    _subscription = null;
    _started = false;
  }
}
