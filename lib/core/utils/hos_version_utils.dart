/// 版本号工具：将 x.y.z 各段补零后拼接为整数再比较大小。
///
/// 例：`0.1.0` → `000100`，`0.2.0` → `000200`，后者更大即视为有新版本。
abstract final class SHOVersionUtils {
  static const _segmentWidth = 2;

  /// 清洗并解析版本号各段（支持去掉 `v` 前缀等非数字字符）。
  static List<int> parseSegments(String version) {
    final cleaned = version.trim().replaceAll(RegExp(r'[^0-9.]'), '');
    if (cleaned.isEmpty) return [0];
    return cleaned
        .split('.')
        .where((part) => part.isNotEmpty)
        .map(int.parse)
        .toList();
  }

  /// 版本号拼接为可比较的整数编码。
  static int toNumericCode(String version) {
    final segments = parseSegments(version);
    final buffer = StringBuffer();
    for (final segment in segments) {
      buffer.write(segment.toString().padLeft(_segmentWidth, '0'));
    }
    return int.parse(buffer.isEmpty ? '0' : buffer.toString());
  }

  /// [remote] 是否比 [current] 新。
  static bool hasUpdate(String current, String remote) {
    return toNumericCode(remote) > toNumericCode(current);
  }

  /// 比较版本：返回负数表示 [current] 更旧，0 相等，正数 [current] 更新。
  static int compare(String current, String remote) {
    return toNumericCode(current).compareTo(toNumericCode(remote));
  }
}
