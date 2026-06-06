import 'package:flutter/material.dart';

import '../theme/hos_colors.dart';

/// 骨架屏基础块，带渐变闪烁动画。
///
/// ```dart
/// const SHOSkeletonBox(height: 140)
/// const SHOProductCardSkeleton()  // 商品卡专用骨架
/// ```
class SHOSkeletonBox extends StatefulWidget {
  const SHOSkeletonBox({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
  });

  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  @override
  State<SHOSkeletonBox> createState() => _SHOSkeletonBoxState();
}

class _SHOSkeletonBoxState extends State<SHOSkeletonBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius,
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                SHOAppColors.skeletonBase,
                Color.lerp(
                  SHOAppColors.skeletonBase,
                  SHOAppColors.skeletonHighlight,
                  _controller.value,
                )!,
                SHOAppColors.skeletonBase,
              ],
            ),
          ),
        );
      },
    );
  }
}

class SHOProductCardSkeleton extends StatelessWidget {
  const SHOProductCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(aspectRatio: 4 / 5, child: SHOSkeletonBox()),
        SizedBox(height: 6),
        SHOSkeletonBox(height: 10, width: double.infinity),
        SizedBox(height: 4),
        SHOSkeletonBox(height: 10, width: 80),
      ],
    );
  }
}
