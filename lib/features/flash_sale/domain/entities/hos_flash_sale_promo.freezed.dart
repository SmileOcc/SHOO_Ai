// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'hos_flash_sale_promo.dart';

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
