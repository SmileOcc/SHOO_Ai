import 'hos_download_task.dart';

const _directVideoExtensions = {
  'mp4',
  'mov',
  'avi',
  'mkv',
  'webm',
};

const _unsupportedStreamHints = {
  'm3u8',
  'mpd',
  'ism',
};

String normalizeVideoUrl(String url) => url.trim();

String inferVideoTitleFromUrl(String url) {
  return inferDownloadFileName(url: url.trim());
}

bool isDirectVideoDownloadUrl(String url) {
  final trimmed = url.trim().toLowerCase();
  if (trimmed.isEmpty) return false;

  for (final hint in _unsupportedStreamHints) {
    if (trimmed.contains(hint)) return false;
  }

  final name = inferDownloadFileName(url: url);
  final ext = downloadFileExtension(name);
  return _directVideoExtensions.contains(ext);
}

bool isLikelyPlayableVideoUrl(String url) {
  final trimmed = url.trim();
  if (trimmed.isEmpty) return false;
  final uri = Uri.tryParse(trimmed);
  if (uri == null || !uri.hasScheme) return false;
  if (!{'http', 'https'}.contains(uri.scheme)) return false;

  final lower = trimmed.toLowerCase();
  if (_unsupportedStreamHints.any(lower.contains)) return true;
  if (isDirectVideoDownloadUrl(trimmed)) return true;

  final ext = downloadFileExtension(inferDownloadFileName(url: trimmed));
  return ext.isEmpty || _directVideoExtensions.contains(ext);
}
