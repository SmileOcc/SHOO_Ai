// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'hos_flash_sale_page.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

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
