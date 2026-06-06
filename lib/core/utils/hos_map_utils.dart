/// 常用字典/Map 工具。
abstract final class SHOMapUtils {
  static bool isEmpty(Map? map) => map == null || map.isEmpty;

  static bool isNotEmpty(Map? map) => !isEmpty(map);

  static Map<K, V> safe<K, V>(Map<K, V>? map) => map ?? {};

  static V? getOrNull<K, V>(Map<K, V> map, K key) => map[key];

  static V getOrDefault<K, V>(Map<K, V> map, K key, V defaultValue) =>
      map[key] ?? defaultValue;

  static Map<K, V> filterNullValues<K, V>(Map<K, V?> map) {
    return Map.fromEntries(
      map.entries.where((e) => e.value != null).map((e) => MapEntry(e.key, e.value as V)),
    );
  }

  static Map<String, dynamic> merge(
    Map<String, dynamic> base,
    Map<String, dynamic> other,
  ) {
    return {...base, ...other};
  }

  static Map<K, V> pick<K, V>(Map<K, V> map, List<K> keys) {
    return {for (final k in keys) if (map.containsKey(k)) k: map[k]!};
  }

  static Map<K, V> omit<K, V>(Map<K, V> map, List<K> keys) {
    return Map.fromEntries(map.entries.where((e) => !keys.contains(e.key)));
  }
}
