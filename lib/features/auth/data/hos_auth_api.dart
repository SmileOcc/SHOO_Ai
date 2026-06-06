import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/hos_dio_client.dart';
import '../domain/hos_auth_user.dart';

final authApiProvider = Provider<SHOAuthApi>((ref) {
  return SHOAuthApi(ref.watch(dioProvider));
});

class SHOAuthApi {
  SHOAuthApi(this._dio);

  final Dio _dio;

  Future<SHOAuthSession> login(SHOLoginRequest request) {
    return _dio.postData<SHOAuthSession>(
      '/auth/login',
      data: request.toJson(),
      parser: (data) => SHOAuthSession.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<SHOAuthUser> fetchProfile() {
    return _dio.getData<SHOAuthUser>(
      '/auth/profile',
      parser: (data) => SHOAuthUser.fromJson(data as Map<String, dynamic>),
    );
  }
}
