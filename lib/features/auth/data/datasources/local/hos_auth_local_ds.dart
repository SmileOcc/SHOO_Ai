import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shoo/core/storage/secure/hos_secure_storage.dart';
import 'package:shoo/features/auth/domain/entities/hos_auth_user.dart';

final authLocalDsProvider = Provider<SHOAuthLocalDataSource>((ref) {
  return SHOAuthLocalDataSource(ref.watch(secureStorageProvider));
});

/// Token / 用户缓存本地读写（SecureStorage 封装）。
class SHOAuthLocalDataSource {
  SHOAuthLocalDataSource(this._secureStorage);

  final SHOSecureStorageService _secureStorage;

  Future<String?> readToken() => _secureStorage.readToken();

  Future<void> writeToken(String? token) => _secureStorage.writeToken(token);

  Future<SHOAuthUser?> readUser() async {
    final raw = await _secureStorage.readUserJson();
    if (raw == null || raw.isEmpty) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return SHOAuthUser.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  Future<void> writeUser(SHOAuthUser? user) async {
    if (user == null) {
      await _secureStorage.writeUserJson(null);
      return;
    }
    await _secureStorage.writeUserJson(jsonEncode(user.toJson()));
  }

  Future<void> clearSession() async {
    await writeToken(null);
    await writeUser(null);
  }
}
