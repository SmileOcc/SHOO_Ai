import 'package:flutter/material.dart';

import '../../../../core/theme/hos_colors.dart';
import '../../../../core/theme/hos_spacing.dart';
import '../../../../core/widgets/hos_dialog.dart';
import '../../../../l10n/app_localizations.dart';

Future<void> showSHOMusicPlayerMoreSheet({
  required BuildContext context,
  required VoidCallback onDownload,
  required VoidCallback onMore,
}) {
  final l10n = AppLocalizations.of(context);

  return SHOAppDialog.showBottomSheet<void>(
    context,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(
        SHOAppSpacing.xl,
        SHOAppSpacing.lg,
        SHOAppSpacing.xl,
        SHOAppSpacing.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.musicPlayerMoreTitle,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: SHOAppSpacing.xl),
          _MoreSheetTile(
            icon: Icons.arrow_circle_down_rounded,
            label: l10n.musicPlayerDownloadSong,
            onTap: () {
              Navigator.pop(context);
              onDownload();
            },
          ),
          const SizedBox(height: SHOAppSpacing.sm),
          _MoreSheetTile(
            icon: Icons.more_horiz_rounded,
            label: l10n.shareMore,
            onTap: () {
              Navigator.pop(context);
              onMore();
            },
          ),
        ],
      ),
    ),
  );
}

class _MoreSheetTile extends StatelessWidget {
  const _MoreSheetTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: SHOAppSpacing.md,
            vertical: SHOAppSpacing.lg,
          ),
          child: Row(
            children: [
              Icon(icon, color: SHOAppColors.accent),
              const SizedBox(width: SHOAppSpacing.lg),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.35),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
