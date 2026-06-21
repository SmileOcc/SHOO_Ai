import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shoo/core/analytics/hos_analytics.dart';
import 'package:shoo/core/errors/hos_exception.dart';
import 'package:shoo/core/logging/hos_logger.dart';
import 'package:shoo/features/auth/domain/repositories/hos_auth_repository.dart';
import 'package:shoo/features/auth/data/repositories/hos_auth_repository_impl.dart';
import 'package:shoo/features/auth/domain/entities/hos_auth_user.dart';
import 'package:shoo/features/auth/presentation/state/hos_auth_token_provider.dart';

class SHOSessionState {
  const SHOSessionState({
    this.token,
    this.user,
    this.isRestoring = false,
  });

  final String? token;
  final SHOAuthUser? user;
  final bool isRestoring;

  bool get isAuthenticated => token != null && user != null;

  SHOSessionState copyWith({
    String? token,
    SHOAuthUser? user,
    bool? isRestoring,
  }) {
    return SHOSessionState(
      token: token ?? this.token,
      user: user ?? this.user,
      isRestoring: isRestoring ?? this.isRestoring,
    );
  }
}

final sessionProvider = NotifierProvider<SHOSessionNotifier, SHOSessionState>(
  SHOSessionNotifier.new,
);

class SHOSessionNotifier extends Notifier<SHOSessionState> {
  late final SHOAuthRepository _repository;

  @override
  SHOSessionState build() {
    _repository = ref.read(authRepositoryProvider);
    Future.microtask(restore);
    return const SHOSessionState(isRestoring: true);
  }

  void _syncToken(String? token) {
    ref.read(authTokenProvider.notifier).state = token;
  }

  Future<void> restore() async {
    state = state.copyWith(isRestoring: true);
    try {
      final session = await _repository.restoreSession();
      if (session == null) {
        _syncToken(null);
        state = const SHOSessionState(isRestoring: false);
        return;
      }
      _syncToken(session.token);
      state = SHOSessionState(
        token: session.token,
        user: session.user,
        isRestoring: false,
      );
      SHOAppLogger.info('Session restored for ${session.user.nickname}');
    } on SHONetworkException catch (error) {
      SHOAppLogger.warn(
        'Session restore skipped — API unreachable (${error.message}). '
        'If using local env, run: cd server && npm run dev',
      );
      state = const SHOSessionState(isRestoring: false);
    } catch (error, stack) {
      SHOAppLogger.error('Session restore failed', error, stack);
      await _repository.logout();
      _syncToken(null);
      state = const SHOSessionState(isRestoring: false);
    }
  }

  Future<SHOAuthSession> loginRequest(SHOLoginRequest request) {
    return _repository.login(request);
  }

  Future<SHOAuthSession> registerRequest(SHOLoginRequest request) {
    return _repository.register(request);
  }

  Future<void> commitLogin(SHOAuthSession session) async {
    _syncToken(session.token);
    state = SHOSessionState(token: session.token, user: session.user);
    SHOAppLogger.info('User logged in: ${session.user.nickname}');
    await SHOAnalyticsManager.instance.trackEvent(
      SHOAnalyticsRegistry.loginSuccess,
      {
        'user_id': session.user.id,
        'method': 'phone_password',
      },
    );
  }

  Future<void> login(SHOLoginRequest request) async {
    final session = await loginRequest(request);
    await commitLogin(session);
  }

  Future<void> logout() async {
    final userId = state.user?.id;
    await _repository.logout();
    _syncToken(null);
    state = const SHOSessionState();
    SHOAppLogger.info('User logged out');
    if (userId != null) {
      await SHOAnalyticsManager.instance.trackEvent(
        SHOAnalyticsRegistry.logout,
        {'user_id': userId},
      );
    }
  }
}


/*
用户登录/登出
    ↓
sessionProvider 状态变化
    ↓
SHORouterNotifier 监听到变化 → notifyListeners()
    ↓
GoRouter.refreshListenable 触发
    ↓
redirect() 重新执行
    ↓
路由守卫重新判断，可能触发重定向
*/