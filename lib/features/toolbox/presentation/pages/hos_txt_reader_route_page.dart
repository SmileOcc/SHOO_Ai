import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shoo/core/analytics/hos_page_analytics.dart';
import 'package:shoo/core/pages/hos_pages.dart';
import 'package:shoo/core/theme/hos_spacing.dart';
import 'package:shoo/l10n/app_localizations.dart';
import 'package:shoo/features/toolbox/domain/entities/hos_download_task.dart';
import 'package:shoo/features/toolbox/presentation/state/hos_download_controller.dart';
import 'package:shoo/features/toolbox/presentation/pages/hos_txt_reader_page.dart';

class SHOTxtReaderRoutePage extends ConsumerStatefulWidget {
  const SHOTxtReaderRoutePage({super.key, required this.taskId});

  final String taskId;

  @override
  ConsumerState<SHOTxtReaderRoutePage> createState() =>
      _SHOTxtReaderRoutePageState();
}

class _SHOTxtReaderRoutePageState extends ConsumerState<SHOTxtReaderRoutePage>
    with SHOPageRouteAnalyticsMixin, SHOAppPageMixin, SHOAppTrackedPageMixin {
  @override
  String get pageName => 'txt_reader_route';

  @override
  Map<String, Object?> get pageAnalyticsExtra => {'task_id': widget.taskId};

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tasks = ref.watch(downloadTasksProvider);
    SHODownloadTask? task;
    for (final item in tasks) {
      if (item.id == widget.taskId) {
        task = item;
        break;
      }
    }

    if (task == null) {
      return buildTrackedPage(
        Scaffold(
          appBar: AppBar(),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(SHOAppSpacing.xxxl),
              child: Text(
                l10n.txtReaderTaskMissing,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
        onRetry: () => ref.invalidate(downloadTasksProvider),
      );
    }

    return SHOTxtReaderPage(task: task);
  }
}
