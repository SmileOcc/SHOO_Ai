import 'package:flutter/material.dart';

import 'hos_image_view.dart';

/// 网络图片快捷组件，底层使用 [SHOAppImage]。
class SHOAppNetworkImage extends StatelessWidget {
  const SHOAppNetworkImage({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.border,
    this.borderColor,
    this.borderWidth = 0,
    this.placeholder,
    this.placeholderAsset,
    this.memCacheWidth,
    this.width,
    this.height,
    this.showLoadingSkeleton = true,
  });

  final String url;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Border? border;
  final Color? borderColor;
  final double borderWidth;
  final Widget? placeholder;
  final String? placeholderAsset;
  final int? memCacheWidth;
  final double? width;
  final double? height;
  final bool showLoadingSkeleton;

  @override
  Widget build(BuildContext context) {
    return SHOAppImage(
      url: url,
      fit: fit,
      borderRadius: borderRadius,
      border: border,
      borderColor: borderColor,
      borderWidth: borderWidth,
      placeholder: placeholder,
      placeholderAsset: placeholderAsset,
      memCacheWidth: memCacheWidth,
      width: width,
      height: height,
      showLoadingSkeleton: showLoadingSkeleton,
    );
  }
}
