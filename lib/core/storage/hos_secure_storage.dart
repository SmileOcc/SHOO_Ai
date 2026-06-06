import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../constants/hos_constants.dart';

final secureStorageProvider = Provider<SHOSecureStorageService>((ref) {
  return SHOSecureStorageService(const FlutterSecureStorage());
});

/// Token 等敏感信息存储，替代 SharedPreferences 明文保存。
class SHOSecureStorageService {
  SHOSecureStorageService(this._storage);

  final FlutterSecureStorage _storage;

  Future<void> writeToken(String? token) async {
    if (token == null || token.isEmpty) {
      await _storage.delete(key: SHOAppConstants.secureTokenKey);
      return;
    }
    await _storage.write(key: SHOAppConstants.secureTokenKey, value: token);
  }

  Future<String?> readToken() =>
      _storage.read(key: SHOAppConstants.secureTokenKey);

  Future<void> clear() => _storage.deleteAll();
}
