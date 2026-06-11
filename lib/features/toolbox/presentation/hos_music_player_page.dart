import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/hos_spacing.dart';
import '../../../core/widgets/hos_guarded_tap.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/hos_music_color_utils.dart';
import 'music/hos_music_library_controller.dart';
import 'music/hos_music_lyrics_view.dart';
import 'music/hos_music_player_controller.dart';
import 'music/hos_music_rotating_cover.dart';

class SHOMusicPlayerPage extends ConsumerStatefulWidget {
  const SHOMusicPlayerPage({
    super.key,
    required this.trackId,
    this.startIndex = 0,
    this.fromDownloadPack = false,
  });

  final String trackId;
  final int startIndex;
  final bool fromDownloadPack;

  @override
  ConsumerState<SHOMusicPlayerPage> createState() => _SHOMusicPlayerPageState();
}

class _SHOMusicPlayerPageState extends ConsumerState<SHOMusicPlayerPage> {
  var _showLyrics = false;
  var _initialized = false;
  var _bootstrapping = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrapPlaylist());
  }

  Future<void> _bootstrapPlaylist() async {
    if (_initialized) return;
    _initialized = true;

    try {
      final playerState = ref.read(musicPlayerProvider);
      final current = playerState.currentTrack;
      if (current?.id == widget.trackId &&
          playerState.playlist.isNotEmpty &&
          !playerState.isLoading) {
        return;
      }

      final items = await ref.read(musicLibraryListProvider.future);
      final playlist = items.map((item) => item.track).toList();
      if (playlist.isEmpty) return;

      var startIndex = widget.startIndex;
      final trackIndex = playlist.indexWhere((t) => t.id == widget.trackId);
      if (trackIndex >= 0) startIndex = trackIndex;

      await ref.read(musicPlayerProvider.notifier).setPlaylist(
            playlist,
            startIndex: startIndex,
          );
    } finally {
      if (mounted) setState(() => _bootstrapping = false);
    }
  }

  Future<void> _handleDownload(AppLocalizations l10n) async {
    final track = ref.read(musicPlayerProvider).currentTrack;
    if (track == null) return;

    if (track.isCachedLocally) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.musicPlayerAlreadyDownloaded)),
      );
      return;
    }

    final ok =
        await ref.read(musicPlayerProvider.notifier).downloadCurrentSong();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok ? l10n.musicPlayerDownloadSuccess : l10n.musicPlayerDownloadFailed,
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  IconData _playModeIcon(SHOMusicPlayMode mode) {
    return switch (mode) {
      SHOMusicPlayMode.sequence => Icons.repeat_rounded,
      SHOMusicPlayMode.loopAll => Icons.repeat_on_rounded,
      SHOMusicPlayMode.loopOne => Icons.repeat_one_on_rounded,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final playerState = ref.watch(musicPlayerProvider);
    final track = playerState.currentTrack;
    final notifier = ref.read(musicPlayerProvider.notifier);

    final songKey = track?.resolvedSongKey ?? '';
    final coverColor = track?.coverColor ??
        SHOMusicColorUtils.colorForKey(songKey, salt: 11);
    final bgColor = track?.bgColor ??
        SHOMusicColorUtils.colorForKey(songKey, salt: 29);
    final bgPath = track?.bgPath;

    if (_bootstrapping && track == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF14141F),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          _buildBackground(bgPath, bgColor),
          SafeArea(
            child: Column(
              children: [
                _buildTopBar(context, l10n),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 280),
                    child: _showLyrics
                        ? SHOMusicLyricsView(
                            key: const ValueKey('lyrics'),
                            lines: playerState.currentLyrics,
                            activeIndex: playerState.currentLyricIndex,
                            emptyText: l10n.musicPlayerNoLyrics,
                          )
                        : Center(
                            key: const ValueKey('cover'),
                            child: SHOMusicRotatingCover(
                              isPlaying: playerState.isPlaying,
                              coverColor: coverColor,
                              coverUrl: track?.coverUrl,
                              coverPath: track?.coverPath,
                            ),
                          ),
                  ),
                ),
                if (track != null) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: SHOAppSpacing.xl,
                    ),
                    child: Column(
                      children: [
                        Text(
                          track.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: SHOAppSpacing.xs),
                        Text(
                          track.artist,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.72),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: SHOAppSpacing.lg),
                ],
                _buildProgressBar(playerState, notifier),
                const SizedBox(height: SHOAppSpacing.md),
                _buildControls(context, l10n, playerState, notifier),
                const SizedBox(height: SHOAppSpacing.lg),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground(String? bgPath, int bgColor) {
    if (bgPath != null && File(bgPath).existsSync()) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Image.file(
            File(bgPath),
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _buildColorBackground(bgColor),
          ),
          Container(color: Colors.black.withValues(alpha: 0.45)),
        ],
      );
    }
    return _buildColorBackground(bgColor);
  }

  Widget _buildColorBackground(int bgColor) {
    final top = Color(bgColor).withValues(alpha: 0.85);
    const bottom = Color(0xFF14141F);
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [top, bottom],
        ),
      ),
    );
  }

  void _handleBack(BuildContext context) {
    context.pop();
  }

  Widget _buildTopBar(BuildContext context, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: SHOAppSpacing.sm,
        vertical: SHOAppSpacing.xs,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => _handleBack(context),
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Colors.white,
            ),
            tooltip: l10n.musicPlayerDownloadSong,
          ),
          Expanded(
            child: Text(
              l10n.musicPlayerNowPlaying,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.85),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SHOGuardedIconButton(
            onPressed: () => _handleDownload(l10n),
            icon: const Icon(
              Icons.arrow_circle_down_rounded,
              color: Colors.white,
            ),
            tooltip: l10n.musicPlayerDownloadSong,
          ),
          TextButton(
            onPressed: () => setState(() => _showLyrics = !_showLyrics),
            child: Text(
              _showLyrics
                  ? l10n.musicPlayerShowCover
                  : l10n.musicPlayerShowLyrics,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(
    SHOMusicPlayerState playerState,
    SHOMusicPlayerNotifier notifier,
  ) {
    final duration = playerState.duration;
    final position = playerState.position;
    final maxMs = duration.inMilliseconds > 0 ? duration.inMilliseconds : 1;
    final value = (position.inMilliseconds / maxMs).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: SHOAppSpacing.xl),
      child: Column(
        children: [
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 3,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
              activeTrackColor: Colors.white,
              inactiveTrackColor: Colors.white.withValues(alpha: 0.25),
              thumbColor: Colors.white,
            ),
            child: Slider(
              value: value,
              onChanged: duration > Duration.zero
                  ? (v) {
                      final target = Duration(
                        milliseconds: (v * maxMs).round(),
                      );
                      notifier.seek(target);
                    }
                  : null,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: SHOAppSpacing.xs),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDuration(position),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 12,
                  ),
                ),
                Text(
                  _formatDuration(duration),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControls(
    BuildContext context,
    AppLocalizations l10n,
    SHOMusicPlayerState playerState,
    SHOMusicPlayerNotifier notifier,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: SHOAppSpacing.xl),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: notifier.cyclePlayMode,
            icon: Icon(
              _playModeIcon(playerState.playMode),
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          IconButton(
            onPressed: notifier.playPrevious,
            iconSize: 34,
            icon: const Icon(Icons.skip_previous_rounded, color: Colors.white),
          ),
          GestureDetector(
            onTap: notifier.togglePlayPause,
            child: Container(
              width: 68,
              height: 68,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: playerState.isLoading
                  ? const Padding(
                      padding: EdgeInsets.all(18),
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    )
                  : Icon(
                      playerState.isPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      size: 38,
                      color: const Color(0xFF222222),
                    ),
            ),
          ),
          IconButton(
            onPressed: notifier.playNext,
            iconSize: 34,
            icon: const Icon(Icons.skip_next_rounded, color: Colors.white),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.queue_music_rounded,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }
}
