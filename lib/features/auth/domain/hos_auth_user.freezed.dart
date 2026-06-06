// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'hos_auth_user.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

SHOAuthUser _$SHOAuthUserFromJson(Map<String, dynamic> json) {
  return _SHOAuthUser.fromJson(json);
}

/// @nodoc
mixin _$SHOAuthUser {
  String get id => throw _privateConstructorUsedError;
  String get nickname => throw _privateConstructorUsedError;
  String? get email => throw _privateConstructorUsedError;
  String? get phone => throw _privateConstructorUsedError;
  String? get avatarUrl => throw _privateConstructorUsedError;

  /// Serializes this SHOAuthUser to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SHOAuthUser
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SHOAuthUserCopyWith<SHOAuthUser> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SHOAuthUserCopyWith<$Res> {
  factory $SHOAuthUserCopyWith(
    SHOAuthUser value,
    $Res Function(SHOAuthUser) then,
  ) = _$SHOAuthUserCopyWithImpl<$Res, SHOAuthUser>;
  @useResult
  $Res call({
    String id,
    String nickname,
    String? email,
    String? phone,
    String? avatarUrl,
  });
}

/// @nodoc
class _$SHOAuthUserCopyWithImpl<$Res, $Val extends SHOAuthUser>
    implements $SHOAuthUserCopyWith<$Res> {
  _$SHOAuthUserCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SHOAuthUser
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? nickname = null,
    Object? email = freezed,
    Object? phone = freezed,
    Object? avatarUrl = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            nickname: null == nickname
                ? _value.nickname
                : nickname // ignore: cast_nullable_to_non_nullable
                      as String,
            email: freezed == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                      as String?,
            phone: freezed == phone
                ? _value.phone
                : phone // ignore: cast_nullable_to_non_nullable
                      as String?,
            avatarUrl: freezed == avatarUrl
                ? _value.avatarUrl
                : avatarUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SHOAuthUserImplCopyWith<$Res>
    implements $SHOAuthUserCopyWith<$Res> {
  factory _$$SHOAuthUserImplCopyWith(
    _$SHOAuthUserImpl value,
    $Res Function(_$SHOAuthUserImpl) then,
  ) = __$$SHOAuthUserImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String nickname,
    String? email,
    String? phone,
    String? avatarUrl,
  });
}

/// @nodoc
class __$$SHOAuthUserImplCopyWithImpl<$Res>
    extends _$SHOAuthUserCopyWithImpl<$Res, _$SHOAuthUserImpl>
    implements _$$SHOAuthUserImplCopyWith<$Res> {
  __$$SHOAuthUserImplCopyWithImpl(
    _$SHOAuthUserImpl _value,
    $Res Function(_$SHOAuthUserImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SHOAuthUser
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? nickname = null,
    Object? email = freezed,
    Object? phone = freezed,
    Object? avatarUrl = freezed,
  }) {
    return _then(
      _$SHOAuthUserImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        nickname: null == nickname
            ? _value.nickname
            : nickname // ignore: cast_nullable_to_non_nullable
                  as String,
        email: freezed == email
            ? _value.email
            : email // ignore: cast_nullable_to_non_nullable
                  as String?,
        phone: freezed == phone
            ? _value.phone
            : phone // ignore: cast_nullable_to_non_nullable
                  as String?,
        avatarUrl: freezed == avatarUrl
            ? _value.avatarUrl
            : avatarUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SHOAuthUserImpl implements _SHOAuthUser {
  const _$SHOAuthUserImpl({
    required this.id,
    required this.nickname,
    this.email,
    this.phone,
    this.avatarUrl,
  });

  factory _$SHOAuthUserImpl.fromJson(Map<String, dynamic> json) =>
      _$$SHOAuthUserImplFromJson(json);

  @override
  final String id;
  @override
  final String nickname;
  @override
  final String? email;
  @override
  final String? phone;
  @override
  final String? avatarUrl;

  @override
  String toString() {
    return 'SHOAuthUser(id: $id, nickname: $nickname, email: $email, phone: $phone, avatarUrl: $avatarUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SHOAuthUserImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.nickname, nickname) ||
                other.nickname == nickname) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.avatarUrl, avatarUrl) ||
                other.avatarUrl == avatarUrl));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, nickname, email, phone, avatarUrl);

  /// Create a copy of SHOAuthUser
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SHOAuthUserImplCopyWith<_$SHOAuthUserImpl> get copyWith =>
      __$$SHOAuthUserImplCopyWithImpl<_$SHOAuthUserImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SHOAuthUserImplToJson(this);
  }
}

abstract class _SHOAuthUser implements SHOAuthUser {
  const factory _SHOAuthUser({
    required final String id,
    required final String nickname,
    final String? email,
    final String? phone,
    final String? avatarUrl,
  }) = _$SHOAuthUserImpl;

  factory _SHOAuthUser.fromJson(Map<String, dynamic> json) =
      _$SHOAuthUserImpl.fromJson;

  @override
  String get id;
  @override
  String get nickname;
  @override
  String? get email;
  @override
  String? get phone;
  @override
  String? get avatarUrl;

  /// Create a copy of SHOAuthUser
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SHOAuthUserImplCopyWith<_$SHOAuthUserImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SHOAuthSession _$SHOAuthSessionFromJson(Map<String, dynamic> json) {
  return _SHOAuthSession.fromJson(json);
}

/// @nodoc
mixin _$SHOAuthSession {
  String get token => throw _privateConstructorUsedError;
  SHOAuthUser get user => throw _privateConstructorUsedError;

  /// Serializes this SHOAuthSession to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SHOAuthSession
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SHOAuthSessionCopyWith<SHOAuthSession> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SHOAuthSessionCopyWith<$Res> {
  factory $SHOAuthSessionCopyWith(
    SHOAuthSession value,
    $Res Function(SHOAuthSession) then,
  ) = _$SHOAuthSessionCopyWithImpl<$Res, SHOAuthSession>;
  @useResult
  $Res call({String token, SHOAuthUser user});

  $SHOAuthUserCopyWith<$Res> get user;
}

/// @nodoc
class _$SHOAuthSessionCopyWithImpl<$Res, $Val extends SHOAuthSession>
    implements $SHOAuthSessionCopyWith<$Res> {
  _$SHOAuthSessionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SHOAuthSession
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? token = null, Object? user = null}) {
    return _then(
      _value.copyWith(
            token: null == token
                ? _value.token
                : token // ignore: cast_nullable_to_non_nullable
                      as String,
            user: null == user
                ? _value.user
                : user // ignore: cast_nullable_to_non_nullable
                      as SHOAuthUser,
          )
          as $Val,
    );
  }

  /// Create a copy of SHOAuthSession
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SHOAuthUserCopyWith<$Res> get user {
    return $SHOAuthUserCopyWith<$Res>(_value.user, (value) {
      return _then(_value.copyWith(user: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$SHOAuthSessionImplCopyWith<$Res>
    implements $SHOAuthSessionCopyWith<$Res> {
  factory _$$SHOAuthSessionImplCopyWith(
    _$SHOAuthSessionImpl value,
    $Res Function(_$SHOAuthSessionImpl) then,
  ) = __$$SHOAuthSessionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String token, SHOAuthUser user});

  @override
  $SHOAuthUserCopyWith<$Res> get user;
}

/// @nodoc
class __$$SHOAuthSessionImplCopyWithImpl<$Res>
    extends _$SHOAuthSessionCopyWithImpl<$Res, _$SHOAuthSessionImpl>
    implements _$$SHOAuthSessionImplCopyWith<$Res> {
  __$$SHOAuthSessionImplCopyWithImpl(
    _$SHOAuthSessionImpl _value,
    $Res Function(_$SHOAuthSessionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SHOAuthSession
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? token = null, Object? user = null}) {
    return _then(
      _$SHOAuthSessionImpl(
        token: null == token
            ? _value.token
            : token // ignore: cast_nullable_to_non_nullable
                  as String,
        user: null == user
            ? _value.user
            : user // ignore: cast_nullable_to_non_nullable
                  as SHOAuthUser,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SHOAuthSessionImpl implements _SHOAuthSession {
  const _$SHOAuthSessionImpl({required this.token, required this.user});

  factory _$SHOAuthSessionImpl.fromJson(Map<String, dynamic> json) =>
      _$$SHOAuthSessionImplFromJson(json);

  @override
  final String token;
  @override
  final SHOAuthUser user;

  @override
  String toString() {
    return 'SHOAuthSession(token: $token, user: $user)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SHOAuthSessionImpl &&
            (identical(other.token, token) || other.token == token) &&
            (identical(other.user, user) || other.user == user));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, token, user);

  /// Create a copy of SHOAuthSession
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SHOAuthSessionImplCopyWith<_$SHOAuthSessionImpl> get copyWith =>
      __$$SHOAuthSessionImplCopyWithImpl<_$SHOAuthSessionImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$SHOAuthSessionImplToJson(this);
  }
}

abstract class _SHOAuthSession implements SHOAuthSession {
  const factory _SHOAuthSession({
    required final String token,
    required final SHOAuthUser user,
  }) = _$SHOAuthSessionImpl;

  factory _SHOAuthSession.fromJson(Map<String, dynamic> json) =
      _$SHOAuthSessionImpl.fromJson;

  @override
  String get token;
  @override
  SHOAuthUser get user;

  /// Create a copy of SHOAuthSession
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SHOAuthSessionImplCopyWith<_$SHOAuthSessionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SHOLoginRequest _$SHOLoginRequestFromJson(Map<String, dynamic> json) {
  return _SHOLoginRequest.fromJson(json);
}

/// @nodoc
mixin _$SHOLoginRequest {
  String get phone => throw _privateConstructorUsedError;
  String get password => throw _privateConstructorUsedError;

  /// Serializes this SHOLoginRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SHOLoginRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SHOLoginRequestCopyWith<SHOLoginRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SHOLoginRequestCopyWith<$Res> {
  factory $SHOLoginRequestCopyWith(
    SHOLoginRequest value,
    $Res Function(SHOLoginRequest) then,
  ) = _$SHOLoginRequestCopyWithImpl<$Res, SHOLoginRequest>;
  @useResult
  $Res call({String phone, String password});
}

/// @nodoc
class _$SHOLoginRequestCopyWithImpl<$Res, $Val extends SHOLoginRequest>
    implements $SHOLoginRequestCopyWith<$Res> {
  _$SHOLoginRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SHOLoginRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? phone = null, Object? password = null}) {
    return _then(
      _value.copyWith(
            phone: null == phone
                ? _value.phone
                : phone // ignore: cast_nullable_to_non_nullable
                      as String,
            password: null == password
                ? _value.password
                : password // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SHOLoginRequestImplCopyWith<$Res>
    implements $SHOLoginRequestCopyWith<$Res> {
  factory _$$SHOLoginRequestImplCopyWith(
    _$SHOLoginRequestImpl value,
    $Res Function(_$SHOLoginRequestImpl) then,
  ) = __$$SHOLoginRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String phone, String password});
}

/// @nodoc
class __$$SHOLoginRequestImplCopyWithImpl<$Res>
    extends _$SHOLoginRequestCopyWithImpl<$Res, _$SHOLoginRequestImpl>
    implements _$$SHOLoginRequestImplCopyWith<$Res> {
  __$$SHOLoginRequestImplCopyWithImpl(
    _$SHOLoginRequestImpl _value,
    $Res Function(_$SHOLoginRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SHOLoginRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? phone = null, Object? password = null}) {
    return _then(
      _$SHOLoginRequestImpl(
        phone: null == phone
            ? _value.phone
            : phone // ignore: cast_nullable_to_non_nullable
                  as String,
        password: null == password
            ? _value.password
            : password // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SHOLoginRequestImpl implements _SHOLoginRequest {
  const _$SHOLoginRequestImpl({required this.phone, required this.password});

  factory _$SHOLoginRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$SHOLoginRequestImplFromJson(json);

  @override
  final String phone;
  @override
  final String password;

  @override
  String toString() {
    return 'SHOLoginRequest(phone: $phone, password: $password)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SHOLoginRequestImpl &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.password, password) ||
                other.password == password));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, phone, password);

  /// Create a copy of SHOLoginRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SHOLoginRequestImplCopyWith<_$SHOLoginRequestImpl> get copyWith =>
      __$$SHOLoginRequestImplCopyWithImpl<_$SHOLoginRequestImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$SHOLoginRequestImplToJson(this);
  }
}

abstract class _SHOLoginRequest implements SHOLoginRequest {
  const factory _SHOLoginRequest({
    required final String phone,
    required final String password,
  }) = _$SHOLoginRequestImpl;

  factory _SHOLoginRequest.fromJson(Map<String, dynamic> json) =
      _$SHOLoginRequestImpl.fromJson;

  @override
  String get phone;
  @override
  String get password;

  /// Create a copy of SHOLoginRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SHOLoginRequestImplCopyWith<_$SHOLoginRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
