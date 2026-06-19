import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shoo/core/theme/hos_spacing.dart';
import 'package:shoo/l10n/app_localizations.dart';
import 'package:shoo/features/toolbox/domain/entities/hos_download_task.dart';
import 'package:shoo/features/toolbox/presentation/state/hos_download_controller.dart';
import 'package:shoo/features/toolbox/presentation/pages/hos_txt_reader_page.dart';

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
