// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'hos_payment_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

SHOPaymentResult _$SHOPaymentResultFromJson(Map<String, dynamic> json) {
  return _SHOPaymentResult.fromJson(json);
}

/// @nodoc
mixin _$SHOPaymentResult {
  String get orderId => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  String get paidAt => throw _privateConstructorUsedError;
  String get message => throw _privateConstructorUsedError;

  /// Serializes this SHOPaymentResult to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SHOPaymentResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SHOPaymentResultCopyWith<SHOPaymentResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SHOPaymentResultCopyWith<$Res> {
  factory $SHOPaymentResultCopyWith(
    SHOPaymentResult value,
    $Res Function(SHOPaymentResult) then,
  ) = _$SHOPaymentResultCopyWithImpl<$Res, SHOPaymentResult>;
  @useResult
  $Res call({String orderId, String status, String paidAt, String message});
}

/// @nodoc
class _$SHOPaymentResultCopyWithImpl<$Res, $Val extends SHOPaymentResult>
    implements $SHOPaymentResultCopyWith<$Res> {
  _$SHOPaymentResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SHOPaymentResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? orderId = null,
    Object? status = null,
    Object? paidAt = null,
    Object? message = null,
  }) {
    return _then(
      _value.copyWith(
            orderId: null == orderId
                ? _value.orderId
                : orderId // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            paidAt: null == paidAt
                ? _value.paidAt
                : paidAt // ignore: cast_nullable_to_non_nullable
                      as String,
            message: null == message
                ? _value.message
                : message // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SHOPaymentResultImplCopyWith<$Res>
    implements $SHOPaymentResultCopyWith<$Res> {
  factory _$$SHOPaymentResultImplCopyWith(
    _$SHOPaymentResultImpl value,
    $Res Function(_$SHOPaymentResultImpl) then,
  ) = __$$SHOPaymentResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String orderId, String status, String paidAt, String message});
}

/// @nodoc
class __$$SHOPaymentResultImplCopyWithImpl<$Res>
    extends _$SHOPaymentResultCopyWithImpl<$Res, _$SHOPaymentResultImpl>
    implements _$$SHOPaymentResultImplCopyWith<$Res> {
  __$$SHOPaymentResultImplCopyWithImpl(
    _$SHOPaymentResultImpl _value,
    $Res Function(_$SHOPaymentResultImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SHOPaymentResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? orderId = null,
    Object? status = null,
    Object? paidAt = null,
    Object? message = null,
  }) {
    return _then(
      _$SHOPaymentResultImpl(
        orderId: null == orderId
            ? _value.orderId
            : orderId // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        paidAt: null == paidAt
            ? _value.paidAt
            : paidAt // ignore: cast_nullable_to_non_nullable
                  as String,
        message: null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SHOPaymentResultImpl implements _SHOPaymentResult {
  const _$SHOPaymentResultImpl({
    required this.orderId,
    required this.status,
    required this.paidAt,
    this.message = '',
  });

  factory _$SHOPaymentResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$SHOPaymentResultImplFromJson(json);

  @override
  final String orderId;
  @override
  final String status;
  @override
  final String paidAt;
  @override
  @JsonKey()
  final String message;

  @override
  String toString() {
    return 'SHOPaymentResult(orderId: $orderId, status: $status, paidAt: $paidAt, message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SHOPaymentResultImpl &&
            (identical(other.orderId, orderId) || other.orderId == orderId) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.paidAt, paidAt) || other.paidAt == paidAt) &&
            (identical(other.message, message) || other.message == message));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, orderId, status, paidAt, message);

  /// Create a copy of SHOPaymentResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SHOPaymentResultImplCopyWith<_$SHOPaymentResultImpl> get copyWith =>
      __$$SHOPaymentResultImplCopyWithImpl<_$SHOPaymentResultImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$SHOPaymentResultImplToJson(this);
  }
}

abstract class _SHOPaymentResult implements SHOPaymentResult {
  const factory _SHOPaymentResult({
    required final String orderId,
    required final String status,
    required final String paidAt,
    final String message,
  }) = _$SHOPaymentResultImpl;

  factory _SHOPaymentResult.fromJson(Map<String, dynamic> json) =
      _$SHOPaymentResultImpl.fromJson;

  @override
  String get orderId;
  @override
  String get status;
  @override
  String get paidAt;
  @override
  String get message;

  /// Create a copy of SHOPaymentResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SHOPaymentResultImplCopyWith<_$SHOPaymentResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
