// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hos_auth_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SHOAuthUserImpl _$$SHOAuthUserImplFromJson(Map<String, dynamic> json) =>
    _$SHOAuthUserImpl(
      id: json['id'] as String,
      nickname: json['nickname'] as String,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
    );

Map<String, dynamic> _$$SHOAuthUserImplToJson(_$SHOAuthUserImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nickname': instance.nickname,
      'email': instance.email,
      'phone': instance.phone,
      'avatarUrl': instance.avatarUrl,
    };

_$SHOAuthSessionImpl _$$SHOAuthSessionImplFromJson(Map<String, dynamic> json) =>
    _$SHOAuthSessionImpl(
      token: json['token'] as String,
      user: SHOAuthUser.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$SHOAuthSessionImplToJson(
  _$SHOAuthSessionImpl instance,
) => <String, dynamic>{'token': instance.token, 'user': instance.user};

_$SHOLoginRequestImpl _$$SHOLoginRequestImplFromJson(
  Map<String, dynamic> json,
) => _$SHOLoginRequestImpl(
  phone: json['phone'] as String,
  password: json['password'] as String,
);

Map<String, dynamic> _$$SHOLoginRequestImplToJson(
  _$SHOLoginRequestImpl instance,
) => <String, dynamic>{'phone': instance.phone, 'password': instance.password};
