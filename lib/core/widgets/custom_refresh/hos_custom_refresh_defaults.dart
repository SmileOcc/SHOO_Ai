import 'package:flutter/material.dart';

import 'package:shoo/core/theme/hos_colors.dart';
import 'package:shoo/core/theme/hos_spacing.dart';
import 'package:shoo/core/widgets/custom_refresh/hos_custom_refresh_controller.dart';
import 'package:shoo/core/widgets/custom_refresh/hos_refresh_brand_indicator.dart';
import 'package:shoo/core/widgets/hos_empty_state.dart';
import 'package:shoo/core/widgets/hos_error_view.dart';
import 'package:shoo/l10n/app_localizations.dart';

/// [SHOAppCustomRefresh] 默认 Header / Footer / 空错态。
abstract final class SHOAppCustomRefreshDefaults {
  static Widget header(
    BuildContext context,
    SHOAppCustomRefreshController controller, {
    required double triggerOffset,
  }) {
    final l10n = AppLocalizations.of(context);
    final status = controller.refreshStatus;

    String? label;
    switch (status) {
      case SHOAppCustomRefreshStatus.dragging:
        label = controller.pullProgress(triggerOffset) >= 1
            ? l10n.customRefreshRelease
            : l10n.customRefreshPull;
      case SHOAppCustomRefreshStatus.loading:
        label = l10n.customRefreshLoading;
      case SHOAppCustomRefreshStatus.completed:
        label = l10n.customRefreshDone;
      case SHOAppCustomRefreshStatus.error:
        label = l10n.loadFailed;
      case SHOAppCustomRefreshStatus.idle:
        label = null;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final height = constraints.maxHeight;
        if (height < 8) return const SizedBox.shrink();

        final showLabel = label != null && height >= 56;

        return ClipRect(
          child: SizedBox(
            height: height,
            width: double.infinity,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: SHOAppSpacing.sm),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SHOAppRefreshBrandIndicator(
                      refreshStatus: status,
                      pullProgress: controller.pullProgress(triggerOffset),
                      size: 36,
                    ),
                    if (showLabel) ...[
                      const SizedBox(height: SHOAppSpacing.xs),
                      Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: SHOAppColors.textMuted,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  static Widget footer(
    BuildContext context,
    SHOAppCustomLoadStatus status, {
    VoidCallback? onRetry,
  }) {
    final l10n = AppLocalizations.of(context);

    switch (status) {
      case SHOAppCustomLoadStatus.idle:
        return const SizedBox(height: SHOAppSpacing.xxxl);
      case SHOAppCustomLoadStatus.loading:
        return Padding(
          padding: const EdgeInsets.all(SHOAppSpacing.xl),
          child: Center(
            child: SHOAppRefreshBrandIndicator(
              refreshStatus: SHOAppCustomRefreshStatus.loading,
              size: 28,
              compact: true,
            ),
          ),
        );
      case SHOAppCustomLoadStatus.noMore:
        return Padding(
          padding: const EdgeInsets.all(SHOAppSpacing.xl),
          child: Center(
            child: Text(
              l10n.pagedListNoMore,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: SHOAppColors.textMuted),
            ),
          ),
        );
      case SHOAppCustomLoadStatus.error:
        return Padding(
          padding: const EdgeInsets.all(SHOAppSpacing.xl),
          child: Center(
            child: InkWell(
              onTap: onRetry,
              borderRadius: BorderRadius.circular(SHOAppSpacing.buttonRadius),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: SHOAppSpacing.lg,
                  vertical: SHOAppSpacing.sm,
                ),
                child: Text(
                  l10n.customRefreshLoadFailed,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: SHOAppColors.accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        );
    }
  }

  static Widget empty(BuildContext context, {String? message}) {
    final l10n = AppLocalizations.of(context);
    return SHOEmptyState(title: message ?? l10n.noData);
  }

  static Widget error(
    BuildContext context, {
    required String message,
    VoidCallback? onRetry,
  }) {
    return SHOAppErrorView(message: message, onRetry: onRetry);
  }
}
