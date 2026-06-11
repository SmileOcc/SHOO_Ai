import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/router/hos_routes.dart';
import '../../../core/dialogs/hos_confirm_card_dialog.dart';
import '../../../core/theme/hos_colors.dart';
import '../../../core/theme/hos_spacing.dart';
import '../../../core/theme/hos_theme_extension.dart';
import '../../../core/widgets/hos_empty_state.dart';
import '../../../core/widgets/hos_profile_section_card.dart';
import '../../../l10n/app_localizations.dart';
import '../data/hos_music_stats_storage.dart';
import 'music/hos_music_library_controller.dart';
import 'music/hos_music_player_controller.dart';

class SHOMusicLibraryPage extends ConsumerWidget {
  const SHOMusicLibraryPage({super.key, this.fromDownload = false});

  final bool fromDownload;

  String _formatDuration(Duration? duration) {
    if (duration == null || duration <= Duration.zero) return '';
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  String _formatPlayDate(DateTime? date) {
    if (date == null) return '';
    return DateFormat('yyyy-MM-dd HH:mm').format(date);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final sort = ref.watch(musicLibrarySortProvider);
    final listAsync = ref.watch(musicLibraryListProvider);
    final playerState = ref.watch(musicPlayerProvider);
    final currentTrackId = playerState.currentTrack?.id;
    final playingTrackId =
        playerState.isPlaying ? currentTrackId : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.musicLibraryTitle,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              SHOAppSpacing.pagePadding,
              SHOAppSpacing.xs,
              SHOAppSpacing.pagePadding,
              SHOAppSpacing.xs,
            ),
            child: Row(
              children: [
                _SortChip(
                  label: l10n.musicLibrarySortRecent,
                  selected: sort == SHOMusicLibrarySort.recent,
                  onTap: () => ref
                      .read(musicLibrarySortProvider.notifier)
                      .state = SHOMusicLibrarySort.recent,
                ),
                const SizedBox(width: SHOAppSpacing.xs),
                _SortChip(
                  label: l10n.musicLibrarySortLiked,
                  selected: sort == SHOMusicLibrarySort.liked,
                  onTap: () => ref
                      .read(musicLibrarySortProvider.notifier)
                      .state = SHOMusicLibrarySort.liked,
                ),
              ],
            ),
          ),
          Expanded(
            child: listAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => SHOEmptyState(title: error.toString()),
              data: (items) {
                if (items.isEmpty) {
                  return SHOEmptyState(title: l10n.musicLibraryEmpty);
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(SHOAppSpacing.pagePadding),
                  itemCount: items.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: SHOAppSpacing.sm),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final track = item.track;
                    final resume = _formatDuration(item.lastPosition);
                    final playDate = _formatPlayDate(item.stats.lastPlayedAt);

                    final isPlayingNow = playingTrackId == track.id;
                    final isCurrentTrack = currentTrackId == track.id;
                    final showPauseIcon =
                        isCurrentTrack && playerState.isPlaying;

                    final tile = SHOProfileSectionCard(
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: SHOAppSpacing.md,
                          vertical: SHOAppSpacing.xs,
                        ),
                        leading: CircleAvatar(
                          backgroundColor:
                              Color(track.coverColor ?? 0xFF5C6BC0)
                                  .withValues(alpha: 0.18),
                          child: isPlayingNow
                              ? Icon(
                                  Icons.graphic_eq_rounded,
                                  color: Color(track.coverColor ?? 0xFF5C6BC0),
                                )
                              : Icon(
                                  Icons.music_note_rounded,
                                  color: Color(track.coverColor ?? 0xFF5C6BC0),
                                ),
                        ),
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                track.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: isPlayingNow
                                      ? SHOAppColors.accent
                                      : null,
                                ),
                              ),
                            ),
                            if (isPlayingNow) ...[
                              const SizedBox(width: SHOAppSpacing.xs),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: SHOAppColors.accent
                                      .withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  l10n.musicLibraryNowPlayingBadge,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: SHOAppColors.accent,
                                  ),
                                ),
                              ),
                            ],
                            const SizedBox(width: SHOAppSpacing.xs),
                            _SourceBadge(
                              label: item.isOnline
                                  ? l10n.musicLibraryOnlineBadge
                                  : l10n.musicLibraryLocalBadge,
                              isOnline: item.isOnline,
                            ),
                          ],
                        ),
                        subtitle: Text(
                          [
                            track.artist,
                            if (playDate.isNotEmpty)
                              l10n.musicLibraryLastPlayedDate(playDate),
                            if (item.stats.liked) l10n.musicLibraryLikedBadge,
                            l10n.musicLibraryPlayCount(
                              item.stats.playCount.toString(),
                            ),
                            if (resume.isNotEmpty)
                              l10n.musicLibraryLastPlayed(resume),
                          ].join(' · '),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: context.shoTheme.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                item.stats.liked
                                    ? Icons.favorite_rounded
                                    : Icons.favorite_border_rounded,
                                size: 20,
                                color: item.stats.liked
                                    ? SHOAppColors.accent
                                    : context.shoTheme.textMuted,
                              ),
                              onPressed: () async {
                                await ref
                                    .read(musicStatsStorageProvider)
                                    .toggleLike(track.id);
                                ref
                                    .read(musicLibraryRevisionProvider.notifier)
                                    .state++;
                              },
                            ),
                            IconButton(
                              icon: Icon(
                                showPauseIcon
                                    ? Icons.pause_rounded
                                    : Icons.play_arrow_rounded,
                              ),
                              onPressed: () async {
                                if (isCurrentTrack) {
                                  await ref
                                      .read(musicPlayerProvider.notifier)
                                      .togglePlayPause();
                                  return;
                                }
                                final playlist =
                                    items.map((e) => e.track).toList();
                                await ref
                                    .read(musicPlayerProvider.notifier)
                                    .setPlaylist(
                                      playlist,
                                      startIndex: index,
                                    );
                              },
                            ),
                          ],
                        ),
                        onTap: () {
                          context.push(
                            SHOAppRoutes.toolboxMusicPlayerFor(
                              track.id,
                              index: index,
                            ),
                          );
                        },
                      ),
                    );

                    return Dismissible(
                      key: ValueKey('music_${track.id}'),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: SHOAppSpacing.lg),
                        decoration: BoxDecoration(
                          color: SHOAppColors.error.withValues(alpha: 0.85),
                          borderRadius:
                              BorderRadius.circular(SHOAppSpacing.cardRadius),
                        ),
                        child: Text(
                          l10n.musicLibraryRemoveAction,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      confirmDismiss: (_) async {
                        final ok = await SHOConfirmCardDialog.show(
                          context,
                          title: l10n.musicLibraryRemoveConfirmTitle,
                          message: l10n.musicLibraryRemoveConfirmMessage,
                          confirmLabel: l10n.musicLibraryRemoveAction,
                          isDestructive: true,
                        );
                        if (ok) {
                          await removeTrackFromLibrary(ref, item: item);
                          await ref
                              .read(musicPlayerProvider.notifier)
                              .removeTrackFromPlaylist(track.id);
                        }
                        return ok;
                      },
                      child: tile,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SortChip extends StatelessWidget {
  const _SortChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = context.shoTheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: selected
              ? theme.textMuted.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: theme.border.withValues(alpha: selected ? 0.5 : 0.35),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color: selected ? theme.textSecondary : theme.textMuted,
          ),
        ),
      ),
    );
  }
}

class _SourceBadge extends StatelessWidget {
  const _SourceBadge({
    required this.label,
    required this.isOnline,
  });

  final String label;
  final bool isOnline;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: (isOnline ? const Color(0xFF5C6BC0) : const Color(0xFF00B578))
            .withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: isOnline ? const Color(0xFF5C6BC0) : const Color(0xFF00B578),
        ),
      ),
    );
  }
}
