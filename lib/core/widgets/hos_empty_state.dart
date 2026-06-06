import 'package:flutter/material.dart';

import '../theme/hos_colors.dart';
import '../theme/hos_spacing.dart';
import 'hos_button.dart';

/// 空数据占位组件（图标 + 文案 + 可选操作按钮）。
///
/// 简单场景用 [SHOEmptyState]；列表四态切换推荐 [SHOAppLoadingState]。
///
/// ```dart
/// SHOEmptyState(
///   title: 'No orders yet',
///   subtitle: 'Start shopping to see your orders here.',
///   actionLabel: 'Shop Now',
///   onAction: () => context.go('/'),
/// )
/// ```
class SHOEmptyState extends StatelessWidget {
  const SHOEmptyState({
    super.key,
    required this.title,
    this.subtitle,
    this.icon = Icons.inbox_outlined,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? subtitle;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(SHOAppSpacing.xxxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: SHOAppColors.textMuted),
            const SizedBox(height: SHOAppSpacing.lg),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: SHOAppSpacing.sm),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: SHOAppSpacing.xl),
              SHOAppButton(label: actionLabel!, onPressed: onAction),
            ],
          ],
        ),
      ),
    );
  }
}
