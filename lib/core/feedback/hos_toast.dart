import 'package:flutter/material.dart';

import '../theme/hos_colors.dart';
import '../theme/hos_spacing.dart';

/// 全局 SnackBar / Toast 入口，样式统一。
final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

enum SHOToastType { success, error, info }

abstract final class SHOAppToast {
  static void show(
    String message, {
    SHOToastType type = SHOToastType.info,
    Duration duration = const Duration(seconds: 2),
  }) {
    final messenger = scaffoldMessengerKey.currentState;
    if (messenger == null) return;

    final (icon, color) = switch (type) {
      SHOToastType.success => (Icons.check_circle_outline, SHOAppColors.success),
      SHOToastType.error => (Icons.error_outline, SHOAppColors.error),
      SHOToastType.info => (Icons.info_outline, SHOAppColors.primary),
    };

    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        duration: duration,
        margin: const EdgeInsets.all(SHOAppSpacing.lg),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SHOAppSpacing.sm),
        ),
        content: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: SHOAppSpacing.sm),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }

  static void success(String message) =>
      show(message, type: SHOToastType.success);

  static void error(String message) => show(message, type: SHOToastType.error);

  static void info(String message) => show(message, type: SHOToastType.info);
}

extension SHOAppToastContext on BuildContext {
  void showToast(String message, {SHOToastType type = SHOToastType.info}) {
    SHOAppToast.show(message, type: type);
  }
}
