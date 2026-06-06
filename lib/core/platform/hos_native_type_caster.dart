import 'dart:typed_data';

/// MethodChannel 返回值类型安全转换。
///
/// [StandardMessageCodec] 支持：`null` / `bool` / `num` / `String` / `Uint8List` /
/// `List` / `Map`；不支持 `BigInt`（请转 String）。
abstract final class SHONativeTypeCaster {
  static T cast<T>(dynamic value) {
    if (value is T) return value;

    final type = T;
    if (type == int) {
      return (value as num).toInt() as T;
    }
    if (type == double) {
      return (value as num).toDouble() as T;
    }
    if (type == String) {
      return value.toString() as T;
    }
    if (type == bool) {
      return (value == true) as T;
    }
    if (type == Uint8List) {
      if (value is Uint8List) return value as T;
      if (value is List<int>) return Uint8List.fromList(value) as T;
    }
    if (type == Map<String, dynamic>) {
      return Map<String, dynamic>.from(value as Map) as T;
    }
    if (type == List<dynamic>) {
      return List<dynamic>.from(value as List) as T;
    }
    if (type == List<String>) {
      return (value as List).map((e) => e.toString()).toList() as T;
    }
    if (type == List<int>) {
      return (value as List).map((e) => (e as num).toInt()).toList() as T;
    }

    return value as T;
  }
}
