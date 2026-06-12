import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

import '../domain/hos_music_color_utils.dart';
import '../domain/hos_music_song_key.dart';
import '../domain/hos_music_track.dart';
import 'hos_music_pack_service.dart';

const _assetMusicPrefix = 'assets/music/';

final musicBundleServiceProvider = Provider<SHOMusicBundleService>((ref) {
  return SHOMusicBundleService(ref.watch(musicPackServiceProvider));
});

class SHOMusicBundleService {
  const SHOMusicBundleService(this._packService);

  final SHOMusicPackService _packService;

  Future<List<SHOMusicTrack>> loadBundledTracks({
    required Set<String> dismissedTrackIds,
    required Set<String> seenSongKeys,
  }) async {
    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    final zipAssets = manifest
        .listAssets()
        .where((path) => path.startsWith(_assetMusicPrefix) && path.endsWith('.zip'))
        .toList()
      ..sort();

    final tracks = <SHOMusicTrack>[];

    for (final assetPath in zipAssets) {
      final bundleKey = _bundleKeyFromAsset(assetPath);
      final bytes = (await rootBundle.load(assetPath)).buffer.asUint8List();
      final songs = await _packService.discoverSongsInArchive(bytes);

      for (final song in songs) {
        if (seenSongKeys.contains(song.songKey)) continue;

        final trackId = SHOMusicTrack.bundleTrackId(bundleKey, song.songKey);
        if (dismissedTrackIds.contains(trackId)) continue;

        final assets = await _packService.importSongFromArchive(
          zipBytes: bytes,
          bundleKey: bundleKey,
          song: song,
        );
        if (!assets.hasAudio) continue;

        seenSongKeys.add(song.songKey);
        tracks.add(
          SHOMusicTrack(
            id: trackId,
            title: song.displayTitle,
            artist: '内置音乐',
            songKey: song.songKey,
            source: SHOMusicSource.cached,
            localPath: assets.audioPath,
            coverPath: assets.coverPath,
            bgPath: assets.bgPath,
            lrc: assets.lyricsText,
            coverColor: SHOMusicColorUtils.colorForKey(song.songKey, salt: 11),
            bgColor: SHOMusicColorUtils.colorForKey(song.songKey, salt: 29),
            packTaskId: 'bundle_$bundleKey',
            isCachedLocally: true,
          ),
        );
      }
    }

    return tracks;
  }

  String _bundleKeyFromAsset(String assetPath) {
    final fileName = p.basename(assetPath);
    if (!fileName.contains('.')) return SHOMusicSongKey.fromTitle(fileName);
    return SHOMusicSongKey.fromTitle(
      fileName.substring(0, fileName.lastIndexOf('.')),
    );
  }
}
