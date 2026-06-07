import 'package:flutter/material.dart';

import '../theme/hos_colors.dart';

/// 个人中心数字角标（红底白字）。
class SHOProfileBadge extends StatelessWidget {
  const SHOProfileBadge({
    super.key,
    required this.text,
    this.compact = false,
  });

  final String text;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        minWidth: compact ? 14 : 16,
        minHeight: compact ? 14 : 16,
      ),
      padding: EdgeInsets.symmetric(horizontal: compact ? 3 : 4),
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: SHOAppColors.accent,
        shape: BoxShape.circle,
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontSize: compact ? 8 : 9,
          fontWeight: FontWeight.w700,
          height: 1,
        ),
      ),
    );
  }
}
