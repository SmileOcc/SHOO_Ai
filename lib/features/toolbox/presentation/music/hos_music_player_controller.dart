import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

import '../../data/hos_music_pack_service.dart';
import '../../data/hos_music_playback_storage.dart';
import '../../data/hos_music_stats_storage.dart';
import '../../domain/hos_lrc_parser.dart';
import '../../domain/hos_music_color_utils.dart';
import '../../domain/hos_music_song_assets.dart';
import '../../domain/hos_music_track.dart';
import '../hos_download_controller.dart';
import 'hos_music_library_controller.dart';
import 'hos_music_mini_player_controller.dart';

enum SHOMusicPlayMode {
  sequence,
  loopAll,
  loopOne,
}

class SHOMusicPlayerState {
  const SHOMusicPlayerState({
    this.playlist = const [],
    this.currentIndex = 0,
    this.isPlaying = false,
    this.isLoading = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.playMode = SHOMusicPlayMode.sequence,
    this.errorMessage,
  });

  final List<SHOMusicTrack> playlist;
  final int currentIndex;
  final bool isPlaying;
  final bool isLoading;
  final Duration position;
  final Duration duration;
  final SHOMusicPlayMode playMode;
  final String? errorMessage;

  SHOMusicTrack? get currentTrack {
    if (playlist.isEmpty || currentIndex < 0 || currentIndex >= playlist.length) {
      return null;
    }
    return playlist[currentIndex];
  }

  List<SHOLrcLine> get currentLyrics {
    final track = currentTrack;
    if (track == null) return const [];
    return parseLrc(track.lrc);
  }

  int get currentLyricIndex => indexForPosition(currentLyrics, position);

  SHOMusicPlayerState copyWith({
    List<SHOMusicTrack>? playlist,
    int? currentIndex,
    bool? isPlaying,
    bool? isLoading,
    Duration? position,
    Duration? duration,
    SHOMusicPlayMode? playMode,
    String? Function()? errorMessage,
  }) {
    return SHOMusicPlayerState(
      playlist: playlist ?? this.playlist,
      currentIndex: currentIndex ?? this.currentIndex,
      isPlaying: isPlaying ?? this.isPlaying,
      isLoading: isLoading ?? this.isLoading,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      playMode: playMode ?? this.playMode,
      errorMessage:
          errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }
}

final musicPlayerProvider =
    StateNotifierProvider<SHOMusicPlayerNotifier, SHOMusicPlayerState>((ref) {
  final notifier = SHOMusicPlayerNotifier(
    ref.watch(musicPlaybackStorageProvider),
    ref.watch(musicStatsStorageProvider),
    ref.watch(musicPackServiceProvider),
    ref,
  );
  ref.onDispose(notifier.dispose);
  return notifier;
});

class SHOMusicPlayerNotifier extends StateNotifier<SHOMusicPlayerState> {
  SHOMusicPlayerNotifier(
    this._playbackStorage,
    this._statsStorage,
    this._packService,
    this._ref,
  ) : super(const SHOMusicPlayerState()) {
    _bindPlayerStreams();
  }

  final SHOMusicPlaybackStorage _playbackStorage;
  final SHOMusicStatsStorage _statsStorage;
  final SHOMusicPackService _packService;
  final Ref _ref;
  final AudioPlayer _player = AudioPlayer();
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<Duration?>? _durationSub;
  StreamSubscription<PlayerState>? _playerStateSub;
  StreamSubscription<ProcessingState>? _processingSub;
  Timer? _progressSaveTimer;
  var _loadToken = 0;
  var _statsRecordedForTrackId = '';

  void _bindPlayerStreams() {
    _positionSub = _player.positionStream.listen((position) {
      if (!mounted) return;
      state = state.copyWith(position: position);
    });
    _durationSub = _player.durationStream.listen((duration) {
      if (!mounted || duration == null) return;
      state = state.copyWith(duration: duration);
    });
    _playerStateSub = _player.playerStateStream.listen((playerState) {
      if (!mounted) return;
      state = state.copyWith(isPlaying: playerState.playing);
      if (playerState.playing) {
        unawaited(_recordPlayStats());
      }
    });
    _processingSub = _player.processingStateStream.listen((processingState) {
      if (!mounted) return;
      final loading = processingState == ProcessingState.loading ||
          processingState == ProcessingState.buffering;
      state = state.copyWith(isLoading: loading);
      if (processingState == ProcessingState.completed) {
        unawaited(_onTrackCompleted());
      }
    });
    _progressSaveTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      unawaited(_saveProgress());
    });
  }

  Future<void> setPlaylist(
    List<SHOMusicTrack> playlist, {
    required int startIndex,
    bool autoPlay = true,
  }) async {
    if (playlist.isEmpty) return;
    final index = startIndex.clamp(0, playlist.length - 1);
    final target = playlist[index];
    final sameLoaded = state.currentTrack?.id == target.id &&
        state.currentIndex == index &&
        state.playlist.length == playlist.length &&
        _player.audioSource != null &&
        !state.isLoading;

    if (sameLoaded) {
      state = state.copyWith(
        playlist: playlist,
        currentIndex: index,
        errorMessage: () => null,
      );
      _ref.read(musicMiniPlayerDismissedProvider.notifier).show();
      if (autoPlay && !state.isPlaying) {
        await _player.play();
      }
      return;
    }

    state = state.copyWith(
      playlist: playlist,
      currentIndex: index,
      errorMessage: () => null,
    );
    _ref.read(musicMiniPlayerDismissedProvider.notifier).show();
    await _loadTrackAt(index, autoPlay: autoPlay);
  }

  Future<void> stop() async {
    _loadToken++;
    await _player.stop();
    await _player.seek(Duration.zero);
    state = const SHOMusicPlayerState();
  }

  Future<void> removeTrackFromPlaylist(String trackId) async {
    final playlist =
        state.playlist.where((track) => track.id != trackId).toList();
    if (playlist.isEmpty) {
      await stop();
      _ref.read(musicMiniPlayerDismissedProvider.notifier).dismiss();
      return;
    }

    var nextIndex = state.currentIndex;
    if (state.currentTrack?.id == trackId) {
      nextIndex = nextIndex.clamp(0, playlist.length - 1);
      state = state.copyWith(playlist: playlist, currentIndex: nextIndex);
      await _loadTrackAt(nextIndex, autoPlay: true);
      return;
    }

    final removedBefore = state.playlist
        .take(state.currentIndex)
        .where((track) => track.id == trackId)
        .length;
    nextIndex = (state.currentIndex - removedBefore).clamp(0, playlist.length - 1);
    state = state.copyWith(playlist: playlist, currentIndex: nextIndex);
  }

  Future<void> playTrack(
    SHOMusicTrack track, {
    List<SHOMusicTrack>? playlist,
    int? index,
  }) async {
    final list = playlist ?? [track];
    final startIndex = index ??
        list.indexWhere((item) => item.id == track.id).clamp(0, list.length - 1);
    await setPlaylist(list, startIndex: startIndex);
  }

  Future<bool> downloadCurrentSong() async {
    final track = state.currentTrack;
    if (track == null) return false;

    if (track.isCachedLocally) return true;

    final tasks = _ref.read(downloadTasksProvider);
    final assets = await _packService.cacheSongFromPack(
      title: track.title,
      downloadTasks: tasks,
    );
    if (!assets.hasAudio) return false;

    final enriched = _applyAssets(track, assets);
    final playlist = [...state.playlist];
    playlist[state.currentIndex] = enriched;
    state = state.copyWith(playlist: playlist);
    _ref.read(musicLibraryRevisionProvider.notifier).state++;
    return true;
  }

  Future<void> togglePlayPause() async {
    if (state.isPlaying || _player.playing) {
      await _player.pause();
      state = state.copyWith(isPlaying: false);
      return;
    }

    if (_player.processingState == ProcessingState.idle ||
        _player.audioSource == null) {
      await _loadTrackAt(state.currentIndex, autoPlay: true);
      return;
    }

    await _player.play();
  }

  Future<void> seek(Duration position) async {
    await _player.seek(position);
    state = state.copyWith(position: position);
    unawaited(_saveProgress());
  }

  Future<void> playPrevious() async {
    if (state.playlist.isEmpty) return;
    final nextIndex = state.currentIndex <= 0
        ? state.playlist.length - 1
        : state.currentIndex - 1;
    state = state.copyWith(currentIndex: nextIndex);
    await _loadTrackAt(nextIndex, autoPlay: true);
  }

  Future<void> playNext() async {
    if (state.playlist.isEmpty) return;
    final nextIndex = (state.currentIndex + 1) % state.playlist.length;
    state = state.copyWith(currentIndex: nextIndex);
    await _loadTrackAt(nextIndex, autoPlay: true);
  }

  void cyclePlayMode() {
    final next = switch (state.playMode) {
      SHOMusicPlayMode.sequence => SHOMusicPlayMode.loopAll,
      SHOMusicPlayMode.loopAll => SHOMusicPlayMode.loopOne,
      SHOMusicPlayMode.loopOne => SHOMusicPlayMode.sequence,
    };
    state = state.copyWith(playMode: next);
    _player.setLoopMode(
      next == SHOMusicPlayMode.loopOne ? LoopMode.one : LoopMode.off,
    );
  }

  Future<void> _loadTrackAt(int index, {required bool autoPlay}) async {
    final token = ++_loadToken;
    var track = state.playlist[index];
    _statsRecordedForTrackId = '';
    state = state.copyWith(
      currentIndex: index,
      isLoading: true,
      position: Duration.zero,
      duration: Duration.zero,
      errorMessage: () => null,
    );

    try {
      track = await _resolveTrackResources(track);
      if (token != _loadToken) return;

      final playlist = [...state.playlist];
      playlist[index] = track;
      state = state.copyWith(playlist: playlist);

      final source = await _resolveAudioSource(track);
      if (token != _loadToken) return;

      await _player.setAudioSource(source);
      if (token != _loadToken) return;

      final resume = _playbackStorage.readPosition(track.id);
      if (resume != null && resume > Duration.zero) {
        await _player.seek(resume);
      }

      if (autoPlay) {
        await _player.play();
      }

      if (token != _loadToken) return;
      state = state.copyWith(isLoading: false);
    } catch (e) {
      if (token != _loadToken) return;
      state = state.copyWith(
        isLoading: false,
        errorMessage: () => e.toString(),
      );
    }
  }

  Future<SHOMusicTrack> _resolveTrackResources(SHOMusicTrack track) async {
    final tasks = _ref.read(downloadTasksProvider);
    final allowedPackIds = track.packTaskId == null
        ? null
        : {track.packTaskId!};
    final assets = await _packService.resolveSongAssets(
      title: track.title,
      downloadTasks: tasks,
      allowedPackTaskIds: allowedPackIds,
    );

    if (assets.hasAudio) {
      return _applyAssets(track, assets);
    }

    if (track.isCachedLocally && track.localPath != null) {
      final cached = await _packService.readCachedAssets(track.title);
      if (cached.hasCover || cached.hasBg || cached.hasLyrics) {
        return _applyAssets(track, cached.copyWith(audioPath: track.localPath));
      }
      return track;
    }

    return track.copyWith(
      coverColor: track.coverColor ??
          SHOMusicColorUtils.colorForKey(track.resolvedSongKey, salt: 11),
      bgColor: track.bgColor ??
          SHOMusicColorUtils.colorForKey(track.resolvedSongKey, salt: 29),
    );
  }

  SHOMusicTrack _applyAssets(SHOMusicTrack track, SHOMusicSongAssets assets) {
    return track.copyWith(
      source: SHOMusicSource.cached,
      localPath: assets.audioPath,
      coverPath: assets.coverPath,
      bgPath: assets.bgPath,
      lrc: assets.lyricsText ?? track.lrc,
      packTaskId: assets.packTaskId,
      isCachedLocally: true,
      coverColor: track.coverColor ??
          SHOMusicColorUtils.colorForKey(track.resolvedSongKey, salt: 11),
      bgColor: track.bgColor ??
          SHOMusicColorUtils.colorForKey(track.resolvedSongKey, salt: 29),
    );
  }

  Future<AudioSource> _resolveAudioSource(SHOMusicTrack track) async {
    if (track.isCachedLocally || track.source == SHOMusicSource.cached) {
      final path = await resolveMusicLocalPath(track);
      if (path != null && File(path).existsSync()) {
        return AudioSource.file(path);
      }
    }

    return switch (track.source) {
      SHOMusicSource.network => AudioSource.uri(Uri.parse(track.audioUrl!)),
      SHOMusicSource.asset => AudioSource.asset(track.assetPath!),
      SHOMusicSource.local => AudioSource.file(
          await _resolveLocalPath(track),
        ),
      SHOMusicSource.cached => AudioSource.file(
          await _resolveLocalPath(track),
        ),
    };
  }

  Future<String> _resolveLocalPath(SHOMusicTrack track) async {
    final path = await resolveMusicLocalPath(track);
    if (path == null || !File(path).existsSync()) {
      throw StateError('Local audio file not found');
    }
    return path;
  }

  Future<void> _recordPlayStats() async {
    final track = state.currentTrack;
    if (track == null || _statsRecordedForTrackId == track.id) return;
    _statsRecordedForTrackId = track.id;
    await _statsStorage.recordPlay(track.id);
  }

  Future<void> _onTrackCompleted() async {
    switch (state.playMode) {
      case SHOMusicPlayMode.loopOne:
        await _player.seek(Duration.zero);
        await _player.play();
      case SHOMusicPlayMode.loopAll:
        await playNext();
      case SHOMusicPlayMode.sequence:
        if (state.currentIndex < state.playlist.length - 1) {
          await playNext();
        } else {
          await stop();
          _ref.read(musicMiniPlayerDismissedProvider.notifier).dismiss();
        }
    }
  }

  Future<void> _saveProgress() async {
    final track = state.currentTrack;
    if (track == null) return;
    if (state.position <= Duration.zero) return;
    await _playbackStorage.writePosition(track.id, state.position);
  }

  @override
  void dispose() {
    _loadToken++;
    unawaited(_saveProgress());
    _positionSub?.cancel();
    _durationSub?.cancel();
    _playerStateSub?.cancel();
    _processingSub?.cancel();
    _progressSaveTimer?.cancel();
    unawaited(_player.dispose());
    super.dispose();
  }
}
