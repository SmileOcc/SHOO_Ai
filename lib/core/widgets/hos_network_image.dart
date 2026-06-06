import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../storage/hos_image_cache_manager.dart';
import '../theme/hos_colors.dart';
import '../theme/hos_theme_extension.dart';
import 'hos_skeleton_box.dart';

class SHOAppNetworkImage extends StatelessWidget {
  const SHOAppNetworkImage({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.memCacheWidth,
  });

  final String url;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final int? memCacheWidth;

  @override
  Widget build(BuildContext context) {
    final muted = context.shoTheme.surfaceMuted;

    final image = CachedNetworkImage(
      imageUrl: url,
      cacheManager: SHOImageCacheManager.instance,
      fit: fit,
      memCacheWidth: memCacheWidth,
      fadeInDuration: const Duration(milliseconds: 280),
      fadeOutDuration: const Duration(milliseconds: 120),
      progressIndicatorBuilder: (context, url, progress) => Stack(
        fit: StackFit.expand,
        alignment: Alignment.center,
        children: [
          const SHOSkeletonBox(),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    muted.withValues(alpha: 0.3),
                    muted.withValues(alpha: 0.6),
                  ],
                ),
              ),
            ),
          ),
          if (progress.progress != null)
            SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                value: progress.progress,
              ),
            ),
        ],
      ),
      errorWidget: (_, __, ___) => ColoredBox(
        color: muted,
        child: Center(
          child: Icon(Icons.image_not_supported_outlined, color: SHOAppColors.textMuted, size: 24),
        ),
      ),
    );

    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: image);
    }
    return image;
  }
}
