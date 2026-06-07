import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/hos_config.dart';
import '../debug/core/hos_runtime_env_provider.dart';
import '../feedback/hos_overlay_loading.dart';
import '../network/hos_connectivity_service.dart';
import '../network/hos_local_server_health.dart';
import '../theme/hos_colors.dart';
import '../theme/hos_spacing.dart';
import '../../l10n/app_localizations.dart';

/// MaterialApp builder 外壳：离线提示 + 环境角标 + 全局 Loading 遮罩。
class SHOAppShell extends ConsumerWidget {
  const SHOAppShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnline = ref.watch(isOnlineProvider);
    final config = ref.watch(effectiveConfigProvider);
    final showEnvBadge = ref.watch(showEnvBadgeProvider);
    final localServerAsync = ref.watch(localServerReachableProvider);
    final l10n = AppLocalizations.of(context);

    final showBadge =
        SHOAppConfig.instance.isDebugPanelEnabled && showEnvBadge;

    final showLocalServerBanner = config.environment.usesLocalServer &&
        localServerAsync.maybeWhen(data: (ok) => !ok, orElse: () => false);

    final topInset = MediaQuery.paddingOf(context).top;

    return SHOGlobalLoadingOverlay(
      child: Stack(
        fit: StackFit.expand,
        children: [
          child,
          if (showLocalServerBanner || !isOnline)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (showLocalServerBanner)
                    _ShellTopBanner(
                      color: SHOAppColors.error.withValues(alpha: 0.92),
                      icon: Icons.dns_outlined,
                      message: l10n.localServerBanner,
                    ),
                  if (!isOnline)
                    _ShellTopBanner(
                      color: SHOAppColors.warning.withValues(alpha: 0.92),
                      icon: Icons.wifi_off,
                      message: l10n.offlineBanner,
                    ),
                ],
              ),
            ),
          if (showBadge)
            Positioned(
              top: topInset + SHOAppSpacing.xs,
              right: SHOAppSpacing.sm,
              child: IgnorePointer(
                child: Text(
                  l10n.envBadgeLabel(config.environment.badgeLabel),
                  style: const TextStyle(
                    fontSize: 9,
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ShellTopBanner extends StatelessWidget {
  const _ShellTopBanner({
    required this.color,
    required this.icon,
    required this.message,
  });

  final Color color;
  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 2,
      color: color,
      shadowColor: Colors.black26,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: SHOAppSpacing.xl,
            vertical: SHOAppSpacing.sm,
          ),
          child: Row(
            children: [
              Icon(icon, size: 16, color: Colors.white),
              const SizedBox(width: SHOAppSpacing.sm),
              Expanded(
                child: Text(
                  message,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
