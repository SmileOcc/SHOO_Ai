// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'hos_message.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

SHOAppMessage _$SHOAppMessageFromJson(Map<String, dynamic> json) {
  return _SHOAppMessage.fromJson(json);
}

/// @nodoc
mixin _$SHOAppMessage {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get body => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  String get createdAt => throw _privateConstructorUsedError;
  bool get isRead => throw _privateConstructorUsedError;

  /// Serializes this SHOAppMessage to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SHOAppMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SHOAppMessageCopyWith<SHOAppMessage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SHOAppMessageCopyWith<$Res> {
  factory $SHOAppMessageCopyWith(
    SHOAppMessage value,
    $Res Function(SHOAppMessage) then,
  ) = _$SHOAppMessageCopyWithImpl<$Res, SHOAppMessage>;
  @useResult
  $Res call({
    String id,
    String title,
    String body,
    String type,
    String createdAt,
    bool isRead,
  });
}

/// @nodoc
class _$SHOAppMessageCopyWithImpl<$Res, $Val extends SHOAppMessage>
    implements $SHOAppMessageCopyWith<$Res> {
  _$SHOAppMessageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SHOAppMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? body = null,
    Object? type = null,
    Object? createdAt = null,
    Object? isRead = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            body: null == body
                ? _value.body
                : body // ignore: cast_nullable_to_non_nullable
                      as String,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as String,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as String,
            isRead: null == isRead
                ? _value.isRead
                : isRead // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SHOAppMessageImplCopyWith<$Res>
    implements $SHOAppMessageCopyWith<$Res> {
  factory _$$SHOAppMessageImplCopyWith(
    _$SHOAppMessageImpl value,
    $Res Function(_$SHOAppMessageImpl) then,
  ) = __$$SHOAppMessageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String title,
    String body,
    String type,
    String createdAt,
    bool isRead,
  });
}

/// @nodoc
class __$$SHOAppMessageImplCopyWithImpl<$Res>
    extends _$SHOAppMessageCopyWithImpl<$Res, _$SHOAppMessageImpl>
    implements _$$SHOAppMessageImplCopyWith<$Res> {
  __$$SHOAppMessageImplCopyWithImpl(
    _$SHOAppMessageImpl _value,
    $Res Function(_$SHOAppMessageImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SHOAppMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? body = null,
    Object? type = null,
    Object? createdAt = null,
    Object? isRead = null,
  }) {
    return _then(
      _$SHOAppMessageImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        body: null == body
            ? _value.body
            : body // ignore: cast_nullable_to_non_nullable
                  as String,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as String,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as String,
        isRead: null == isRead
            ? _value.isRead
            : isRead // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SHOAppMessageImpl implements _SHOAppMessage {
  const _$SHOAppMessageImpl({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.createdAt,
    this.isRead = false,
  });

  factory _$SHOAppMessageImpl.fromJson(Map<String, dynamic> json) =>
      _$$SHOAppMessageImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final String body;
  @override
  final String type;
  @override
  final String createdAt;
  @override
  @JsonKey()
  final bool isRead;

  @override
  String toString() {
    return 'SHOAppMessage(id: $id, title: $title, body: $body, type: $type, createdAt: $createdAt, isRead: $isRead)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SHOAppMessageImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.body, body) || other.body == body) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.isRead, isRead) || other.isRead == isRead));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, title, body, type, createdAt, isRead);

  /// Create a copy of SHOAppMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SHOAppMessageImplCopyWith<_$SHOAppMessageImpl> get copyWith =>
      __$$SHOAppMessageImplCopyWithImpl<_$SHOAppMessageImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SHOAppMessageImplToJson(this);
  }
}

abstract class _SHOAppMessage implements SHOAppMessage {
  const factory _SHOAppMessage({
    required final String id,
    required final String title,
    required final String body,
    required final String type,
    required final String createdAt,
    final bool isRead,
  }) = _$SHOAppMessageImpl;

  factory _SHOAppMessage.fromJson(Map<String, dynamic> json) =
      _$SHOAppMessageImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String get body;
  @override
  String get type;
  @override
  String get createdAt;
  @override
  bool get isRead;

  /// Create a copy of SHOAppMessage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SHOAppMessageImplCopyWith<_$SHOAppMessageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
