import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/dialogs/hos_confirm_card_dialog.dart';
import '../../../core/theme/hos_colors.dart';
import '../../../core/theme/hos_spacing.dart';
import '../../../core/theme/hos_theme_extension.dart';
import '../../../core/utils/hos_file_size_formatter.dart';
import '../../../core/widgets/hos_profile_section_card.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/hos_download_task.dart';
import 'hos_download_file_type_ui.dart';
import 'hos_download_preview_helper.dart';
import 'hos_download_task_status.dart';

class SHODownloadTaskTile extends ConsumerWidget {
  const SHODownloadTaskTile({
    super.key,
    required this.task,
    required this.onPause,
    required this.onResume,
    required this.onDelete,
    required this.onOpen,
  });

  final SHODownloadTask task;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final Future<void> Function() onDelete;
  final VoidCallback onOpen;

  Future<void> _confirmDelete(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final ok = await SHOConfirmCardDialog.show(
      context,
      title: l10n.downloadDeleteConfirmTitle,
      message: l10n.downloadDeleteConfirmMessage,
      confirmLabel: l10n.downloadActionDelete,
      isDestructive: true,
    );
    if (ok) await onDelete();
  }

  Future<void> _copyUrl(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    await Clipboard.setData(ClipboardData(text: task.url));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.downloadUrlCopied)),
      );
    }
  }

  List<PopupMenuEntry<String>> _menuItems(
    AppLocalizations l10n,
    SHODownloadTaskStatus status,
  ) {
    final copyItem = PopupMenuItem(
      value: 'copy',
      child: Text(l10n.downloadActionCopyUrl),
    );

    final extraItems = <PopupMenuEntry<String>>[];
    if (task.status == SHODownloadStatus.completed) {
      if (status.isTxtNovel && !status.inBookshelf) {
        extraItems.add(
          PopupMenuItem(
            value: 'add_bookshelf',
            child: Text(l10n.downloadActionAddBookshelf),
          ),
        );
      }
      if (status.isMusicPack && !status.inMusicLibrary) {
        extraItems.add(
          PopupMenuItem(
            value: 'add_music',
            child: Text(l10n.downloadActionAddMusicLibrary),
          ),
        );
      }
    }

    final statusItems = switch (task.status) {
      SHODownloadStatus.downloading => [
          PopupMenuItem(value: 'pause', child: Text(l10n.downloadActionPause)),
          PopupMenuItem(value: 'delete', child: Text(l10n.downloadActionDelete)),
        ],
      SHODownloadStatus.paused => [
          PopupMenuItem(value: 'start', child: Text(l10n.downloadActionStart)),
          PopupMenuItem(value: 'delete', child: Text(l10n.downloadActionDelete)),
        ],
      SHODownloadStatus.completed => [
          PopupMenuItem(value: 'delete', child: Text(l10n.downloadActionDelete)),
        ],
    };

    return [copyItem, ...extraItems, ...statusItems];
  }

  void _handleMenu(String? action) {
    switch (action) {
      case 'pause':
        onPause();
      case 'start':
        onResume();
      case 'delete':
      case 'copy':
      case 'add_bookshelf':
      case 'add_music':
        break;
    }
  }

  Color _statusColor() {
    return switch (task.status) {
      SHODownloadStatus.downloading => SHOAppColors.error,
      SHODownloadStatus.completed => SHOAppColors.success,
      SHODownloadStatus.paused => SHOAppColors.textSecondary,
    };
  }

  List<Widget> _statusBadges(
    AppLocalizations l10n,
    SHODownloadTaskStatus status,
  ) {
    final badges = <Widget>[];
    if (task.status != SHODownloadStatus.completed) return badges;

    if (status.showExtractedBadge) {
      badges.add(_StatusBadge(label: l10n.downloadBadgeExtracted));
    }
    if (status.showInMusicBadge) {
      badges.add(_StatusBadge(label: l10n.downloadBadgeInMusicLibrary));
    }
    if (status.showInBookshelfBadge) {
      badges.add(_StatusBadge(label: l10n.downloadBadgeInBookshelf));
    }
    return badges;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = context.shoTheme;
    final date = DateFormat.yMd().add_Hm().format(task.createdAt);
    final sizeLabel = task.totalBytes != null
        ? '${formatFileSize(task.downloadedBytes)} / ${formatFileSize(task.totalBytes!)}'
        : formatFileSize(task.downloadedBytes);
    final isCompleted = task.status == SHODownloadStatus.completed;
    final statusAsync = ref.watch(downloadTaskStatusProvider(task.id));
    final status = statusAsync.value ?? const SHODownloadTaskStatus();
    final badges = _statusBadges(l10n, status);

    return SHOProfileSectionCard(
      padding: const EdgeInsets.all(SHOAppSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: InkWell(
              onTap: onOpen,
              borderRadius:
                  BorderRadius.circular(SHOAppSpacing.cardRadius),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: SHOAppColors.accent.withValues(alpha: 0.1),
                      borderRadius:
                          BorderRadius.circular(SHOAppSpacing.cardRadius),
                    ),
                    child: Icon(
                      downloadFileTypeIcon(task),
                      size: 22,
                      color: SHOAppColors.accent,
                    ),
                  ),
                  const SizedBox(width: SHOAppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.fileName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                        ),
                        const SizedBox(height: SHOAppSpacing.xxs),
                        Text.rich(
                          TextSpan(
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: theme.textSecondary),
                            children: [
                              TextSpan(
                                text: downloadTaskTypeLabel(l10n, task),
                              ),
                              const TextSpan(text: ' · '),
                              TextSpan(
                                text: downloadStatusLabel(l10n, task.status),
                                style: TextStyle(color: _statusColor()),
                              ),
                            ],
                          ),
                        ),
                        if (badges.isNotEmpty) ...[
                          const SizedBox(height: SHOAppSpacing.xs),
                          Wrap(
                            spacing: SHOAppSpacing.xs,
                            runSpacing: SHOAppSpacing.xxs,
                            children: badges,
                          ),
                        ],
                        const SizedBox(height: SHOAppSpacing.sm),
                        SizedBox(
                          height: 4,
                          child: isCompleted
                              ? null
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                    SHOAppSpacing.cardRadius,
                                  ),
                                  child: LinearProgressIndicator(
                                    value: task.progress,
                                    minHeight: 4,
                                    backgroundColor: theme.surfaceMuted,
                                    color: SHOAppColors.accent,
                                  ),
                                ),
                        ),
                        const SizedBox(height: SHOAppSpacing.xs),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                sizeLabel,
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(color: theme.textSecondary),
                              ),
                            ),
                            Text(
                              date,
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(color: theme.textMuted),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, size: 20),
            padding: EdgeInsets.zero,
            onSelected: (value) async {
              if (value == 'delete') {
                if (context.mounted) await _confirmDelete(context);
              } else if (value == 'copy') {
                await _copyUrl(context);
              } else if (value == 'add_bookshelf') {
                await addDownloadTaskToBookshelf(context, ref, task);
              } else if (value == 'add_music') {
                await addDownloadMusicPackToLibrary(context, ref, task);
              } else {
                _handleMenu(value);
              }
            },
            itemBuilder: (context) => _menuItems(l10n, status),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: SHOAppColors.accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: SHOAppColors.accent,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
