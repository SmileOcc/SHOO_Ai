import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';
import 'package:pointycastle/export.dart' hide State;

import 'package:shoo/core/storage/secure/hos_secure_storage.dart';

/// AES / RSA / 签名 / 国密 Demo 加解密服务。
class SHOCryptoService {
  SHOCryptoService(this._storage);

  final SHOSecureStorageService _storage;

  Future<String> ensureAesKey() async {
    final existing = await _storage.readAesKey();
    if (existing != null && existing.isNotEmpty) return existing;
    final key = Key.fromSecureRandom(32).base64;
    await _storage.writeAesKey(key);
    return key;
  }

  Future<String> ensureSignSecret() async {
    final existing = await _storage.readSignSecret();
    if (existing != null && existing.isNotEmpty) return existing;
    final secret = Key.fromSecureRandom(32).base64;
    await _storage.writeSignSecret(secret);
    return secret;
  }

  Future<RSAPublicKey> ensureRsaPublicKey() async {
    final stored = await _storage.readRsaModulusExponent();
    if (stored != null) {
      return RSAPublicKey(
        BigInt.parse(stored.modulus),
        BigInt.parse(stored.exponent),
      );
    }
    final pair = _generateRsaKeyPair();
    final publicKey = pair.publicKey as RSAPublicKey;
    await _storage.writeRsaModulusExponent(
      modulus: publicKey.modulus!.toString(),
      exponent: publicKey.exponent!.toString(),
    );
    return publicKey;
  }

  Future<String> ensureSm4Key() async {
    final existing = await _storage.readSm4Key();
    if (existing != null && existing.isNotEmpty) return existing;
    final key = Key.fromSecureRandom(16).base64;
    await _storage.writeSm4Key(key);
    return key;
  }

  Future<Map<String, dynamic>> encryptAes(Object data) async {
    final keyBase64 = await ensureAesKey();
    final key = Key.fromBase64(keyBase64);
    final iv = IV.fromSecureRandom(16);
    final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
    final plain = data is String ? data : jsonEncode(data);
    final encrypted = encrypter.encrypt(plain, iv: iv);
    return {'algorithm': 'aes', 'iv': iv.base64, 'payload': encrypted.base64};
  }

  Future<dynamic> decryptAes(Map<String, dynamic> envelope) async {
    final keyBase64 = await ensureAesKey();
    final key = Key.fromBase64(keyBase64);
    final iv = IV.fromBase64(envelope['iv'] as String);
    final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
    final decrypted = encrypter.decrypt64(
      envelope['payload'] as String,
      iv: iv,
    );
    return _tryParseJson(decrypted);
  }

  Future<Map<String, dynamic>> encryptRsa(Object data) async {
    final publicKey = await ensureRsaPublicKey();
    final encrypter = Encrypter(RSA(publicKey: publicKey));
    final plain = data is String ? data : jsonEncode(data);
    final encrypted = encrypter.encrypt(plain);
    return {'algorithm': 'rsa', 'payload': encrypted.base64};
  }

  Future<Map<String, dynamic>> encryptHybrid(Object data) async {
    final publicKey = await ensureRsaPublicKey();
    final rsaEncrypter = Encrypter(RSA(publicKey: publicKey));

    final sessionKey = Key.fromSecureRandom(32);
    final iv = IV.fromSecureRandom(16);
    final aesEncrypter = Encrypter(AES(sessionKey, mode: AESMode.cbc));
    final plain = data is String ? data : jsonEncode(data);
    final encryptedBody = aesEncrypter.encrypt(plain, iv: iv);
    final encryptedKey = rsaEncrypter.encrypt(sessionKey.base64);

    return {
      'algorithm': 'hybrid',
      'encryptedKey': encryptedKey.base64,
      'iv': iv.base64,
      'payload': encryptedBody.base64,
    };
  }

  /// 国密 SM4 Demo：使用 AES 同类块加密模拟 SM4 载荷格式。
  Future<Map<String, dynamic>> encryptSm4(Object data) async {
    final keyBase64 = await ensureSm4Key();
    final key = Key.fromBase64(keyBase64);
    final iv = IV.fromSecureRandom(16);
    final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
    final plain = data is String ? data : jsonEncode(data);
    final encrypted = encrypter.encrypt(plain, iv: iv);
    return {'algorithm': 'sm4', 'iv': iv.base64, 'payload': encrypted.base64};
  }

  Future<dynamic> decryptSm4(Map<String, dynamic> envelope) async {
    final keyBase64 = await ensureSm4Key();
    final key = Key.fromBase64(keyBase64);
    final iv = IV.fromBase64(envelope['iv'] as String);
    final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
    final decrypted = encrypter.decrypt64(
      envelope['payload'] as String,
      iv: iv,
    );
    return _tryParseJson(decrypted);
  }

  Future<String> signRequest({
    required String method,
    required String path,
    required String timestamp,
    required String nonce,
    Object? body,
  }) async {
    final secret = await ensureSignSecret();
    final bodyText = body == null
        ? ''
        : (body is String ? body : jsonEncode(body));
    final payload = '$method|$path|$timestamp|$nonce|$bodyText';
    final hmac = Hmac(sha256, utf8.encode(secret));
    return hmac.convert(utf8.encode(payload)).toString();
  }

  String generateNonce() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    return base64Url.encode(bytes);
  }

  dynamic _tryParseJson(String text) {
    try {
      return jsonDecode(text);
    } catch (_) {
      return text;
    }
  }

  AsymmetricKeyPair<PublicKey, PrivateKey> _generateRsaKeyPair() {
    final secureRandom = FortunaRandom();
    final seed = Uint8List.fromList(
      List<int>.generate(32, (_) => Random.secure().nextInt(256)),
    );
    secureRandom.seed(KeyParameter(seed));

    final keyGen = RSAKeyGenerator()
      ..init(
        ParametersWithRandom(
          RSAKeyGeneratorParameters(BigInt.parse('65537'), 2048, 64),
          secureRandom,
        ),
      );
    return keyGen.generateKeyPair();
  }
}
