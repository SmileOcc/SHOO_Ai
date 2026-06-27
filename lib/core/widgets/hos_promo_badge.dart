import 'package:flutter/material.dart';

import 'package:shoo/core/theme/hos_colors.dart';
import 'package:shoo/core/theme/hos_spacing.dart';

/// 促销类型，后台 [type] 字段映射到此枚举。
enum SHOPromoBadgeType {
  discountPercent,
  discountFixed,
  discountFlash,
  discountMember,
  discountBundle,
  fullReductionTier,
  fullReductionSingle,
  fullReductionCross,
  fullReductionCategory,
  status,
}

extension SHOPromoBadgeTypeX on SHOPromoBadgeType {
  bool get isDiscount {
    switch (this) {
      case SHOPromoBadgeType.discountPercent:
      case SHOPromoBadgeType.discountFixed:
      case SHOPromoBadgeType.discountFlash:
      case SHOPromoBadgeType.discountMember:
      case SHOPromoBadgeType.discountBundle:
        return true;
      default:
        return false;
    }
  }

  bool get isFullReduction {
    switch (this) {
      case SHOPromoBadgeType.fullReductionTier:
      case SHOPromoBadgeType.fullReductionSingle:
      case SHOPromoBadgeType.fullReductionCross:
      case SHOPromoBadgeType.fullReductionCategory:
        return true;
      default:
        return false;
    }
  }

  static SHOPromoBadgeType fromApi(String? raw) {
    switch (raw) {
      case 'discount_percent':
        return SHOPromoBadgeType.discountPercent;
      case 'discount_fixed':
        return SHOPromoBadgeType.discountFixed;
      case 'discount_flash':
        return SHOPromoBadgeType.discountFlash;
      case 'discount_member':
        return SHOPromoBadgeType.discountMember;
      case 'discount_bundle':
        return SHOPromoBadgeType.discountBundle;
      case 'full_reduction_tier':
        return SHOPromoBadgeType.fullReductionTier;
      case 'full_reduction_single':
        return SHOPromoBadgeType.fullReductionSingle;
      case 'full_reduction_cross':
        return SHOPromoBadgeType.fullReductionCross;
      case 'full_reduction_category':
        return SHOPromoBadgeType.fullReductionCategory;
      default:
        return SHOPromoBadgeType.status;
    }
  }
}

/// 预设样式，禁止业务侧随意硬编码颜色。
enum SHOPromoBadgePreset {
  cornerOnImage,
  wrapTag,
  priceInline,
  overlayBanner,
}

class SHOPromoBadgeStyle {
  const SHOPromoBadgeStyle({
    required this.hasBackground,
    this.backgroundColor,
    this.textColor,
    this.fontSize = 10,
    this.fontWeight = FontWeight.w700,
    this.padding = const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    this.borderRadius = SHOAppSpacing.tagRadius,
    this.showBorder = false,
    this.borderColor,
  });

  final bool hasBackground;
  final Color? backgroundColor;
  final Color? textColor;
  final double fontSize;
  final FontWeight fontWeight;
  final EdgeInsets padding;
  final double borderRadius;
  final bool showBorder;
  final Color? borderColor;

  static SHOPromoBadgeStyle forPreset(
    SHOPromoBadgePreset preset, {
    required SHOPromoBadgeType type,
    bool enabled = true,
  }) {
    final base = _baseColors(type, enabled: enabled);
    switch (preset) {
      case SHOPromoBadgePreset.cornerOnImage:
        return SHOPromoBadgeStyle(
          hasBackground: true,
          backgroundColor: base.background,
          textColor: base.foreground,
          fontSize: 10,
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
          borderRadius: 4,
        );
      case SHOPromoBadgePreset.wrapTag:
        return SHOPromoBadgeStyle(
          hasBackground: true,
          backgroundColor: base.background.withValues(alpha: enabled ? 0.12 : 0.06),
          textColor: enabled ? base.background : SHOAppColors.textMuted,
          fontSize: 10,
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          borderRadius: SHOAppSpacing.tagRadius,
        );
      case SHOPromoBadgePreset.priceInline:
        return SHOPromoBadgeStyle(
          hasBackground: true,
          backgroundColor: base.background.withValues(alpha: 0.1),
          textColor: enabled ? base.background : SHOAppColors.textMuted,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
        );
      case SHOPromoBadgePreset.overlayBanner:
        return SHOPromoBadgeStyle(
          hasBackground: true,
          backgroundColor: Colors.black.withValues(alpha: 0.55),
          textColor: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          borderRadius: 0,
        );
    }
  }

  static ({Color background, Color foreground}) _baseColors(
    SHOPromoBadgeType type, {
    required bool enabled,
  }) {
    if (!enabled) {
      return (background: SHOAppColors.textMuted, foreground: Colors.white);
    }
    if (type.isDiscount) {
      return (background: const Color(0xFFFFB800), foreground: Colors.white);
    }
    if (type.isFullReduction) {
      return (background: SHOAppColors.accent, foreground: Colors.white);
    }
    return (background: SHOAppColors.textSecondary, foreground: Colors.white);
  }
}

/// 全 App 统一的折扣 / 满减 / 状态标识组件。
class SHOPromoBadge extends StatelessWidget {
  const SHOPromoBadge({
    super.key,
    required this.type,
    required this.label,
    this.preset = SHOPromoBadgePreset.wrapTag,
    this.enabled = true,
    this.style,
  });

  final SHOPromoBadgeType type;
  final String label;
  final SHOPromoBadgePreset preset;
  final bool enabled;
  final SHOPromoBadgeStyle? style;

  @override
  Widget build(BuildContext context) {
    final resolved = style ??
        SHOPromoBadgeStyle.forPreset(preset, type: type, enabled: enabled);

    return Container(
      padding: resolved.padding,
      decoration: BoxDecoration(
        color: resolved.hasBackground ? resolved.backgroundColor : null,
        borderRadius: BorderRadius.circular(resolved.borderRadius),
        border: resolved.showBorder
            ? Border.all(color: resolved.borderColor ?? SHOAppColors.border)
            : null,
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: resolved.fontSize,
          fontWeight: resolved.fontWeight,
          color: resolved.textColor,
        ),
      ),
    );
  }
}

/// 活动标签 Wrap，最多 [maxTags] 个，自动换行。
class SHOPromoBadgeWrap extends StatelessWidget {
  const SHOPromoBadgeWrap({
    super.key,
    required this.tags,
    this.maxTags = 6,
    this.enabled = true,
    this.spacing = 4,
    this.runSpacing = 4,
  });

  final List<SHOPromoBadgeTagData> tags;
  final int maxTags;
  final bool enabled;
  final double spacing;
  final double runSpacing;

  @override
  Widget build(BuildContext context) {
    if (tags.isEmpty) return const SizedBox.shrink();

    final visible = tags.take(maxTags).toList();
    return Wrap(
      spacing: spacing,
      runSpacing: runSpacing,
      children: [
        for (final tag in visible)
          SHOPromoBadge(
            type: tag.type,
            label: tag.label,
            preset: SHOPromoBadgePreset.wrapTag,
            enabled: enabled && tag.enabled,
          ),
      ],
    );
  }
}

class SHOPromoBadgeTagData {
  const SHOPromoBadgeTagData({
    required this.type,
    required this.label,
    this.enabled = true,
  });

  final SHOPromoBadgeType type;
  final String label;
  final bool enabled;

  factory SHOPromoBadgeTagData.fromJson(Map<String, dynamic> json) {
    return SHOPromoBadgeTagData(
      type: SHOPromoBadgeTypeX.fromApi(json['type'] as String?),
      label: json['label'] as String? ?? '',
      enabled: json['enabled'] as bool? ?? true,
    );
  }
}
