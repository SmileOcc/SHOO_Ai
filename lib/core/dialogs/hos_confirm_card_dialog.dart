import 'package:flutter/material.dart';

import '../theme/hos_spacing.dart';
import '../widgets/hos_button.dart';
import 'hos_card_dialog_shell.dart';

/// 通用卡片确认弹窗：标题、描述、底部确认按钮。
class SHOConfirmCardDialog extends StatelessWidget {
  const SHOConfirmCardDialog({
    super.key,
    required this.title,
    this.message,
    required this.confirmLabel,
    this.isDestructive = false,
  });

  final String title;
  final String? message;
  final String confirmLabel;
  final bool isDestructive;

  static Future<bool> show(
    BuildContext context, {
    required String title,
    String? message,
    required String confirmLabel,
    bool isDestructive = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => SHOConfirmCardDialog(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        isDestructive: isDestructive,
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return SHOCardDialogShell(
      onClose: () => Navigator.of(context).pop(false),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: SHOAppSpacing.xxl),
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: SHOAppSpacing.md),
            Text(
              message!,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
          const SizedBox(height: SHOAppSpacing.xl),
          SHOAppButton(
            label: confirmLabel,
            fullWidth: true,
            variant: isDestructive
                ? SHOAppButtonVariant.accent
                : SHOAppButtonVariant.primary,
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );
  }
}
