import 'package:freezed_annotation/freezed_annotation.dart';

part 'hos_page_result.freezed.dart';
part 'hos_page_result.g.dart';

@Freezed(genericArgumentFactories: true)
class SHOPageResult<T> with _$SHOPageResult<T> {
  const factory SHOPageResult({
    required List<T> items,
    @Default(1) int page,
    @Default(20) int pageSize,
    @Default(0) int total,
    @Default(false) bool hasMore,
  }) = _SHOPageResult<T>;

  factory SHOPageResult.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) =>
      _$SHOPageResultFromJson(json, fromJsonT);
}
