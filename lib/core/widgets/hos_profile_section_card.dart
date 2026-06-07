import 'package:flutter/material.dart';

import '../theme/hos_spacing.dart';
import '../theme/hos_theme_extension.dart';

/// 个人中心模块卡片：圆角 + 0.5 描边。
class SHOProfileSectionCard extends StatelessWidget {
  const SHOProfileSectionCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(SHOAppSpacing.lg),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  static const double radius = 12;
  static const double borderWidth = 0.5;

  @override
  Widget build(BuildContext context) {
    final theme = context.shoTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.shoSurface,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: theme.border, width: borderWidth),
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}
