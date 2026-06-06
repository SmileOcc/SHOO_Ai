import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/hos_routes.dart';
import '../../../core/constants/hos_constants.dart';
import '../../../core/permissions/hos_permission_service.dart';
import '../../../core/share/hos_share_panel.dart';
import '../../../core/theme/hos_colors.dart';
import '../../../core/theme/hos_spacing.dart';
import '../../../core/widgets/hos_button.dart';
import '../../../features/auth/presentation/hos_session_provider.dart';
import '../../../l10n/app_localizations.dart';

class SHOProfilePage extends ConsumerWidget {
  const SHOProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final session = ref.watch(sessionProvider);

    return ListView(
      padding: const EdgeInsets.all(SHOAppSpacing.pagePadding),
      children: [
        GestureDetector(
          onTap: session.isAuthenticated
              ? null
              : () => context.push(SHOAppRoutes.login),
          child: Container(
            padding: const EdgeInsets.all(SHOAppSpacing.xl),
            color: SHOAppColors.surfaceMuted,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: SHOAppColors.primary,
                  backgroundImage: session.user?.avatarUrl != null
                      ? NetworkImage(session.user!.avatarUrl!)
                      : null,
                  child: session.user?.avatarUrl == null
                      ? const Icon(Icons.person, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: SHOAppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        session.isAuthenticated
                            ? l10n.welcomeUser(session.user!.nickname)
                            : l10n.profileSignIn,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: SHOAppSpacing.xs),
                      Text(
                        session.isAuthenticated
                            ? (session.user?.email ?? session.user?.phone ?? '')
                            : l10n.profileSignInHint,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                if (!session.isAuthenticated)
                  const Icon(Icons.chevron_right),
              ],
            ),
          ),
        ),
        if (session.isAuthenticated) ...[
          const SizedBox(height: SHOAppSpacing.lg),
          SHOAppButton(
            label: l10n.logout,
            variant: SHOAppButtonVariant.outline,
            size: SHOAppButtonSize.sm,
            onPressed: () => ref.read(sessionProvider.notifier).logout(),
          ),
        ],
        const SizedBox(height: SHOAppSpacing.xl),
        _SHOMenuSection(
          title: l10n.profileOrders,
          items: [
            l10n.ordersAll,
            l10n.ordersPendingPayment,
            l10n.ordersShipped,
            l10n.ordersReviews,
          ],
          onItemTap: (item) {
            if (item == l10n.ordersAll ||
                item == l10n.ordersPendingPayment ||
                item == l10n.ordersShipped) {
              context.push(SHOAppRoutes.orders);
            }
          },
        ),
        const SizedBox(height: SHOAppSpacing.xl),
        _SHOMenuSection(
          title: l10n.profileServices,
          items: [
            l10n.profileMessages,
            l10n.profileShareDemo,
            l10n.profileCameraPermission,
            'Coupons',
            'Addresses',
            'Customer Service',
            l10n.profileSettings,
          ],
          onItemTap: (item) async {
            if (item == l10n.profileSettings) {
              context.push(SHOAppRoutes.settings);
            } else if (item == l10n.profileMessages) {
              context.push(SHOAppRoutes.messages);
            } else if (item == l10n.profileShareDemo) {
              SHOSharePanel.show(
                context,
                ref,
                title: l10n.appName,
                link: 'https://shoo.app',
              );
            } else if (item == l10n.profileCameraPermission) {
              await ref.read(permissionServiceProvider).requestCamera();
            }
          },
        ),
        const SizedBox(height: SHOAppSpacing.xxxl),
        SHOAppButton(
          label: l10n.versionLabel(SHOAppConstants.appName, SHOAppConstants.appVersion),
          variant: SHOAppButtonVariant.outline,
          isExpanded: true,
        ),
      ],
    );
  }
}

class _SHOMenuSection extends StatelessWidget {
  const _SHOMenuSection({
    required this.title,
    required this.items,
    this.onItemTap,
  });

  final String title;
  final List<String> items;
  final void Function(String item)? onItemTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: SHOAppSpacing.md),
        ...items.map(
          (item) => ListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            title: Text(
              item,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 13),
            ),
            trailing: const Icon(Icons.chevron_right, size: 18),
            onTap: onItemTap != null ? () => onItemTap!(item) : null,
          ),
        ),
      ],
    );
  }
}
