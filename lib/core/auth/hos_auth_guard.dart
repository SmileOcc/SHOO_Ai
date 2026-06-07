import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router/hos_routes.dart';
import '../../features/auth/presentation/hos_session_provider.dart';

/// 登录态守卫：需要用户信息的操作先校验，未登录则跳转登录页。
abstract final class SHOAuthGuard {
  static bool isAuthenticated(WidgetRef ref) {
    return ref.read(sessionProvider).isAuthenticated;
  }

  static String loginPath({String? redirectTo}) {
    if (redirectTo == null || redirectTo.isEmpty) {
      return SHOAppRoutes.login;
    }
    return '${SHOAppRoutes.login}?redirect=${Uri.encodeComponent(redirectTo)}';
  }

  /// 已登录返回 true；未登录 push 登录页并返回 false。
  ///
  /// 使用 push 保留当前页面栈，登录成功后 pop 返回，避免 go 替换栈导致无法返回。
  static bool requireAuth(BuildContext context, WidgetRef ref) {
    if (isAuthenticated(ref)) return true;

    final returnTo = GoRouterState.of(context).uri.toString();
    context.push(loginPath(redirectTo: returnTo));
    return false;
  }

  static Future<void> logout(BuildContext context, WidgetRef ref) async {
    await ref.read(sessionProvider.notifier).logout();
    if (context.mounted) {
      context.go(SHOAppRoutes.login);
    }
  }
}
