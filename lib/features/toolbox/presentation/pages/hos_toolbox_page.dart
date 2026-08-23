import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:shoo/app/router/hos_routes.dart';
import 'package:shoo/core/analytics/hos_page_analytics.dart';
import 'package:shoo/core/feedback/hos_toast.dart';
import 'package:shoo/core/pages/hos_pages.dart';
import 'package:shoo/core/platform/hybrid/hos_hybrid_bridge.dart';
import 'package:shoo/core/platform/native_components/hos_native_components_bridge.dart';
import 'package:shoo/core/theme/hos_spacing.dart';
import 'package:shoo/core/theme/hos_theme_extension.dart';
import 'package:shoo/core/widgets/hos_profile_section_card.dart';
import 'package:shoo/l10n/app_localizations.dart';

Future<void> _openNativeComponents(BuildContext context) async {
  if (!SHONativeComponentsBridge.isSupported) {
    context.showToast(
      AppLocalizations.of(context).toolboxNativeComponentsIosOnly,
    );
    return;
  }
  try {
    await SHONativeComponentsBridge.openHub();
  } catch (error) {
    if (context.mounted) {
      context.showToast(
        '${AppLocalizations.of(context).toolboxNativeComponents}: $error',
      );
    }
  }
}

Future<void> _openSActivity(BuildContext context) async {
  if (!SHOHybridBridge.isNativeActivitySupported) {
    context.showToast(AppLocalizations.of(context).toolboxSActivityIosOnly);
    return;
  }
  try {
    await SHOHybridBridge.openSActivity();
  } catch (error) {
    if (context.mounted) {
      context.showToast(
        '${AppLocalizations.of(context).toolboxSActivity}: $error',
      );
    }
  }
}

class SHOToolboxPage extends ConsumerStatefulWidget {
  const SHOToolboxPage({super.key});

  @override
  ConsumerState<SHOToolboxPage> createState() => _SHOToolboxPageState();
}

class _SHOToolboxPageState extends ConsumerState<SHOToolboxPage>
    with SHOPageRouteAnalyticsMixin, SHOAppPageMixin, SHOAppTrackedPageMixin {
  @override
  String get pageName => 'toolbox';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final groups = [
      _ToolboxGroup(
        title: l10n.toolboxGroupReading,
        items: [
          _ToolboxMenuItem(
            icon: Icons.menu_book_outlined,
            color: const Color(0xFFB8860B),
            label: l10n.toolboxBookshelf,
            onTap: () => context.push(SHOAppRoutes.profileBookshelf),
          ),
          _ToolboxMenuItem(
            icon: Icons.play_circle_outline,
            color: const Color(0xFF5C6BC0),
            label: l10n.toolboxVideoPlayback,
            onTap: () => context.push(SHOAppRoutes.profileVideoLibrary),
          ),
          _ToolboxMenuItem(
            icon: Icons.music_note_outlined,
            color: const Color(0xFFE57373),
            label: l10n.toolboxMusicPlayback,
            onTap: () => context.push(SHOAppRoutes.profileMusicLibrary),
          ),
        ],
      ),
      _ToolboxGroup(
        title: l10n.toolboxGroupLearning,
        items: [
          _ToolboxMenuItem(
            icon: Icons.school_outlined,
            color: const Color(0xFF42A5F5),
            label: l10n.toolboxStudy,
            onTap: () => context.push(SHOAppRoutes.toolboxStudy),
          ),
        ],
      ),
      _ToolboxGroup(
        title: l10n.toolboxGroupNative,
        items: [
          _ToolboxMenuItem(
            icon: Icons.widgets_outlined,
            color: const Color(0xFF00897B),
            label: l10n.toolboxNativeComponents,
            onTap: () => _openNativeComponents(context),
          ),
        ],
      ),
      _ToolboxGroup(
        title: l10n.toolboxGroupTools,
        items: [
          _ToolboxMenuItem(
            icon: Icons.bolt_outlined,
            color: const Color(0xFFFF4657),
            label: l10n.toolboxFlashSale,
            onTap: () => context.push(SHOAppRoutes.flashSale),
          ),
          _ToolboxMenuItem(
            icon: Icons.local_fire_department_outlined,
            color: const Color(0xFFFF7043),
            label: l10n.toolboxThemeActivity,
            onTap: () => context.push(SHOAppRoutes.toolboxThemeActivity),
          ),
          _ToolboxMenuItem(
            icon: Icons.contacts_outlined,
            color: const Color(0xFF1E88E5),
            label: l10n.toolboxContacts,
            onTap: () => context.push(SHOAppRoutes.toolboxContacts),
          ),
          _ToolboxMenuItem(
            icon: Icons.download_outlined,
            color: const Color(0xFF4A90E2),
            label: l10n.toolboxFileDownload,
            onTap: () => context.push(SHOAppRoutes.toolboxDownloads),
          ),
          _ToolboxMenuItem(
            icon: Icons.bug_report_outlined,
            color: const Color(0xFFEF6C00),
            label: l10n.toolboxWebDebug,
            onTap: () => context.push(SHOAppRoutes.toolboxWebDebug),
          ),
          _ToolboxMenuItem(
            icon: Icons.language_outlined,
            color: const Color(0xFF26A69A),
            label: l10n.toolboxGeneralWeb,
            onTap: () => context.push(SHOAppRoutes.toolboxWeb),
          ),
          _ToolboxMenuItem(
            icon: Icons.web_outlined,
            color: const Color(0xFF7E57C2),
            label: l10n.toolboxWebViewActivity,
            onTap: () => context.push(SHOAppRoutes.activity),
          ),
          _ToolboxMenuItem(
            icon: Icons.hub_outlined,
            color: const Color(0xFF6A5ACD),
            label: l10n.toolboxSActivity,
            onTap: () => _openSActivity(context),
          ),
          _ToolboxMenuItem(
            icon: Icons.qr_code_scanner_outlined,
            color: const Color(0xFF7B61FF),
            label: l10n.toolboxComingSoon,
            onTap: () {},
          ),
          _ToolboxMenuItem(
            icon: Icons.calculate_outlined,
            color: const Color(0xFF2DBE7E),
            label: l10n.toolboxComingSoon,
            onTap: () {},
          ),
          _ToolboxMenuItem(
            icon: Icons.translate_outlined,
            color: const Color(0xFFFF8A3D),
            label: l10n.toolboxComingSoon,
            onTap: () {},
          ),
        ],
      ),
    ];

    return buildTrackedPage(
      Scaffold(
        appBar: AppBar(
          title: Text(
            l10n.toolboxTitle,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
        body: ListView.separated(
          padding: const EdgeInsets.all(SHOAppSpacing.pagePadding),
          itemCount: groups.length,
          separatorBuilder: (_, __) => const SizedBox(height: SHOAppSpacing.lg),
          itemBuilder: (context, index) {
            final group = groups[index];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    left: SHOAppSpacing.xs,
                    bottom: SHOAppSpacing.sm,
                  ),
                  child: Text(
                    group.title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                SHOProfileSectionCard(
                  padding: const EdgeInsets.symmetric(
                    horizontal: SHOAppSpacing.sm,
                    vertical: SHOAppSpacing.md,
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      const columns = 4;
                      final itemWidth = constraints.maxWidth / columns;
                      return Wrap(
                        spacing: 0,
                        runSpacing: SHOAppSpacing.md,
                        children: [
                          for (final item in group.items)
                            SizedBox(
                              width: itemWidth,
                              child: _ToolboxMenuButton(item: item),
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ToolboxGroup {
  const _ToolboxGroup({required this.title, required this.items});

  final String title;
  final List<_ToolboxMenuItem> items;
}

class _ToolboxMenuItem {
  const _ToolboxMenuItem({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;
}

class _ToolboxMenuButton extends StatelessWidget {
  const _ToolboxMenuButton({required this.item});

  final _ToolboxMenuItem item;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: item.onTap,
      borderRadius: BorderRadius.circular(SHOAppSpacing.cardRadius),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: SHOAppSpacing.xs),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: item.color.withValues(alpha: 0.18),
              child: Icon(item.icon, size: 20, color: item.color),
            ),
            const SizedBox(height: SHOAppSpacing.xs),
            Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: context.shoTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
