import 'dart:convert';

abstract final class SHOMusicSongKey {
  /// Stable filesystem-safe cache directory key derived from title/filename.
  static String fromTitle(String title) => toCacheKey(title);

  static String normalize(String name) {
    var value = name.trim();
    if (value.contains('.')) {
      value = value.substring(0, value.lastIndexOf('.'));
    }
    return value.toLowerCase();
  }

  /// Hash-based key safe for filesystem paths (handles special characters).
  static String toCacheKey(String name) {
    final normalized = normalize(name);
    if (normalized.isEmpty) return 's00000000';
    final hash = _fnv1a32(utf8.encode(normalized));
    return 's${hash.toRadixString(16).padLeft(8, '0')}';
  }

  static int _fnv1a32(List<int> bytes) {
    var hash = 0x811c9dc5;
    for (final b in bytes) {
      hash ^= b;
      hash = (hash * 0x01000193) & 0xFFFFFFFF;
    }
    return hash;
  }

  static bool matches(String a, String b) => fromTitle(a) == fromTitle(b);

  static String baseName(String path) {
    final segments = path.split('/');
    final file = segments.isEmpty ? path : segments.last;
    return fromTitle(file);
  }
}
