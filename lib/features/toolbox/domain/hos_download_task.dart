enum SHODownloadStatus {
  downloading,
  paused,
  completed,
}

enum SHODownloadFileType {
  doc,
  pdf,
  excel,
  zip,
  video,
  other,
}

class SHODownloadTask {
  const SHODownloadTask({
    required this.id,
    required this.url,
    required this.fileName,
    required this.fileType,
    required this.status,
    required this.downloadedBytes,
    required this.createdAt,
    required this.localPath,
    this.totalBytes,
    this.priority = false,
  });

  final String id;
  final String url;
  final String fileName;
  final SHODownloadFileType fileType;
  final SHODownloadStatus status;
  final int downloadedBytes;
  final int? totalBytes;
  final bool priority;
  final DateTime createdAt;
  final String localPath;

  double get progress {
    if (status == SHODownloadStatus.completed) return 1;
    if (totalBytes == null || totalBytes! <= 0) return 0;
    return (downloadedBytes / totalBytes!).clamp(0, 1);
  }

  SHODownloadTask copyWith({
    String? id,
    String? url,
    String? fileName,
    SHODownloadFileType? fileType,
    SHODownloadStatus? status,
    int? downloadedBytes,
    int? Function()? totalBytes,
    bool? priority,
    DateTime? createdAt,
    String? localPath,
  }) {
    return SHODownloadTask(
      id: id ?? this.id,
      url: url ?? this.url,
      fileName: fileName ?? this.fileName,
      fileType: fileType ?? this.fileType,
      status: status ?? this.status,
      downloadedBytes: downloadedBytes ?? this.downloadedBytes,
      totalBytes: totalBytes != null ? totalBytes() : this.totalBytes,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      localPath: localPath ?? this.localPath,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'url': url,
        'fileName': fileName,
        'fileType': fileType.name,
        'status': status.name,
        'downloadedBytes': downloadedBytes,
        'totalBytes': totalBytes,
        'priority': priority,
        'createdAt': createdAt.toIso8601String(),
        'localPath': localPath,
      };

  factory SHODownloadTask.fromJson(Map<String, dynamic> json) {
    return SHODownloadTask(
      id: json['id'] as String? ?? '',
      url: json['url'] as String? ?? '',
      fileName: json['fileName'] as String? ?? '',
      fileType: SHODownloadFileType.values.asNameMap()[json['fileType']] ??
          SHODownloadFileType.other,
      status: SHODownloadStatus.values.asNameMap()[json['status']] ??
          SHODownloadStatus.paused,
      downloadedBytes: json['downloadedBytes'] as int? ?? 0,
      totalBytes: json['totalBytes'] as int?,
      priority: json['priority'] as bool? ?? false,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      localPath: json['localPath'] as String? ?? '',
    );
  }
}

SHODownloadFileType detectDownloadFileType(String fileName) {
  final ext = fileName.contains('.')
      ? fileName.split('.').last.toLowerCase()
      : '';
  return switch (ext) {
    'doc' || 'docx' => SHODownloadFileType.doc,
    'pdf' => SHODownloadFileType.pdf,
    'xls' || 'xlsx' || 'csv' => SHODownloadFileType.excel,
    'zip' || 'rar' || '7z' => SHODownloadFileType.zip,
    'mp4' || 'mov' || 'avi' || 'mkv' || 'webm' => SHODownloadFileType.video,
    _ => SHODownloadFileType.other,
  };
}

String safeDecodeUriComponent(String input) {
  try {
    return Uri.decodeComponent(input);
  } catch (_) {
    return input;
  }
}

String inferDownloadFileName({required String url, String? custom}) {
  final trimmed = custom?.trim();
  if (trimmed != null && trimmed.isNotEmpty) return trimmed;
  final uri = Uri.tryParse(url);
  if (uri == null) return 'download';
  final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
  if (segments.isEmpty) return 'download';
  return safeDecodeUriComponent(segments.last);
}

enum SHODownloadPreviewKind {
  image,
  text,
  pdf,
  video,
}

String downloadFileExtension(String fileName) {
  if (!fileName.contains('.')) return '';
  return fileName.split('.').last.toLowerCase();
}

SHODownloadPreviewKind? previewKindForFileName(String fileName) {
  return switch (downloadFileExtension(fileName)) {
    'png' || 'jpg' || 'jpeg' || 'gif' || 'webp' || 'bmp' => SHODownloadPreviewKind.image,
    'txt' || 'json' || 'csv' || 'log' || 'md' => SHODownloadPreviewKind.text,
    'pdf' => SHODownloadPreviewKind.pdf,
    'mp4' || 'mov' || 'avi' || 'mkv' || 'webm' => SHODownloadPreviewKind.video,
    _ => null,
  };
}

bool isDownloadTaskPreviewable(SHODownloadTask task) {
  return previewKindForFileName(task.fileName) != null;
}
