// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'hos_flash_sale_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

SHOFlashSalePromoTag _$SHOFlashSalePromoTagFromJson(Map<String, dynamic> json) {
  return _SHOFlashSalePromoTag.fromJson(json);
}

// mixin 限制 Dart mixin 不能定义抽象方法（abstract）
/// @nodoc
mixin _$SHOFlashSalePromoTag {
  String get type => throw _privateConstructorUsedError;
  String get label => throw _privateConstructorUsedError;
  bool get enabled => throw _privateConstructorUsedError;

  /// Serializes this SHOFlashSalePromoTag to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SHOFlashSalePromoTag
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SHOFlashSalePromoTagCopyWith<SHOFlashSalePromoTag> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SHOFlashSalePromoTagCopyWith<$Res> {
  factory $SHOFlashSalePromoTagCopyWith(
    SHOFlashSalePromoTag value,
    $Res Function(SHOFlashSalePromoTag) then,
  ) = _$SHOFlashSalePromoTagCopyWithImpl<$Res, SHOFlashSalePromoTag>;
  @useResult
  $Res call({String type, String label, bool enabled});
}

/// @nodoc
class _$SHOFlashSalePromoTagCopyWithImpl<
  $Res,
  $Val extends SHOFlashSalePromoTag
>
    implements $SHOFlashSalePromoTagCopyWith<$Res> {
  _$SHOFlashSalePromoTagCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SHOFlashSalePromoTag
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? label = null,
    Object? enabled = null,
  }) {
    return _then(
      _value.copyWith(
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as String,
            label: null == label
                ? _value.label
                : label // ignore: cast_nullable_to_non_nullable
                      as String,
            enabled: null == enabled
                ? _value.enabled
                : enabled // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SHOFlashSalePromoTagImplCopyWith<$Res>
    implements $SHOFlashSalePromoTagCopyWith<$Res> {
  factory _$$SHOFlashSalePromoTagImplCopyWith(
    _$SHOFlashSalePromoTagImpl value,
    $Res Function(_$SHOFlashSalePromoTagImpl) then,
  ) = __$$SHOFlashSalePromoTagImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String type, String label, bool enabled});
}

/// @nodoc
class __$$SHOFlashSalePromoTagImplCopyWithImpl<$Res>
    extends _$SHOFlashSalePromoTagCopyWithImpl<$Res, _$SHOFlashSalePromoTagImpl>
    implements _$$SHOFlashSalePromoTagImplCopyWith<$Res> {
  __$$SHOFlashSalePromoTagImplCopyWithImpl(
    _$SHOFlashSalePromoTagImpl _value,
    $Res Function(_$SHOFlashSalePromoTagImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SHOFlashSalePromoTag
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? label = null,
    Object? enabled = null,
  }) {
    return _then(
      _$SHOFlashSalePromoTagImpl(
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as String,
        label: null == label
            ? _value.label
            : label // ignore: cast_nullable_to_non_nullable
                  as String,
        enabled: null == enabled
            ? _value.enabled
            : enabled // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SHOFlashSalePromoTagImpl extends _SHOFlashSalePromoTag {
  const _$SHOFlashSalePromoTagImpl({
    required this.type,
    required this.label,
    this.enabled = true,
  }) : super._();

  factory _$SHOFlashSalePromoTagImpl.fromJson(Map<String, dynamic> json) =>
      _$$SHOFlashSalePromoTagImplFromJson(json);

  @override
  final String type;
  @override
  final String label;
  @override
  @JsonKey()
  final bool enabled;

  @override
  String toString() {
    return 'SHOFlashSalePromoTag(type: $type, label: $label, enabled: $enabled)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SHOFlashSalePromoTagImpl &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.label, label) || other.label == label) &&
            (identical(other.enabled, enabled) || other.enabled == enabled));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, type, label, enabled);

  /// Create a copy of SHOFlashSalePromoTag
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SHOFlashSalePromoTagImplCopyWith<_$SHOFlashSalePromoTagImpl>
  get copyWith =>
      __$$SHOFlashSalePromoTagImplCopyWithImpl<_$SHOFlashSalePromoTagImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$SHOFlashSalePromoTagImplToJson(this);
  }
}

abstract class _SHOFlashSalePromoTag extends SHOFlashSalePromoTag {
  const factory _SHOFlashSalePromoTag({
    required final String type,
    required final String label,
    final bool enabled,
  }) = _$SHOFlashSalePromoTagImpl;
  const _SHOFlashSalePromoTag._() : super._();

  factory _SHOFlashSalePromoTag.fromJson(Map<String, dynamic> json) =
      _$SHOFlashSalePromoTagImpl.fromJson;

  @override
  String get type;
  @override
  String get label;
  @override
  bool get enabled;

  /// Create a copy of SHOFlashSalePromoTag
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SHOFlashSalePromoTagImplCopyWith<_$SHOFlashSalePromoTagImpl>
  get copyWith => throw _privateConstructorUsedError;
}

SHOFlashSaleCalendar _$SHOFlashSaleCalendarFromJson(Map<String, dynamic> json) {
  return _SHOFlashSaleCalendar.fromJson(json);
}

/// @nodoc
mixin _$SHOFlashSaleCalendar {
  String get serverTime => throw _privateConstructorUsedError;
  List<SHOFlashSaleDay> get days => throw _privateConstructorUsedError;

  /// Serializes this SHOFlashSaleCalendar to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SHOFlashSaleCalendar
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SHOFlashSaleCalendarCopyWith<SHOFlashSaleCalendar> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SHOFlashSaleCalendarCopyWith<$Res> {
  factory $SHOFlashSaleCalendarCopyWith(
    SHOFlashSaleCalendar value,
    $Res Function(SHOFlashSaleCalendar) then,
  ) = _$SHOFlashSaleCalendarCopyWithImpl<$Res, SHOFlashSaleCalendar>;
  @useResult
  $Res call({String serverTime, List<SHOFlashSaleDay> days});
}

/// @nodoc
class _$SHOFlashSaleCalendarCopyWithImpl<
  $Res,
  $Val extends SHOFlashSaleCalendar
>
    implements $SHOFlashSaleCalendarCopyWith<$Res> {
  _$SHOFlashSaleCalendarCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SHOFlashSaleCalendar
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? serverTime = null, Object? days = null}) {
    return _then(
      _value.copyWith(
            serverTime: null == serverTime
                ? _value.serverTime
                : serverTime // ignore: cast_nullable_to_non_nullable
                      as String,
            days: null == days
                ? _value.days
                : days // ignore: cast_nullable_to_non_nullable
                      as List<SHOFlashSaleDay>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SHOFlashSaleCalendarImplCopyWith<$Res>
    implements $SHOFlashSaleCalendarCopyWith<$Res> {
  factory _$$SHOFlashSaleCalendarImplCopyWith(
    _$SHOFlashSaleCalendarImpl value,
    $Res Function(_$SHOFlashSaleCalendarImpl) then,
  ) = __$$SHOFlashSaleCalendarImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String serverTime, List<SHOFlashSaleDay> days});
}

/// @nodoc
class __$$SHOFlashSaleCalendarImplCopyWithImpl<$Res>
    extends _$SHOFlashSaleCalendarCopyWithImpl<$Res, _$SHOFlashSaleCalendarImpl>
    implements _$$SHOFlashSaleCalendarImplCopyWith<$Res> {
  __$$SHOFlashSaleCalendarImplCopyWithImpl(
    _$SHOFlashSaleCalendarImpl _value,
    $Res Function(_$SHOFlashSaleCalendarImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SHOFlashSaleCalendar
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? serverTime = null, Object? days = null}) {
    return _then(
      _$SHOFlashSaleCalendarImpl(
        serverTime: null == serverTime
            ? _value.serverTime
            : serverTime // ignore: cast_nullable_to_non_nullable
                  as String,
        days: null == days
            ? _value._days
            : days // ignore: cast_nullable_to_non_nullable
                  as List<SHOFlashSaleDay>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SHOFlashSaleCalendarImpl implements _SHOFlashSaleCalendar {
  const _$SHOFlashSaleCalendarImpl({
    required this.serverTime,
    required final List<SHOFlashSaleDay> days,
  }) : _days = days;

  factory _$SHOFlashSaleCalendarImpl.fromJson(Map<String, dynamic> json) =>
      _$$SHOFlashSaleCalendarImplFromJson(json);

  @override
  final String serverTime;
  final List<SHOFlashSaleDay> _days;
  @override
  List<SHOFlashSaleDay> get days {
    if (_days is EqualUnmodifiableListView) return _days;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_days);
  }

  @override
  String toString() {
    return 'SHOFlashSaleCalendar(serverTime: $serverTime, days: $days)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SHOFlashSaleCalendarImpl &&
            (identical(other.serverTime, serverTime) ||
                other.serverTime == serverTime) &&
            const DeepCollectionEquality().equals(other._days, _days));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    serverTime,
    const DeepCollectionEquality().hash(_days),
  );

  /// Create a copy of SHOFlashSaleCalendar
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SHOFlashSaleCalendarImplCopyWith<_$SHOFlashSaleCalendarImpl>
  get copyWith =>
      __$$SHOFlashSaleCalendarImplCopyWithImpl<_$SHOFlashSaleCalendarImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$SHOFlashSaleCalendarImplToJson(this);
  }
}

abstract class _SHOFlashSaleCalendar implements SHOFlashSaleCalendar {
  const factory _SHOFlashSaleCalendar({
    required final String serverTime,
    required final List<SHOFlashSaleDay> days,
  }) = _$SHOFlashSaleCalendarImpl;

  factory _SHOFlashSaleCalendar.fromJson(Map<String, dynamic> json) =
      _$SHOFlashSaleCalendarImpl.fromJson;

  @override
  String get serverTime;
  @override
  List<SHOFlashSaleDay> get days;

  /// Create a copy of SHOFlashSaleCalendar
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SHOFlashSaleCalendarImplCopyWith<_$SHOFlashSaleCalendarImpl>
  get copyWith => throw _privateConstructorUsedError;
}

SHOFlashSaleDay _$SHOFlashSaleDayFromJson(Map<String, dynamic> json) {
  return _SHOFlashSaleDay.fromJson(json);
}

/// @nodoc
mixin _$SHOFlashSaleDay {
  String get date => throw _privateConstructorUsedError;
  String get label => throw _privateConstructorUsedError;
  String get weekday => throw _privateConstructorUsedError;
  SHOFlashSaleDayStatus get status => throw _privateConstructorUsedError;
  int get sessionCount => throw _privateConstructorUsedError;

  /// Serializes this SHOFlashSaleDay to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SHOFlashSaleDay
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SHOFlashSaleDayCopyWith<SHOFlashSaleDay> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SHOFlashSaleDayCopyWith<$Res> {
  factory $SHOFlashSaleDayCopyWith(
    SHOFlashSaleDay value,
    $Res Function(SHOFlashSaleDay) then,
  ) = _$SHOFlashSaleDayCopyWithImpl<$Res, SHOFlashSaleDay>;
  @useResult
  $Res call({
    String date,
    String label,
    String weekday,
    SHOFlashSaleDayStatus status,
    int sessionCount,
  });
}

/// @nodoc
class _$SHOFlashSaleDayCopyWithImpl<$Res, $Val extends SHOFlashSaleDay>
    implements $SHOFlashSaleDayCopyWith<$Res> {
  _$SHOFlashSaleDayCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SHOFlashSaleDay
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? label = null,
    Object? weekday = null,
    Object? status = null,
    Object? sessionCount = null,
  }) {
    return _then(
      _value.copyWith(
            date: null == date
                ? _value.date
                : date // ignore: cast_nullable_to_non_nullable
                      as String,
            label: null == label
                ? _value.label
                : label // ignore: cast_nullable_to_non_nullable
                      as String,
            weekday: null == weekday
                ? _value.weekday
                : weekday // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as SHOFlashSaleDayStatus,
            sessionCount: null == sessionCount
                ? _value.sessionCount
                : sessionCount // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SHOFlashSaleDayImplCopyWith<$Res>
    implements $SHOFlashSaleDayCopyWith<$Res> {
  factory _$$SHOFlashSaleDayImplCopyWith(
    _$SHOFlashSaleDayImpl value,
    $Res Function(_$SHOFlashSaleDayImpl) then,
  ) = __$$SHOFlashSaleDayImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String date,
    String label,
    String weekday,
    SHOFlashSaleDayStatus status,
    int sessionCount,
  });
}

/// @nodoc
class __$$SHOFlashSaleDayImplCopyWithImpl<$Res>
    extends _$SHOFlashSaleDayCopyWithImpl<$Res, _$SHOFlashSaleDayImpl>
    implements _$$SHOFlashSaleDayImplCopyWith<$Res> {
  __$$SHOFlashSaleDayImplCopyWithImpl(
    _$SHOFlashSaleDayImpl _value,
    $Res Function(_$SHOFlashSaleDayImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SHOFlashSaleDay
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? label = null,
    Object? weekday = null,
    Object? status = null,
    Object? sessionCount = null,
  }) {
    return _then(
      _$SHOFlashSaleDayImpl(
        date: null == date
            ? _value.date
            : date // ignore: cast_nullable_to_non_nullable
                  as String,
        label: null == label
            ? _value.label
            : label // ignore: cast_nullable_to_non_nullable
                  as String,
        weekday: null == weekday
            ? _value.weekday
            : weekday // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as SHOFlashSaleDayStatus,
        sessionCount: null == sessionCount
            ? _value.sessionCount
            : sessionCount // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SHOFlashSaleDayImpl implements _SHOFlashSaleDay {
  const _$SHOFlashSaleDayImpl({
    required this.date,
    required this.label,
    required this.weekday,
    this.status = SHOFlashSaleDayStatus.notStarted,
    this.sessionCount = 0,
  });

  factory _$SHOFlashSaleDayImpl.fromJson(Map<String, dynamic> json) =>
      _$$SHOFlashSaleDayImplFromJson(json);

  @override
  final String date;
  @override
  final String label;
  @override
  final String weekday;
  @override
  @JsonKey()
  final SHOFlashSaleDayStatus status;
  @override
  @JsonKey()
  final int sessionCount;

  @override
  String toString() {
    return 'SHOFlashSaleDay(date: $date, label: $label, weekday: $weekday, status: $status, sessionCount: $sessionCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SHOFlashSaleDayImpl &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.label, label) || other.label == label) &&
            (identical(other.weekday, weekday) || other.weekday == weekday) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.sessionCount, sessionCount) ||
                other.sessionCount == sessionCount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, date, label, weekday, status, sessionCount);

  /// Create a copy of SHOFlashSaleDay
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SHOFlashSaleDayImplCopyWith<_$SHOFlashSaleDayImpl> get copyWith =>
      __$$SHOFlashSaleDayImplCopyWithImpl<_$SHOFlashSaleDayImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$SHOFlashSaleDayImplToJson(this);
  }
}

abstract class _SHOFlashSaleDay implements SHOFlashSaleDay {
  const factory _SHOFlashSaleDay({
    required final String date,
    required final String label,
    required final String weekday,
    final SHOFlashSaleDayStatus status,
    final int sessionCount,
  }) = _$SHOFlashSaleDayImpl;

  factory _SHOFlashSaleDay.fromJson(Map<String, dynamic> json) =
      _$SHOFlashSaleDayImpl.fromJson;

  @override
  String get date;
  @override
  String get label;
  @override
  String get weekday;
  @override
  SHOFlashSaleDayStatus get status;
  @override
  int get sessionCount;

  /// Create a copy of SHOFlashSaleDay
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SHOFlashSaleDayImplCopyWith<_$SHOFlashSaleDayImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SHOFlashSaleSession _$SHOFlashSaleSessionFromJson(Map<String, dynamic> json) {
  return _SHOFlashSaleSession.fromJson(json);
}

/// @nodoc
mixin _$SHOFlashSaleSession {
  String get id => throw _privateConstructorUsedError;
  String get label => throw _privateConstructorUsedError;
  String get startAt => throw _privateConstructorUsedError;
  String get endAt => throw _privateConstructorUsedError;
  String get claimStartAt => throw _privateConstructorUsedError;
  String get claimEndAt => throw _privateConstructorUsedError;
  SHOFlashSaleDayStatus get status => throw _privateConstructorUsedError;

  /// Serializes this SHOFlashSaleSession to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SHOFlashSaleSession
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SHOFlashSaleSessionCopyWith<SHOFlashSaleSession> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SHOFlashSaleSessionCopyWith<$Res> {
  factory $SHOFlashSaleSessionCopyWith(
    SHOFlashSaleSession value,
    $Res Function(SHOFlashSaleSession) then,
  ) = _$SHOFlashSaleSessionCopyWithImpl<$Res, SHOFlashSaleSession>;
  @useResult
  $Res call({
    String id,
    String label,
    String startAt,
    String endAt,
    String claimStartAt,
    String claimEndAt,
    SHOFlashSaleDayStatus status,
  });
}

/// @nodoc
class _$SHOFlashSaleSessionCopyWithImpl<$Res, $Val extends SHOFlashSaleSession>
    implements $SHOFlashSaleSessionCopyWith<$Res> {
  _$SHOFlashSaleSessionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SHOFlashSaleSession
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? label = null,
    Object? startAt = null,
    Object? endAt = null,
    Object? claimStartAt = null,
    Object? claimEndAt = null,
    Object? status = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            label: null == label
                ? _value.label
                : label // ignore: cast_nullable_to_non_nullable
                      as String,
            startAt: null == startAt
                ? _value.startAt
                : startAt // ignore: cast_nullable_to_non_nullable
                      as String,
            endAt: null == endAt
                ? _value.endAt
                : endAt // ignore: cast_nullable_to_non_nullable
                      as String,
            claimStartAt: null == claimStartAt
                ? _value.claimStartAt
                : claimStartAt // ignore: cast_nullable_to_non_nullable
                      as String,
            claimEndAt: null == claimEndAt
                ? _value.claimEndAt
                : claimEndAt // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as SHOFlashSaleDayStatus,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SHOFlashSaleSessionImplCopyWith<$Res>
    implements $SHOFlashSaleSessionCopyWith<$Res> {
  factory _$$SHOFlashSaleSessionImplCopyWith(
    _$SHOFlashSaleSessionImpl value,
    $Res Function(_$SHOFlashSaleSessionImpl) then,
  ) = __$$SHOFlashSaleSessionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String label,
    String startAt,
    String endAt,
    String claimStartAt,
    String claimEndAt,
    SHOFlashSaleDayStatus status,
  });
}

/// @nodoc
class __$$SHOFlashSaleSessionImplCopyWithImpl<$Res>
    extends _$SHOFlashSaleSessionCopyWithImpl<$Res, _$SHOFlashSaleSessionImpl>
    implements _$$SHOFlashSaleSessionImplCopyWith<$Res> {
  __$$SHOFlashSaleSessionImplCopyWithImpl(
    _$SHOFlashSaleSessionImpl _value,
    $Res Function(_$SHOFlashSaleSessionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SHOFlashSaleSession
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? label = null,
    Object? startAt = null,
    Object? endAt = null,
    Object? claimStartAt = null,
    Object? claimEndAt = null,
    Object? status = null,
  }) {
    return _then(
      _$SHOFlashSaleSessionImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        label: null == label
            ? _value.label
            : label // ignore: cast_nullable_to_non_nullable
                  as String,
        startAt: null == startAt
            ? _value.startAt
            : startAt // ignore: cast_nullable_to_non_nullable
                  as String,
        endAt: null == endAt
            ? _value.endAt
            : endAt // ignore: cast_nullable_to_non_nullable
                  as String,
        claimStartAt: null == claimStartAt
            ? _value.claimStartAt
            : claimStartAt // ignore: cast_nullable_to_non_nullable
                  as String,
        claimEndAt: null == claimEndAt
            ? _value.claimEndAt
            : claimEndAt // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as SHOFlashSaleDayStatus,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SHOFlashSaleSessionImpl implements _SHOFlashSaleSession {
  const _$SHOFlashSaleSessionImpl({
    required this.id,
    required this.label,
    required this.startAt,
    required this.endAt,
    required this.claimStartAt,
    required this.claimEndAt,
    this.status = SHOFlashSaleDayStatus.notStarted,
  });

  factory _$SHOFlashSaleSessionImpl.fromJson(Map<String, dynamic> json) =>
      _$$SHOFlashSaleSessionImplFromJson(json);

  @override
  final String id;
  @override
  final String label;
  @override
  final String startAt;
  @override
  final String endAt;
  @override
  final String claimStartAt;
  @override
  final String claimEndAt;
  @override
  @JsonKey()
  final SHOFlashSaleDayStatus status;

  @override
  String toString() {
    return 'SHOFlashSaleSession(id: $id, label: $label, startAt: $startAt, endAt: $endAt, claimStartAt: $claimStartAt, claimEndAt: $claimEndAt, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SHOFlashSaleSessionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.label, label) || other.label == label) &&
            (identical(other.startAt, startAt) || other.startAt == startAt) &&
            (identical(other.endAt, endAt) || other.endAt == endAt) &&
            (identical(other.claimStartAt, claimStartAt) ||
                other.claimStartAt == claimStartAt) &&
            (identical(other.claimEndAt, claimEndAt) ||
                other.claimEndAt == claimEndAt) &&
            (identical(other.status, status) || other.status == status));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    label,
    startAt,
    endAt,
    claimStartAt,
    claimEndAt,
    status,
  );

  /// Create a copy of SHOFlashSaleSession
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SHOFlashSaleSessionImplCopyWith<_$SHOFlashSaleSessionImpl> get copyWith =>
      __$$SHOFlashSaleSessionImplCopyWithImpl<_$SHOFlashSaleSessionImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$SHOFlashSaleSessionImplToJson(this);
  }
}

abstract class _SHOFlashSaleSession implements SHOFlashSaleSession {
  const factory _SHOFlashSaleSession({
    required final String id,
    required final String label,
    required final String startAt,
    required final String endAt,
    required final String claimStartAt,
    required final String claimEndAt,
    final SHOFlashSaleDayStatus status,
  }) = _$SHOFlashSaleSessionImpl;

  factory _SHOFlashSaleSession.fromJson(Map<String, dynamic> json) =
      _$SHOFlashSaleSessionImpl.fromJson;

  @override
  String get id;
  @override
  String get label;
  @override
  String get startAt;
  @override
  String get endAt;
  @override
  String get claimStartAt;
  @override
  String get claimEndAt;
  @override
  SHOFlashSaleDayStatus get status;

  /// Create a copy of SHOFlashSaleSession
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SHOFlashSaleSessionImplCopyWith<_$SHOFlashSaleSessionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SHOFlashSalePromoEntry _$SHOFlashSalePromoEntryFromJson(
  Map<String, dynamic> json,
) {
  return _SHOFlashSalePromoEntry.fromJson(json);
}

/// @nodoc
mixin _$SHOFlashSalePromoEntry {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get iconUrl => throw _privateConstructorUsedError;
  String get deeplink => throw _privateConstructorUsedError;

  /// Serializes this SHOFlashSalePromoEntry to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SHOFlashSalePromoEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SHOFlashSalePromoEntryCopyWith<SHOFlashSalePromoEntry> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SHOFlashSalePromoEntryCopyWith<$Res> {
  factory $SHOFlashSalePromoEntryCopyWith(
    SHOFlashSalePromoEntry value,
    $Res Function(SHOFlashSalePromoEntry) then,
  ) = _$SHOFlashSalePromoEntryCopyWithImpl<$Res, SHOFlashSalePromoEntry>;
  @useResult
  $Res call({String id, String title, String iconUrl, String deeplink});
}

/// @nodoc
class _$SHOFlashSalePromoEntryCopyWithImpl<
  $Res,
  $Val extends SHOFlashSalePromoEntry
>
    implements $SHOFlashSalePromoEntryCopyWith<$Res> {
  _$SHOFlashSalePromoEntryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SHOFlashSalePromoEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? iconUrl = null,
    Object? deeplink = null,
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
            iconUrl: null == iconUrl
                ? _value.iconUrl
                : iconUrl // ignore: cast_nullable_to_non_nullable
                      as String,
            deeplink: null == deeplink
                ? _value.deeplink
                : deeplink // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SHOFlashSalePromoEntryImplCopyWith<$Res>
    implements $SHOFlashSalePromoEntryCopyWith<$Res> {
  factory _$$SHOFlashSalePromoEntryImplCopyWith(
    _$SHOFlashSalePromoEntryImpl value,
    $Res Function(_$SHOFlashSalePromoEntryImpl) then,
  ) = __$$SHOFlashSalePromoEntryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String title, String iconUrl, String deeplink});
}

/// @nodoc
class __$$SHOFlashSalePromoEntryImplCopyWithImpl<$Res>
    extends
        _$SHOFlashSalePromoEntryCopyWithImpl<$Res, _$SHOFlashSalePromoEntryImpl>
    implements _$$SHOFlashSalePromoEntryImplCopyWith<$Res> {
  __$$SHOFlashSalePromoEntryImplCopyWithImpl(
    _$SHOFlashSalePromoEntryImpl _value,
    $Res Function(_$SHOFlashSalePromoEntryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SHOFlashSalePromoEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? iconUrl = null,
    Object? deeplink = null,
  }) {
    return _then(
      _$SHOFlashSalePromoEntryImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        iconUrl: null == iconUrl
            ? _value.iconUrl
            : iconUrl // ignore: cast_nullable_to_non_nullable
                  as String,
        deeplink: null == deeplink
            ? _value.deeplink
            : deeplink // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SHOFlashSalePromoEntryImpl implements _SHOFlashSalePromoEntry {
  const _$SHOFlashSalePromoEntryImpl({
    required this.id,
    required this.title,
    required this.iconUrl,
    required this.deeplink,
  });

  factory _$SHOFlashSalePromoEntryImpl.fromJson(Map<String, dynamic> json) =>
      _$$SHOFlashSalePromoEntryImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final String iconUrl;
  @override
  final String deeplink;

  @override
  String toString() {
    return 'SHOFlashSalePromoEntry(id: $id, title: $title, iconUrl: $iconUrl, deeplink: $deeplink)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SHOFlashSalePromoEntryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.iconUrl, iconUrl) || other.iconUrl == iconUrl) &&
            (identical(other.deeplink, deeplink) ||
                other.deeplink == deeplink));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, title, iconUrl, deeplink);

  /// Create a copy of SHOFlashSalePromoEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SHOFlashSalePromoEntryImplCopyWith<_$SHOFlashSalePromoEntryImpl>
  get copyWith =>
      __$$SHOFlashSalePromoEntryImplCopyWithImpl<_$SHOFlashSalePromoEntryImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$SHOFlashSalePromoEntryImplToJson(this);
  }
}

abstract class _SHOFlashSalePromoEntry implements SHOFlashSalePromoEntry {
  const factory _SHOFlashSalePromoEntry({
    required final String id,
    required final String title,
    required final String iconUrl,
    required final String deeplink,
  }) = _$SHOFlashSalePromoEntryImpl;

  factory _SHOFlashSalePromoEntry.fromJson(Map<String, dynamic> json) =
      _$SHOFlashSalePromoEntryImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String get iconUrl;
  @override
  String get deeplink;

  /// Create a copy of SHOFlashSalePromoEntry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SHOFlashSalePromoEntryImplCopyWith<_$SHOFlashSalePromoEntryImpl>
  get copyWith => throw _privateConstructorUsedError;
}

SHOFlashSaleCoupon _$SHOFlashSaleCouponFromJson(Map<String, dynamic> json) {
  return _SHOFlashSaleCoupon.fromJson(json);
}

/// @nodoc
mixin _$SHOFlashSaleCoupon {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  SHOFlashSaleCouponStatus get status => throw _privateConstructorUsedError;

  /// Serializes this SHOFlashSaleCoupon to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SHOFlashSaleCoupon
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SHOFlashSaleCouponCopyWith<SHOFlashSaleCoupon> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SHOFlashSaleCouponCopyWith<$Res> {
  factory $SHOFlashSaleCouponCopyWith(
    SHOFlashSaleCoupon value,
    $Res Function(SHOFlashSaleCoupon) then,
  ) = _$SHOFlashSaleCouponCopyWithImpl<$Res, SHOFlashSaleCoupon>;
  @useResult
  $Res call({
    String id,
    String title,
    String description,
    SHOFlashSaleCouponStatus status,
  });
}

/// @nodoc
class _$SHOFlashSaleCouponCopyWithImpl<$Res, $Val extends SHOFlashSaleCoupon>
    implements $SHOFlashSaleCouponCopyWith<$Res> {
  _$SHOFlashSaleCouponCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SHOFlashSaleCoupon
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? status = null,
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
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as SHOFlashSaleCouponStatus,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SHOFlashSaleCouponImplCopyWith<$Res>
    implements $SHOFlashSaleCouponCopyWith<$Res> {
  factory _$$SHOFlashSaleCouponImplCopyWith(
    _$SHOFlashSaleCouponImpl value,
    $Res Function(_$SHOFlashSaleCouponImpl) then,
  ) = __$$SHOFlashSaleCouponImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String title,
    String description,
    SHOFlashSaleCouponStatus status,
  });
}

/// @nodoc
class __$$SHOFlashSaleCouponImplCopyWithImpl<$Res>
    extends _$SHOFlashSaleCouponCopyWithImpl<$Res, _$SHOFlashSaleCouponImpl>
    implements _$$SHOFlashSaleCouponImplCopyWith<$Res> {
  __$$SHOFlashSaleCouponImplCopyWithImpl(
    _$SHOFlashSaleCouponImpl _value,
    $Res Function(_$SHOFlashSaleCouponImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SHOFlashSaleCoupon
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? status = null,
  }) {
    return _then(
      _$SHOFlashSaleCouponImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as SHOFlashSaleCouponStatus,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SHOFlashSaleCouponImpl implements _SHOFlashSaleCoupon {
  const _$SHOFlashSaleCouponImpl({
    required this.id,
    required this.title,
    required this.description,
    this.status = SHOFlashSaleCouponStatus.notStarted,
  });

  factory _$SHOFlashSaleCouponImpl.fromJson(Map<String, dynamic> json) =>
      _$$SHOFlashSaleCouponImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final String description;
  @override
  @JsonKey()
  final SHOFlashSaleCouponStatus status;

  @override
  String toString() {
    return 'SHOFlashSaleCoupon(id: $id, title: $title, description: $description, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SHOFlashSaleCouponImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.status, status) || other.status == status));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, title, description, status);

  /// Create a copy of SHOFlashSaleCoupon
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SHOFlashSaleCouponImplCopyWith<_$SHOFlashSaleCouponImpl> get copyWith =>
      __$$SHOFlashSaleCouponImplCopyWithImpl<_$SHOFlashSaleCouponImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$SHOFlashSaleCouponImplToJson(this);
  }
}

abstract class _SHOFlashSaleCoupon implements SHOFlashSaleCoupon {
  const factory _SHOFlashSaleCoupon({
    required final String id,
    required final String title,
    required final String description,
    final SHOFlashSaleCouponStatus status,
  }) = _$SHOFlashSaleCouponImpl;

  factory _SHOFlashSaleCoupon.fromJson(Map<String, dynamic> json) =
      _$SHOFlashSaleCouponImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String get description;
  @override
  SHOFlashSaleCouponStatus get status;

  /// Create a copy of SHOFlashSaleCoupon
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SHOFlashSaleCouponImplCopyWith<_$SHOFlashSaleCouponImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SHOFlashSaleProduct _$SHOFlashSaleProductFromJson(Map<String, dynamic> json) {
  return _SHOFlashSaleProduct.fromJson(json);
}

/// @nodoc
mixin _$SHOFlashSaleProduct {
  String get id => throw _privateConstructorUsedError;
  String get sessionId => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get imageUrl => throw _privateConstructorUsedError;
  int get originalPrice => throw _privateConstructorUsedError;
  int get activityPrice => throw _privateConstructorUsedError;
  List<String> get skuAttributes => throw _privateConstructorUsedError;
  List<SHOFlashSalePromoTag> get promoTags =>
      throw _privateConstructorUsedError;
  String? get primaryPromoType => throw _privateConstructorUsedError;
  String? get primaryPromoLabel => throw _privateConstructorUsedError;
  SHOFlashSaleProductStatus get status => throw _privateConstructorUsedError;
  int get stock => throw _privateConstructorUsedError;
  int get soldCount => throw _privateConstructorUsedError;
  bool get isFollowed => throw _privateConstructorUsedError;
  String? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this SHOFlashSaleProduct to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SHOFlashSaleProduct
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SHOFlashSaleProductCopyWith<SHOFlashSaleProduct> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SHOFlashSaleProductCopyWith<$Res> {
  factory $SHOFlashSaleProductCopyWith(
    SHOFlashSaleProduct value,
    $Res Function(SHOFlashSaleProduct) then,
  ) = _$SHOFlashSaleProductCopyWithImpl<$Res, SHOFlashSaleProduct>;
  @useResult
  $Res call({
    String id,
    String sessionId,
    String title,
    String imageUrl,
    int originalPrice,
    int activityPrice,
    List<String> skuAttributes,
    List<SHOFlashSalePromoTag> promoTags,
    String? primaryPromoType,
    String? primaryPromoLabel,
    SHOFlashSaleProductStatus status,
    int stock,
    int soldCount,
    bool isFollowed,
    String? createdAt,
  });
}

/// @nodoc
class _$SHOFlashSaleProductCopyWithImpl<$Res, $Val extends SHOFlashSaleProduct>
    implements $SHOFlashSaleProductCopyWith<$Res> {
  _$SHOFlashSaleProductCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SHOFlashSaleProduct
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? sessionId = null,
    Object? title = null,
    Object? imageUrl = null,
    Object? originalPrice = null,
    Object? activityPrice = null,
    Object? skuAttributes = null,
    Object? promoTags = null,
    Object? primaryPromoType = freezed,
    Object? primaryPromoLabel = freezed,
    Object? status = null,
    Object? stock = null,
    Object? soldCount = null,
    Object? isFollowed = null,
    Object? createdAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            sessionId: null == sessionId
                ? _value.sessionId
                : sessionId // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            imageUrl: null == imageUrl
                ? _value.imageUrl
                : imageUrl // ignore: cast_nullable_to_non_nullable
                      as String,
            originalPrice: null == originalPrice
                ? _value.originalPrice
                : originalPrice // ignore: cast_nullable_to_non_nullable
                      as int,
            activityPrice: null == activityPrice
                ? _value.activityPrice
                : activityPrice // ignore: cast_nullable_to_non_nullable
                      as int,
            skuAttributes: null == skuAttributes
                ? _value.skuAttributes
                : skuAttributes // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            promoTags: null == promoTags
                ? _value.promoTags
                : promoTags // ignore: cast_nullable_to_non_nullable
                      as List<SHOFlashSalePromoTag>,
            primaryPromoType: freezed == primaryPromoType
                ? _value.primaryPromoType
                : primaryPromoType // ignore: cast_nullable_to_non_nullable
                      as String?,
            primaryPromoLabel: freezed == primaryPromoLabel
                ? _value.primaryPromoLabel
                : primaryPromoLabel // ignore: cast_nullable_to_non_nullable
                      as String?,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as SHOFlashSaleProductStatus,
            stock: null == stock
                ? _value.stock
                : stock // ignore: cast_nullable_to_non_nullable
                      as int,
            soldCount: null == soldCount
                ? _value.soldCount
                : soldCount // ignore: cast_nullable_to_non_nullable
                      as int,
            isFollowed: null == isFollowed
                ? _value.isFollowed
                : isFollowed // ignore: cast_nullable_to_non_nullable
                      as bool,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SHOFlashSaleProductImplCopyWith<$Res>
    implements $SHOFlashSaleProductCopyWith<$Res> {
  factory _$$SHOFlashSaleProductImplCopyWith(
    _$SHOFlashSaleProductImpl value,
    $Res Function(_$SHOFlashSaleProductImpl) then,
  ) = __$$SHOFlashSaleProductImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String sessionId,
    String title,
    String imageUrl,
    int originalPrice,
    int activityPrice,
    List<String> skuAttributes,
    List<SHOFlashSalePromoTag> promoTags,
    String? primaryPromoType,
    String? primaryPromoLabel,
    SHOFlashSaleProductStatus status,
    int stock,
    int soldCount,
    bool isFollowed,
    String? createdAt,
  });
}

/// @nodoc
class __$$SHOFlashSaleProductImplCopyWithImpl<$Res>
    extends _$SHOFlashSaleProductCopyWithImpl<$Res, _$SHOFlashSaleProductImpl>
    implements _$$SHOFlashSaleProductImplCopyWith<$Res> {
  __$$SHOFlashSaleProductImplCopyWithImpl(
    _$SHOFlashSaleProductImpl _value,
    $Res Function(_$SHOFlashSaleProductImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SHOFlashSaleProduct
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? sessionId = null,
    Object? title = null,
    Object? imageUrl = null,
    Object? originalPrice = null,
    Object? activityPrice = null,
    Object? skuAttributes = null,
    Object? promoTags = null,
    Object? primaryPromoType = freezed,
    Object? primaryPromoLabel = freezed,
    Object? status = null,
    Object? stock = null,
    Object? soldCount = null,
    Object? isFollowed = null,
    Object? createdAt = freezed,
  }) {
    return _then(
      _$SHOFlashSaleProductImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        sessionId: null == sessionId
            ? _value.sessionId
            : sessionId // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        imageUrl: null == imageUrl
            ? _value.imageUrl
            : imageUrl // ignore: cast_nullable_to_non_nullable
                  as String,
        originalPrice: null == originalPrice
            ? _value.originalPrice
            : originalPrice // ignore: cast_nullable_to_non_nullable
                  as int,
        activityPrice: null == activityPrice
            ? _value.activityPrice
            : activityPrice // ignore: cast_nullable_to_non_nullable
                  as int,
        skuAttributes: null == skuAttributes
            ? _value._skuAttributes
            : skuAttributes // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        promoTags: null == promoTags
            ? _value._promoTags
            : promoTags // ignore: cast_nullable_to_non_nullable
                  as List<SHOFlashSalePromoTag>,
        primaryPromoType: freezed == primaryPromoType
            ? _value.primaryPromoType
            : primaryPromoType // ignore: cast_nullable_to_non_nullable
                  as String?,
        primaryPromoLabel: freezed == primaryPromoLabel
            ? _value.primaryPromoLabel
            : primaryPromoLabel // ignore: cast_nullable_to_non_nullable
                  as String?,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as SHOFlashSaleProductStatus,
        stock: null == stock
            ? _value.stock
            : stock // ignore: cast_nullable_to_non_nullable
                  as int,
        soldCount: null == soldCount
            ? _value.soldCount
            : soldCount // ignore: cast_nullable_to_non_nullable
                  as int,
        isFollowed: null == isFollowed
            ? _value.isFollowed
            : isFollowed // ignore: cast_nullable_to_non_nullable
                  as bool,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SHOFlashSaleProductImpl extends _SHOFlashSaleProduct {
  const _$SHOFlashSaleProductImpl({
    required this.id,
    required this.sessionId,
    required this.title,
    required this.imageUrl,
    required this.originalPrice,
    required this.activityPrice,
    final List<String> skuAttributes = const [],
    final List<SHOFlashSalePromoTag> promoTags = const [],
    this.primaryPromoType,
    this.primaryPromoLabel,
    this.status = SHOFlashSaleProductStatus.notStarted,
    this.stock = 0,
    this.soldCount = 0,
    this.isFollowed = false,
    this.createdAt,
  }) : _skuAttributes = skuAttributes,
       _promoTags = promoTags,
       super._();

  factory _$SHOFlashSaleProductImpl.fromJson(Map<String, dynamic> json) =>
      _$$SHOFlashSaleProductImplFromJson(json);

  @override
  final String id;
  @override
  final String sessionId;
  @override
  final String title;
  @override
  final String imageUrl;
  @override
  final int originalPrice;
  @override
  final int activityPrice;
  final List<String> _skuAttributes;
  @override
  @JsonKey()
  List<String> get skuAttributes {
    if (_skuAttributes is EqualUnmodifiableListView) return _skuAttributes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_skuAttributes);
  }

  final List<SHOFlashSalePromoTag> _promoTags;
  @override
  @JsonKey()
  List<SHOFlashSalePromoTag> get promoTags {
    if (_promoTags is EqualUnmodifiableListView) return _promoTags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_promoTags);
  }

  @override
  final String? primaryPromoType;
  @override
  final String? primaryPromoLabel;
  @override
  @JsonKey()
  final SHOFlashSaleProductStatus status;
  @override
  @JsonKey()
  final int stock;
  @override
  @JsonKey()
  final int soldCount;
  @override
  @JsonKey()
  final bool isFollowed;
  @override
  final String? createdAt;

  @override
  String toString() {
    return 'SHOFlashSaleProduct(id: $id, sessionId: $sessionId, title: $title, imageUrl: $imageUrl, originalPrice: $originalPrice, activityPrice: $activityPrice, skuAttributes: $skuAttributes, promoTags: $promoTags, primaryPromoType: $primaryPromoType, primaryPromoLabel: $primaryPromoLabel, status: $status, stock: $stock, soldCount: $soldCount, isFollowed: $isFollowed, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SHOFlashSaleProductImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.sessionId, sessionId) ||
                other.sessionId == sessionId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.originalPrice, originalPrice) ||
                other.originalPrice == originalPrice) &&
            (identical(other.activityPrice, activityPrice) ||
                other.activityPrice == activityPrice) &&
            const DeepCollectionEquality().equals(
              other._skuAttributes,
              _skuAttributes,
            ) &&
            const DeepCollectionEquality().equals(
              other._promoTags,
              _promoTags,
            ) &&
            (identical(other.primaryPromoType, primaryPromoType) ||
                other.primaryPromoType == primaryPromoType) &&
            (identical(other.primaryPromoLabel, primaryPromoLabel) ||
                other.primaryPromoLabel == primaryPromoLabel) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.stock, stock) || other.stock == stock) &&
            (identical(other.soldCount, soldCount) ||
                other.soldCount == soldCount) &&
            (identical(other.isFollowed, isFollowed) ||
                other.isFollowed == isFollowed) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    sessionId,
    title,
    imageUrl,
    originalPrice,
    activityPrice,
    const DeepCollectionEquality().hash(_skuAttributes),
    const DeepCollectionEquality().hash(_promoTags),
    primaryPromoType,
    primaryPromoLabel,
    status,
    stock,
    soldCount,
    isFollowed,
    createdAt,
  );

  /// Create a copy of SHOFlashSaleProduct
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SHOFlashSaleProductImplCopyWith<_$SHOFlashSaleProductImpl> get copyWith =>
      __$$SHOFlashSaleProductImplCopyWithImpl<_$SHOFlashSaleProductImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$SHOFlashSaleProductImplToJson(this);
  }
}

abstract class _SHOFlashSaleProduct extends SHOFlashSaleProduct {
  const factory _SHOFlashSaleProduct({
    required final String id,
    required final String sessionId,
    required final String title,
    required final String imageUrl,
    required final int originalPrice,
    required final int activityPrice,
    final List<String> skuAttributes,
    final List<SHOFlashSalePromoTag> promoTags,
    final String? primaryPromoType,
    final String? primaryPromoLabel,
    final SHOFlashSaleProductStatus status,
    final int stock,
    final int soldCount,
    final bool isFollowed,
    final String? createdAt,
  }) = _$SHOFlashSaleProductImpl;
  const _SHOFlashSaleProduct._() : super._();

  factory _SHOFlashSaleProduct.fromJson(Map<String, dynamic> json) =
      _$SHOFlashSaleProductImpl.fromJson;

  @override
  String get id;
  @override
  String get sessionId;
  @override
  String get title;
  @override
  String get imageUrl;
  @override
  int get originalPrice;
  @override
  int get activityPrice;
  @override
  List<String> get skuAttributes;
  @override
  List<SHOFlashSalePromoTag> get promoTags;
  @override
  String? get primaryPromoType;
  @override
  String? get primaryPromoLabel;
  @override
  SHOFlashSaleProductStatus get status;
  @override
  int get stock;
  @override
  int get soldCount;
  @override
  bool get isFollowed;
  @override
  String? get createdAt;

  /// Create a copy of SHOFlashSaleProduct
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SHOFlashSaleProductImplCopyWith<_$SHOFlashSaleProductImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SHOFlashSalePageData _$SHOFlashSalePageDataFromJson(Map<String, dynamic> json) {
  return _SHOFlashSalePageData.fromJson(json);
}

/// @nodoc
mixin _$SHOFlashSalePageData {
  String get serverTime => throw _privateConstructorUsedError;
  String get date => throw _privateConstructorUsedError;
  String get sessionId => throw _privateConstructorUsedError;
  SHOFlashSaleClaimPhase get claimPhase => throw _privateConstructorUsedError;
  String? get claimCountdownTarget => throw _privateConstructorUsedError;
  List<SHOFlashSaleSession> get sessions => throw _privateConstructorUsedError;
  List<SHOFlashSalePromoEntry> get promoEntries =>
      throw _privateConstructorUsedError;
  List<SHOFlashSaleCoupon> get coupons => throw _privateConstructorUsedError;
  List<SHOFlashSaleProduct> get products => throw _privateConstructorUsedError;
  int get page => throw _privateConstructorUsedError;
  int get pageSize => throw _privateConstructorUsedError;
  int get total => throw _privateConstructorUsedError;
  bool get hasMore => throw _privateConstructorUsedError;

  /// Serializes this SHOFlashSalePageData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SHOFlashSalePageData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SHOFlashSalePageDataCopyWith<SHOFlashSalePageData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SHOFlashSalePageDataCopyWith<$Res> {
  factory $SHOFlashSalePageDataCopyWith(
    SHOFlashSalePageData value,
    $Res Function(SHOFlashSalePageData) then,
  ) = _$SHOFlashSalePageDataCopyWithImpl<$Res, SHOFlashSalePageData>;
  @useResult
  $Res call({
    String serverTime,
    String date,
    String sessionId,
    SHOFlashSaleClaimPhase claimPhase,
    String? claimCountdownTarget,
    List<SHOFlashSaleSession> sessions,
    List<SHOFlashSalePromoEntry> promoEntries,
    List<SHOFlashSaleCoupon> coupons,
    List<SHOFlashSaleProduct> products,
    int page,
    int pageSize,
    int total,
    bool hasMore,
  });
}

/// @nodoc
class _$SHOFlashSalePageDataCopyWithImpl<
  $Res,
  $Val extends SHOFlashSalePageData
>
    implements $SHOFlashSalePageDataCopyWith<$Res> {
  _$SHOFlashSalePageDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SHOFlashSalePageData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? serverTime = null,
    Object? date = null,
    Object? sessionId = null,
    Object? claimPhase = null,
    Object? claimCountdownTarget = freezed,
    Object? sessions = null,
    Object? promoEntries = null,
    Object? coupons = null,
    Object? products = null,
    Object? page = null,
    Object? pageSize = null,
    Object? total = null,
    Object? hasMore = null,
  }) {
    return _then(
      _value.copyWith(
            serverTime: null == serverTime
                ? _value.serverTime
                : serverTime // ignore: cast_nullable_to_non_nullable
                      as String,
            date: null == date
                ? _value.date
                : date // ignore: cast_nullable_to_non_nullable
                      as String,
            sessionId: null == sessionId
                ? _value.sessionId
                : sessionId // ignore: cast_nullable_to_non_nullable
                      as String,
            claimPhase: null == claimPhase
                ? _value.claimPhase
                : claimPhase // ignore: cast_nullable_to_non_nullable
                      as SHOFlashSaleClaimPhase,
            claimCountdownTarget: freezed == claimCountdownTarget
                ? _value.claimCountdownTarget
                : claimCountdownTarget // ignore: cast_nullable_to_non_nullable
                      as String?,
            sessions: null == sessions
                ? _value.sessions
                : sessions // ignore: cast_nullable_to_non_nullable
                      as List<SHOFlashSaleSession>,
            promoEntries: null == promoEntries
                ? _value.promoEntries
                : promoEntries // ignore: cast_nullable_to_non_nullable
                      as List<SHOFlashSalePromoEntry>,
            coupons: null == coupons
                ? _value.coupons
                : coupons // ignore: cast_nullable_to_non_nullable
                      as List<SHOFlashSaleCoupon>,
            products: null == products
                ? _value.products
                : products // ignore: cast_nullable_to_non_nullable
                      as List<SHOFlashSaleProduct>,
            page: null == page
                ? _value.page
                : page // ignore: cast_nullable_to_non_nullable
                      as int,
            pageSize: null == pageSize
                ? _value.pageSize
                : pageSize // ignore: cast_nullable_to_non_nullable
                      as int,
            total: null == total
                ? _value.total
                : total // ignore: cast_nullable_to_non_nullable
                      as int,
            hasMore: null == hasMore
                ? _value.hasMore
                : hasMore // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SHOFlashSalePageDataImplCopyWith<$Res>
    implements $SHOFlashSalePageDataCopyWith<$Res> {
  factory _$$SHOFlashSalePageDataImplCopyWith(
    _$SHOFlashSalePageDataImpl value,
    $Res Function(_$SHOFlashSalePageDataImpl) then,
  ) = __$$SHOFlashSalePageDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String serverTime,
    String date,
    String sessionId,
    SHOFlashSaleClaimPhase claimPhase,
    String? claimCountdownTarget,
    List<SHOFlashSaleSession> sessions,
    List<SHOFlashSalePromoEntry> promoEntries,
    List<SHOFlashSaleCoupon> coupons,
    List<SHOFlashSaleProduct> products,
    int page,
    int pageSize,
    int total,
    bool hasMore,
  });
}

/// @nodoc
class __$$SHOFlashSalePageDataImplCopyWithImpl<$Res>
    extends _$SHOFlashSalePageDataCopyWithImpl<$Res, _$SHOFlashSalePageDataImpl>
    implements _$$SHOFlashSalePageDataImplCopyWith<$Res> {
  __$$SHOFlashSalePageDataImplCopyWithImpl(
    _$SHOFlashSalePageDataImpl _value,
    $Res Function(_$SHOFlashSalePageDataImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SHOFlashSalePageData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? serverTime = null,
    Object? date = null,
    Object? sessionId = null,
    Object? claimPhase = null,
    Object? claimCountdownTarget = freezed,
    Object? sessions = null,
    Object? promoEntries = null,
    Object? coupons = null,
    Object? products = null,
    Object? page = null,
    Object? pageSize = null,
    Object? total = null,
    Object? hasMore = null,
  }) {
    return _then(
      _$SHOFlashSalePageDataImpl(
        serverTime: null == serverTime
            ? _value.serverTime
            : serverTime // ignore: cast_nullable_to_non_nullable
                  as String,
        date: null == date
            ? _value.date
            : date // ignore: cast_nullable_to_non_nullable
                  as String,
        sessionId: null == sessionId
            ? _value.sessionId
            : sessionId // ignore: cast_nullable_to_non_nullable
                  as String,
        claimPhase: null == claimPhase
            ? _value.claimPhase
            : claimPhase // ignore: cast_nullable_to_non_nullable
                  as SHOFlashSaleClaimPhase,
        claimCountdownTarget: freezed == claimCountdownTarget
            ? _value.claimCountdownTarget
            : claimCountdownTarget // ignore: cast_nullable_to_non_nullable
                  as String?,
        sessions: null == sessions
            ? _value._sessions
            : sessions // ignore: cast_nullable_to_non_nullable
                  as List<SHOFlashSaleSession>,
        promoEntries: null == promoEntries
            ? _value._promoEntries
            : promoEntries // ignore: cast_nullable_to_non_nullable
                  as List<SHOFlashSalePromoEntry>,
        coupons: null == coupons
            ? _value._coupons
            : coupons // ignore: cast_nullable_to_non_nullable
                  as List<SHOFlashSaleCoupon>,
        products: null == products
            ? _value._products
            : products // ignore: cast_nullable_to_non_nullable
                  as List<SHOFlashSaleProduct>,
        page: null == page
            ? _value.page
            : page // ignore: cast_nullable_to_non_nullable
                  as int,
        pageSize: null == pageSize
            ? _value.pageSize
            : pageSize // ignore: cast_nullable_to_non_nullable
                  as int,
        total: null == total
            ? _value.total
            : total // ignore: cast_nullable_to_non_nullable
                  as int,
        hasMore: null == hasMore
            ? _value.hasMore
            : hasMore // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SHOFlashSalePageDataImpl implements _SHOFlashSalePageData {
  const _$SHOFlashSalePageDataImpl({
    required this.serverTime,
    required this.date,
    required this.sessionId,
    required this.claimPhase,
    this.claimCountdownTarget,
    final List<SHOFlashSaleSession> sessions = const [],
    final List<SHOFlashSalePromoEntry> promoEntries = const [],
    final List<SHOFlashSaleCoupon> coupons = const [],
    final List<SHOFlashSaleProduct> products = const [],
    this.page = 1,
    this.pageSize = 10,
    this.total = 0,
    this.hasMore = false,
  }) : _sessions = sessions,
       _promoEntries = promoEntries,
       _coupons = coupons,
       _products = products;

  factory _$SHOFlashSalePageDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$SHOFlashSalePageDataImplFromJson(json);

  @override
  final String serverTime;
  @override
  final String date;
  @override
  final String sessionId;
  @override
  final SHOFlashSaleClaimPhase claimPhase;
  @override
  final String? claimCountdownTarget;
  final List<SHOFlashSaleSession> _sessions;
  @override
  @JsonKey()
  List<SHOFlashSaleSession> get sessions {
    if (_sessions is EqualUnmodifiableListView) return _sessions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_sessions);
  }

  final List<SHOFlashSalePromoEntry> _promoEntries;
  @override
  @JsonKey()
  List<SHOFlashSalePromoEntry> get promoEntries {
    if (_promoEntries is EqualUnmodifiableListView) return _promoEntries;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_promoEntries);
  }

  final List<SHOFlashSaleCoupon> _coupons;
  @override
  @JsonKey()
  List<SHOFlashSaleCoupon> get coupons {
    if (_coupons is EqualUnmodifiableListView) return _coupons;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_coupons);
  }

  final List<SHOFlashSaleProduct> _products;
  @override
  @JsonKey()
  List<SHOFlashSaleProduct> get products {
    if (_products is EqualUnmodifiableListView) return _products;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_products);
  }

  @override
  @JsonKey()
  final int page;
  @override
  @JsonKey()
  final int pageSize;
  @override
  @JsonKey()
  final int total;
  @override
  @JsonKey()
  final bool hasMore;

  @override
  String toString() {
    return 'SHOFlashSalePageData(serverTime: $serverTime, date: $date, sessionId: $sessionId, claimPhase: $claimPhase, claimCountdownTarget: $claimCountdownTarget, sessions: $sessions, promoEntries: $promoEntries, coupons: $coupons, products: $products, page: $page, pageSize: $pageSize, total: $total, hasMore: $hasMore)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SHOFlashSalePageDataImpl &&
            (identical(other.serverTime, serverTime) ||
                other.serverTime == serverTime) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.sessionId, sessionId) ||
                other.sessionId == sessionId) &&
            (identical(other.claimPhase, claimPhase) ||
                other.claimPhase == claimPhase) &&
            (identical(other.claimCountdownTarget, claimCountdownTarget) ||
                other.claimCountdownTarget == claimCountdownTarget) &&
            const DeepCollectionEquality().equals(other._sessions, _sessions) &&
            const DeepCollectionEquality().equals(
              other._promoEntries,
              _promoEntries,
            ) &&
            const DeepCollectionEquality().equals(other._coupons, _coupons) &&
            const DeepCollectionEquality().equals(other._products, _products) &&
            (identical(other.page, page) || other.page == page) &&
            (identical(other.pageSize, pageSize) ||
                other.pageSize == pageSize) &&
            (identical(other.total, total) || other.total == total) &&
            (identical(other.hasMore, hasMore) || other.hasMore == hasMore));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    serverTime,
    date,
    sessionId,
    claimPhase,
    claimCountdownTarget,
    const DeepCollectionEquality().hash(_sessions),
    const DeepCollectionEquality().hash(_promoEntries),
    const DeepCollectionEquality().hash(_coupons),
    const DeepCollectionEquality().hash(_products),
    page,
    pageSize,
    total,
    hasMore,
  );

  /// Create a copy of SHOFlashSalePageData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SHOFlashSalePageDataImplCopyWith<_$SHOFlashSalePageDataImpl>
  get copyWith =>
      __$$SHOFlashSalePageDataImplCopyWithImpl<_$SHOFlashSalePageDataImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$SHOFlashSalePageDataImplToJson(this);
  }
}

abstract class _SHOFlashSalePageData implements SHOFlashSalePageData {
  const factory _SHOFlashSalePageData({
    required final String serverTime,
    required final String date,
    required final String sessionId,
    required final SHOFlashSaleClaimPhase claimPhase,
    final String? claimCountdownTarget,
    final List<SHOFlashSaleSession> sessions,
    final List<SHOFlashSalePromoEntry> promoEntries,
    final List<SHOFlashSaleCoupon> coupons,
    final List<SHOFlashSaleProduct> products,
    final int page,
    final int pageSize,
    final int total,
    final bool hasMore,
  }) = _$SHOFlashSalePageDataImpl;

  factory _SHOFlashSalePageData.fromJson(Map<String, dynamic> json) =
      _$SHOFlashSalePageDataImpl.fromJson;

  @override
  String get serverTime;
  @override
  String get date;
  @override
  String get sessionId;
  @override
  SHOFlashSaleClaimPhase get claimPhase;
  @override
  String? get claimCountdownTarget;
  @override
  List<SHOFlashSaleSession> get sessions;
  @override
  List<SHOFlashSalePromoEntry> get promoEntries;
  @override
  List<SHOFlashSaleCoupon> get coupons;
  @override
  List<SHOFlashSaleProduct> get products;
  @override
  int get page;
  @override
  int get pageSize;
  @override
  int get total;
  @override
  bool get hasMore;

  /// Create a copy of SHOFlashSalePageData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SHOFlashSalePageDataImplCopyWith<_$SHOFlashSalePageDataImpl>
  get copyWith => throw _privateConstructorUsedError;
}

SHOFlashSaleProductActivity _$SHOFlashSaleProductActivityFromJson(
  Map<String, dynamic> json,
) {
  return _SHOFlashSaleProductActivity.fromJson(json);
}

/// @nodoc
mixin _$SHOFlashSaleProductActivity {
  String get sessionId => throw _privateConstructorUsedError;
  SHOFlashSaleProductStatus get status => throw _privateConstructorUsedError;
  int get originalPrice => throw _privateConstructorUsedError;
  int get activityPrice => throw _privateConstructorUsedError;
  List<SHOFlashSalePromoTag> get promoTags =>
      throw _privateConstructorUsedError;
  String? get primaryPromoType => throw _privateConstructorUsedError;
  String? get primaryPromoLabel => throw _privateConstructorUsedError;
  String? get sessionStartAt => throw _privateConstructorUsedError;
  String? get sessionEndAt => throw _privateConstructorUsedError;
  String? get overlayLabel => throw _privateConstructorUsedError;
  bool get isFollowed => throw _privateConstructorUsedError;
  int get stock => throw _privateConstructorUsedError;

  /// Serializes this SHOFlashSaleProductActivity to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SHOFlashSaleProductActivity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SHOFlashSaleProductActivityCopyWith<SHOFlashSaleProductActivity>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SHOFlashSaleProductActivityCopyWith<$Res> {
  factory $SHOFlashSaleProductActivityCopyWith(
    SHOFlashSaleProductActivity value,
    $Res Function(SHOFlashSaleProductActivity) then,
  ) =
      _$SHOFlashSaleProductActivityCopyWithImpl<
        $Res,
        SHOFlashSaleProductActivity
      >;
  @useResult
  $Res call({
    String sessionId,
    SHOFlashSaleProductStatus status,
    int originalPrice,
    int activityPrice,
    List<SHOFlashSalePromoTag> promoTags,
    String? primaryPromoType,
    String? primaryPromoLabel,
    String? sessionStartAt,
    String? sessionEndAt,
    String? overlayLabel,
    bool isFollowed,
    int stock,
  });
}

/// @nodoc
class _$SHOFlashSaleProductActivityCopyWithImpl<
  $Res,
  $Val extends SHOFlashSaleProductActivity
>
    implements $SHOFlashSaleProductActivityCopyWith<$Res> {
  _$SHOFlashSaleProductActivityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SHOFlashSaleProductActivity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sessionId = null,
    Object? status = null,
    Object? originalPrice = null,
    Object? activityPrice = null,
    Object? promoTags = null,
    Object? primaryPromoType = freezed,
    Object? primaryPromoLabel = freezed,
    Object? sessionStartAt = freezed,
    Object? sessionEndAt = freezed,
    Object? overlayLabel = freezed,
    Object? isFollowed = null,
    Object? stock = null,
  }) {
    return _then(
      _value.copyWith(
            sessionId: null == sessionId
                ? _value.sessionId
                : sessionId // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as SHOFlashSaleProductStatus,
            originalPrice: null == originalPrice
                ? _value.originalPrice
                : originalPrice // ignore: cast_nullable_to_non_nullable
                      as int,
            activityPrice: null == activityPrice
                ? _value.activityPrice
                : activityPrice // ignore: cast_nullable_to_non_nullable
                      as int,
            promoTags: null == promoTags
                ? _value.promoTags
                : promoTags // ignore: cast_nullable_to_non_nullable
                      as List<SHOFlashSalePromoTag>,
            primaryPromoType: freezed == primaryPromoType
                ? _value.primaryPromoType
                : primaryPromoType // ignore: cast_nullable_to_non_nullable
                      as String?,
            primaryPromoLabel: freezed == primaryPromoLabel
                ? _value.primaryPromoLabel
                : primaryPromoLabel // ignore: cast_nullable_to_non_nullable
                      as String?,
            sessionStartAt: freezed == sessionStartAt
                ? _value.sessionStartAt
                : sessionStartAt // ignore: cast_nullable_to_non_nullable
                      as String?,
            sessionEndAt: freezed == sessionEndAt
                ? _value.sessionEndAt
                : sessionEndAt // ignore: cast_nullable_to_non_nullable
                      as String?,
            overlayLabel: freezed == overlayLabel
                ? _value.overlayLabel
                : overlayLabel // ignore: cast_nullable_to_non_nullable
                      as String?,
            isFollowed: null == isFollowed
                ? _value.isFollowed
                : isFollowed // ignore: cast_nullable_to_non_nullable
                      as bool,
            stock: null == stock
                ? _value.stock
                : stock // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SHOFlashSaleProductActivityImplCopyWith<$Res>
    implements $SHOFlashSaleProductActivityCopyWith<$Res> {
  factory _$$SHOFlashSaleProductActivityImplCopyWith(
    _$SHOFlashSaleProductActivityImpl value,
    $Res Function(_$SHOFlashSaleProductActivityImpl) then,
  ) = __$$SHOFlashSaleProductActivityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String sessionId,
    SHOFlashSaleProductStatus status,
    int originalPrice,
    int activityPrice,
    List<SHOFlashSalePromoTag> promoTags,
    String? primaryPromoType,
    String? primaryPromoLabel,
    String? sessionStartAt,
    String? sessionEndAt,
    String? overlayLabel,
    bool isFollowed,
    int stock,
  });
}

/// @nodoc
class __$$SHOFlashSaleProductActivityImplCopyWithImpl<$Res>
    extends
        _$SHOFlashSaleProductActivityCopyWithImpl<
          $Res,
          _$SHOFlashSaleProductActivityImpl
        >
    implements _$$SHOFlashSaleProductActivityImplCopyWith<$Res> {
  __$$SHOFlashSaleProductActivityImplCopyWithImpl(
    _$SHOFlashSaleProductActivityImpl _value,
    $Res Function(_$SHOFlashSaleProductActivityImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SHOFlashSaleProductActivity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sessionId = null,
    Object? status = null,
    Object? originalPrice = null,
    Object? activityPrice = null,
    Object? promoTags = null,
    Object? primaryPromoType = freezed,
    Object? primaryPromoLabel = freezed,
    Object? sessionStartAt = freezed,
    Object? sessionEndAt = freezed,
    Object? overlayLabel = freezed,
    Object? isFollowed = null,
    Object? stock = null,
  }) {
    return _then(
      _$SHOFlashSaleProductActivityImpl(
        sessionId: null == sessionId
            ? _value.sessionId
            : sessionId // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as SHOFlashSaleProductStatus,
        originalPrice: null == originalPrice
            ? _value.originalPrice
            : originalPrice // ignore: cast_nullable_to_non_nullable
                  as int,
        activityPrice: null == activityPrice
            ? _value.activityPrice
            : activityPrice // ignore: cast_nullable_to_non_nullable
                  as int,
        promoTags: null == promoTags
            ? _value._promoTags
            : promoTags // ignore: cast_nullable_to_non_nullable
                  as List<SHOFlashSalePromoTag>,
        primaryPromoType: freezed == primaryPromoType
            ? _value.primaryPromoType
            : primaryPromoType // ignore: cast_nullable_to_non_nullable
                  as String?,
        primaryPromoLabel: freezed == primaryPromoLabel
            ? _value.primaryPromoLabel
            : primaryPromoLabel // ignore: cast_nullable_to_non_nullable
                  as String?,
        sessionStartAt: freezed == sessionStartAt
            ? _value.sessionStartAt
            : sessionStartAt // ignore: cast_nullable_to_non_nullable
                  as String?,
        sessionEndAt: freezed == sessionEndAt
            ? _value.sessionEndAt
            : sessionEndAt // ignore: cast_nullable_to_non_nullable
                  as String?,
        overlayLabel: freezed == overlayLabel
            ? _value.overlayLabel
            : overlayLabel // ignore: cast_nullable_to_non_nullable
                  as String?,
        isFollowed: null == isFollowed
            ? _value.isFollowed
            : isFollowed // ignore: cast_nullable_to_non_nullable
                  as bool,
        stock: null == stock
            ? _value.stock
            : stock // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SHOFlashSaleProductActivityImpl extends _SHOFlashSaleProductActivity {
  const _$SHOFlashSaleProductActivityImpl({
    required this.sessionId,
    required this.status,
    required this.originalPrice,
    required this.activityPrice,
    final List<SHOFlashSalePromoTag> promoTags = const [],
    this.primaryPromoType,
    this.primaryPromoLabel,
    this.sessionStartAt,
    this.sessionEndAt,
    this.overlayLabel,
    this.isFollowed = false,
    this.stock = 0,
  }) : _promoTags = promoTags,
       super._();

  factory _$SHOFlashSaleProductActivityImpl.fromJson(
    Map<String, dynamic> json,
  ) => _$$SHOFlashSaleProductActivityImplFromJson(json);

  @override
  final String sessionId;
  @override
  final SHOFlashSaleProductStatus status;
  @override
  final int originalPrice;
  @override
  final int activityPrice;
  final List<SHOFlashSalePromoTag> _promoTags;
  @override
  @JsonKey()
  List<SHOFlashSalePromoTag> get promoTags {
    if (_promoTags is EqualUnmodifiableListView) return _promoTags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_promoTags);
  }

  @override
  final String? primaryPromoType;
  @override
  final String? primaryPromoLabel;
  @override
  final String? sessionStartAt;
  @override
  final String? sessionEndAt;
  @override
  final String? overlayLabel;
  @override
  @JsonKey()
  final bool isFollowed;
  @override
  @JsonKey()
  final int stock;

  @override
  String toString() {
    return 'SHOFlashSaleProductActivity(sessionId: $sessionId, status: $status, originalPrice: $originalPrice, activityPrice: $activityPrice, promoTags: $promoTags, primaryPromoType: $primaryPromoType, primaryPromoLabel: $primaryPromoLabel, sessionStartAt: $sessionStartAt, sessionEndAt: $sessionEndAt, overlayLabel: $overlayLabel, isFollowed: $isFollowed, stock: $stock)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SHOFlashSaleProductActivityImpl &&
            (identical(other.sessionId, sessionId) ||
                other.sessionId == sessionId) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.originalPrice, originalPrice) ||
                other.originalPrice == originalPrice) &&
            (identical(other.activityPrice, activityPrice) ||
                other.activityPrice == activityPrice) &&
            const DeepCollectionEquality().equals(
              other._promoTags,
              _promoTags,
            ) &&
            (identical(other.primaryPromoType, primaryPromoType) ||
                other.primaryPromoType == primaryPromoType) &&
            (identical(other.primaryPromoLabel, primaryPromoLabel) ||
                other.primaryPromoLabel == primaryPromoLabel) &&
            (identical(other.sessionStartAt, sessionStartAt) ||
                other.sessionStartAt == sessionStartAt) &&
            (identical(other.sessionEndAt, sessionEndAt) ||
                other.sessionEndAt == sessionEndAt) &&
            (identical(other.overlayLabel, overlayLabel) ||
                other.overlayLabel == overlayLabel) &&
            (identical(other.isFollowed, isFollowed) ||
                other.isFollowed == isFollowed) &&
            (identical(other.stock, stock) || other.stock == stock));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    sessionId,
    status,
    originalPrice,
    activityPrice,
    const DeepCollectionEquality().hash(_promoTags),
    primaryPromoType,
    primaryPromoLabel,
    sessionStartAt,
    sessionEndAt,
    overlayLabel,
    isFollowed,
    stock,
  );

  /// Create a copy of SHOFlashSaleProductActivity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SHOFlashSaleProductActivityImplCopyWith<_$SHOFlashSaleProductActivityImpl>
  get copyWith =>
      __$$SHOFlashSaleProductActivityImplCopyWithImpl<
        _$SHOFlashSaleProductActivityImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SHOFlashSaleProductActivityImplToJson(this);
  }
}

abstract class _SHOFlashSaleProductActivity
    extends SHOFlashSaleProductActivity {
  const factory _SHOFlashSaleProductActivity({
    required final String sessionId,
    required final SHOFlashSaleProductStatus status,
    required final int originalPrice,
    required final int activityPrice,
    final List<SHOFlashSalePromoTag> promoTags,
    final String? primaryPromoType,
    final String? primaryPromoLabel,
    final String? sessionStartAt,
    final String? sessionEndAt,
    final String? overlayLabel,
    final bool isFollowed,
    final int stock,
  }) = _$SHOFlashSaleProductActivityImpl;
  const _SHOFlashSaleProductActivity._() : super._();

  factory _SHOFlashSaleProductActivity.fromJson(Map<String, dynamic> json) =
      _$SHOFlashSaleProductActivityImpl.fromJson;

  @override
  String get sessionId;
  @override
  SHOFlashSaleProductStatus get status;
  @override
  int get originalPrice;
  @override
  int get activityPrice;
  @override
  List<SHOFlashSalePromoTag> get promoTags;
  @override
  String? get primaryPromoType;
  @override
  String? get primaryPromoLabel;
  @override
  String? get sessionStartAt;
  @override
  String? get sessionEndAt;
  @override
  String? get overlayLabel;
  @override
  bool get isFollowed;
  @override
  int get stock;

  /// Create a copy of SHOFlashSaleProductActivity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SHOFlashSaleProductActivityImplCopyWith<_$SHOFlashSaleProductActivityImpl>
  get copyWith => throw _privateConstructorUsedError;
}

SHOFlashSaleFollow _$SHOFlashSaleFollowFromJson(Map<String, dynamic> json) {
  return _SHOFlashSaleFollow.fromJson(json);
}

/// @nodoc
mixin _$SHOFlashSaleFollow {
  String get id => throw _privateConstructorUsedError;
  String get sessionId => throw _privateConstructorUsedError;
  String get productId => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get imageUrl => throw _privateConstructorUsedError;
  String get sessionStartAt => throw _privateConstructorUsedError;
  SHOFlashSaleProductStatus get status => throw _privateConstructorUsedError;

  /// Serializes this SHOFlashSaleFollow to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SHOFlashSaleFollow
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SHOFlashSaleFollowCopyWith<SHOFlashSaleFollow> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SHOFlashSaleFollowCopyWith<$Res> {
  factory $SHOFlashSaleFollowCopyWith(
    SHOFlashSaleFollow value,
    $Res Function(SHOFlashSaleFollow) then,
  ) = _$SHOFlashSaleFollowCopyWithImpl<$Res, SHOFlashSaleFollow>;
  @useResult
  $Res call({
    String id,
    String sessionId,
    String productId,
    String title,
    String imageUrl,
    String sessionStartAt,
    SHOFlashSaleProductStatus status,
  });
}

/// @nodoc
class _$SHOFlashSaleFollowCopyWithImpl<$Res, $Val extends SHOFlashSaleFollow>
    implements $SHOFlashSaleFollowCopyWith<$Res> {
  _$SHOFlashSaleFollowCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SHOFlashSaleFollow
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? sessionId = null,
    Object? productId = null,
    Object? title = null,
    Object? imageUrl = null,
    Object? sessionStartAt = null,
    Object? status = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            sessionId: null == sessionId
                ? _value.sessionId
                : sessionId // ignore: cast_nullable_to_non_nullable
                      as String,
            productId: null == productId
                ? _value.productId
                : productId // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            imageUrl: null == imageUrl
                ? _value.imageUrl
                : imageUrl // ignore: cast_nullable_to_non_nullable
                      as String,
            sessionStartAt: null == sessionStartAt
                ? _value.sessionStartAt
                : sessionStartAt // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as SHOFlashSaleProductStatus,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SHOFlashSaleFollowImplCopyWith<$Res>
    implements $SHOFlashSaleFollowCopyWith<$Res> {
  factory _$$SHOFlashSaleFollowImplCopyWith(
    _$SHOFlashSaleFollowImpl value,
    $Res Function(_$SHOFlashSaleFollowImpl) then,
  ) = __$$SHOFlashSaleFollowImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String sessionId,
    String productId,
    String title,
    String imageUrl,
    String sessionStartAt,
    SHOFlashSaleProductStatus status,
  });
}

/// @nodoc
class __$$SHOFlashSaleFollowImplCopyWithImpl<$Res>
    extends _$SHOFlashSaleFollowCopyWithImpl<$Res, _$SHOFlashSaleFollowImpl>
    implements _$$SHOFlashSaleFollowImplCopyWith<$Res> {
  __$$SHOFlashSaleFollowImplCopyWithImpl(
    _$SHOFlashSaleFollowImpl _value,
    $Res Function(_$SHOFlashSaleFollowImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SHOFlashSaleFollow
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? sessionId = null,
    Object? productId = null,
    Object? title = null,
    Object? imageUrl = null,
    Object? sessionStartAt = null,
    Object? status = null,
  }) {
    return _then(
      _$SHOFlashSaleFollowImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        sessionId: null == sessionId
            ? _value.sessionId
            : sessionId // ignore: cast_nullable_to_non_nullable
                  as String,
        productId: null == productId
            ? _value.productId
            : productId // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        imageUrl: null == imageUrl
            ? _value.imageUrl
            : imageUrl // ignore: cast_nullable_to_non_nullable
                  as String,
        sessionStartAt: null == sessionStartAt
            ? _value.sessionStartAt
            : sessionStartAt // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as SHOFlashSaleProductStatus,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SHOFlashSaleFollowImpl implements _SHOFlashSaleFollow {
  const _$SHOFlashSaleFollowImpl({
    required this.id,
    required this.sessionId,
    required this.productId,
    required this.title,
    required this.imageUrl,
    required this.sessionStartAt,
    this.status = SHOFlashSaleProductStatus.notStarted,
  });

  factory _$SHOFlashSaleFollowImpl.fromJson(Map<String, dynamic> json) =>
      _$$SHOFlashSaleFollowImplFromJson(json);

  @override
  final String id;
  @override
  final String sessionId;
  @override
  final String productId;
  @override
  final String title;
  @override
  final String imageUrl;
  @override
  final String sessionStartAt;
  @override
  @JsonKey()
  final SHOFlashSaleProductStatus status;

  @override
  String toString() {
    return 'SHOFlashSaleFollow(id: $id, sessionId: $sessionId, productId: $productId, title: $title, imageUrl: $imageUrl, sessionStartAt: $sessionStartAt, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SHOFlashSaleFollowImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.sessionId, sessionId) ||
                other.sessionId == sessionId) &&
            (identical(other.productId, productId) ||
                other.productId == productId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.sessionStartAt, sessionStartAt) ||
                other.sessionStartAt == sessionStartAt) &&
            (identical(other.status, status) || other.status == status));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    sessionId,
    productId,
    title,
    imageUrl,
    sessionStartAt,
    status,
  );

  /// Create a copy of SHOFlashSaleFollow
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SHOFlashSaleFollowImplCopyWith<_$SHOFlashSaleFollowImpl> get copyWith =>
      __$$SHOFlashSaleFollowImplCopyWithImpl<_$SHOFlashSaleFollowImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$SHOFlashSaleFollowImplToJson(this);
  }
}

abstract class _SHOFlashSaleFollow implements SHOFlashSaleFollow {
  const factory _SHOFlashSaleFollow({
    required final String id,
    required final String sessionId,
    required final String productId,
    required final String title,
    required final String imageUrl,
    required final String sessionStartAt,
    final SHOFlashSaleProductStatus status,
  }) = _$SHOFlashSaleFollowImpl;

  factory _SHOFlashSaleFollow.fromJson(Map<String, dynamic> json) =
      _$SHOFlashSaleFollowImpl.fromJson;

  @override
  String get id;
  @override
  String get sessionId;
  @override
  String get productId;
  @override
  String get title;
  @override
  String get imageUrl;
  @override
  String get sessionStartAt;
  @override
  SHOFlashSaleProductStatus get status;

  /// Create a copy of SHOFlashSaleFollow
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SHOFlashSaleFollowImplCopyWith<_$SHOFlashSaleFollowImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
