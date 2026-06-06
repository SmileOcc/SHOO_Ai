import 'package:flutter/material.dart';

import '../theme/hos_spacing.dart';

/// 浮层圆形半透明按钮，用于商品详情等沉浸式顶图场景。
class SHOCircleOverlayButton extends StatelessWidget {
  const SHOCircleOverlayButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.tooltip,
    this.size = 40,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final double size;

  @override
  Widget build(BuildContext context) {
    final button = Material(
      color: Colors.black.withValues(alpha: 0.38),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );

    if (tooltip == null) return button;
    return Tooltip(message: tooltip!, child: button);
  }
}

/// 带数字角标的浮层圆形按钮。
class SHOCircleOverlayBadgeButton extends StatelessWidget {
  const SHOCircleOverlayBadgeButton({
    super.key,
    required this.icon,
    this.badge,
    this.onPressed,
    this.tooltip,
    this.size = 40,
  });

  final IconData icon;
  final int? badge;
  final VoidCallback? onPressed;
  final String? tooltip;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        SHOCircleOverlayButton(
          icon: icon,
          onPressed: onPressed,
          tooltip: tooltip,
          size: size,
        ),
        if (badge != null && badge! > 0)
          Positioned(
            right: -2,
            top: -2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.error,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white, width: 1.2),
              ),
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
              child: Text(
                badge! > 99 ? '99+' : '$badge',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  height: 1.1,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// 底部栏图标+文字入口（客服等）。
class SHOFooterIconAction extends StatelessWidget {
  const SHOFooterIconAction({
    super.key,
    required this.icon,
    required this.label,
    this.badge,
    this.onPressed,
  });

  final IconData icon;
  final String label;
  final int? badge;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(SHOAppSpacing.sm),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: SHOAppSpacing.xs),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(icon, size: 22),
                if (badge != null && badge! > 0)
                  Positioned(
                    right: -8,
                    top: -6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.error,
                        borderRadius: BorderRadius.circular(8),
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
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}
