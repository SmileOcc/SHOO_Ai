import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shoo/core/storage/secure/hos_secure_storage.dart';

final authLocalDsProvider = Provider<SHOAuthLocalDataSource>((ref) {
  return SHOAuthLocalDataSource(ref.watch(secureStorageProvider));
});

/// Token 本地读写（SecureStorage 封装）。
class SHOAuthLocalDataSource {
  SHOAuthLocalDataSource(this._secureStorage);

  final SHOSecureStorageService _secureStorage;

  Future<String?> readToken() => _secureStorage.readToken();

  Future<void> writeToken(String? token) => _secureStorage.writeToken(token);
}
