import 'package:flutter/material.dart';

import '../../../core/feedback/hos_toast.dart';
import '../../../core/theme/hos_colors.dart';
import '../../../core/theme/hos_spacing.dart';
import '../domain/hos_community_models.dart';

class SHOCommunityMenuBar extends StatelessWidget {
  const SHOCommunityMenuBar({
    super.key,
    required this.items,
  });

  final List<SHOCommunityMenuItem> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 88,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: SHOAppSpacing.pagePadding,
          vertical: SHOAppSpacing.md,
        ),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: SHOAppSpacing.lg),
        itemBuilder: (context, index) {
          final item = items[index];
          return _MenuChip(
            item: item,
            onTap: () => SHOAppToast.info('${item.label} 即将上线'),
          );
        },
      ),
    );
  }
}

class _MenuChip extends StatelessWidget {
  const _MenuChip({required this.item, required this.onTap});

  final SHOCommunityMenuItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tint = Color(item.tintArgb);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(SHOAppSpacing.cardRadius),
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: tint.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(SHOAppSpacing.cardRadius),
              ),
              alignment: Alignment.center,
              child: Text(item.icon, style: const TextStyle(fontSize: 20)),
            ),
            const SizedBox(height: SHOAppSpacing.xs),
            Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 10,
                color: SHOAppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
