import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/hos_colors.dart';
import '../../../core/theme/hos_spacing.dart';
import '../../../core/utils/hos_async_value_ui.dart';
import '../../../core/widgets/hos_error_view.dart';
import '../../../core/widgets/hos_empty_state.dart';
import '../../../core/widgets/hos_skeleton_box.dart';
import 'hos_category_controller.dart';

class SHOCategoryPage extends ConsumerWidget {
  const SHOCategoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return categoriesAsync.whenWidget(
      loading: ListView.builder(
        itemCount: 8,
        itemBuilder: (_, __) => const Padding(
          padding: EdgeInsets.all(SHOAppSpacing.pagePadding),
          child: SHOSkeletonBox(height: 48),
        ),
      ),
      error: (error, _) => SHOAppErrorView(
        message: error.toString(),
        onRetry: () => ref.invalidate(categoriesProvider),
      ),
      data: (categories) {
        if (categories.isEmpty) {
          return const SHOEmptyState(title: 'No categories yet');
        }

        return Row(
          children: [
            SizedBox(
              width: 96,
              child: ListView.builder(
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final item = categories[index];
                  final selected = index == 0;
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: SHOAppSpacing.md,
                      vertical: SHOAppSpacing.lg,
                    ),
                    color: selected ? SHOAppColors.surface : SHOAppColors.surfaceMuted,
                    child: Text(
                      item.name,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                        color: selected ? SHOAppColors.textPrimary : SHOAppColors.textSecondary,
                      ),
                    ),
                  );
                },
              ),
            ),
            const VerticalDivider(width: 0.5),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(SHOAppSpacing.pagePadding),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: SHOAppSpacing.lg,
                  crossAxisSpacing: SHOAppSpacing.lg,
                  childAspectRatio: 0.9,
                ),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final item = categories[index];
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: SHOAppColors.surfaceMuted,
                          borderRadius: BorderRadius.circular(SHOAppSpacing.cardRadius),
                        ),
                        child: Text(item.icon, style: const TextStyle(fontSize: 24)),
                      ),
                      const SizedBox(height: SHOAppSpacing.sm),
                      Text(
                        item.name,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontSize: 11,
                              color: SHOAppColors.textPrimary,
                            ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
