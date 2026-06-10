import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/dialogs/hos_confirm_card_dialog.dart';
import '../../../core/theme/hos_colors.dart';
import '../../../core/theme/hos_spacing.dart';
import '../../../core/theme/hos_theme_extension.dart';
import '../../../core/widgets/hos_empty_state.dart';
import '../../../core/widgets/hos_profile_section_card.dart';
import '../../../l10n/app_localizations.dart';
import '../data/hos_txt_reader_progress_storage.dart';
import '../domain/hos_download_task.dart';
import '../domain/hos_txt_novel_models.dart';
import 'hos_bookshelf_controller.dart';
import 'hos_download_controller.dart';
import 'hos_download_preview_helper.dart';

class SHOBookshelfListPage extends ConsumerWidget {
  const SHOBookshelfListPage({super.key});

  bool _hasMeaningfulProgress(SHOTxtReaderProgress? progress) {
    if (progress == null) return false;
    return progress.chapterIndex > 0 || progress.pageIndexInChapter > 0;
  }

  String _displayTitle(String fileName) {
    final lower = fileName.toLowerCase();
    if (lower.endsWith('.txt')) {
      return fileName.substring(0, fileName.length - 4);
    }
    return fileName;
  }

  Future<void> _confirmRemove(
    BuildContext context,
    WidgetRef ref,
    String taskId,
  ) async {
    final l10n = AppLocalizations.of(context);
    final ok = await SHOConfirmCardDialog.show(
      context,
      title: l10n.bookshelfRemoveConfirmTitle,
      message: l10n.bookshelfRemoveConfirmMessage,
      confirmLabel: l10n.bookshelfRemoveAction,
      isDestructive: true,
    );
    if (!ok) return;
    await ref.read(bookshelfEntriesProvider.notifier).remove(taskId);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final items = ref.watch(bookshelfListItemsProvider);
    final progressStorage = ref.watch(txtReaderProgressStorageProvider);
    final orphanCount = items.where((item) => item.task == null).length;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.bookshelfTitle,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: items.isEmpty
          ? SHOEmptyState(title: l10n.bookshelfEmpty)
          : ListView.separated(
              padding: const EdgeInsets.all(SHOAppSpacing.pagePadding),
              itemCount: items.length + (orphanCount > 0 ? 1 : 0),
              separatorBuilder: (_, __) =>
                  const SizedBox(height: SHOAppSpacing.lg),
              itemBuilder: (context, index) {
                if (orphanCount > 0 && index == 0) {
                  return SHOProfileSectionCard(
                    child: ListTile(
                      leading: const Icon(Icons.cleaning_services_outlined),
                      title: Text(l10n.bookshelfCleanupOrphansTitle),
                      subtitle: Text(
                        l10n.bookshelfCleanupOrphansMessage(orphanCount),
                      ),
                      trailing: TextButton(
                        onPressed: () async {
                          final validIds = {
                            for (final task in ref.read(downloadTasksProvider))
                              task.id,
                          };
                          await ref
                              .read(bookshelfEntriesProvider.notifier)
                              .removeOrphans(validIds);
                        },
                        child: Text(l10n.bookshelfCleanupOrphansAction),
                      ),
                    ),
                  );
                }

                final itemIndex = orphanCount > 0 ? index - 1 : index;
                final item = items[itemIndex];
                final task = item.task;
                final progress = progressStorage.read(item.entry.taskId);
                final subtitle = task == null
                    ? l10n.bookshelfFileMissing
                    : task.status != SHODownloadStatus.completed
                        ? l10n.bookshelfNotCompleted
                        : !_hasMeaningfulProgress(progress)
                            ? l10n.bookshelfUnread
                            : l10n.bookshelfReadingProgress(
                                progress!.chapterIndex + 1,
                              );

                return Dismissible(
                  key: ValueKey(item.entry.taskId),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: SHOAppSpacing.xl),
                    decoration: BoxDecoration(
                      color: SHOAppColors.error.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      l10n.bookshelfRemoveAction,
                      style: const TextStyle(
                        color: SHOAppColors.error,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  confirmDismiss: (_) async {
                    final ok = await SHOConfirmCardDialog.show(
                      context,
                      title: l10n.bookshelfRemoveConfirmTitle,
                      message: l10n.bookshelfRemoveConfirmMessage,
                      confirmLabel: l10n.bookshelfRemoveAction,
                      isDestructive: true,
                    );
                    if (ok) {
                      await ref
                          .read(bookshelfEntriesProvider.notifier)
                          .remove(item.entry.taskId);
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
                      leading: Container(
                        width: 44,
                        height: 56,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8E3D3),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(
                          Icons.menu_book_outlined,
                          color: Color(0xFF6B5B45),
                        ),
                      ),
                      title: Text(
                        task == null
                            ? l10n.bookshelfUnknownTitle
                            : _displayTitle(task.fileName),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      subtitle: Text(
                        subtitle,
                        style: TextStyle(
                          color: context.shoTheme.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        color: context.shoTheme.textSecondary,
                        tooltip: l10n.bookshelfRemoveAction,
                        onPressed: () =>
                            _confirmRemove(context, ref, item.entry.taskId),
                      ),
                      onTap: task == null
                          ? null
                          : () => handleDownloadTaskTap(context, task),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
