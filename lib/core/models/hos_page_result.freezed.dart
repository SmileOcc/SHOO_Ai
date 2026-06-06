// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'hos_page_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

SHOPageResult<T> _$SHOPageResultFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object?) fromJsonT,
) {
  return _SHOPageResult<T>.fromJson(json, fromJsonT);
}

/// @nodoc
mixin _$SHOPageResult<T> {
  List<T> get items => throw _privateConstructorUsedError;
  int get page => throw _privateConstructorUsedError;
  int get pageSize => throw _privateConstructorUsedError;
  int get total => throw _privateConstructorUsedError;
  bool get hasMore => throw _privateConstructorUsedError;

  /// Serializes this SHOPageResult to a JSON map.
  Map<String, dynamic> toJson(Object? Function(T) toJsonT) =>
      throw _privateConstructorUsedError;

  /// Create a copy of SHOPageResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SHOPageResultCopyWith<T, SHOPageResult<T>> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SHOPageResultCopyWith<T, $Res> {
  factory $SHOPageResultCopyWith(
    SHOPageResult<T> value,
    $Res Function(SHOPageResult<T>) then,
  ) = _$SHOPageResultCopyWithImpl<T, $Res, SHOPageResult<T>>;
  @useResult
  $Res call({List<T> items, int page, int pageSize, int total, bool hasMore});
}

/// @nodoc
class _$SHOPageResultCopyWithImpl<T, $Res, $Val extends SHOPageResult<T>>
    implements $SHOPageResultCopyWith<T, $Res> {
  _$SHOPageResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SHOPageResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? items = null,
    Object? page = null,
    Object? pageSize = null,
    Object? total = null,
    Object? hasMore = null,
  }) {
    return _then(
      _value.copyWith(
            items: null == items
                ? _value.items
                : items // ignore: cast_nullable_to_non_nullable
                      as List<T>,
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
abstract class _$$SHOPageResultImplCopyWith<T, $Res>
    implements $SHOPageResultCopyWith<T, $Res> {
  factory _$$SHOPageResultImplCopyWith(
    _$SHOPageResultImpl<T> value,
    $Res Function(_$SHOPageResultImpl<T>) then,
  ) = __$$SHOPageResultImplCopyWithImpl<T, $Res>;
  @override
  @useResult
  $Res call({List<T> items, int page, int pageSize, int total, bool hasMore});
}

/// @nodoc
class __$$SHOPageResultImplCopyWithImpl<T, $Res>
    extends _$SHOPageResultCopyWithImpl<T, $Res, _$SHOPageResultImpl<T>>
    implements _$$SHOPageResultImplCopyWith<T, $Res> {
  __$$SHOPageResultImplCopyWithImpl(
    _$SHOPageResultImpl<T> _value,
    $Res Function(_$SHOPageResultImpl<T>) _then,
  ) : super(_value, _then);

  /// Create a copy of SHOPageResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? items = null,
    Object? page = null,
    Object? pageSize = null,
    Object? total = null,
    Object? hasMore = null,
  }) {
    return _then(
      _$SHOPageResultImpl<T>(
        items: null == items
            ? _value._items
            : items // ignore: cast_nullable_to_non_nullable
                  as List<T>,
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
@JsonSerializable(genericArgumentFactories: true)
class _$SHOPageResultImpl<T> implements _SHOPageResult<T> {
  const _$SHOPageResultImpl({
    required final List<T> items,
    this.page = 1,
    this.pageSize = 20,
    this.total = 0,
    this.hasMore = false,
  }) : _items = items;

  factory _$SHOPageResultImpl.fromJson(
    Map<String, dynamic> json,
    T Function(Object?) fromJsonT,
  ) => _$$SHOPageResultImplFromJson(json, fromJsonT);

  final List<T> _items;
  @override
  List<T> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
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
    return 'SHOPageResult<$T>(items: $items, page: $page, pageSize: $pageSize, total: $total, hasMore: $hasMore)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SHOPageResultImpl<T> &&
            const DeepCollectionEquality().equals(other._items, _items) &&
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
    const DeepCollectionEquality().hash(_items),
    page,
    pageSize,
    total,
    hasMore,
  );

  /// Create a copy of SHOPageResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SHOPageResultImplCopyWith<T, _$SHOPageResultImpl<T>> get copyWith =>
      __$$SHOPageResultImplCopyWithImpl<T, _$SHOPageResultImpl<T>>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson(Object? Function(T) toJsonT) {
    return _$$SHOPageResultImplToJson<T>(this, toJsonT);
  }
}

abstract class _SHOPageResult<T> implements SHOPageResult<T> {
  const factory _SHOPageResult({
    required final List<T> items,
    final int page,
    final int pageSize,
    final int total,
    final bool hasMore,
  }) = _$SHOPageResultImpl<T>;

  factory _SHOPageResult.fromJson(
    Map<String, dynamic> json,
    T Function(Object?) fromJsonT,
  ) = _$SHOPageResultImpl<T>.fromJson;

  @override
  List<T> get items;
  @override
  int get page;
  @override
  int get pageSize;
  @override
  int get total;
  @override
  bool get hasMore;

  /// Create a copy of SHOPageResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SHOPageResultImplCopyWith<T, _$SHOPageResultImpl<T>> get copyWith =>
      throw _privateConstructorUsedError;
}
