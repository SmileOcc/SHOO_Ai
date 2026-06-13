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

enum SHOMusicPlaylistScope {
  library,
  likedDirectory,
}

/// UI maps this key to localized [musicPlayerNoValidTracks].
abstract final class SHOMusicPlayerMessages {
  static const noValidTracks = '__music_no_valid_tracks__';
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
    this.playlistScope = SHOMusicPlaylistScope.library,
    this.errorMessage,
  });

  final List<SHOMusicTrack> playlist;
  final int currentIndex;
  final bool isPlaying;
  final bool isLoading;
  final Duration position;
  final Duration duration;
  final SHOMusicPlayMode playMode;
  final SHOMusicPlaylistScope playlistScope;
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
    SHOMusicPlaylistScope? playlistScope,
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
      playlistScope: playlistScope ?? this.playlistScope,
      errorMessage:
          errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }
}

final musicPlayerProvider =
    NotifierProvider<SHOMusicPlayerNotifier, SHOMusicPlayerState>(
  SHOMusicPlayerNotifier.new,
);

class SHOMusicPlayerNotifier extends Notifier<SHOMusicPlayerState> {
  late final SHOMusicPlaybackStorage _playbackStorage;
  late final SHOMusicStatsStorage _statsStorage;
  late final SHOMusicPackService _packService;
  final AudioPlayer _player = AudioPlayer();
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<Duration?>? _durationSub;
  StreamSubscription<PlayerState>? _playerStateSub;
  StreamSubscription<ProcessingState>? _processingSub;
  Timer? _progressSaveTimer;
  var _loadToken = 0;
  var _statsRecordedForTrackId = '';
  var _handlingCompletion = false;
  var _disposed = false;

  static const _resumeTail = Duration(seconds: 5);

  @override
  SHOMusicPlayerState build() {
    _playbackStorage = ref.read(musicPlaybackStorageProvider);
    _statsStorage = ref.read(musicStatsStorageProvider);
    _packService = ref.read(musicPackServiceProvider);
    ref.onDispose(_dispose);
    _bindPlayerStreams();
    return const SHOMusicPlayerState();
  }

  void _bindPlayerStreams() {
    _positionSub = _player.positionStream.listen((position) {
      if (_disposed) return;
      state = state.copyWith(position: position);
    });
    _durationSub = _player.durationStream.listen((duration) {
      if (_disposed || duration == null) return;
      state = state.copyWith(duration: duration);
    });
    _playerStateSub = _player.playerStateStream.listen((playerState) {
      if (_disposed) return;
      state = state.copyWith(isPlaying: playerState.playing);
      if (playerState.playing) {
        unawaited(_recordPlayStats());
      }
    });
    _processingSub = _player.processingStateStream.listen((processingState) {
      if (_disposed) return;
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
    SHOMusicPlaylistScope scope = SHOMusicPlaylistScope.library,
  }) async {
    if (playlist.isEmpty) return;

    var index = startIndex.clamp(0, playlist.length - 1);
    final target = playlist[index];
    final sameLoaded = state.currentTrack?.id == target.id &&
        state.currentIndex == index &&
        state.playlist.length == playlist.length &&
        state.playlistScope == scope &&
        _player.audioSource != null &&
        !state.isLoading;

    if (sameLoaded) {
      state = state.copyWith(
        playlist: playlist,
        currentIndex: index,
        playlistScope: scope,
        errorMessage: () => null,
      );
      ref.read(musicMiniPlayerDismissedProvider.notifier).show();
      if (autoPlay && !state.isPlaying) {
        await _player.play();
      }
      return;
    }

    if (!await _isTrackPlayable(target)) {
      final fallback = await _findNextValidFrom(index, wrap: true);
      if (fallback == null) {
        await _pauseWithNoValidTracks(keepPlaylist: playlist);
        return;
      }
      index = fallback;
    }

    state = state.copyWith(
      playlist: playlist,
      currentIndex: index,
      playlistScope: scope,
      errorMessage: () => null,
    );
    ref.read(musicMiniPlayerDismissedProvider.notifier).show();
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
      ref.read(musicMiniPlayerDismissedProvider.notifier).dismiss();
      return;
    }

    var nextIndex = state.currentIndex;
    if (state.currentTrack?.id == trackId) {
      nextIndex = nextIndex.clamp(0, playlist.length - 1);
      state = state.copyWith(playlist: playlist, currentIndex: nextIndex);
      final valid = await _findNextValidFrom(nextIndex, wrap: true);
      if (valid == null) {
        await _pauseWithNoValidTracks(keepPlaylist: playlist);
        return;
      }
      await _loadTrackAt(valid, autoPlay: true);
      return;
    }

    final removedBefore = state.playlist
        .take(state.currentIndex)
        .where((track) => track.id == trackId)
        .length;
    nextIndex =
        (state.currentIndex - removedBefore).clamp(0, playlist.length - 1);
    state = state.copyWith(playlist: playlist, currentIndex: nextIndex);
  }

  Future<void> playTrack(
    SHOMusicTrack track, {
    List<SHOMusicTrack>? playlist,
    int? index,
  }) async {
    final list = playlist ?? [track];
    final rawIndex = index ?? list.indexWhere((item) => item.id == track.id);
    final startIndex =
        rawIndex >= 0 ? rawIndex.clamp(0, list.length - 1) : 0;
    await setPlaylist(list, startIndex: startIndex);
  }

  Future<bool> downloadCurrentSong() async {
    final track = state.currentTrack;
    if (track == null) return false;

    if (track.isCachedLocally) return true;

    final tasks = ref.read(downloadTasksProvider);
    final assets = await _packService.cacheSongFromPack(
      title: track.title,
      downloadTasks: tasks,
    );
    if (!assets.hasAudio) return false;

    final enriched = _applyAssets(track, assets);
    final playlist = [...state.playlist];
    playlist[state.currentIndex] = enriched;
    state = state.copyWith(playlist: playlist);
    ref.read(musicLibraryRevisionProvider.notifier).state++;
    return true;
  }

  Future<void> togglePlayPause() async {
    if (state.currentTrack == null) return;

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
    final previous = await _findNextValidBefore(
      state.currentIndex,
      wrap: state.playMode == SHOMusicPlayMode.loopAll,
    );
    if (previous == null) {
      await _pauseWithNoValidTracks();
      return;
    }
    await _advanceToIndex(previous);
  }

  Future<void> playNext() async {
    if (state.playlist.isEmpty) return;
    final next = await _findNextValidAfter(
      state.currentIndex,
      wrap: state.playMode == SHOMusicPlayMode.loopAll,
    );
    if (next == null) {
      if (state.playMode == SHOMusicPlayMode.sequence) {
        await _pausePlaybackEnded();
      } else {
        await _pauseWithNoValidTracks();
      }
      return;
    }
    await _advanceToIndex(next);
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

  Future<void> _advanceToIndex(int index) async {
    state = state.copyWith(currentIndex: index, errorMessage: () => null);
    await _loadTrackAt(index, autoPlay: true);
  }

  Future<void> _loadTrackAt(
    int index, {
    required bool autoPlay,
    Set<int>? tried,
  }) async {
    if (state.playlist.isEmpty || index < 0 || index >= state.playlist.length) {
      await _pauseWithNoValidTracks();
      return;
    }

    tried ??= <int>{};
    if (tried.contains(index) || tried.length >= state.playlist.length) {
      await _pauseWithNoValidTracks();
      return;
    }
    tried.add(index);

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

      if (!await _isTrackPlayable(track)) {
        final next = await _findNextValidAfter(index, wrap: true);
        if (next != null && !tried.contains(next)) {
          await _loadTrackAt(next, autoPlay: autoPlay, tried: tried);
        } else {
          await _pauseWithNoValidTracks();
        }
        return;
      }

      final playlist = [...state.playlist];
      playlist[index] = track;
      state = state.copyWith(playlist: playlist);

      final source = await _resolveAudioSource(track);
      if (token != _loadToken) return;

      await _player.setAudioSource(source);
      if (token != _loadToken) return;

      await _applyResumePosition(track.id, token);
      if (token != _loadToken) return;

      if (autoPlay) {
        await _player.play();
      }

      if (token != _loadToken) return;
      state = state.copyWith(isLoading: false);
    } catch (_) {
      if (token != _loadToken) return;
      final next = await _findNextValidAfter(index, wrap: true);
      if (next != null && !tried.contains(next)) {
        await _loadTrackAt(next, autoPlay: autoPlay, tried: tried);
        return;
      }
      await _pauseWithNoValidTracks();
    }
  }

  Future<void> _applyResumePosition(String trackId, int token) async {
    final resume = _playbackStorage.readPosition(trackId);
    if (resume == null || resume <= Duration.zero) return;

    var duration = _player.duration ?? Duration.zero;
    if (duration <= Duration.zero) {
      await Future<void>.delayed(const Duration(milliseconds: 120));
      if (token != _loadToken) return;
      duration = _player.duration ?? Duration.zero;
    }

    if (duration > Duration.zero && resume >= duration - _resumeTail) {
      await _playbackStorage.writePosition(trackId, Duration.zero);
      await _player.seek(Duration.zero);
      return;
    }

    if (resume > Duration.zero) {
      await _player.seek(resume);
    }
  }

  Future<bool> _isTrackPlayable(SHOMusicTrack track) async {
    if (track.title.trim().isEmpty) return false;

    try {
      final resolved = await _resolveTrackResources(track);
      if (_hasPlayableSource(resolved)) return true;

      if (resolved.source == SHOMusicSource.cached ||
          resolved.source == SHOMusicSource.local ||
          resolved.isCachedLocally) {
        final path = await resolveMusicLocalPath(resolved);
        return path != null && File(path).existsSync() && File(path).lengthSync() > 0;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  bool _hasPlayableSource(SHOMusicTrack track) {
    switch (track.source) {
      case SHOMusicSource.network:
        final url = track.audioUrl;
        if (url == null || url.trim().isEmpty) return false;
        final uri = Uri.tryParse(url);
        return uri != null && uri.hasScheme;
      case SHOMusicSource.asset:
        return track.assetPath != null && track.assetPath!.trim().isNotEmpty;
      case SHOMusicSource.local:
      case SHOMusicSource.cached:
        final path = track.localPath;
        if (path == null || path.trim().isEmpty) return false;
        final file = File(path);
        return file.existsSync() && file.lengthSync() > 0;
    }
  }

  Future<int?> _findNextValidAfter(int fromIndex, {required bool wrap}) async {
    final playlist = state.playlist;
    final n = playlist.length;
    if (n == 0) return null;

    for (var i = fromIndex + 1; i < n; i++) {
      if (await _isTrackPlayable(playlist[i])) return i;
    }
    if (!wrap) return null;

    for (var i = 0; i <= fromIndex; i++) {
      if (await _isTrackPlayable(playlist[i])) return i;
    }
    return null;
  }

  Future<int?> _findNextValidFrom(int start, {required bool wrap}) async {
    final playlist = state.playlist;
    final n = playlist.length;
    if (n == 0) return null;

    for (var i = start; i < n; i++) {
      if (await _isTrackPlayable(playlist[i])) return i;
    }
    if (!wrap) return null;

    for (var i = 0; i < start; i++) {
      if (await _isTrackPlayable(playlist[i])) return i;
    }
    return null;
  }

  Future<int?> _findNextValidBefore(int fromIndex, {required bool wrap}) async {
    final playlist = state.playlist;
    final n = playlist.length;
    if (n == 0) return null;

    for (var i = fromIndex - 1; i >= 0; i--) {
      if (await _isTrackPlayable(playlist[i])) return i;
    }
    if (!wrap) return null;

    for (var i = n - 1; i >= fromIndex; i--) {
      if (await _isTrackPlayable(playlist[i])) return i;
    }
    return null;
  }

  Future<SHOMusicTrack> _resolveTrackResources(SHOMusicTrack track) async {
    final tasks = ref.read(downloadTasksProvider);
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

  bool _isNearPlaybackEnd() {
    final duration = state.duration;
    if (duration <= Duration.zero) return true;
    return state.position >= duration - const Duration(milliseconds: 800);
  }

  int? _nextPlaylistIndex({required bool wrap}) {
    final n = state.playlist.length;
    if (n == 0) return null;
    final current = state.currentIndex;
    if (current + 1 < n) return current + 1;
    if (wrap) return 0;
    return null;
  }

  Future<void> _onTrackCompleted() async {
    if (_handlingCompletion || state.playlist.isEmpty) return;
    if (!_isNearPlaybackEnd()) return;

    _handlingCompletion = true;
    try {
      final completedTrack = state.currentTrack;
      if (completedTrack != null) {
        await _playbackStorage.writePosition(completedTrack.id, Duration.zero);
      }

      _loadToken++;

      switch (state.playMode) {
        case SHOMusicPlayMode.loopOne:
          if (state.currentTrack != null &&
              await _isTrackPlayable(state.currentTrack!)) {
            await _player.seek(Duration.zero);
            await _player.play();
          } else {
            await _pauseWithNoValidTracks();
          }
        case SHOMusicPlayMode.loopAll:
          final next = _nextPlaylistIndex(wrap: true);
          if (next == null) {
            await _pauseWithNoValidTracks();
          } else {
            await _advanceToIndex(next);
          }
        case SHOMusicPlayMode.sequence:
          final next = _nextPlaylistIndex(wrap: false);
          if (next == null) {
            await _pausePlaybackEnded();
          } else {
            await _advanceToIndex(next);
          }
      }
    } finally {
      _handlingCompletion = false;
    }
  }

  Future<void> _pausePlaybackEnded() async {
    _loadToken++;
    await _player.stop();
    state = state.copyWith(
      isPlaying: false,
      isLoading: false,
      position: Duration.zero,
      duration: Duration.zero,
      errorMessage: () => null,
    );
    ref.read(musicMiniPlayerDismissedProvider.notifier).dismiss();
  }

  Future<void> _pauseWithNoValidTracks({
    List<SHOMusicTrack>? keepPlaylist,
  }) async {
    _loadToken++;
    await _player.stop();
    final playlist = keepPlaylist ?? state.playlist;
    state = SHOMusicPlayerState(
      playlist: playlist,
      currentIndex: playlist.isEmpty
          ? 0
          : state.currentIndex.clamp(0, playlist.length - 1),
      playMode: state.playMode,
      playlistScope: state.playlistScope,
      errorMessage: SHOMusicPlayerMessages.noValidTracks,
    );
    ref.read(musicMiniPlayerDismissedProvider.notifier).dismiss();
  }

  Future<void> _saveProgress() async {
    final track = state.currentTrack;
    if (track == null) return;
    if (state.position <= Duration.zero) return;
    final duration = state.duration;
    if (duration > Duration.zero &&
        state.position >= duration - const Duration(seconds: 2)) {
      return;
    }
    await _playbackStorage.writePosition(track.id, state.position);
  }

  void _dispose() {
    if (_disposed) return;
    _disposed = true;
    _loadToken++;
    unawaited(_saveProgress());
    _positionSub?.cancel();
    _durationSub?.cancel();
    _playerStateSub?.cancel();
    _processingSub?.cancel();
    _progressSaveTimer?.cancel();
    unawaited(_player.dispose());
  }
}
