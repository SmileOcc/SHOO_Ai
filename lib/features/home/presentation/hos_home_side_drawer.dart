import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/hos_routes.dart';
import '../../../core/auth/hos_auth_guard.dart';
import '../../../core/theme/hos_colors.dart';
import '../../../core/theme/hos_spacing.dart';
import '../../../core/theme/hos_theme_extension.dart';
import '../../../features/auth/presentation/hos_session_provider.dart';
import '../../../l10n/app_localizations.dart';

/// 首页侧拉栏开关。
final homeSideDrawerOpenProvider = StateProvider<bool>((ref) => false);

void openHomeSideDrawer(WidgetRef ref) {
  ref.read(homeSideDrawerOpenProvider.notifier).state = true;
}

void closeHomeSideDrawer(WidgetRef ref) {
  ref.read(homeSideDrawerOpenProvider.notifier).state = false;
}

/// 飞书风格左侧滑出面板宿主：遮罩 + 侧栏动画，点击遮罩或系统返回关闭。
class SHOHomeSideDrawerHost extends ConsumerWidget {
  const SHOHomeSideDrawerHost({super.key, required this.child});

  final Widget child;

  static const _animDuration = Duration(milliseconds: 280);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOpen = ref.watch(homeSideDrawerOpenProvider);
    final panelWidth = math.min(MediaQuery.sizeOf(context).width * 0.82, 320.0);

    return PopScope(
      canPop: !isOpen,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && isOpen) closeHomeSideDrawer(ref);
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          child,
          Positioned.fill(
            child: IgnorePointer(
              ignoring: !isOpen,
              child: AnimatedOpacity(
                opacity: isOpen ? 1 : 0,
                duration: _animDuration,
                curve: Curves.easeOut,
                child: GestureDetector(
                  onTap: () => closeHomeSideDrawer(ref),
                  child: Container(color: Colors.black.withValues(alpha: 0.42)),
                ),
              ),
            ),
          ),
          AnimatedPositioned(
            duration: _animDuration,
            curve: Curves.easeOutCubic,
            top: 0,
            bottom: 0,
            left: isOpen ? 0 : -panelWidth,
            width: panelWidth,
            child: Material(
              elevation: 18,
              shadowColor: Colors.black.withValues(alpha: 0.28),
              color: Theme.of(context).scaffoldBackgroundColor,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.horizontal(
                  right: Radius.circular(18),
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: SHOHomeSideDrawerPanel(
                onClose: () => closeHomeSideDrawer(ref),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SHOHomeSideDrawerPanel extends ConsumerWidget {
  const SHOHomeSideDrawerPanel({super.key, required this.onClose});

  final VoidCallback onClose;

  void _navigate(BuildContext context, WidgetRef ref, VoidCallback action) {
    onClose();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) action();
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final session = ref.watch(sessionProvider);
    final theme = context.shoTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final displayName = session.isAuthenticated
        ? session.user!.nickname
        : l10n.profileSignIn;
    final subtitle = session.isAuthenticated
        ? (session.user?.email ?? session.user?.phone ?? l10n.tabMe)
        : l10n.profileSignInHint;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _DrawerHeader(
          displayName: displayName,
          subtitle: subtitle,
          isAuthenticated: session.isAuthenticated,
          theme: theme,
          isDark: isDark,
          l10n: l10n,
          onClose: onClose,
          onProfileTap: () =>
              _navigate(context, ref, () => context.go(SHOAppRoutes.profile)),
          onLoginTap: () =>
              _navigate(context, ref, () => context.push(SHOAppRoutes.login)),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              SHOAppSpacing.lg,
              SHOAppSpacing.md,
              SHOAppSpacing.lg,
              SHOAppSpacing.xxxl,
            ),
            children: [
              _SectionLabel(l10n.homeSideDrawerQuickSection),
              _DrawerMenuTile(
                icon: Icons.receipt_long_outlined,
                label: l10n.profileOrders,
                onTap: () => _navigate(context, ref, () {
                  if (!SHOAuthGuard.requireAuth(context, ref)) return;
                  context.push(SHOAppRoutes.orders);
                }),
              ),
              _DrawerMenuTile(
                icon: Icons.mail_outline_rounded,
                label: l10n.profileMessages,
                onTap: () => _navigate(
                  context,
                  ref,
                  () => context.push(SHOAppRoutes.messages),
                ),
              ),
              _DrawerMenuTile(
                icon: Icons.search_rounded,
                label: l10n.profileServiceSearch,
                onTap: () => _navigate(
                  context,
                  ref,
                  () => context.push(SHOAppRoutes.search),
                ),
              ),
              _DrawerMenuTile(
                icon: Icons.person_outline_rounded,
                label: l10n.tabMe,
                onTap: () => _navigate(
                  context,
                  ref,
                  () => context.go(SHOAppRoutes.profile),
                ),
              ),
              const SizedBox(height: SHOAppSpacing.lg),
              _SectionLabel(l10n.homeSideDrawerToolsSection),
              _DrawerMenuTile(
                icon: Icons.menu_book_outlined,
                label: l10n.profileServiceNovelReading,
                onTap: () => _navigate(
                  context,
                  ref,
                  () => context.push(SHOAppRoutes.profileBookshelf),
                ),
              ),
              _DrawerMenuTile(
                icon: Icons.play_circle_outline_rounded,
                label: l10n.profileServiceVideoPlayback,
                onTap: () => _navigate(
                  context,
                  ref,
                  () => context.push(SHOAppRoutes.profileVideoLibrary),
                ),
              ),
              _DrawerMenuTile(
                icon: Icons.apps_rounded,
                label: l10n.profileServiceToolbox,
                onTap: () => _navigate(
                  context,
                  ref,
                  () => context.push(SHOAppRoutes.toolbox),
                ),
              ),
              const SizedBox(height: SHOAppSpacing.lg),
              _SectionLabel(l10n.profileServices),
              _DrawerMenuTile(
                icon: Icons.confirmation_number_outlined,
                label: l10n.profileServiceCoupons,
                onTap: () => _navigate(context, ref, () {
                  if (!SHOAuthGuard.requireAuth(context, ref)) return;
                  context.push(SHOAppRoutes.coupons);
                }),
              ),
              _DrawerMenuTile(
                icon: Icons.support_agent_outlined,
                label: l10n.profileServiceAfterSale,
                onTap: () => _navigate(context, ref, () {
                  if (!SHOAuthGuard.requireAuth(context, ref)) return;
                  context.push(SHOAppRoutes.afterSales);
                }),
              ),
              _DrawerMenuTile(
                icon: Icons.settings_outlined,
                label: l10n.profileSettings,
                onTap: () => _navigate(
                  context,
                  ref,
                  () => context.push(SHOAppRoutes.settings),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DrawerHeader extends StatelessWidget {
  const _DrawerHeader({
    required this.displayName,
    required this.subtitle,
    required this.isAuthenticated,
    required this.theme,
    required this.isDark,
    required this.l10n,
    required this.onClose,
    required this.onProfileTap,
    required this.onLoginTap,
  });

  final String displayName;
  final String subtitle;
  final bool isAuthenticated;
  final SHOAppThemeColors theme;
  final bool isDark;
  final AppLocalizations l10n;
  final VoidCallback onClose;
  final VoidCallback onProfileTap;
  final VoidCallback onLoginTap;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;

    return ClipRRect(
      borderRadius: const BorderRadius.only(topRight: Radius.circular(18)),
      child: Stack(
        children: [
          Container(
            height: topInset + 132,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [theme.profileHeaderStart, theme.profileHeaderEnd],
              ),
            ),
          ),
          Positioned(
            left: SHOAppSpacing.lg,
            right: SHOAppSpacing.lg,
            top: topInset + SHOAppSpacing.xl,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: isAuthenticated ? onProfileTap : onLoginTap,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: SHOAppSpacing.xs,
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.white.withValues(alpha: 0.18),
                        child: Text(
                          displayName.isNotEmpty
                              ? displayName.characters.first.toUpperCase()
                              : 'S',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: SHOAppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              displayName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              subtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.72),
                                  ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: Colors.white.withValues(alpha: 0.72),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: SHOAppSpacing.lg,
            bottom: SHOAppSpacing.md,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: SHOAppSpacing.md,
                vertical: SHOAppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: SHOAppColors.accent.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.storefront_rounded,
                    size: 14,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    l10n.appName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: SHOAppSpacing.xs,
        bottom: SHOAppSpacing.sm,
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: context.shoTheme.textMuted,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class _DrawerMenuTile extends StatelessWidget {
  const _DrawerMenuTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: SHOAppSpacing.xs),
      child: Material(
        color: context.shoTheme.surfaceMuted.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: SHOAppSpacing.md,
              vertical: SHOAppSpacing.md,
            ),
            child: Row(
              children: [
                Icon(icon, size: 22, color: context.shoTheme.textSecondary),
                const SizedBox(width: SHOAppSpacing.md),
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
                  size: 20,
                  color: context.shoTheme.textMuted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
