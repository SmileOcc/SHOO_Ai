import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:shoo/app/router/hos_routes.dart';
import 'package:shoo/core/auth/hos_auth_guard.dart';
import 'package:shoo/core/theme/hos_colors.dart';
import 'package:shoo/core/theme/hos_spacing.dart';
import 'package:shoo/core/widgets/hos_profile_section_card.dart';
import 'package:shoo/features/flash_sale/presentation/state/hos_flash_sale_follow_controller.dart';
import 'package:shoo/l10n/app_localizations.dart';

/// 我的 → 活动通知入口（抢购关注列表等）。
class SHOProfileActivityNotificationHub extends ConsumerWidget {
  const SHOProfileActivityNotificationHub({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final follows =
        ref.watch(flashSaleFollowControllerProvider).valueOrNull ?? const [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: SHOAppSpacing.xs,
            bottom: SHOAppSpacing.sm,
          ),
          child: Text(
            l10n.profileActivityNotifications,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
        ),
        SHOProfileSectionCard(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: SHOAppColors.accent.withValues(alpha: 0.12),
              child: const Icon(
                Icons.notifications_active_outlined,
                color: SHOAppColors.accent,
              ),
            ),
            title: Text(l10n.profileActivityFlashSale),
            subtitle: Text(l10n.profileActivityFlashSaleDesc),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (follows.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: SHOAppColors.accent,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '${follows.length}',
                      style: const TextStyle(color: Colors.white, fontSize: 11),
                    ),
                  ),
                const Icon(Icons.chevron_right),
              ],
            ),
            onTap: () {
              if (!SHOAuthGuard.requireAuth(context, ref)) return;
              context.push(SHOAppRoutes.profileFlashSaleFollows);
            },
          ),
        ),
      ],
    );
  }
}
