import 'package:flutter/material.dart';

import '../../../core/theme/hos_colors.dart';
import '../../../core/theme/hos_spacing.dart';
import '../../../core/theme/hos_theme_extension.dart';

class SHOSettingsPickerOption<T> {
  const SHOSettingsPickerOption({
    required this.value,
    required this.label,
  });

  final T value;
  final String label;
}

/// 设置项选择底部弹窗（勾选样式，暗黑模式友好）。
Future<T?> showSHOSettingsPickerSheet<T>({
  required BuildContext context,
  required List<SHOSettingsPickerOption<T>> options,
  required T groupValue,
}) {
  return showModalBottomSheet<T>(
    context: context,
    backgroundColor: context.shoSurface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
    ),
    builder: (context) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < options.length; i++) ...[
              if (i > 0) Divider(height: 1, color: context.shoTheme.divider),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: SHOAppSpacing.xl,
                ),
                title: Text(
                  options[i].label,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontSize: 15,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                ),
                trailing: groupValue == options[i].value
                    ? const Icon(
                        Icons.check_rounded,
                        color: SHOAppColors.accent,
                        size: 22,
                      )
                    : null,
                onTap: () => Navigator.pop(context, options[i].value),
              ),
            ],
            const SizedBox(height: SHOAppSpacing.sm),
          ],
        ),
      );
    },
  );
}
