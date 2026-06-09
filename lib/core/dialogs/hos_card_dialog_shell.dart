import 'package:flutter/material.dart';

import '../theme/hos_spacing.dart';
import '../theme/hos_theme_extension.dart';
import '../widgets/hos_profile_section_card.dart';

/// 圆角卡片弹窗外壳：右上角关闭 X。
class SHOCardDialogShell extends StatelessWidget {
  const SHOCardDialogShell({
    super.key,
    required this.child,
    required this.onClose,
    this.padding = const EdgeInsets.fromLTRB(
      SHOAppSpacing.xl,
      SHOAppSpacing.lg,
      SHOAppSpacing.xl,
      SHOAppSpacing.xl,
    ),
  });

  final Widget child;
  final VoidCallback onClose;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: context.shoSurface,
              borderRadius:
                  BorderRadius.circular(SHOProfileSectionCard.radius),
              border: Border.all(
                color: context.shoTheme.border,
                width: SHOProfileSectionCard.borderWidth,
              ),
            ),
            child: Padding(padding: padding, child: child),
          ),
          Positioned(
            top: SHOAppSpacing.sm,
            right: SHOAppSpacing.sm,
            child: IconButton(
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.close, size: 20),
              onPressed: onClose,
            ),
          ),
        ],
      ),
    );
  }
}
