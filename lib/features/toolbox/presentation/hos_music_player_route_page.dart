import 'package:flutter/material.dart';

import 'hos_music_player_page.dart';

class SHOMusicPlayerRoutePage extends StatelessWidget {
  const SHOMusicPlayerRoutePage({
    super.key,
    required this.trackId,
    this.startIndex = 0,
    this.fromDownloadPack = false,
  });

  final String trackId;
  final int startIndex;
  final bool fromDownloadPack;

  @override
  Widget build(BuildContext context) {
    return SHOMusicPlayerPage(
      trackId: trackId,
      startIndex: startIndex,
      fromDownloadPack: fromDownloadPack,
    );
  }
}
