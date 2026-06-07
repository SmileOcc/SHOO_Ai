import 'package:flutter/material.dart';

import '../theme/hos_colors.dart';
import '../theme/hos_spacing.dart';
import '../theme/hos_theme_extension.dart';
import '../theme/hos_typography.dart';

/// 按钮变体：覆盖填充 / 描边 / 文字 / 幽灵 / 促销强调 5 种样式。
enum SHOAppButtonVariant {
  /// 主色填充（默认）
  primary,
  /// 促销强调色填充（Shein 红）
  accent,
  /// 描边按钮
  outline,
  /// 纯文字按钮
  text,
  /// 浅色背景幽灵按钮
  ghost,
}

/// 按钮尺寸：sm(32) / md(40) / lg(48)，对应文章 3 档尺寸设计。
enum SHOAppButtonSize { sm, md, lg }

/// 统一按钮组件。
///
/// 参考《5步搭建Flutter UI组件库》：3 尺寸 × 多变体 + 内置 loading，
/// 避免页面层重复写 Container + GestureDetector。
///
/// ```dart
/// // 提交按钮（带 loading）
/// SHOAppButton(
///   label: 'Checkout',
///   onPressed: _submit,
///   variant: SHOAppButtonVariant.accent,
///   isLoading: _isSubmitting,
///   fullWidth: true,
/// )
///
/// // 取消按钮
/// SHOAppButton(
///   label: 'Cancel',
///   onPressed: () => Navigator.pop(context),
///   variant: SHOAppButtonVariant.outline,
///   size: SHOAppButtonSize.sm,
/// )
///
/// // 带图标
/// SHOAppButton(
///   label: 'Add to Bag',
///   icon: const Icon(Icons.shopping_bag_outlined, size: 16),
///   onPressed: _addToCart,
/// )
/// ```
class SHOAppButton extends StatelessWidget {
  const SHOAppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = SHOAppButtonVariant.primary,
    this.size = SHOAppButtonSize.md,
    this.isLoading = false,
    this.icon,
    this.fullWidth = false,
    this.isExpanded = false,
    this.height,
  });

  final String label;
  final VoidCallback? onPressed;
  final SHOAppButtonVariant variant;
  final SHOAppButtonSize size;
  final bool isLoading;
  final Widget? icon;
  final bool fullWidth;

  /// 兼容旧 API，`isExpanded` 与 `fullWidth` 任一为 true 即全宽。
  final bool isExpanded;
  final double? height;

  double get _height => height ?? switch (size) {
        SHOAppButtonSize.sm => 32,
        SHOAppButtonSize.md => 40,
        SHOAppButtonSize.lg => 48,
      };

  EdgeInsets get _padding => switch (size) {
        SHOAppButtonSize.sm => const EdgeInsets.symmetric(horizontal: SHOAppSpacing.lg),
        SHOAppButtonSize.md => const EdgeInsets.symmetric(horizontal: SHOAppSpacing.xl),
        SHOAppButtonSize.lg => const EdgeInsets.symmetric(horizontal: SHOAppSpacing.xxl),
      };

  TextStyle get _textStyle => switch (size) {
        SHOAppButtonSize.sm => SHOAppTypography.textTheme.labelMedium!,
        SHOAppButtonSize.md => SHOAppTypography.textTheme.labelLarge!,
        SHOAppButtonSize.lg => SHOAppTypography.textTheme.titleMedium!,
      };

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null || isLoading;
    final borderRadius = BorderRadius.circular(
      size == SHOAppButtonSize.sm ? SHOAppSpacing.tagRadius : SHOAppSpacing.buttonRadius,
    );

    final scheme = Theme.of(context).colorScheme;
    final accentColor = variant == SHOAppButtonVariant.accent
        ? SHOAppColors.accent
        : SHOAppColors.primary;

    final contentColor = switch (variant) {
      SHOAppButtonVariant.primary || SHOAppButtonVariant.accent => SHOAppColors.textOnAccent,
      SHOAppButtonVariant.outline => scheme.onSurface,
      _ => accentColor,
    };

    final outlineBorderColor = disabled
        ? context.shoTheme.border
        : scheme.onSurface.withValues(alpha: 0.85);

    final buttonContent = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading)
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(contentColor),
            ),
          )
        else ...[
          if (icon != null) ...[
            IconTheme(
              data: IconThemeData(color: contentColor, size: 16),
              child: icon!,
            ),
            const SizedBox(width: SHOAppSpacing.xs),
          ],
          Text(label, style: _textStyle.copyWith(color: contentColor)),
        ],
      ],
    );

    final Widget styledButton = switch (variant) {
      SHOAppButtonVariant.primary || SHOAppButtonVariant.accent => Container(
          height: _height,
          decoration: BoxDecoration(
            color: disabled ? SHOAppColors.textMuted : accentColor,
            borderRadius: borderRadius,
          ),
          alignment: Alignment.center,
          padding: _padding,
          child: buttonContent,
        ),
      SHOAppButtonVariant.outline => Container(
          height: _height,
          decoration: BoxDecoration(
            border: Border.all(
              color: outlineBorderColor,
              width: 1,
            ),
            borderRadius: borderRadius,
          ),
          alignment: Alignment.center,
          padding: _padding,
          child: buttonContent,
        ),
      SHOAppButtonVariant.text => Padding(
          padding: _padding,
          child: DefaultTextStyle(
            style: _textStyle.copyWith(
              color: disabled ? SHOAppColors.textMuted : accentColor,
            ),
            child: buttonContent,
          ),
        ),
      SHOAppButtonVariant.ghost => Container(
          height: _height,
          decoration: BoxDecoration(
            color: disabled
                ? Colors.transparent
                : accentColor.withValues(alpha: 0.08),
            borderRadius: borderRadius,
          ),
          alignment: Alignment.center,
          padding: _padding,
          child: buttonContent,
        ),
    };

    final button = IgnorePointer(
      ignoring: disabled,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: disabled ? null : onPressed,
          borderRadius: borderRadius,
          child: styledButton,
        ),
      ),
    );

    return (fullWidth || isExpanded)
        ? SizedBox(width: double.infinity, child: button)
        : button;
  }
}

/// 带角标的图标按钮，适用于购物车、消息等 Tab/AppBar 区域。
///
/// ```dart
/// SHOAppIconButton(
///   icon: Icons.shopping_bag_outlined,
///   badge: cartCount,
///   onPressed: () => context.go('/cart'),
/// )
/// ```
class SHOAppIconButton extends StatelessWidget {
  const SHOAppIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.badge,
    this.size = 22,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final int? badge;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          onPressed: onPressed,
          icon: Icon(icon, size: size),
          padding: const EdgeInsets.all(SHOAppSpacing.sm),
          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
        ),
        if (badge != null && badge! > 0)
          Positioned(
            right: 4,
            top: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: const BoxDecoration(
                color: SHOAppColors.accent,
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
              child: Text(
                badge! > 99 ? '99+' : '$badge',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
