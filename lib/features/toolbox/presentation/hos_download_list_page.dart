import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/dialogs/hos_download_task_dialog.dart';
import '../../../core/theme/hos_colors.dart';
import '../../../core/theme/hos_spacing.dart';
import '../../../core/theme/hos_theme_extension.dart';
import '../../../core/widgets/hos_empty_state.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/hos_download_task.dart';
import 'hos_download_controller.dart';
import 'hos_download_file_type_ui.dart';
import 'hos_download_preview_helper.dart';
import 'hos_download_task_tile.dart';
import 'music/hos_music_library_controller.dart';

class SHODownloadListPage extends ConsumerStatefulWidget {
  const SHODownloadListPage({super.key});

  @override
  ConsumerState<SHODownloadListPage> createState() =>
      _SHODownloadListPageState();
}

class _SHODownloadListPageState extends ConsumerState<SHODownloadListPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  static const _tabs = SHODownloadListTab.values;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(reconcileStaleMusicPackAddedTasks(ref));
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _openAddTaskDialog() async {
    final result = await SHODownloadTaskDialog.show(context);
    if (result == null || !mounted) return;
    await ref.read(downloadTasksProvider.notifier).addTask(
          url: result.url,
          fileName: result.fileName,
          priority: result.priority,
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.downloadListTitle,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: l10n.downloadAddTask,
            onPressed: _openAddTaskDialog,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(kTextTabBarHeight + 1),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Divider(
                height: 1,
                thickness: 1,
                color: SHOAppColors.border,
              ),
              TabBar(
                controller: _tabController,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                dividerHeight: 0,
                labelColor: Theme.of(context).colorScheme.onSurface,
                unselectedLabelColor: context.shoTheme.textSecondary,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
                indicator: const UnderlineTabIndicator(
                  borderSide: BorderSide(color: SHOAppColors.accent, width: 3),
                ),
                tabs: _tabs.map((tab) => Tab(text: tab.label(l10n))).toList(),
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _tabs
            .map((tab) => _SHODownloadTabView(tab: tab))
            .toList(),
      ),
    );
  }
}

class _SHODownloadTabView extends ConsumerWidget {
  const _SHODownloadTabView({required this.tab});

  final SHODownloadListTab tab;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tasks = ref.watch(downloadTasksProvider);
    final filtered = switch (tab) {
      SHODownloadListTab.all => tasks,
      SHODownloadListTab.downloading => tasks
          .where((t) => t.status == SHODownloadStatus.downloading)
          .toList(),
      SHODownloadListTab.paused => tasks
          .where((t) => t.status == SHODownloadStatus.paused)
          .toList(),
      SHODownloadListTab.completed => tasks
          .where((t) => t.status == SHODownloadStatus.completed)
          .toList(),
    };

    if (tasks.isEmpty) {
      return SHOEmptyState(title: l10n.downloadEmpty);
    }
    if (filtered.isEmpty) {
      return SHOEmptyState(title: l10n.downloadEmpty);
    }

    final notifier = ref.read(downloadTasksProvider.notifier);

    return ListView.separated(
      padding: const EdgeInsets.all(SHOAppSpacing.pagePadding),
      itemCount: filtered.length,
      separatorBuilder: (_, __) => const SizedBox(height: SHOAppSpacing.lg),
      itemBuilder: (context, index) {
        final task = filtered[index];
        return SHODownloadTaskTile(
          task: task,
          onPause: () => notifier.pauseTask(task.id),
          onResume: () => notifier.resumeTask(task.id),
          onDelete: () => notifier.deleteTask(task.id),
          onOpen: () => handleDownloadTaskTap(context, ref, task),
        );
      },
    );
  }
}
