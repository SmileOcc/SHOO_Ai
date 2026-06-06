import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../feedback/hos_overlay_loading.dart';
import '../network/hos_connectivity_service.dart';
import '../theme/hos_colors.dart';
import '../theme/hos_spacing.dart';
import '../../l10n/app_localizations.dart';

/// MaterialApp builder 外壳：离线提示 + 全局 Loading 遮罩。
class SHOAppShell extends ConsumerWidget {
  const SHOAppShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnline = ref.watch(isOnlineProvider);

    return SHOGlobalLoadingOverlay(
      child: Column(
        children: [
          if (!isOnline)
            Material(
              color: SHOAppColors.warning.withValues(alpha: 0.15),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: SHOAppSpacing.xl,
                    vertical: SHOAppSpacing.sm,
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.wifi_off, size: 16, color: SHOAppColors.warning),
                      const SizedBox(width: SHOAppSpacing.sm),
                      Expanded(
                        child: Text(
                          AppLocalizations.of(context).offlineBanner,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          Expanded(child: child),
        ],
      ),
    );
  }
}
