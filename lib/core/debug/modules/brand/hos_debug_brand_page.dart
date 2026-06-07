import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../brand/hos_app_icon.dart';
import '../../../brand/hos_app_icon_style.dart';
import '../../../brand/hos_brand_config.dart';
import '../../../theme/hos_colors.dart';
import '../../../theme/hos_spacing.dart';
import '../../../widgets/hos_app_loading.dart';

/// Debug：预览并选择 SHOO App Icon 风格。
class SHODebugBrandPage extends ConsumerWidget {
  const SHODebugBrandPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(appIconStyleProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('SHOO Brand / Icon')),
      body: ListView(
        padding: const EdgeInsets.all(SHOAppSpacing.xl),
        children: [
          Text(
            '当前选中：${selected.labelZh} (${selected.label})',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: SHOAppSpacing.sm),
          Text(
            '应用名称：${SHOAppBrandConfig.displayName}。正式 Icon 已锁定为「经典方块」。',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: SHOAppSpacing.xxxl),
          Center(
            child: SHOAppLoading(
              size: 96,
              iconStyle: selected,
              showAppName: true,
            ),
          ),
          const SizedBox(height: SHOAppSpacing.xxxl),
          ...SHOAppIconStyle.values.map((style) {
            final isSelected = style == selected;
            return Padding(
              padding: const EdgeInsets.only(bottom: SHOAppSpacing.md),
              child: Material(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(SHOAppSpacing.cardRadius),
                child: InkWell(
                  borderRadius: BorderRadius.circular(SHOAppSpacing.cardRadius),
                  onTap: () => ref.read(appIconStyleProvider.notifier).select(style),
                  child: Container(
                    padding: const EdgeInsets.all(SHOAppSpacing.lg),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(SHOAppSpacing.cardRadius),
                      border: Border.all(
                        color: isSelected ? SHOAppColors.accent : SHOAppColors.border,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        SHOAppIcon(size: 52, style: style),
                        const SizedBox(width: SHOAppSpacing.lg),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                style.labelZh,
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                              const SizedBox(height: SHOAppSpacing.xs),
                              Text(
                                style.label,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          const Icon(Icons.check_circle, color: SHOAppColors.accent),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
