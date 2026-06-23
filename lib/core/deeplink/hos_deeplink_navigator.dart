import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:shoo/app/router/hos_routes.dart';
import 'package:shoo/core/deeplink/hos_deeplink_resolver.dart';
import 'package:shoo/core/deeplink/hos_deeplink_target.dart';
import 'package:shoo/core/feedback/hos_toast.dart';
import 'package:shoo/core/logging/hos_logger.dart';
import 'package:shoo/features/auth/presentation/state/hos_session_provider.dart';

/// 统一 Deep Link 导航（含登录校验）。
abstract final class SHODeepLinkNavigator {
  static String? _lastLink;
  static int _lastNavAtMs = 0;

  static Future<bool> openLink(
    BuildContext context,
    String link, {
    required SHOSessionState session,
    bool closeCurrentPage = false,
  }) async {
    final target = SHODeepLinkResolver.resolveLink(link);
    if (target == null) {
      SHOAppLogger.warn('Unsupported deep link: $link');
      if (context.mounted) {
        context.showToast('不支持的链接');
      }
      return false;
    }
    return openTarget(
      context,
      target,
      session: session,
      closeCurrentPage: closeCurrentPage,
    );
  }

  static Future<bool> openTarget(
    BuildContext context,
    SHODeepLinkTarget target, {
    required SHOSessionState session,
    bool closeCurrentPage = false,
  }) async {
    if (!context.mounted) return false;
    final router = GoRouter.of(context);

    if (target.requiresAuth && !session.isAuthenticated) {
      SHOAppLogger.info('Deep link requires auth → login');
      await router.push(
        '${SHOAppRoutes.login}?redirect=${Uri.encodeComponent(target.appPath)}',
      );
      return false;
    }

    final path = target.appPath;
    SHOAppLogger.info('Deep link navigate → $path');

    if (closeCurrentPage && router.canPop()) {
      router.pop();
    }

    if (SHOAppRoutes.isShellTabRoute(path)) {
      router.go(path);
    } else {
      router.push(path);
    }
    return true;
  }

  /// 供 [GoRouter] 监听等无 [BuildContext] 场景调用。
  static void navigate(
    GoRouter router,
    SHODeepLinkTarget target, {
    required SHOSessionState session,
  }) {
    if (target.requiresAuth && !session.isAuthenticated) {
      SHOAppLogger.info('Deep link requires auth → login');
      router.push(
        '${SHOAppRoutes.login}?redirect=${Uri.encodeComponent(target.appPath)}',
      );
      return;
    }

    SHOAppLogger.info('Deep link navigate → ${target.appPath}');
    final path = target.appPath;
    if (SHOAppRoutes.isShellTabRoute(path)) {
      router.go(path);
    } else {
      router.push(path);
    }
  }

  /// WebView / H5 场景：尽快跳转（microtask，不阻塞 WebView 回调）。
  ///
  /// - 全屏页：push 叠在 WebView 上，返回回到 Web 页。
  /// - Tab 页：先 pop Web 页再 go。
  static void openFromWebView(
    BuildContext context,
    String link, {
    required SHOSessionState session,
  }) {
    final now = DateTime.now().millisecondsSinceEpoch;
    if (link == _lastLink && now - _lastNavAtMs < 600) return;
    _lastLink = link;
    _lastNavAtMs = now;

    scheduleMicrotask(() {
      if (!context.mounted) return;
      final target = SHODeepLinkResolver.resolveLink(link);
      if (target == null) {
        context.showToast('不支持的链接');
        return;
      }
      final closeWebPage = SHOAppRoutes.isShellTabRoute(target.appPath);
      unawaited(
        openTarget(
          context,
          target,
          session: session,
          closeCurrentPage: closeWebPage,
        ),
      );
    });
  }
}
