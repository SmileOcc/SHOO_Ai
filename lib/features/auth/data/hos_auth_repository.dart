import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/hos_secure_storage.dart';
import '../domain/hos_auth_user.dart';
import 'hos_auth_api.dart';

final authRepositoryProvider = Provider<SHOAuthRepository>((ref) {
  return SHOAuthRepository(
    ref.watch(authApiProvider),
    ref.watch(secureStorageProvider),
  );
});

class SHOAuthRepository {
  SHOAuthRepository(this._api, this._secureStorage);

  final SHOAuthApi _api;
  final SHOSecureStorageService _secureStorage;

  Future<SHOAuthSession> login(SHOLoginRequest request) async {
    final session = await _api.login(request);
    await _secureStorage.writeToken(session.token);
    return session;
  }

  Future<SHOAuthSession?> restoreSession() async {
    final token = await _secureStorage.readToken();
    if (token == null || token.isEmpty) return null;
    final user = await _api.fetchProfile();
    return SHOAuthSession(token: token, user: user);
  }

  Future<void> logout() => _secureStorage.writeToken(null);
}
