import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../theme/hos_colors.dart';
import '../theme/hos_spacing.dart';
import 'hos_empty_state.dart';

class SHOAppErrorView extends StatelessWidget {
  const SHOAppErrorView({
    super.key,
    required this.message,
    this.onRetry,
  });

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SHOEmptyState(
      icon: Icons.wifi_off_rounded,
      title: l10n.loadFailed,
      subtitle: message,
      actionLabel: onRetry != null ? l10n.retry : null,
      onAction: onRetry,
    );
  }
}

class SHOAppRefreshHeader extends StatelessWidget {
  const SHOAppRefreshHeader({
    super.key,
    required this.child,
    required this.onRefresh,
  });

  final Widget child;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: SHOAppColors.accent,
      onRefresh: onRefresh,
      child: child,
    );
  }
}

class SHOSectionHeader extends StatelessWidget {
  const SHOSectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: SHOAppSpacing.pagePadding,
        vertical: SHOAppSpacing.md,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
            ),
          ),
          if (actionLabel != null && onAction != null)
            GestureDetector(
              onTap: onAction,
              child: Text(
                actionLabel!,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
              ),
            ),
        ],
      ),
    );
  }
}
