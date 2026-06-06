import 'package:flutter/material.dart';

import '../theme/hos_colors.dart';

/// Tab 角标：支持纯红点（dot）或数字角标（count）。
///
/// ```dart
/// SHOTabBadgeIcon(
///   icon: Icons.person_outline,
///   badge: SHOTabBadge(dot: true),       // 红点
///   badge: SHOTabBadge(count: 5),         // 数字
///   badge: SHOTabBadge(count: 120),       // 显示 99+
/// )
/// ```
class SHOTabBadge {
  const SHOTabBadge({this.count, this.dot = false});

  final int? count;
  final bool dot;

  bool get hasBadge => dot || (count != null && count! > 0);
}

class SHOTabBadgeIcon extends StatelessWidget {
  const SHOTabBadgeIcon({
    super.key,
    required this.icon,
    this.badge,
    this.iconSize = 22,
  });

  final IconData icon;
  final SHOTabBadge? badge;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final b = badge;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(icon, size: iconSize),
        if (b != null && b.hasBadge) Positioned(
          right: b.dot ? -2 : -6,
          top: -4,
          child: b.dot
              ? Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: SHOAppColors.accent,
                    shape: BoxShape.circle,
                  ),
                )
              : Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: const BoxDecoration(
                    color: SHOAppColors.accent,
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  child: Text(
                    (b.count ?? 0) > 99 ? '99+' : '${b.count}',
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
