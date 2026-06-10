import 'package:flutter/material.dart';

import '../theme/hos_colors.dart';
import '../theme/hos_theme_extension.dart';

/// 个人中心数字角标。
class SHOProfileBadge extends StatelessWidget {
  const SHOProfileBadge({
    super.key,
    required this.text,
    this.compact = false,
    this.muted = false,
  });

  final String text;
  final bool compact;
  /// 弱化样式：浅底 + 次要文字色，用于足迹/收藏等统计数字。
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final theme = context.shoTheme;
    final background = muted ? theme.surfaceMuted : SHOAppColors.accent;
    final foreground = muted ? theme.textSecondary : Colors.white;
    final fontWeight = muted ? FontWeight.w600 : FontWeight.w700;

    return Container(
      constraints: BoxConstraints(
        minWidth: compact ? 14 : 16,
        minHeight: compact ? 14 : 16,
      ),
      padding: EdgeInsets.symmetric(horizontal: compact ? 3 : 4),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background,
        shape: BoxShape.circle,
        border: muted
            ? Border.all(color: theme.border.withValues(alpha: 0.9))
            : null,
      ),
      child: Text(
        text,
        style: TextStyle(
          color: foreground,
          fontSize: compact ? 8 : 9,
          fontWeight: fontWeight,
          height: 1,
        ),
      ),
    );
  }
}

/// 个人中心弱化文字角标（如「种草」旁标签）。
class SHOProfileMutedChipBadge extends StatelessWidget {
  const SHOProfileMutedChipBadge({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = context.shoTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: theme.surfaceMuted,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.border.withValues(alpha: 0.9)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: theme.textSecondary,
          fontSize: 9,
          fontWeight: FontWeight.w600,
          height: 1.1,
        ),
      ),
    );
  }
}
