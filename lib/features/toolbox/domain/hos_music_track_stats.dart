class SHOMusicTrackStats {
  const SHOMusicTrackStats({
    this.playCount = 0,
    this.liked = false,
    this.lastPlayedAt,
  });

  final int playCount;
  final bool liked;
  final DateTime? lastPlayedAt;

  SHOMusicTrackStats copyWith({
    int? playCount,
    bool? liked,
    DateTime? Function()? lastPlayedAt,
  }) {
    return SHOMusicTrackStats(
      playCount: playCount ?? this.playCount,
      liked: liked ?? this.liked,
      lastPlayedAt:
          lastPlayedAt != null ? lastPlayedAt() : this.lastPlayedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'playCount': playCount,
        'liked': liked,
        'lastPlayedAt': lastPlayedAt?.toIso8601String(),
      };

  factory SHOMusicTrackStats.fromJson(Map<String, dynamic> json) {
    return SHOMusicTrackStats(
      playCount: json['playCount'] as int? ?? 0,
      liked: json['liked'] as bool? ?? false,
      lastPlayedAt: json['lastPlayedAt'] == null
          ? null
          : DateTime.tryParse(json['lastPlayedAt'] as String),
    );
  }
}
