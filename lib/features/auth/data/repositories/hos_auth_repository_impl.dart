import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  @override
  Future<SHOAuthSession> login(SHOLoginRequest request) async {
    final session = await _remote.login(request);
    await _local.writeToken(session.token);
    return session;
  }

  @override
  Future<SHOAuthSession?> restoreSession() async {
    final token = await _local.readToken();
    if (token == null || token.isEmpty) return null;
    final user = await _remote.fetchProfile();
    return SHOAuthSession(token: token, user: user);
  }

  @override
  Future<void> logout() => _local.writeToken(null);
}
