import 'package:flutter/material.dart';

/// 横向模块条：用 [SingleChildScrollView] + [Row] 替代嵌套 [ListView]，
/// 避免放在 [CustomScrollView] 内时触发 Viewport 断言。
class SHOThemeHorizontalStrip extends StatelessWidget {
  const SHOThemeHorizontalStrip({
    super.key,
    required this.height,
    required this.children,
    this.padding,
  });

  final double height;
  final List<Widget> children;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: padding,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        ),
      ),
    );
  }
}
