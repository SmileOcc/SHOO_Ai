import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/hos_routes.dart';
import '../../../core/theme/hos_spacing.dart';
import '../../../core/theme/hos_theme_extension.dart';
import '../../../features/auth/presentation/hos_session_provider.dart'
    show SHOSessionState, sessionProvider;
import '../../../l10n/app_localizations.dart';
import 'hos_profile_controller.dart';
import 'hos_profile_discovery_section.dart';
import 'hos_profile_order_hub.dart';

class SHOProfilePage extends ConsumerStatefulWidget {
  const SHOProfilePage({super.key});

  static const _headerExpandedHeight = 240.0;

  @override
  ConsumerState<SHOProfilePage> createState() => _SHOProfilePageState();
}

class _SHOProfilePageState extends ConsumerState<SHOProfilePage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabChanged);
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChanged() {
    if (_tabController.indexIsChanging) return;
    final next = SHOProfileFeedTab.values[_tabController.index];
    if (ref.read(profileFeedTabProvider) != next) {
      ref.read(profileFeedTabProvider.notifier).state = next;
    }
  }

  void _syncTabFromProvider(SHOProfileFeedTab tab) {
    final index = SHOProfileFeedTab.values.indexOf(tab);
    if (_tabController.index != index) {
      _tabController.animateTo(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<SHOProfileFeedTab>(profileFeedTabProvider, (_, next) {
      _syncTabFromProvider(next);
    });

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

    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) => [
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
          padding: const EdgeInsets.fromLTRB(
            SHOAppSpacing.pagePadding,
            SHOAppSpacing.pagePadding,
            SHOAppSpacing.pagePadding,
            0,
          ),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const SHOProfileOrderHub(),
              const SizedBox(height: SHOAppSpacing.lg),
              const SHOProfileServiceHub(),
              const SizedBox(height: SHOAppSpacing.lg),
              const SHOProfileCouponStrip(),
              const SizedBox(height: SHOAppSpacing.lg),
            ]),
          ),
        ),
        SliverPersistentHeader(
          pinned: true,
          delegate: _SHOProfileTabBarDelegate(
            tabController: _tabController,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          ),
        ),
      ],
      body: TabBarView(
        controller: _tabController,
        children: SHOProfileFeedTab.values
            .map(
              (tab) => CustomScrollView(
                key: PageStorageKey<String>('profile_feed_${tab.name}'),
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      SHOAppSpacing.pagePadding,
                      SHOAppSpacing.lg,
                      SHOAppSpacing.pagePadding,
                      SHOAppSpacing.xxxl,
                    ),
                    sliver: buildProfileFeedSliver(ref, context, tab),
                  ),
                ],
              ),
            )
            .toList(),
      ),
    );
  }
}

class _SHOProfileTabBarDelegate extends SliverPersistentHeaderDelegate {
  _SHOProfileTabBarDelegate({
    required this.tabController,
    required this.backgroundColor,
  });

  final TabController tabController;
  final Color backgroundColor;

  @override
  double get minExtent => 44;

  @override
  double get maxExtent => 44;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return ColoredBox(
      color: backgroundColor,
      child: SHOProfileFeedTabBar(controller: tabController),
    );
  }

  @override
  bool shouldRebuild(covariant _SHOProfileTabBarDelegate oldDelegate) =>
      oldDelegate.tabController != tabController ||
      oldDelegate.backgroundColor != backgroundColor;
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
