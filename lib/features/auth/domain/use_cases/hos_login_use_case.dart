import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shoo/features/auth/data/repositories/hos_auth_repository_impl.dart';
import 'package:shoo/features/auth/domain/entities/hos_auth_user.dart';
import 'package:shoo/features/auth/domain/repositories/hos_auth_repository.dart';

final loginUseCaseProvider = Provider<SHOLoginUseCase>((ref) {
  return SHOLoginUseCase(ref.watch(authRepositoryProvider));
});

class SHOLoginUseCase {
  SHOLoginUseCase(this._repository);

  final SHOAuthRepository _repository;

  Future<SHOAuthSession> call(SHOLoginRequest request) =>
      _repository.login(request);
}

class SHOLogoutUseCase {
  SHOLogoutUseCase(this._repository);

  final SHOAuthRepository _repository;

  Future<void> call() => _repository.logout();
}
