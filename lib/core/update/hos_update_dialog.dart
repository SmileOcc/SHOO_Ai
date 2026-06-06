import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/hos_button.dart';
import 'hos_update_service.dart';
import '../../l10n/app_localizations.dart';

/// 更新弹窗：支持可选更新与强制更新（层级高于活动弹窗）。
abstract final class SHOAppUpdateDialog {
  static Future<void> showIfNeeded(BuildContext context, WidgetRef ref) async {
    try {
      final info = await ref.read(appUpdateServiceProvider).checkUpdate();
      if (!info.hasUpdate || !context.mounted) return;
      await show(context, ref, info: info);
    } catch (_) {
      // 静默失败，不阻塞启动
    }
  }

  static Future<void> show(
    BuildContext context,
    WidgetRef ref, {
    required SHOAppUpdateInfo info,
  }) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: !info.forceUpdate,
      builder: (ctx) => PopScope(
        canPop: !info.forceUpdate,
        child: AlertDialog(
          title: Text(AppLocalizations.of(ctx).updateTitle),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppLocalizations.of(ctx).updateNewVersion(info.latestVersion)),
                const SizedBox(height: 8),
                Text(info.releaseNotes),
              ],
            ),
          ),
          actions: [
            if (!info.forceUpdate)
              SHOAppButton(
                label: AppLocalizations.of(ctx).updateLater,
                variant: SHOAppButtonVariant.text,
                size: SHOAppButtonSize.sm,
                onPressed: () => Navigator.pop(ctx),
              ),
            SHOAppButton(
              label: AppLocalizations.of(ctx).updateNow,
              size: SHOAppButtonSize.sm,
              onPressed: () async {
                await ref.read(appUpdateServiceProvider).openUpdateUrl(info.updateUrl);
                if (!info.forceUpdate && ctx.mounted) Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }
}
