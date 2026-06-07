import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../storage/hos_image_cache_manager.dart';
import '../theme/hos_colors.dart';
import '../theme/hos_theme_extension.dart';
import 'hos_skeleton_box.dart';

/// 通用图片组件：支持网络/本地图、占位图、圆角、边框与填充模式。
///
/// 加载失败或 URL 为空时显示 [placeholder] / [placeholderAsset]，
/// 均未配置时使用内置默认空图。
///
/// ```dart
/// SHOAppImage(
///   url: product.imageUrl,
///   fit: BoxFit.cover,
///   borderRadius: BorderRadius.circular(8),
///   borderColor: theme.border,
///   borderWidth: 1,
///   placeholderAsset: 'assets/images/placeholder.png',
/// )
/// ```
class SHOAppImage extends StatelessWidget {
  const SHOAppImage({
    super.key,
    this.url,
    this.asset,
    this.placeholder,
    this.placeholderAsset,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.border,
    this.borderColor,
    this.borderWidth = 0,
    this.width,
    this.height,
    this.memCacheWidth,
    this.showLoadingSkeleton = true,
  });

  final String? url;
  final String? asset;
  final Widget? placeholder;
  final String? placeholderAsset;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Border? border;
  final Color? borderColor;
  final double borderWidth;
  final double? width;
  final double? height;
  final int? memCacheWidth;
  final bool showLoadingSkeleton;

  static Widget buildDefaultEmptyImage(BuildContext context) {
    final theme = context.shoTheme;
    return ColoredBox(
      color: theme.surfaceMuted,
      child: Center(
        child: Icon(
          Icons.image_outlined,
          size: 32,
          color: theme.textMuted,
        ),
      ),
    );
  }

  bool get _hasBorder =>
      border != null || (borderWidth > 0 && borderColor != null);

  Border? get _resolvedBorder {
    if (border != null) return border;
    if (borderWidth > 0 && borderColor != null) {
      return Border.all(color: borderColor!, width: borderWidth);
    }
    return null;
  }

  Widget _buildPlaceholder(BuildContext context) {
    if (placeholder != null) {
      return SizedBox(width: width, height: height, child: placeholder);
    }
    if (placeholderAsset != null && placeholderAsset!.isNotEmpty) {
      return Image.asset(
        placeholderAsset!,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, __, ___) => buildDefaultEmptyImage(context),
      );
    }
    return buildDefaultEmptyImage(context);
  }

  Widget _buildLoading(BuildContext context) {
    if (!showLoadingSkeleton) {
      return const SizedBox.shrink();
    }
    return const SHOSkeletonBox();
  }

  Widget _buildImage(BuildContext context) {
    final trimmedUrl = url?.trim();
    if (trimmedUrl != null && trimmedUrl.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: trimmedUrl,
        cacheManager: SHOImageCacheManager.instance,
        width: width,
        height: height,
        fit: fit,
        memCacheWidth: memCacheWidth,
        fadeInDuration: const Duration(milliseconds: 280),
        fadeOutDuration: const Duration(milliseconds: 120),
        progressIndicatorBuilder: (context, _, progress) => Stack(
          fit: StackFit.expand,
          children: [
            _buildLoading(context),
            if (progress.progress != null)
              Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    value: progress.progress,
                    color: SHOAppColors.accent,
                  ),
                ),
              ),
          ],
        ),
        errorWidget: (_, __, ___) => _buildPlaceholder(context),
      );
    }

    final trimmedAsset = asset?.trim();
    if (trimmedAsset != null && trimmedAsset.isNotEmpty) {
      return Image.asset(
        trimmedAsset,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, __, ___) => _buildPlaceholder(context),
      );
    }

    return _buildPlaceholder(context);
  }

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.zero;
    final content = SizedBox(
      width: width,
      height: height,
      child: _buildImage(context),
    );

    Widget result = ClipRRect(borderRadius: radius, child: content);

    if (_hasBorder) {
      result = DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: radius,
          border: _resolvedBorder,
        ),
        child: result,
      );
    }

    return result;
  }
}
