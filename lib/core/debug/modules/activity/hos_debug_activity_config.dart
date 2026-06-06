/// Debug 活动弹窗覆盖配置（仅 Debug 包读取）。
class SHODebugActivityConfig {
  const SHODebugActivityConfig({
    this.overrideEnabled = false,
    this.id = 'debug_activity_001',
    this.delaySeconds = 3,
    this.title = 'DEBUG — Flash Sale',
    this.description =
        'Limited time offer.\nUp to 50% off selected styles.\nFree shipping over \$49.\nNew arrivals daily.\nTap below to shop now.',
    this.imageUrl = 'https://picsum.photos/seed/debug_activity/600/800',
    this.link = '/flash-sale',
    this.buttonText = 'Shop Now',
    this.startAt,
    this.endAt,
    this.prefetchEnabled = false,
    this.maxDailyShows = 1,
  });

  final bool overrideEnabled;
  final String id;
  final int delaySeconds;
  final String title;
  final String description;
  final String imageUrl;
  final String link;
  final String buttonText;
  final DateTime? startAt;
  final DateTime? endAt;
  final bool prefetchEnabled;
  final int maxDailyShows;

  SHODebugActivityConfig copyWith({
    bool? overrideEnabled,
    String? id,
    int? delaySeconds,
    String? title,
    String? description,
    String? imageUrl,
    String? link,
    String? buttonText,
    DateTime? startAt,
    DateTime? endAt,
    bool? prefetchEnabled,
    int? maxDailyShows,
    bool clearStartAt = false,
    bool clearEndAt = false,
  }) {
    return SHODebugActivityConfig(
      overrideEnabled: overrideEnabled ?? this.overrideEnabled,
      id: id ?? this.id,
      delaySeconds: delaySeconds ?? this.delaySeconds,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      link: link ?? this.link,
      buttonText: buttonText ?? this.buttonText,
      startAt: clearStartAt ? null : (startAt ?? this.startAt),
      endAt: clearEndAt ? null : (endAt ?? this.endAt),
      prefetchEnabled: prefetchEnabled ?? this.prefetchEnabled,
      maxDailyShows: maxDailyShows ?? this.maxDailyShows,
    );
  }

  Map<String, dynamic> toJson() => {
        'overrideEnabled': overrideEnabled,
        'id': id,
        'delaySeconds': delaySeconds,
        'title': title,
        'description': description,
        'imageUrl': imageUrl,
        'link': link,
        'buttonText': buttonText,
        'startAt': startAt?.toIso8601String(),
        'endAt': endAt?.toIso8601String(),
        'prefetchEnabled': prefetchEnabled,
        'maxDailyShows': maxDailyShows,
      };

  factory SHODebugActivityConfig.fromJson(Map<String, dynamic> json) {
    return SHODebugActivityConfig(
      overrideEnabled: json['overrideEnabled'] as bool? ?? false,
      id: json['id'] as String? ?? 'debug_activity_001',
      delaySeconds: json['delaySeconds'] as int? ?? 3,
      title: json['title'] as String? ?? 'DEBUG — Flash Sale',
      description: json['description'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ??
          'https://picsum.photos/seed/debug_activity/600/800',
      link: json['link'] as String? ?? '/flash-sale',
      buttonText: json['buttonText'] as String? ?? 'Shop Now',
      startAt: _parseDate(json['startAt']),
      endAt: _parseDate(json['endAt']),
      prefetchEnabled: json['prefetchEnabled'] as bool? ?? false,
      maxDailyShows: json['maxDailyShows'] as int? ?? 1,
    );
  }

  static DateTime? _parseDate(Object? raw) {
    if (raw is! String || raw.isEmpty) return null;
    return DateTime.tryParse(raw);
  }
}
