import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/hos_routes.dart';
import '../../../core/dialogs/hos_confirm_card_dialog.dart';
import '../../../core/theme/hos_colors.dart';
import '../../../core/theme/hos_spacing.dart';
import '../../../core/theme/hos_theme_extension.dart';
import '../../../core/utils/hos_file_size_formatter.dart';
import '../../../core/widgets/hos_empty_state.dart';
import '../../../core/widgets/hos_profile_section_card.dart';
import '../../../l10n/app_localizations.dart';
import '../data/hos_download_paths.dart';
import '../domain/hos_download_task.dart';
import 'hos_download_file_type_ui.dart';
import 'hos_video_player_page.dart';
import 'video/hos_video_library_controller.dart';
import 'video/hos_video_online_play_dialog.dart';
import 'video/hos_video_player_widget.dart';

class SHOVideoLibraryPage extends ConsumerWidget {
  const SHOVideoLibraryPage({super.key});

  Future<void> _openOnlinePlay(BuildContext context, WidgetRef ref) async {
    final url = await SHOVideoOnlinePlayDialog.show(context);
    if (url == null || !context.mounted) return;

    final l10n = AppLocalizations.of(context);
    final entry = await ref
        .read(videoLibraryEntriesProvider.notifier)
        .addNetwork(url);
    if (!context.mounted) return;
    if (entry == null) {
      await SHOConfirmCardDialog.show(
        context,
        title: l10n.videoLibraryInvalidUrl,
        confirmLabel: l10n.downloadPreviewOk,
      );
      return;
    }

    await SHOVideoPlayerPage.open(context: context, entry: entry);
  }

  Future<void> _openItem(
    BuildContext context,
    WidgetRef ref,
    SHOVideoLibraryListItem item,
  ) async {
    final l10n = AppLocalizations.of(context);
    final entry = item.entry;

    if (entry.isLocal) {
      final task = item.task;
      if (task == null) {
        await SHOConfirmCardDialog.show(
          context,
          title: l10n.videoLibraryFileMissing,
          confirmLabel: l10n.downloadPreviewOk,
        );
        return;
      }
      if (task.status != SHODownloadStatus.completed) {
        await SHOConfirmCardDialog.show(
          context,
          title: l10n.videoLibraryNotCompleted,
          confirmLabel: l10n.downloadPreviewOk,
        );
        return;
      }

      final path = await SHODownloadPaths.resolveExistingFilePath(task);
      if (!context.mounted) return;
      if (path == null) {
        await SHOConfirmCardDialog.show(
          context,
          title: l10n.videoLibraryFileMissing,
          confirmLabel: l10n.downloadPreviewOk,
        );
        return;
      }
    }

    if (!context.mounted) return;
    await SHOVideoPlayerPage.open(context: context, entry: entry);
  }

  String _buildSubtitle(AppLocalizations l10n, SHOVideoLibraryListItem item) {
    final parts = <String>[];
    final entry = item.entry;
    final task = item.task;

    if (entry.isNetwork) {
      parts.add(l10n.videoLibraryOnlineBadge);
    }

    if (task != null) {
      if (item.isFullyCached) {
        parts.add(l10n.videoLibraryCachedComplete);
        parts.add(l10n.videoLibraryCacheSize(formatFileSize(item.cacheBytes)));
      } else {
        parts.add(switch (task.status) {
          SHODownloadStatus.completed => l10n.videoLibraryReady,
          SHODownloadStatus.downloading => l10n.downloadStatusDownloading,
          SHODownloadStatus.paused => l10n.downloadStatusPaused,
        });

        if (item.cacheTotalBytes != null && item.cacheTotalBytes! > 0) {
          parts.add(
            l10n.videoLibraryCacheProgress(
              formatFileSize(item.cacheBytes),
              formatFileSize(item.cacheTotalBytes!),
              (item.cachePercent ?? 0).toStringAsFixed(0),
            ),
          );
        } else if (item.cacheBytes > 0) {
          parts.add(l10n.videoLibraryCacheSize(formatFileSize(item.cacheBytes)));
        }
      }
    } else if (entry.isNetwork) {
      parts.add(l10n.videoLibraryOnlineReady);
    } else {
      parts.add(l10n.videoLibraryFileMissing);
    }

    final progress = item.progress;
    if (progress != null && progress.positionMs > 0) {
      parts.add(
        l10n.videoLibraryLastPlayed(
          formatVideoDuration(
            Duration(milliseconds: progress.positionMs),
          ),
        ),
      );
    }

    return parts.join(' · ');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final items = ref.watch(videoLibraryListItemsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.videoLibraryTitle,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          TextButton(
            onPressed: () => _openOnlinePlay(context, ref),
            child: Text(
              l10n.videoLibraryOnlinePlay,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
      body: items.isEmpty
          ? SHOEmptyState(
              title: l10n.videoLibraryEmpty,
              actionLabel: l10n.videoLibraryGoDownloads,
              onAction: () => context.push(SHOAppRoutes.toolboxDownloads),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(SHOAppSpacing.pagePadding),
              itemCount: items.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: SHOAppSpacing.lg),
              itemBuilder: (context, index) {
                final item = items[index];
                final entry = item.entry;
                final canPlay = entry.isNetwork ||
                    (item.task != null &&
                        item.task!.status == SHODownloadStatus.completed);

                return Dismissible(
                  key: ValueKey(entry.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: SHOAppSpacing.xl),
                    decoration: BoxDecoration(
                      color: SHOAppColors.error.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      l10n.videoLibraryRemoveAction,
                      style: const TextStyle(
                        color: SHOAppColors.error,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  confirmDismiss: (_) async {
                    final ok = await SHOConfirmCardDialog.show(
                      context,
                      title: l10n.videoLibraryRemoveConfirmTitle,
                      message: l10n.videoLibraryRemoveConfirmMessage,
                      confirmLabel: l10n.videoLibraryRemoveAction,
                      isDestructive: true,
                    );
                    if (ok) {
                      await ref
                          .read(videoLibraryEntriesProvider.notifier)
                          .remove(entry.id);
                    }
                    return ok;
                  },
                  child: SHOProfileSectionCard(
                    padding: EdgeInsets.zero,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: SHOAppSpacing.lg,
                        vertical: SHOAppSpacing.xs,
                      ),
                      leading: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: const Color(0xFF5C6BC0)
                                  .withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              entry.isNetwork
                                  ? Icons.cloud_outlined
                                  : downloadFileTypeIconFor(
                                      item.task?.fileType ??
                                          SHODownloadFileType.video,
                                    ),
                              color: const Color(0xFF5C6BC0),
                            ),
                          ),
                          if (entry.isNetwork)
                            Positioned(
                              right: -2,
                              bottom: -2,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 1,
                                ),
                                decoration: BoxDecoration(
                                  color: SHOAppColors.accent,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  l10n.videoLibraryOnlineBadge,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 8,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                          if (entry.isNetwork && item.isFullyCached)
                            Positioned(
                              left: -2,
                              top: -2,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 1,
                                ),
                                decoration: BoxDecoration(
                                  color: SHOAppColors.success,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  l10n.videoLibraryCachedComplete,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 8,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      title: Text(
                        entry.displayName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      subtitle: Text(
                        _buildSubtitle(l10n, item),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: context.shoTheme.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      trailing: canPlay
                          ? const Icon(Icons.play_circle_outline)
                          : null,
                      onTap: () => _openItem(context, ref, item),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
