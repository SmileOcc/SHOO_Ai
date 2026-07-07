// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'hos_flash_sale_calendar.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

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
