import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shoo/app/router/hos_router.dart';
import 'package:shoo/core/analytics/hos_analytics_manager.dart';
import 'package:shoo/core/analytics/hos_analytics_registry.dart';
import 'package:shoo/core/deeplink/hos_deeplink_config.dart';
import 'package:shoo/core/deeplink/hos_deeplink_link_kind.dart';
import 'package:shoo/core/deeplink/hos_deeplink_navigator.dart';
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

/// 监听系统深链（Custom Scheme + App Links / Universal Link）并走统一 Deep Link 导航。
///
/// - Android：`AndroidManifest` 已声明 `https://shoo.app` App Links（`autoVerify`）。
/// - iOS：`applinks:shoo.app` Associated Domains **暂未配置**；当前依赖 Custom Scheme
///   与调试模拟。正式上线再写入 Runner.entitlements。
/// - Flutter 引擎内置 Deep Link（`FlutterDeepLinkingEnabled`）已关闭，统一由
///   [app_links] + 本 Listener 处理，避免与 GoRouter 双路由冲突。
class SHODeepLinkListener {
  SHODeepLinkListener(this._router, this._ref);

  final GoRouter _router;
  final Ref _ref;
  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _subscription;
  bool _started = false;
  String? _lastHandled;
  int _lastHandledAtMs = 0;

  void start() {
    if (_started) return;
    _started = true;

    _appLinks.getInitialLink().then((uri) {
      if (uri == null) return;
      _handleIncomingUri(uri, source: 'initial_link');
    });
    _subscription = _appLinks.uriLinkStream.listen((uri) {
      _handleIncomingUri(uri, source: 'stream');
    });

    SHOAppLogger.i(
      'Deep link listener started '
      '(hosts=${SHODeepLinkConfig.appLinkHosts.join(',')}, '
      'associatedDomains deferred=${SHODeepLinkConfig.associatedDomains.join(',')})',
    );
  }

  /// 供 Debug / 测试模拟系统唤起（含 App Link）。
  void handleUriForDebug(Uri uri) =>
      _handleIncomingUri(uri, source: 'debug_simulate');

  void _handleIncomingUri(Uri uri, {required String source}) {
    final now = DateTime.now().millisecondsSinceEpoch;
    final key = uri.toString();
    if (key == _lastHandled && now - _lastHandledAtMs < 800) {
      return;
    }
    _lastHandled = key;
    _lastHandledAtMs = now;

    final linkKind = SHODeepLinkResolver.linkKindOf(uri);
    final target = SHODeepLinkResolver.resolveUri(uri);

    unawaited(
      SHOAnalyticsManager.instance
          .trackEvent(SHOAnalyticsRegistry.deeplinkReceive, {
            'uri': uri.toString(),
            'app_path': target?.appPath ?? '',
            'action_type': target?.type.name ?? 'unsupported',
            'link_kind': linkKind.name,
            'is_app_link': linkKind == SHODeepLinkLinkKind.appLink,
            'source': source,
            'supported': target != null,
          }),
    );

    if (target == null) {
      SHOAppLogger.w('Unsupported deep link ($linkKind/$source): $uri');
      return;
    }

    SHOAppLogger.i(
      'Deep link ($linkKind/$source) → ${target.appPath}',
    );

    final session = _ref.read(sessionProvider);
    SHODeepLinkNavigator.navigate(_router, target, session: session);
  }

  void dispose() {
    _subscription?.cancel();
    _subscription = null;
    _started = false;
  }
}
