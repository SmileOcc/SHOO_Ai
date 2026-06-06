import 'package:flutter/material.dart';

import '../theme/hos_colors.dart';
import '../utils/hos_price_formatter.dart';

class SHOAppPriceText extends StatelessWidget {
  const SHOAppPriceText({
    super.key,
    required this.priceCents,
    this.originalCents,
    this.size = SHOAppPriceSize.medium,
    this.showOriginal = true,
  });

  final int priceCents;
  final int? originalCents;
  final SHOAppPriceSize size;
  final bool showOriginal;

  @override
  Widget build(BuildContext context) {
    final priceStyle = switch (size) {
      SHOAppPriceSize.large => const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: SHOAppColors.sale,
        ),
      SHOAppPriceSize.medium => const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: SHOAppColors.sale,
        ),
      SHOAppPriceSize.small => const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: SHOAppColors.sale,
        ),
    };

    final originalStyle = TextStyle(
      fontSize: size == SHOAppPriceSize.large ? 12 : 10,
      color: SHOAppColors.textMuted,
      decoration: TextDecoration.lineThrough,
    );

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 4,
      children: [
        Text(priceFormatter.formatCents(priceCents), style: priceStyle),
        if (showOriginal && originalCents != null && originalCents! > priceCents)
          Text(priceFormatter.formatCents(originalCents!), style: originalStyle),
      ],
    );
  }
}

enum SHOAppPriceSize { small, medium, large }
