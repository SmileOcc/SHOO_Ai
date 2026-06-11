import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/hos_routes.dart';
import '../../../core/theme/hos_spacing.dart';
import '../../../core/theme/hos_theme_extension.dart';
import '../../../core/widgets/hos_profile_section_card.dart';
import '../../../l10n/app_localizations.dart';

class SHOToolboxPage extends StatelessWidget {
  const SHOToolboxPage({super.key});

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
        title: l10n.toolboxGroupTools,
        items: [
          _ToolboxMenuItem(
            icon: Icons.download_outlined,
            color: const Color(0xFF4A90E2),
            label: l10n.toolboxFileDownload,
            onTap: () => context.push(SHOAppRoutes.toolboxDownloads),
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

    return Scaffold(
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
