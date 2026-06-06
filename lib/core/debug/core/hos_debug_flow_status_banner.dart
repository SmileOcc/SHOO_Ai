import 'package:flutter/material.dart';

import '../../theme/hos_spacing.dart';
import '../../../l10n/app_localizations.dart';

/// 调试面板顶部状态条：标明当前走正常流程还是调试覆盖。
class SHODebugFlowStatusBanner extends StatelessWidget {
  const SHODebugFlowStatusBanner({super.key, required this.overrideEnabled});

  final bool overrideEnabled;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final active = overrideEnabled;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: SHOAppSpacing.lg,
        vertical: SHOAppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: active
            ? Theme.of(context).colorScheme.primaryContainer
            : Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(SHOAppSpacing.sm),
      ),
      child: Row(
        children: [
          Icon(
            active ? Icons.bug_report : Icons.cloud_outlined,
            size: 18,
            color: active
                ? Theme.of(context).colorScheme.onPrimaryContainer
                : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: SHOAppSpacing.sm),
          Expanded(
            child: Text(
              active ? l10n.debugFlowOverride : l10n.debugFlowNormal,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
