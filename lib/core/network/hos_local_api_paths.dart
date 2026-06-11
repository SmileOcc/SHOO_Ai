import '../constants/hos_constants.dart';

/// 本地 Mock Server 资源路径（与 `/api/v1/download` 风格一致）。
///
/// 固定前缀：`http://127.0.0.1:3847/api/v1/`
/// - 下载：`/download/{fileName}`
/// - 音乐：`/music/{fileName}`
abstract final class SHOLocalApiPaths {
  static const String defaultBase = SHOAppConstants.defaultLocalApiBaseUrl;

  static String resourceUrl(String resource, String fileName, {String? base}) {
    final root = _normalizeBase(base ?? defaultBase);
    final encoded = Uri.encodeComponent(fileName);
    return '$root/$resource/$encoded';
  }

  static String download(String fileName, {String? base}) =>
      resourceUrl('download', fileName, base: base);

  static String music(String fileName, {String? base}) =>
      resourceUrl('music', fileName, base: base);

  static bool isResourceUrl(String url, String resource) {
    final uri = Uri.tryParse(url);
    if (uri == null) return false;

    final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
    if (segments.length < 2) return false;

    final resourceIndex = segments.lastIndexOf(resource);
    if (resourceIndex < 0) return false;

    // 期望路径形如 .../api/v1/{resource}/{fileName}
    return resourceIndex >= 2 &&
        segments[resourceIndex - 1] == 'v1' &&
        segments[resourceIndex] == resource &&
        segments.length > resourceIndex + 1;
  }

  static bool isDownloadUrl(String url) => isResourceUrl(url, 'download');

  static bool isMusicUrl(String url) => isResourceUrl(url, 'music');

  static String _normalizeBase(String base) {
    return base.endsWith('/') ? base.substring(0, base.length - 1) : base;
  }
}
