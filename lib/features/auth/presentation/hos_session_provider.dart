import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/logging/hos_logger.dart';
import '../data/hos_auth_repository.dart';
import '../domain/hos_auth_user.dart';
import 'hos_auth_token_provider.dart';

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

final sessionProvider =
    StateNotifierProvider<SHOSessionNotifier, SHOSessionState>((ref) {
  final notifier = SHOSessionNotifier(
    ref.watch(authRepositoryProvider),
    ref,
  );
  Future.microtask(notifier.restore);
  return notifier;
});

class SHOSessionNotifier extends StateNotifier<SHOSessionState> {
  SHOSessionNotifier(this._repository, this._ref)
      : super(const SHOSessionState(isRestoring: true));

  final SHOAuthRepository _repository;
  final Ref _ref;

  void _syncToken(String? token) {
    _ref.read(authTokenProvider.notifier).state = token;
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

  Future<void> commitLogin(SHOAuthSession session) async {
    _syncToken(session.token);
    state = SHOSessionState(token: session.token, user: session.user);
    SHOAppLogger.info('User logged in: ${session.user.nickname}');
  }

  Future<void> login(SHOLoginRequest request) async {
    final session = await loginRequest(request);
    await commitLogin(session);
  }

  Future<void> logout() async {
    await _repository.logout();
    _syncToken(null);
    state = const SHOSessionState();
    SHOAppLogger.info('User logged out');
  }
}
