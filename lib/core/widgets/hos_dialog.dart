import 'package:flutter/material.dart';

import '../theme/hos_colors.dart';
import '../theme/hos_spacing.dart';
import '../theme/hos_typography.dart';
import 'hos_button.dart';

/// 弹窗工具类：确认框 / 信息框 / 底部 Sheet。
///
/// 参考文章扩展建议：避免每个页面自行拼装 AlertDialog。
///
/// ```dart
/// // 确认弹窗
/// final ok = await SHOAppDialog.confirm(
///   context,
///   title: 'Remove item?',
///   message: 'This action cannot be undone.',
///   confirmLabel: 'Remove',
///   isDestructive: true,
/// );
///
/// // 信息提示
/// await SHOAppDialog.alert(context, title: 'Saved', message: 'Address updated.');
///
/// // 底部操作面板
/// await SHOAppDialog.showBottomSheet(
///   context,
///   child: Column(
///     mainAxisSize: MainAxisSize.min,
///     children: [
///       ListTile(title: Text('Share'), onTap: () => Navigator.pop(context)),
///       ListTile(title: Text('Report'), onTap: () => Navigator.pop(context)),
///     ],
///   ),
/// );
/// ```
abstract final class SHOAppDialog {
  static Future<bool> confirm(
    BuildContext context, {
    required String title,
    String? message,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
    bool isDestructive = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: SHOAppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SHOAppSpacing.buttonRadius),
        ),
        title: Text(title, style: SHOAppTypography.textTheme.titleLarge),
        content: message != null
            ? Text(message, style: SHOAppTypography.textTheme.bodyMedium)
            : null,
        actions: [
          SHOAppButton(
            label: cancelLabel,
            variant: SHOAppButtonVariant.text,
            size: SHOAppButtonSize.sm,
            onPressed: () => Navigator.pop(ctx, false),
          ),
          SHOAppButton(
            label: confirmLabel,
            variant: isDestructive ? SHOAppButtonVariant.accent : SHOAppButtonVariant.primary,
            size: SHOAppButtonSize.sm,
            onPressed: () => Navigator.pop(ctx, true),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  static Future<void> alert(
    BuildContext context, {
    required String title,
    String? message,
    String okLabel = 'OK',
  }) {
    return showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: SHOAppColors.surface,
        title: Text(title, style: SHOAppTypography.textTheme.titleLarge),
        content: message != null
            ? Text(message, style: SHOAppTypography.textTheme.bodyMedium)
            : null,
        actions: [
          SHOAppButton(
            label: okLabel,
            size: SHOAppButtonSize.sm,
            onPressed: () => Navigator.pop(ctx),
          ),
        ],
      ),
    );
  }

  static Future<T?> showBottomSheet<T>(
    BuildContext context, {
    required Widget child,
    bool isDismissible = true,
    bool isScrollControlled = false,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isDismissible: isDismissible,
      isScrollControlled: isScrollControlled,
      backgroundColor: SHOAppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(SHOAppSpacing.xl)),
      ),
      builder: (_) => SafeArea(child: child),
    );
  }
}
