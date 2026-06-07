import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/hos_routes.dart';
import '../../../core/auth/hos_auth_guard.dart';
import '../../../core/share/hos_share_panel.dart';
import '../../../core/theme/hos_spacing.dart';
import '../../../core/theme/hos_theme_extension.dart';
import '../../../features/auth/presentation/hos_session_provider.dart'
    show SHOSessionState, sessionProvider;
import '../../../l10n/app_localizations.dart';

class SHOProfilePage extends ConsumerWidget {
  const SHOProfilePage({super.key});

  static const _headerExpandedHeight = 240.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final session = ref.watch(sessionProvider);
    final theme = context.shoTheme;
    final topInset = MediaQuery.paddingOf(context).top;

    final displayName = session.isAuthenticated
        ? session.user!.nickname
        : l10n.profileSignIn;
    final subtitle = session.isAuthenticated
        ? (session.user?.email ?? session.user?.phone ?? '')
        : l10n.profileSignInHint;

    return CustomScrollView(
      slivers: [
        SliverPersistentHeader(
          pinned: true,
          delegate: _SHOProfileHeaderDelegate(
            topInset: topInset,
            session: session,
            displayName: displayName,
            subtitle: subtitle,
            theme: theme,
            backgroundColor: context.shoBackground,
            l10n: l10n,
            onMessages: () => context.push(SHOAppRoutes.messages),
            onSettings: () => context.push(SHOAppRoutes.settings),
            onLogin: () => context.push(SHOAppRoutes.login),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(SHOAppSpacing.pagePadding),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _SHOOrderShortcuts(
                title: l10n.profileOrders,
                items: [
                  _SHOOrderShortcutItem(
                    icon: Icons.receipt_long_outlined,
                    label: l10n.ordersAllShort,
                    onTap: () {
                      if (!SHOAuthGuard.requireAuth(context, ref)) {
                        return;
                      }
                      context.push(SHOAppRoutes.orders);
                    },
                  ),
                  _SHOOrderShortcutItem(
                    icon: Icons.payment_outlined,
                    label: l10n.ordersPendingPayment,
                    onTap: () {
                      final route = SHOAppRoutes.ordersFiltered('pending_payment');
                      if (!SHOAuthGuard.requireAuth(context, ref)) {
                        return;
                      }
                      context.push(route);
                    },
                  ),
                  _SHOOrderShortcutItem(
                    icon: Icons.local_shipping_outlined,
                    label: l10n.ordersShipped,
                    onTap: () {
                      final route = SHOAppRoutes.ordersFiltered('shipped');
                      if (!SHOAuthGuard.requireAuth(context, ref)) {
                        return;
                      }
                      context.push(route);
                    },
                  ),
                  _SHOOrderShortcutItem(
                    icon: Icons.rate_review_outlined,
                    label: l10n.ordersReviews,
                    onTap: () {
                      final route = SHOAppRoutes.ordersFiltered('delivered');
                      if (!SHOAuthGuard.requireAuth(context, ref)) {
                        return;
                      }
                      context.push(route);
                    },
                  ),
                ],
              ),
              const SizedBox(height: SHOAppSpacing.xl),
              _SHOMenuSection(
                title: l10n.profileServices,
                items: [
                  l10n.profileShareDemo,
                  l10n.profileCoupons,
                  l10n.profileAfterSales,
                ],
                onItemTap: (item) {
                  if (item == l10n.profileCoupons) {
                    if (!SHOAuthGuard.requireAuth(context, ref)) {
                      return;
                    }
                    context.push(SHOAppRoutes.coupons);
                  } else if (item == l10n.profileAfterSales) {
                    if (!SHOAuthGuard.requireAuth(context, ref)) {
                      return;
                    }
                    context.push(SHOAppRoutes.afterSales);
                  } else if (item == l10n.profileShareDemo) {
                    SHOSharePanel.show(
                      context,
                      ref,
                      title: l10n.appName,
                      link: 'https://shoo.app',
                    );
                  }
                },
              ),
              const SizedBox(height: SHOAppSpacing.xxxl),
            ]),
          ),
        ),
      ],
    );
  }
}

class _SHOProfileHeaderDelegate extends SliverPersistentHeaderDelegate {
  _SHOProfileHeaderDelegate({
    required this.topInset,
    required this.session,
    required this.displayName,
    required this.subtitle,
    required this.theme,
    required this.backgroundColor,
    required this.l10n,
    required this.onMessages,
    required this.onSettings,
    required this.onLogin,
  });

  final double topInset;
  final SHOSessionState session;
  final String displayName;
  final String subtitle;
  final SHOAppThemeColors theme;
  final Color backgroundColor;
  final AppLocalizations l10n;
  final VoidCallback onMessages;
  final VoidCallback onSettings;
  final VoidCallback onLogin;

  static const expandedHeight = SHOProfilePage._headerExpandedHeight;

  @override
  double get maxExtent => expandedHeight;

  @override
  double get minExtent => topInset + kToolbarHeight;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final shrinkRange = maxExtent - minExtent;
    final progress = shrinkRange <= 0
        ? 1.0
        : (shrinkOffset / shrinkRange).clamp(0.0, 1.0);
    final t = (1 - progress).clamp(0.0, 1.0);

    const collapsedAvatarRadius = 16.0;
    const expandedAvatarRadius = 36.0;
    final avatarRadius = lerpDouble(collapsedAvatarRadius, expandedAvatarRadius, t)!;
    final nameSize = lerpDouble(14, 18, t)!;
    final left = lerpDouble(16, 20, t)!;
    const expandedRowExtra = 46.0;
    const expandedRowHeight = expandedAvatarRadius * 2 + expandedRowExtra;
    final toolbarBottom = topInset + kToolbarHeight;
    final bodyHeight = maxExtent - toolbarBottom;
    final collapsedTop =
        topInset + (kToolbarHeight - collapsedAvatarRadius * 2) / 2;
    final expandedTop = toolbarBottom + (bodyHeight - expandedRowHeight) / 2;
    final avatarTop = lerpDouble(collapsedTop, expandedTop, t)!;
    final nameGap = lerpDouble(8, 14, t)!;
    final collapsedName = displayName;
    final expandedName = session.isAuthenticated
        ? l10n.welcomeUser(displayName)
        : displayName;
    final nameText = t > 0.35 ? expandedName : collapsedName;

    return Material(
      color: theme.profileHeaderEnd,
      child: Stack(
        clipBehavior: Clip.hardEdge,
        fit: StackFit.expand,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.profileHeaderStart,
                  theme.profileHeaderEnd,
                  backgroundColor,
                ],
                stops: const [0.0, 0.55, 1.0],
              ),
            ),
          ),
          Positioned(
            top: topInset,
            right: 4,
            height: kToolbarHeight,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications_none_rounded),
                  tooltip: l10n.profileMessages,
                  color: Colors.white,
                  onPressed: onMessages,
                ),
                IconButton(
                  icon: const Icon(Icons.settings_outlined),
                  tooltip: l10n.profileSettings,
                  color: Colors.white,
                  onPressed: onSettings,
                ),
              ],
            ),
          ),
          Positioned(
            left: left,
            top: avatarTop,
            right: 96,
            child: GestureDetector(
              onTap: session.isAuthenticated ? null : onLogin,
              behavior: HitTestBehavior.opaque,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _SHOProfileAvatar(session: session, radius: avatarRadius),
                  SizedBox(width: nameGap),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          nameText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: nameSize,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.3,
                            height: 1.2,
                          ),
                        ),
                        ClipRect(
                          child: Align(
                            alignment: Alignment.topLeft,
                            heightFactor: t.clamp(0.0, 1.0),
                            child: Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                subtitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.78),
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!session.isAuthenticated && t > 0.5)
                    const Icon(
                      Icons.chevron_right,
                      color: Colors.white70,
                      size: 20,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _SHOProfileHeaderDelegate old) {
    return old.session != session ||
        old.displayName != displayName ||
        old.subtitle != subtitle ||
        old.topInset != topInset;
  }
}

class _SHOProfileAvatar extends StatelessWidget {
  const _SHOProfileAvatar({
    required this.session,
    required this.radius,
  });

  final SHOSessionState session;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.white24,
      backgroundImage: session.user?.avatarUrl != null
          ? NetworkImage(session.user!.avatarUrl!)
          : null,
      child: session.user?.avatarUrl == null
          ? Icon(Icons.person, color: Colors.white, size: radius)
          : null,
    );
  }
}

class _SHOOrderShortcutItem {
  const _SHOOrderShortcutItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
}

class _SHOOrderShortcuts extends StatelessWidget {
  const _SHOOrderShortcuts({
    required this.title,
    required this.items,
  });

  final String title;
  final List<_SHOOrderShortcutItem> items;

  @override
  Widget build(BuildContext context) {
    final theme = context.shoTheme;

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
        DecoratedBox(
          decoration: BoxDecoration(
            color: context.shoSurface,
            borderRadius: BorderRadius.circular(SHOAppSpacing.cardRadius),
            border: Border.all(color: theme.border),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: SHOAppSpacing.lg),
            child: Row(
              children: items
                  .map(
                    (item) => Expanded(
                      child: InkWell(
                        onTap: item.onTap,
                        borderRadius: BorderRadius.circular(SHOAppSpacing.cardRadius),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(item.icon, size: 24),
                            const SizedBox(height: SHOAppSpacing.xs),
                            Text(
                              item.label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
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
    final theme = context.shoTheme;

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
        DecoratedBox(
          decoration: BoxDecoration(
            color: context.shoSurface,
            borderRadius: BorderRadius.circular(SHOAppSpacing.cardRadius),
            border: Border.all(color: theme.border),
          ),
          child: Column(
            children: [
              for (var i = 0; i < items.length; i++) ...[
                if (i > 0) Divider(height: 1, color: theme.divider, indent: 16),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: SHOAppSpacing.lg),
                  dense: true,
                  title: Text(
                    items[i],
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 13),
                  ),
                  trailing: Icon(
                    Icons.chevron_right,
                    size: 18,
                    color: theme.textMuted,
                  ),
                  onTap: onItemTap != null ? () => onItemTap!(items[i]) : null,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
