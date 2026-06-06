import 'package:flutter/material.dart';

import '../../features/category/domain/hos_category.dart';
import '../theme/hos_colors.dart';
import '../theme/hos_spacing.dart';

class SHOQuickEntryGrid extends StatelessWidget {
  const SHOQuickEntryGrid({
    super.key,
    required this.items,
    this.onTap,
  });

  final List<SHOCategoryItem> items;
  final void Function(SHOCategoryItem item)? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: SHOAppSpacing.pagePadding),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: SHOAppSpacing.md,
          crossAxisSpacing: SHOAppSpacing.sm,
          childAspectRatio: 0.85,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return GestureDetector(
            onTap: () => onTap?.call(item),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: SHOAppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(SHOAppSpacing.cardRadius),
                  ),
                  child: Text(item.icon, style: const TextStyle(fontSize: 20)),
                ),
                const SizedBox(height: SHOAppSpacing.xs),
                Text(
                  item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 10,
                        color: SHOAppColors.textPrimary,
                      ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
