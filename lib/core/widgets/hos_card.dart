import 'package:flutter/material.dart';

import '../theme/hos_colors.dart';
import '../theme/hos_spacing.dart';

/// 统一卡片容器：固定圆角、内边距、可选点击。
///
/// 参考文章扩展建议：列表页 / 详情页复用同一卡片规范。
///
/// ```dart
/// SHOAppCard(
///   onTap: () => context.push('/product/$id'),
///   child: Column(
///     children: [
///       SHOAppNetworkImage(url: product.imageUrl),
///       Text(product.title),
///     ],
///   ),
/// )
///
/// // 无阴影扁平卡片（Shein 风格默认）
/// SHOAppCard(elevation: 0, padding: EdgeInsets.all(8), child: ...)
/// ```
class SHOAppCard extends StatelessWidget {
  const SHOAppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.color,
    this.elevation = 0,
    this.borderRadius,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final double elevation;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ??
        BorderRadius.circular(SHOAppSpacing.cardRadius);

    final content = Padding(
      padding: padding ?? const EdgeInsets.all(SHOAppSpacing.lg),
      child: child,
    );

    final card = Card(
      color: color ?? SHOAppColors.surface,
      elevation: elevation,
      margin: margin ?? EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: elevation == 0
            ? const BorderSide(color: SHOAppColors.border, width: 0.5)
            : BorderSide.none,
      ),
      child: content,
    );

    if (onTap == null) return card;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: card,
      ),
    );
  }
}
