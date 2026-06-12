import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/feedback/hos_toast.dart';
import '../../../core/share/hos_share_service.dart';
import '../../../core/theme/hos_colors.dart';
import '../../../core/theme/hos_spacing.dart';
import '../../../l10n/app_localizations.dart';
import '../data/hos_music_stats_storage.dart';
import '../domain/hos_music_color_utils.dart';
import '../domain/hos_music_track.dart';
import 'music/hos_music_cover_utils.dart';
import 'music/hos_music_library_controller.dart';
import 'music/hos_music_lyrics_view.dart';
import 'music/hos_music_marquee_text.dart';
import 'music/hos_music_more_sheet.dart';
import 'music/hos_music_playlist_sheet.dart';
import 'music/hos_music_mini_player_controller.dart';
import 'music/hos_music_player_controller.dart';
import '../data/hos_music_pack_service.dart';
import '../domain/hos_download_task.dart';
import 'hos_download_controller.dart';
import 'music/hos_music_rotating_cover.dart';
import 'music/hos_music_seek_bar.dart';

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
  var _showLyrics = true;
  var _initialized = false;
  var _bootstrapping = true;
  String? _lastSyncedTrackId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(musicOnPlayerPageProvider.notifier).state = true;
      unawaited(_bootstrapPlaylist());
    });
  }

  @override
  void dispose() {
    ref.read(musicOnPlayerPageProvider.notifier).state = false;
    super.dispose();
  }

  void _syncViewModeForTrack(SHOMusicTrack? track) {
    final trackId = track?.id;
    if (trackId == null || trackId == _lastSyncedTrackId) return;
    _lastSyncedTrackId = trackId;
    final hasCover = shoMusicTrackHasCover(track);
    setState(() => _showLyrics = !hasCover);
  }

  void _showPlaybackNotice(String? messageKey, AppLocalizations l10n) {
    if (messageKey == null || !mounted) return;
    final text = switch (messageKey) {
      SHOMusicPlayerMessages.noValidTracks => l10n.musicPlayerNoValidTracks,
      _ => messageKey,
    };
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  bool _isAlreadyPlayingRequestedTrack(SHOMusicPlayerState playerState) {
    final current = playerState.currentTrack;
    if (current?.id != widget.trackId) return false;
    if (playerState.playlist.isEmpty || playerState.isLoading) return false;
    return playerState.playlist.any((track) => track.id == widget.trackId);
  }

  Future<List<SHOMusicTrack>> _playlistForDownloadPack() async {
    final items = await ref.read(musicLibraryListProvider.future);
    SHOMusicLibraryListItem? target;
    for (final item in items) {
      if (item.track.id == widget.trackId) {
        target = item;
        break;
      }
    }

    final packTaskId = target?.track.packTaskId;
    if (packTaskId != null) {
      final packTracks = items
          .where((item) => item.track.packTaskId == packTaskId)
          .map((item) => item.track)
          .toList();
      if (packTracks.isNotEmpty) return packTracks;
    }

    final packService = ref.read(musicPackServiceProvider);
    final tasks = ref.read(downloadTasksProvider);
    for (final task in tasks) {
      if (!packService.isMusicPackZip(task)) continue;
      if (task.status != SHODownloadStatus.completed) continue;

      final cachedTracks = await packService.buildCachedPackTracks(
        packTask: task,
        downloadTasks: tasks,
      );
      final index = cachedTracks.indexWhere((track) => track.id == widget.trackId);
      if (index >= 0) return cachedTracks;
    }

    return const [];
  }

  Future<void> _loadPlaylistForRoute() async {
    final playerState = ref.read(musicPlayerProvider);
    if (_isAlreadyPlayingRequestedTrack(playerState)) {
      if (mounted) {
        _syncViewModeForTrack(playerState.currentTrack);
        setState(() => _bootstrapping = false);
      }
      return;
    }

    try {
      List<SHOMusicTrack> playlist;
      if (widget.fromDownloadPack) {
        playlist = await _playlistForDownloadPack();
      } else {
        final items = await ref.read(musicLibraryListProvider.future);
        playlist = items.map((item) => item.track).toList();
      }
      if (playlist.isEmpty) return;

      var startIndex = widget.startIndex;
      final trackIndex = playlist.indexWhere((t) => t.id == widget.trackId);
      if (trackIndex >= 0) startIndex = trackIndex;

      await ref.read(musicPlayerProvider.notifier).setPlaylist(
            playlist,
            startIndex: startIndex,
            scope: SHOMusicPlaylistScope.library,
          );
      if (mounted) {
        _syncViewModeForTrack(ref.read(musicPlayerProvider).currentTrack);
      }
    } finally {
      if (mounted) setState(() => _bootstrapping = false);
    }
  }

  Future<void> _bootstrapPlaylist() async {
    if (_initialized) return;
    _initialized = true;
    await _loadPlaylistForRoute();
  }

  @override
  void didUpdateWidget(covariant SHOMusicPlayerPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.trackId != widget.trackId) {
      setState(() => _bootstrapping = true);
      unawaited(_loadPlaylistForRoute());
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

  Future<void> _handleMoreShare(AppLocalizations l10n) async {
    final track = ref.read(musicPlayerProvider).currentTrack;
    if (track == null) return;
    final share = ref.read(shareServiceProvider);
    await share.shareText('${track.title} - ${track.artist}');
    if (mounted) {
      SHOAppToast.success(l10n.sharePanelTitle);
    }
  }

  Future<void> _toggleLike(String trackId) async {
    await ref.read(musicStatsStorageProvider).toggleLike(trackId);
    ref.read(musicLibraryRevisionProvider.notifier).state++;
  }

  void _toggleLyricsCover(SHOMusicTrack? track) {
    if (!shoMusicTrackHasCover(track)) return;
    setState(() => _showLyrics = !_showLyrics);
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
    ref.listen<SHOMusicPlayerState>(musicPlayerProvider, (previous, next) {
      if (previous?.currentTrack?.id != next.currentTrack?.id) {
        _syncViewModeForTrack(next.currentTrack);
      }
      if (previous?.errorMessage != next.errorMessage &&
          next.errorMessage != null) {
        _showPlaybackNotice(next.errorMessage, l10n);
      }
    });
    final playerState = ref.watch(musicPlayerProvider);
    final track = playerState.currentTrack;
    final notifier = ref.read(musicPlayerProvider.notifier);
    final hasCover = shoMusicTrackHasCover(track);
    final showLyrics = !hasCover || _showLyrics;

    ref.watch(musicLibraryRevisionProvider);
    final isLiked = track == null
        ? false
        : ref.read(musicStatsStorageProvider).read(track.id).liked;

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
                _buildTopBar(context, l10n, track),
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => _toggleLyricsCover(track),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 280),
                      child: showLyrics
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
                ),
                _buildProgressSection(
                  playerState: playerState,
                  notifier: notifier,
                  track: track,
                  isLiked: isLiked,
                ),
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

  Widget _buildTopBar(
    BuildContext context,
    AppLocalizations l10n,
    SHOMusicTrack? track,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        SHOAppSpacing.xs,
        SHOAppSpacing.xs,
        SHOAppSpacing.xs,
        SHOAppSpacing.sm,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Colors.white,
            ),
          ),
          Expanded(
            child: track == null
                ? Text(
                    l10n.musicPlayerNowPlaying,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontWeight: FontWeight.w600,
                    ),
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SHOMusicMarqueeText(
                        text: track.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        track.artist,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.62),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
          ),
          IconButton(
            onPressed: track == null
                ? null
                : () => showSHOMusicPlayerMoreSheet(
                      context: context,
                      onDownload: () => _handleDownload(l10n),
                      onMore: () => _handleMoreShare(l10n),
                    ),
            icon: const Icon(
              Icons.ios_share_rounded,
              color: Colors.white,
            ),
            tooltip: l10n.musicPlayerShare,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection({
    required SHOMusicPlayerState playerState,
    required SHOMusicPlayerNotifier notifier,
    required SHOMusicTrack? track,
    required bool isLiked,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: SHOAppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (track != null)
            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              icon: Icon(
                isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                size: 22,
                color: isLiked
                    ? SHOAppColors.accent
                    : Colors.white.withValues(alpha: 0.72),
              ),
              onPressed: () => _toggleLike(track.id),
            ),
          SHOMusicSeekBar(
            position: playerState.position,
            duration: playerState.duration,
            formatDuration: _formatDuration,
            onSeekCommitted: notifier.seek,
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
            onPressed: () => showSHOMusicPlaylistSheet(
              context: context,
              ref: ref,
            ),
            icon: Icon(
              Icons.queue_music_rounded,
              color: Colors.white.withValues(alpha: 0.9),
            ),
            tooltip: l10n.musicPlayerLikedPlaylistTitle,
          ),
        ],
      ),
    );
  }
}
