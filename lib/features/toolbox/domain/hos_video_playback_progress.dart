class SHOVideoPlaybackProgress {
  const SHOVideoPlaybackProgress({
    required this.entryId,
    required this.positionMs,
    this.durationMs,
    this.updatedAt,
  });

  final String entryId;
  final int positionMs;
  final int? durationMs;
  final DateTime? updatedAt;

  double? get watchedPercent {
    if (durationMs == null || durationMs! <= 0) return null;
    return (positionMs / durationMs! * 100).clamp(0, 100);
  }

  Map<String, dynamic> toJson() => {
        'entryId': entryId,
        'positionMs': positionMs,
        'durationMs': durationMs,
        'updatedAt': (updatedAt ?? DateTime.now()).toIso8601String(),
      };

  factory SHOVideoPlaybackProgress.fromJson(Map<String, dynamic> json) {
    return SHOVideoPlaybackProgress(
      entryId: json['entryId'] as String,
      positionMs: json['positionMs'] as int? ?? 0,
      durationMs: json['durationMs'] as int?,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }
}
