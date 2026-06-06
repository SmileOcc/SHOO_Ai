import 'package:flutter/material.dart';

/// 屏幕断点常量，配合 [LayoutBuilder] / [MediaQuery] 做响应式布局。
///
/// 参考文章扩展建议：不同屏幕尺寸自动调整列数与间距。
abstract final class SHOAppBreakpoints {
  static const double mobile = 600;
  static const double tablet = 900;
  static const double desktop = 1200;
}

/// 响应式工具：根据屏宽返回列数、内边距等。
///
/// ```dart
/// SHOAppResponsive(
///   builder: (context, info) => GridView.builder(
///     gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
///       crossAxisCount: info.gridColumns,
///       crossAxisSpacing: info.spacing,
///     ),
///     itemBuilder: ...,
///   ),
/// )
/// ```
class SHOAppResponsive extends StatelessWidget {
  const SHOAppResponsive({
    super.key,
    required this.builder,
  });

  final Widget Function(BuildContext context, SHOResponsiveInfo info) builder;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final info = SHOResponsiveInfo.fromWidth(width);
        return builder(context, info);
      },
    );
  }
}

/// 响应式布局信息快照。
class SHOResponsiveInfo {
  const SHOResponsiveInfo({
    required this.width,
    required this.isMobile,
    required this.isTablet,
    required this.isDesktop,
    required this.gridColumns,
    required this.spacing,
    required this.pagePadding,
  });

  final double width;
  final bool isMobile;
  final bool isTablet;
  final bool isDesktop;
  final int gridColumns;
  final double spacing;
  final double pagePadding;

  factory SHOResponsiveInfo.fromWidth(double width) {
    if (width >= SHOAppBreakpoints.desktop) {
      return SHOResponsiveInfo(
        width: width,
        isMobile: false,
        isTablet: false,
        isDesktop: true,
        gridColumns: 4,
        spacing: 12,
        pagePadding: 16,
      );
    }
    if (width >= SHOAppBreakpoints.tablet) {
      return SHOResponsiveInfo(
        width: width,
        isMobile: false,
        isTablet: true,
        isDesktop: false,
        gridColumns: 3,
        spacing: 8,
        pagePadding: 12,
      );
    }
    return SHOResponsiveInfo(
      width: width,
      isMobile: true,
      isTablet: false,
      isDesktop: false,
      gridColumns: 2,
      spacing: 6,
      pagePadding: 10,
    );
  }
}

/// 快捷读取当前屏宽分类。
///
/// ```dart
/// final info = SHOResponsiveInfo.of(context);
/// if (info.isMobile) { ... }
/// ```
extension SHOResponsiveInfoContext on BuildContext {
  SHOResponsiveInfo get responsiveInfo {
    final width = MediaQuery.sizeOf(this).width;
    return SHOResponsiveInfo.fromWidth(width);
  }
}
