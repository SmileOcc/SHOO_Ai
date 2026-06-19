import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shoo/features/auth/domain/repositories/hos_auth_repository.dart';
import 'package:shoo/features/auth/data/repositories/hos_auth_repository_impl.dart';

final logoutUseCaseProvider = Provider<SHOLogoutUseCase>((ref) {
  return SHOLogoutUseCase(ref.watch(authRepositoryProvider));
});

class SHOLogoutUseCase {
  SHOLogoutUseCase(this._repository);

  final SHOAuthRepository _repository;

  Future<void> call() => _repository.logout();
}
