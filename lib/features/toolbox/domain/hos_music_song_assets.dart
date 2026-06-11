class SHOMusicSongAssets {
  const SHOMusicSongAssets({
    required this.songKey,
    this.audioPath,
    this.coverPath,
    this.bgPath,
    this.lyricsText,
    this.isCached = false,
    this.packTaskId,
  });

  final String songKey;
  final String? audioPath;
  final String? coverPath;
  final String? bgPath;
  final String? lyricsText;
  final bool isCached;
  final String? packTaskId;

  bool get hasAudio => audioPath != null && audioPath!.isNotEmpty;

  bool get hasCover => coverPath != null && coverPath!.isNotEmpty;

  bool get hasBg => bgPath != null && bgPath!.isNotEmpty;

  bool get hasLyrics => lyricsText != null && lyricsText!.trim().isNotEmpty;

  bool get needsAssetExtraction => !hasCover || !hasBg || !hasLyrics;

  SHOMusicSongAssets copyWith({
    String? audioPath,
    String? coverPath,
    String? bgPath,
    String? lyricsText,
    bool? isCached,
    String? packTaskId,
  }) {
    return SHOMusicSongAssets(
      songKey: songKey,
      audioPath: audioPath ?? this.audioPath,
      coverPath: coverPath ?? this.coverPath,
      bgPath: bgPath ?? this.bgPath,
      lyricsText: lyricsText ?? this.lyricsText,
      isCached: isCached ?? this.isCached,
      packTaskId: packTaskId ?? this.packTaskId,
    );
  }
}
