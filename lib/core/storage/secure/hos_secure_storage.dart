import 'dart:convert';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shoo/core/constants/hos_constants.dart';

// ============================================
// 密钥安全存储（不要硬编码！）
// ============================================

final secureStorageProvider = Provider<SHOSecureStorageService>((ref) {
  return SHOSecureStorageService(const FlutterSecureStorage());
});

/// Token、AES/RSA/SM 密钥等敏感信息存储。
class SHOSecureStorageService {
  SHOSecureStorageService(this._storage);

  final FlutterSecureStorage _storage;

  // ---- Auth Token ----

  Future<void> writeToken(String? token) async {
    if (token == null || token.isEmpty) {
      await _storage.delete(key: SHOAppConstants.secureTokenKey);
      return;
    }
    await _storage.write(key: SHOAppConstants.secureTokenKey, value: token);
  }

  Future<String?> readToken() =>
      _storage.read(key: SHOAppConstants.secureTokenKey);

  // ---- Cached Auth User (JSON) ----

  Future<void> writeUserJson(String? json) async {
    if (json == null || json.isEmpty) {
      await _storage.delete(key: SHOAppConstants.secureUserKey);
      return;
    }
    await _storage.write(key: SHOAppConstants.secureUserKey, value: json);
  }

  Future<String?> readUserJson() =>
      _storage.read(key: SHOAppConstants.secureUserKey);

  // ---- AES Session Key ----

  Future<void> writeAesKey(String? key) async {
    if (key == null || key.isEmpty) {
      await _storage.delete(key: SHOAppConstants.secureAesKeyKey);
      return;
    }
    await _storage.write(key: SHOAppConstants.secureAesKeyKey, value: key);
  }

  Future<String?> readAesKey() =>
      _storage.read(key: SHOAppConstants.secureAesKeyKey);

  //参考
  Future<String> getAesKey() async {
    // 首次使用时生成并存储
    String? key = await readAesKey();
    if (key == null) {
      key = _generateRandomKey();
      await _storage.write(key: SHOAppConstants.secureAesKeyKey, value: key);
    }
    return key;
  }

  String _generateRandomKey() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (_) => random.nextInt(256));
    return base64.encode(bytes);
  }

  // ---- Request Sign Secret ----

  Future<void> writeSignSecret(String? secret) async {
    if (secret == null || secret.isEmpty) {
      await _storage.delete(key: SHOAppConstants.secureSignSecretKey);
      return;
    }
    await _storage.write(
      key: SHOAppConstants.secureSignSecretKey,
      value: secret,
    );
  }

  Future<String?> readSignSecret() =>
      _storage.read(key: SHOAppConstants.secureSignSecretKey);

  // ---- RSA Public Key (PEM) ----

  Future<void> writeRsaPublicKeyPem(String? pem) async {
    if (pem == null || pem.isEmpty) {
      await _storage.delete(key: SHOAppConstants.secureRsaPublicKeyKey);
      return;
    }
    await _storage.write(
      key: SHOAppConstants.secureRsaPublicKeyKey,
      value: pem,
    );
  }

  Future<String?> readRsaPublicKeyPem() =>
      _storage.read(key: SHOAppConstants.secureRsaPublicKeyKey);

  Future<void> writeRsaModulusExponent({
    required String modulus,
    required String exponent,
  }) async {
    await _storage.write(
      key: SHOAppConstants.secureRsaModulusKey,
      value: modulus,
    );
    await _storage.write(
      key: SHOAppConstants.secureRsaExponentKey,
      value: exponent,
    );
  }

  Future<({String modulus, String exponent})?> readRsaModulusExponent() async {
    final modulus = await _storage.read(
      key: SHOAppConstants.secureRsaModulusKey,
    );
    final exponent = await _storage.read(
      key: SHOAppConstants.secureRsaExponentKey,
    );
    if (modulus == null || exponent == null) return null;
    return (modulus: modulus, exponent: exponent);
  }

  // ---- SM4 Session Key ----

  Future<void> writeSm4Key(String? key) async {
    if (key == null || key.isEmpty) {
      await _storage.delete(key: SHOAppConstants.secureSm4KeyKey);
      return;
    }
    await _storage.write(key: SHOAppConstants.secureSm4KeyKey, value: key);
  }

  Future<String?> readSm4Key() =>
      _storage.read(key: SHOAppConstants.secureSm4KeyKey);

  Future<void> clear() => _storage.deleteAll();
}
