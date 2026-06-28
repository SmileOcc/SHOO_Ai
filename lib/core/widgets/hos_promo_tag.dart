import 'package:flutter/material.dart';

import 'package:shoo/core/theme/hos_colors.dart';
import 'package:shoo/core/theme/hos_spacing.dart';

class SHOPromoTag extends StatelessWidget {
  const SHOPromoTag({
    super.key,
    required this.label,
    this.color = SHOAppColors.sale,
    this.textColor = SHOAppColors.textOnAccent,
  });

  final String label;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(SHOAppSpacing.tagRadius),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: textColor,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

class SHOFlashTag extends StatelessWidget {
  const SHOFlashTag({super.key});

  @override
  Widget build(BuildContext context) {
    return const SHOPromoTag(label: 'FLASH', color: SHOAppColors.flash);
  }
}
