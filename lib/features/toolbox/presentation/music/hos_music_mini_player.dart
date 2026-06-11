import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/hos_guarded_tap.dart';
import '../../domain/hos_music_color_utils.dart';
import 'hos_music_mini_player_controller.dart';
import 'hos_music_player_controller.dart';
import 'hos_music_rotating_cover.dart';

class SHOMusicMiniPlayer extends ConsumerStatefulWidget {
  const SHOMusicMiniPlayer({super.key});

  @override
  ConsumerState<SHOMusicMiniPlayer> createState() => _SHOMusicMiniPlayerState();
}

class _SHOMusicMiniPlayerState extends ConsumerState<SHOMusicMiniPlayer> {
  static const _size = 64.0;
  static const _closeSize = 20.0;

  Offset? _dragOffset;

  @override
  Widget build(BuildContext context) {
    final dismissed = ref.watch(musicMiniPlayerDismissedProvider);
    final onPlayerPage = ref.watch(musicOnPlayerPageProvider);
    final playerState = ref.watch(musicPlayerProvider);
    final track = playerState.currentTrack;

    if (dismissed || track == null || onPlayerPage) {
      return const SizedBox.shrink();
    }

    final active = playerState.isPlaying ||
        playerState.isLoading ||
        playerState.position > Duration.zero;
    if (!active) return const SizedBox.shrink();

    final saved = ref.watch(musicMiniPlayerOffsetProvider);
    final media = MediaQuery.of(context);
    final defaultOffset = Offset(
      media.size.width - _size - 16,
      media.size.height - _size - media.padding.bottom - 88,
    );
    final position = _dragOffset ?? saved ?? defaultOffset;

    final songKey = track.resolvedSongKey;
    final coverColor =
        track.coverColor ?? SHOMusicColorUtils.colorForKey(songKey, salt: 11);

    return Positioned(
      left: position.dx,
      top: position.dy,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            _dragOffset = Offset(
              (position.dx + details.delta.dx)
                  .clamp(0.0, media.size.width - _size),
              (position.dy + details.delta.dy)
                  .clamp(media.padding.top, media.size.height - _size - 16),
            );
          });
        },
        onPanEnd: (_) {
          final offset = _dragOffset;
          if (offset != null) {
            ref.read(musicMiniPlayerOffsetProvider.notifier).save(offset);
          }
        },
        child: SizedBox(
          width: _size + 4,
          height: _size + 4,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              SHOGuardedTap(
                interval: const Duration(milliseconds: 600),
                onTap: () async {
                  final index = playerState.playlist.indexWhere(
                    (item) => item.id == track.id,
                  );
                  await openMusicPlayerPage(
                    ref,
                    trackId: track.id,
                    index: index >= 0 ? index : 0,
                  );
                },
                child: SHOMusicRotatingCover(
                  isPlaying: playerState.isPlaying,
                  coverColor: coverColor,
                  coverUrl: track.coverUrl,
                  coverPath: track.coverPath,
                  size: _size,
                ),
              ),
              Positioned(
                top: -4,
                right: -4,
                child: SHOGuardedTap(
                  onTap: () async {
                    await ref.read(musicPlayerProvider.notifier).stop();
                    ref
                        .read(musicMiniPlayerDismissedProvider.notifier)
                        .dismiss();
                  },
                  child: Container(
                    width: _closeSize,
                    height: _closeSize,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.72),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white70, width: 1),
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      size: 12,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
