abstract final class SHOMusicSongKey {
  static String fromTitle(String title) => normalize(title);

  static String normalize(String name) {
    var value = name.trim();
    if (value.contains('.')) {
      value = value.substring(0, value.lastIndexOf('.'));
    }
    return value.toLowerCase();
  }

  static bool matches(String a, String b) => normalize(a) == normalize(b);

  static String baseName(String path) {
    final segments = path.split('/');
    final file = segments.isEmpty ? path : segments.last;
    return normalize(file);
  }
}
