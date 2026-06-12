import 'dart:io';

import '../../domain/hos_music_track.dart';

bool shoMusicTrackHasCover(SHOMusicTrack? track) {
  if (track == null) return false;
  final path = track.coverPath;
  if (path != null && path.trim().isNotEmpty && File(path).existsSync()) {
    return true;
  }
  final url = track.coverUrl;
  return url != null && url.trim().isNotEmpty;
}
