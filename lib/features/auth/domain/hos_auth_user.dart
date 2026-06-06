import 'package:freezed_annotation/freezed_annotation.dart';

part 'hos_auth_user.freezed.dart';
part 'hos_auth_user.g.dart';

@freezed
class SHOAuthUser with _$SHOAuthUser {
  const factory SHOAuthUser({
    required String id,
    required String nickname,
    String? email,
    String? phone,
    String? avatarUrl,
  }) = _SHOAuthUser;

  factory SHOAuthUser.fromJson(Map<String, dynamic> json) =>
      _$SHOAuthUserFromJson(json);
}

@freezed
class SHOAuthSession with _$SHOAuthSession {
  const factory SHOAuthSession({
    required String token,
    required SHOAuthUser user,
  }) = _SHOAuthSession;

  factory SHOAuthSession.fromJson(Map<String, dynamic> json) =>
      _$SHOAuthSessionFromJson(json);
}

@freezed
class SHOLoginRequest with _$SHOLoginRequest {
  const factory SHOLoginRequest({
    required String phone,
    required String password,
  }) = _SHOLoginRequest;

  factory SHOLoginRequest.fromJson(Map<String, dynamic> json) =>
      _$SHOLoginRequestFromJson(json);
}
