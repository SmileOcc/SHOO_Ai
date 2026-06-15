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
    // 1. 读取当前会话状态
    final session = _ref.read(sessionProvider);
    // 2. 如果正在恢复会话，不干预路由
    if (session.isRestoring) return null;

    // 获取匹配的路径（不含查询参数）
    final location = state.matchedLocation;
    // 3. Debug 路由权限检查
    if (SHOAppRoutes.debugRoutes.contains(location) &&
        !SHOAppConfig.instance.isDebugPanelEnabled) {
      return SHOAppRoutes.home;
    }

    final loggingIn = location == SHOAppRoutes.login || location == SHOAppRoutes.register;

    if (!session.isAuthenticated && SHOAppRoutes.requiresAuth(location)) {
      // 重定向到登录页，携带原目标地址 登录后自动跳转机制
      final redirectUri = Uri.encodeComponent(state.uri.toString());
      return '${SHOAppRoutes.login}?redirect=$redirectUri';
    }

    // 登录/注册成功后的跳转由页面自行处理（pop 或 go），避免与会话更新竞态冲突。
    if (session.isAuthenticated && loggingIn) return null;

    return null;
  }
}
