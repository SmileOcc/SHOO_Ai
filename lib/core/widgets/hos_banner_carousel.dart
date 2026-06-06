import 'package:flutter/material.dart';

import '../../features/home/domain/hos_banner.dart';
import '../theme/hos_colors.dart';
import '../theme/hos_spacing.dart';
import 'hos_network_image.dart';

class SHOBannerCarousel extends StatefulWidget {
  const SHOBannerCarousel({
    super.key,
    required this.banners,
    this.height = 140,
  });

  final List<SHOBannerItem> banners;
  final double height;

  @override
  State<SHOBannerCarousel> createState() => _SHOBannerCarouselState();
}

class _SHOBannerCarouselState extends State<SHOBannerCarousel> {
  late final PageController _controller;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.banners.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        SizedBox(
          height: widget.height,
          child: PageView.builder(
            controller: _controller,
            itemCount: widget.banners.length,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (context, index) {
              final banner = widget.banners[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: SHOAppSpacing.pagePadding),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    SHOAppNetworkImage(
                      url: banner.imageUrl,
                      borderRadius: BorderRadius.circular(SHOAppSpacing.cardRadius),
                    ),
                    Positioned(
                      left: SHOAppSpacing.md,
                      bottom: SHOAppSpacing.md,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        color: SHOAppColors.primary.withValues(alpha: 0.72),
                        child: Text(
                          banner.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: SHOAppSpacing.sm),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.banners.length, (i) {
            final active = i == _index;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 2),
              width: active ? 14 : 6,
              height: 3,
              decoration: BoxDecoration(
                color: active ? SHOAppColors.primary : SHOAppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            );
          }),
        ),
      ],
    );
  }
}
