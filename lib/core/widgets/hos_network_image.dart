import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../storage/hos_image_cache_manager.dart';
import '../theme/hos_colors.dart';
import 'hos_skeleton_box.dart';

class SHOAppNetworkImage extends StatelessWidget {
  const SHOAppNetworkImage({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  final String url;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final image = CachedNetworkImage(
      imageUrl: url,
      cacheManager: SHOImageCacheManager.instance,
      fit: fit,
      placeholder: (_, __) => const SHOSkeletonBox(),
      errorWidget: (_, __, ___) => const ColoredBox(
        color: SHOAppColors.surfaceMuted,
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
