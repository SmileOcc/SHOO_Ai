import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shoo/core/config/hos_config.dart';
import 'package:shoo/core/network/hos_dio_client.dart';
import 'package:shoo/core/network/security/hos_crypto_service.dart';
import 'package:shoo/core/network/security/hos_rsa_api_helper.dart';
import 'package:shoo/features/auth/domain/entities/hos_auth_user.dart';

final authApiProvider = Provider<SHOAuthApi>((ref) {
  return SHOAuthApi(
    ref.watch(dioProvider),
    ref.watch(cryptoServiceProvider),
    ref.watch(appConfigProvider),
  );
});

class SHOAuthApi {
  SHOAuthApi(this._dio, this._crypto, this._config);

  final Dio _dio;
  final SHOCryptoService _crypto;
  final SHOAppConfig _config;

  Future<SHOAuthSession> login(SHOLoginRequest request) {
    return _postRsaEncrypted(
      '/auth/login',
      request.toJson(),
      (data) => SHOAuthSession.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<SHOAuthSession> register(SHOLoginRequest request) {
    return _postRsaEncrypted(
      '/auth/register',
      request.toJson(),
      (data) => SHOAuthSession.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<SHOAuthUser> fetchProfile() {
    return _dio.getData<SHOAuthUser>(
      '/auth/profile',
      parser: (data) => SHOAuthUser.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<SHOAuthSession> _postRsaEncrypted(
    String path,
    Map<String, dynamic> plainBody,
    SHOAuthSession Function(dynamic data) parser,
  ) async {
    final prepared = await SHORsaApiHelper.prepareRsaPost(
      config: _config,
      crypto: _crypto,
      plainBody: plainBody,
    );
    return _dio.postData<SHOAuthSession>(
      path,
      data: prepared.body,
      parser: parser,
      headers: prepared.headers.isEmpty ? null : prepared.headers,
      skipPayloadEncrypt: true,
    );
  }
}
