import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shoo/core/errors/hos_exception.dart';
import 'package:shoo/features/auth/data/datasources/local/hos_auth_local_ds.dart';
import 'package:shoo/features/auth/data/datasources/remote/hos_auth_remote_ds.dart';
import 'package:shoo/features/auth/domain/entities/hos_auth_user.dart';
import 'package:shoo/features/auth/domain/repositories/hos_auth_repository.dart';

final authRepositoryProvider = Provider<SHOAuthRepository>((ref) {
  return SHOAuthRepositoryImpl(
    ref.watch(authApiProvider),
    ref.watch(authLocalDsProvider),
  );
});

class SHOAuthRepositoryImpl implements SHOAuthRepository {
  SHOAuthRepositoryImpl(this._remote, this._local);

  final SHOAuthApi _remote;
  final SHOAuthLocalDataSource _local;

  Future<void> _persistSession(SHOAuthSession session) async {
    await _local.writeToken(session.token);
    await _local.writeUser(session.user);
  }

  @override
  Future<SHOAuthSession> login(SHOLoginRequest request) async {
    final session = await _remote.login(request);
    await _persistSession(session);
    return session;
  }

  @override
  Future<SHOAuthSession> register(SHOLoginRequest request) async {
    final session = await _remote.register(request);
    await _persistSession(session);
    return session;
  }

  @override
  Future<SHOAuthSession?> restoreSession() async {
    final token = await _local.readToken();
    if (token == null || token.isEmpty) return null;

    try {
      final user = await _remote.fetchProfile(bearerToken: token);
      await _local.writeUser(user);
      return SHOAuthSession(token: token, user: user);
    } on SHOServerException catch (error) {
      // 鉴权失败才清本地登录态；其余错误尽量用缓存用户保活。
      if (error.code == 401 || error.code == 403) {
        await logout();
        return null;
      }
      final cached = await _local.readUser();
      if (cached != null) {
        return SHOAuthSession(token: token, user: cached);
      }
      rethrow;
    } catch (error) {
      // 网络不可达 / 未知错误：有缓存则离线保活，无缓存再上抛。
      if (error is! SHONetworkException && error is! SHOUnknownException) {
        rethrow;
      }
      final cached = await _local.readUser();
      if (cached != null) {
        return SHOAuthSession(token: token, user: cached);
      }
      rethrow;
    }
  }

  @override
  Future<void> logout() => _local.clearSession();
}
