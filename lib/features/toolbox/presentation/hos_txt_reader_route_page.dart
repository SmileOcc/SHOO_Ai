import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/hos_spacing.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/hos_download_task.dart';
import 'hos_download_controller.dart';
import 'hos_txt_reader_page.dart';

class SHOTxtReaderRoutePage extends ConsumerWidget {
  const SHOTxtReaderRoutePage({super.key, required this.taskId});

  final String taskId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tasks = ref.watch(downloadTasksProvider);
    SHODownloadTask? task;
    for (final item in tasks) {
      if (item.id == taskId) {
        task = item;
        break;
      }
    }

    if (task == null) {
      return Scaffold(
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
      );
    }

    return SHOTxtReaderPage(task: task);
  }
}
