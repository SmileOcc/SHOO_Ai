import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../theme/hos_spacing.dart';
import '../widgets/hos_button.dart';
import 'hos_update_download_service.dart';
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
      builder: (ctx) => _SHOUpdateDialogBody(info: info),
    );
  }
}

class _SHOUpdateDialogBody extends ConsumerStatefulWidget {
  const _SHOUpdateDialogBody({required this.info});

  final SHOAppUpdateInfo info;

  @override
  ConsumerState<_SHOUpdateDialogBody> createState() => _SHOUpdateDialogBodyState();
}

class _SHOUpdateDialogBodyState extends ConsumerState<_SHOUpdateDialogBody> {
  double _progress = 0;
  bool _downloading = false;
  String? _statusMessage;
  StreamSubscription<SHOAppUpdateDownloadState>? _downloadSub;

  @override
  void dispose() {
    _downloadSub?.cancel();
    super.dispose();
  }

  Future<void> _startUpdate() async {
    if (_downloading) return;
    setState(() {
      _downloading = true;
      _progress = 0;
      _statusMessage = null;
    });

    _downloadSub?.cancel();
    _downloadSub = ref
        .read(appUpdateDownloadServiceProvider)
        .watchProgress()
        .listen((state) async {
      if (!mounted) return;
      setState(() {
        _progress = state.progress;
        _statusMessage = state.message;
      });
      if (state.isCompleted) {
        _downloadSub?.cancel();
        await ref.read(appUpdateServiceProvider).openUpdateUrl(widget.info.updateUrl);
        if (!widget.info.forceUpdate && mounted) {
          Navigator.pop(context);
        } else if (mounted) {
          setState(() => _downloading = false);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final info = widget.info;

    return PopScope(
      canPop: !info.forceUpdate && !_downloading,
      child: AlertDialog(
        title: Text(l10n.updateTitle),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.updateNewVersion(info.latestVersion)),
              const SizedBox(height: 8),
              Text(info.releaseNotes),
              if (_downloading) ...[
                const SizedBox(height: SHOAppSpacing.lg),
                LinearProgressIndicator(value: _progress > 0 ? _progress : null),
                const SizedBox(height: SHOAppSpacing.sm),
                Text(
                  _statusMessage ??
                      l10n.updateDownloadProgress(((_progress) * 100).round()),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ],
          ),
        ),
        actions: [
          if (!info.forceUpdate && !_downloading)
            SHOAppButton(
              label: l10n.updateLater,
              variant: SHOAppButtonVariant.text,
              size: SHOAppButtonSize.sm,
              onPressed: () => Navigator.pop(context),
            ),
          SHOAppButton(
            label: l10n.updateNow,
            size: SHOAppButtonSize.sm,
            isLoading: _downloading,
            onPressed: _downloading ? null : _startUpdate,
          ),
        ],
      ),
    );
  }
}
