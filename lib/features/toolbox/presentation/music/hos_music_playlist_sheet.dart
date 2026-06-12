import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/hos_colors.dart';
import '../../../../core/theme/hos_spacing.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/hos_music_track.dart';
import 'hos_music_library_controller.dart';
import 'hos_music_player_controller.dart';

const _dismissDragThreshold = 70.0;
const _topRadius = 20.0;
const _itemExtent = 58.0;

Future<void> showSHOMusicPlaylistSheet({
  required BuildContext context,
  required WidgetRef ref,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    isDismissible: true,
    enableDrag: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.45),
    builder: (sheetContext) => _SHOMusicPlaylistSheet(ref: ref),
  );
}

class _SHOMusicPlaylistSheet extends ConsumerStatefulWidget {
  const _SHOMusicPlaylistSheet({required this.ref});

  final WidgetRef ref;

  @override
  ConsumerState<_SHOMusicPlaylistSheet> createState() =>
      _SHOMusicPlaylistSheetState();
}

class _SHOMusicPlaylistSheetState extends ConsumerState<_SHOMusicPlaylistSheet> {
  late double _height;
  var _downwardDrag = 0.0;
  var _dragging = false;
  var _heightInitialized = false;
  final _scrollController = ScrollController();
  String? _lastScrolledTrackId;
  var _didRequestInitialScroll = false;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_heightInitialized) return;
    _height = MediaQuery.sizeOf(context).height * 0.45;
    _heightInitialized = true;
  }

  void _onVerticalDragStart(DragStartDetails details) {
    _downwardDrag = 0;
    _dragging = true;
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    final screenH = MediaQuery.sizeOf(context).height;
    final maxH = screenH * 0.7;
    const minH = 220.0;

    setState(() {
      if (details.delta.dy > 0) {
        _downwardDrag += details.delta.dy;
      } else {
        _downwardDrag = 0;
      }
      _height = (_height - details.delta.dy).clamp(minH, maxH);
    });
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    _dragging = false;
    if (_downwardDrag >= _dismissDragThreshold) {
      Navigator.of(context).pop();
      return;
    }
    _downwardDrag = 0;
  }

  void _scrollToCurrentTrack(List<SHOMusicTrack> likedTracks, String? trackId) {
    if (trackId == null || trackId == _lastScrolledTrackId) return;
    final index = likedTracks.indexWhere((track) => track.id == trackId);
    if (index < 0) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      final offset = (index * _itemExtent).clamp(
        0.0,
        _scrollController.position.maxScrollExtent,
      );
      _scrollController.animateTo(
        offset,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
      );
      _lastScrolledTrackId = trackId;
    });
  }

  Future<void> _playAt(int index, List<SHOMusicTrack> likedTracks) async {
    if (index < 0 || index >= likedTracks.length) return;
    await ref.read(musicPlayerProvider.notifier).setPlaylist(
          likedTracks,
          startIndex: index,
          scope: SHOMusicPlaylistScope.likedDirectory,
        );
  }

  List<SHOMusicTrack> _likedTracksFrom(
    List<SHOMusicLibraryListItem> items,
  ) {
    return items
        .where((item) => item.stats.liked)
        .map((item) => item.track)
        .toList();
  }

  void _syncScrollToCurrent(List<SHOMusicLibraryListItem> items) {
    final likedTracks = _likedTracksFrom(items);
    final trackId = ref.read(musicPlayerProvider).currentTrack?.id;
    _scrollToCurrentTrack(likedTracks, trackId);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final playerState = ref.watch(musicPlayerProvider);
    final currentTrackId = playerState.currentTrack?.id;
    final listAsync = ref.watch(musicLibraryListProvider);
    final screenH = MediaQuery.sizeOf(context).height;
    final maxH = screenH * 0.7;

    ref.listen<AsyncValue<List<SHOMusicLibraryListItem>>>(
      musicLibraryListProvider,
      (_, next) => next.whenData(_syncScrollToCurrent),
    );
    ref.listen<SHOMusicPlayerState>(
      musicPlayerProvider,
      (_, __) {
        listAsync.whenData(_syncScrollToCurrent);
      },
    );

    return SizedBox(
      height: screenH,
      width: double.infinity,
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Navigator.of(context).pop(),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: GestureDetector(
              onTap: () {},
              child: AnimatedContainer(
                duration: _dragging
                    ? Duration.zero
                    : const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                height: _height.clamp(220.0, maxH),
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFF1E1E2A),
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(_topRadius),
                  ),
                ),
                child: Column(
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onVerticalDragStart: _onVerticalDragStart,
              onVerticalDragUpdate: _onVerticalDragUpdate,
              onVerticalDragEnd: _onVerticalDragEnd,
              child: Column(
                children: [
                  const SizedBox(height: SHOAppSpacing.sm),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.28),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      SHOAppSpacing.lg,
                      SHOAppSpacing.md,
                      SHOAppSpacing.lg,
                      SHOAppSpacing.sm,
                    ),
                    child: listAsync.maybeWhen(
                      data: (items) {
                        final likedCount =
                            items.where((item) => item.stats.liked).length;
                        return Row(
                          children: [
                            Text(
                              l10n.musicPlayerLikedPlaylistTitle,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              l10n.musicPlayerPlaylistCount(
                                likedCount.toString(),
                              ),
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.55),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        );
                      },
                      orElse: () => Text(
                        l10n.musicPlayerLikedPlaylistTitle,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: listAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                error: (error, _) => Center(
                  child: Text(
                    error.toString(),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                  ),
                ),
                data: (items) {
                  final likedTracks = _likedTracksFrom(items);

                  if (!_didRequestInitialScroll) {
                    _didRequestInitialScroll = true;
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) _syncScrollToCurrent(items);
                    });
                  }

                  if (likedTracks.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(SHOAppSpacing.lg),
                        child: Text(
                          l10n.musicPlayerLikedPlaylistEmpty,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            height: 1.4,
                          ),
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    controller: _scrollController,
                    padding: const EdgeInsets.only(
                      left: SHOAppSpacing.md,
                      right: SHOAppSpacing.md,
                      bottom: SHOAppSpacing.lg,
                    ),
                    itemCount: likedTracks.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 4),
                    itemBuilder: (context, index) {
                      final track = likedTracks[index];
                      final isSelected = track.id == currentTrackId;
                      final isPlaying = isSelected && playerState.isPlaying;

                      return _PlaylistTile(
                        track: track,
                        index: index + 1,
                        isSelected: isSelected,
                        isPlaying: isPlaying,
                        onTap: () => _playAt(index, likedTracks),
                      );
                    },
                  );
                },
              ),
            ),
                ],
              ),
            ),
          ),
        ),
        ],
      ),
    );
  }
}

class _PlaylistTile extends StatelessWidget {
  const _PlaylistTile({
    required this.track,
    required this.index,
    required this.isSelected,
    required this.isPlaying,
    required this.onTap,
  });

  final SHOMusicTrack track;
  final int index;
  final bool isSelected;
  final bool isPlaying;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(
            horizontal: SHOAppSpacing.sm,
            vertical: SHOAppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? SHOAppColors.accent.withValues(alpha: 0.16)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: isSelected
                ? Border.all(
                    color: SHOAppColors.accent.withValues(alpha: 0.45),
                    width: 1,
                  )
                : null,
          ),
          child: Row(
            children: [
              SizedBox(
                width: 28,
                child: isSelected
                    ? Icon(
                        isPlaying
                            ? Icons.graphic_eq_rounded
                            : Icons.music_note_rounded,
                        size: 20,
                        color: SHOAppColors.accent,
                      )
                    : Text(
                        '$index',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.45),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
              const SizedBox(width: SHOAppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      track.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isSelected ? SHOAppColors.accent : Colors.white,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      track.artist,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isSelected
                            ? SHOAppColors.accent.withValues(alpha: 0.72)
                            : Colors.white.withValues(alpha: 0.5),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: isSelected
                    ? Icon(
                        Icons.check_circle_rounded,
                        key: const ValueKey('selected'),
                        size: 22,
                        color: SHOAppColors.accent,
                      )
                    : Icon(
                        Icons.radio_button_unchecked_rounded,
                        key: const ValueKey('unselected'),
                        size: 22,
                        color: Colors.white.withValues(alpha: 0.22),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
