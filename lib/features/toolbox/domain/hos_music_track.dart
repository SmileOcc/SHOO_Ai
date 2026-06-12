enum SHOMusicSource {
  network,
  asset,
  local,
  cached,
}

class SHOMusicTrack {
  const SHOMusicTrack({
    required this.id,
    required this.title,
    required this.artist,
    required this.source,
    this.album,
    this.songKey,
    this.coverUrl,
    this.coverPath,
    this.bgPath,
    this.coverColor,
    this.bgColor,
    this.audioUrl,
    this.assetPath,
    this.localPath,
    this.taskId,
    this.packTaskId,
    this.lrc,
    this.isCachedLocally = false,
  });

  final String id;
  final String title;
  final String artist;
  final String? album;
  final String? songKey;
  final SHOMusicSource source;
  final String? coverUrl;
  final String? coverPath;
  final String? bgPath;
  final int? coverColor;
  final int? bgColor;
  final String? audioUrl;
  final String? assetPath;
  final String? localPath;
  final String? taskId;
  final String? packTaskId;
  final String? lrc;
  final bool isCachedLocally;

  String get resolvedSongKey => songKey ?? title;

  bool get hasLyrics => lrc != null && lrc!.trim().isNotEmpty;

  bool get isOnlineSource =>
      source == SHOMusicSource.network && !isCachedLocally;

  static const localIdPrefix = 'music_local_';
  static const cachedIdPrefix = 'music_cached_';
  static const packIdPrefix = 'music_pack_';
  static const bundleIdPrefix = 'music_bundle_';

  static String localTrackId(String taskId) => '$localIdPrefix$taskId';

  static String cachedTrackId(String songKey) => '$cachedIdPrefix$songKey';

  static String packTrackId(String packTaskId, String songKey) =>
      '$packIdPrefix${packTaskId}_$songKey';

  static String bundleTrackId(String bundleKey, String songKey) =>
      '$bundleIdPrefix${bundleKey}_$songKey';

  static String? taskIdFromTrackId(String trackId) {
    if (!trackId.startsWith(localIdPrefix)) return null;
    final taskId = trackId.substring(localIdPrefix.length);
    return taskId.isEmpty ? null : taskId;
  }

  SHOMusicTrack copyWith({
    String? title,
    String? artist,
    String? songKey,
    String? coverPath,
    String? bgPath,
    String? localPath,
    String? lrc,
    int? coverColor,
    int? bgColor,
    String? packTaskId,
    bool? isCachedLocally,
    SHOMusicSource? source,
  }) {
    return SHOMusicTrack(
      id: id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album,
      songKey: songKey ?? this.songKey,
      source: source ?? this.source,
      coverUrl: coverUrl,
      coverPath: coverPath ?? this.coverPath,
      bgPath: bgPath ?? this.bgPath,
      coverColor: coverColor ?? this.coverColor,
      bgColor: bgColor ?? this.bgColor,
      audioUrl: audioUrl,
      assetPath: assetPath,
      localPath: localPath ?? this.localPath,
      taskId: taskId,
      packTaskId: packTaskId ?? this.packTaskId,
      lrc: lrc ?? this.lrc,
      isCachedLocally: isCachedLocally ?? this.isCachedLocally,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'artist': artist,
        'album': album,
        'songKey': songKey,
        'source': source.name,
        'coverUrl': coverUrl,
        'coverPath': coverPath,
        'bgPath': bgPath,
        'coverColor': coverColor,
        'bgColor': bgColor,
        'audioUrl': audioUrl,
        'assetPath': assetPath,
        'localPath': localPath,
        'taskId': taskId,
        'packTaskId': packTaskId,
        'lrc': lrc,
        'isCachedLocally': isCachedLocally,
      };

  factory SHOMusicTrack.fromJson(Map<String, dynamic> json) {
    return SHOMusicTrack(
      id: json['id'] as String,
      title: json['title'] as String,
      artist: json['artist'] as String,
      album: json['album'] as String?,
      songKey: json['songKey'] as String?,
      source: SHOMusicSource.values.byName(json['source'] as String),
      coverUrl: json['coverUrl'] as String?,
      coverPath: json['coverPath'] as String?,
      bgPath: json['bgPath'] as String?,
      coverColor: json['coverColor'] as int?,
      bgColor: json['bgColor'] as int?,
      audioUrl: json['audioUrl'] as String?,
      assetPath: json['assetPath'] as String?,
      localPath: json['localPath'] as String?,
      taskId: json['taskId'] as String?,
      packTaskId: json['packTaskId'] as String?,
      lrc: json['lrc'] as String?,
      isCachedLocally: json['isCachedLocally'] as bool? ?? false,
    );
  }

  factory SHOMusicTrack.local({
    required String taskId,
    required String title,
    required String artist,
    String? localPath,
  }) {
    return SHOMusicTrack(
      id: localTrackId(taskId),
      title: title,
      artist: artist,
      songKey: title,
      source: SHOMusicSource.local,
      taskId: taskId,
      localPath: localPath,
      coverColor: 0xFF5C6BC0,
    );
  }
}
