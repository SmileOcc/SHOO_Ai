import 'package:flutter/material.dart';

import '../../../core/theme/hos_colors.dart';
import '../../../core/theme/hos_spacing.dart';
import '../../../core/theme/hos_theme_extension.dart';
import '../../../core/widgets/hos_network_image.dart';
import '../../../core/widgets/hos_price_text.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/hos_profile_activity_product.dart';

class SHOProfileActivityProductTile extends StatelessWidget {
  const SHOProfileActivityProductTile({
    super.key,
    required this.item,
    required this.editing,
    required this.selected,
    required this.onTap,
    required this.onToggleSelect,
  });

  final SHOProfileActivityProduct item;
  final bool editing;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onToggleSelect;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.shoTheme;
    final unavailable = !item.available;

    return Opacity(
      opacity: unavailable ? 0.45 : 1,
      child: Material(
        color: context.shoSurface,
        child: InkWell(
          onTap: editing ? onToggleSelect : (unavailable ? null : onTap),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: SHOAppSpacing.pagePadding,
              vertical: SHOAppSpacing.md,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (editing) ...[
                  Checkbox(
                    value: selected,
                    onChanged: (_) => onToggleSelect(),
                    activeColor: SHOAppColors.accent,
                  ),
                  const SizedBox(width: SHOAppSpacing.xs),
                ],
                ClipRRect(
                  borderRadius: BorderRadius.circular(SHOAppSpacing.cardRadius),
                  child: SizedBox(
                    width: 88,
                    height: 88,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (item.product.imageUrl.isNotEmpty)
                          SHOAppNetworkImage(
                            url: item.product.imageUrl,
                            fit: BoxFit.cover,
                            memCacheWidth: 176,
                          )
                        else
                          ColoredBox(color: theme.surfaceMuted),
                        if (unavailable)
                          Container(
                            color: Colors.black.withValues(alpha: 0.45),
                            alignment: Alignment.center,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: SHOAppSpacing.md,
                                vertical: SHOAppSpacing.xs,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.55),
                                borderRadius:
                                    BorderRadius.circular(SHOAppSpacing.cardRadius),
                              ),
                              child: Text(
                                l10n.cartItemUnavailable,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: SHOAppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.product.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontSize: 13,
                              height: 1.25,
                            ),
                      ),
                      const SizedBox(height: SHOAppSpacing.sm),
                      if (item.available)
                        SHOAppPriceText(
                          priceCents: item.product.price,
                          originalCents: item.product.originalPrice,
                          size: SHOAppPriceSize.small,
                        )
                      else
                        Text(
                          l10n.cartItemUnavailable,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: SHOAppColors.error,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                    ],
                  ),
                ),
                if (!editing && item.available)
                  Icon(
                    Icons.chevron_right,
                    color: theme.textMuted,
                    size: 20,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
