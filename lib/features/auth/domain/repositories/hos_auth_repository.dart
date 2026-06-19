import 'package:shoo/features/auth/domain/entities/hos_auth_user.dart';

/// 认证仓储接口（Domain 层）。
abstract interface class SHOAuthRepository {
  Future<SHOAuthSession> login(SHOLoginRequest request);

  Future<SHOAuthSession?> restoreSession();

  Future<void> logout();
}
