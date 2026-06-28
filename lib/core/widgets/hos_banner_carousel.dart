import 'dart:async';

import 'package:flutter/material.dart';

import 'package:shoo/app/router/hos_route_navigator.dart';
import 'package:shoo/features/home/domain/entities/hos_banner.dart';
import 'package:shoo/core/theme/hos_colors.dart';
import 'package:shoo/core/theme/hos_spacing.dart';
import 'package:shoo/core/theme/hos_theme_extension.dart';
import 'package:shoo/core/widgets/hos_network_image.dart';

class SHOBannerCarousel extends StatefulWidget {
  const SHOBannerCarousel({
    super.key,
    required this.banners,
    this.height = 140,
    this.edgeToEdge = false,
    this.showTitleOverlay = true,
    this.showIndicators = true,
    this.autoPlay = true,
    this.autoPlayInterval = const Duration(seconds: 4),
  });

  final List<SHOBannerItem> banners;
  final double height;
  final bool edgeToEdge;
  final bool showTitleOverlay;
  final bool showIndicators;
  final bool autoPlay;
  final Duration autoPlayInterval;

  @override
  State<SHOBannerCarousel> createState() => _SHOBannerCarouselState();
}

class _SHOBannerCarouselState extends State<SHOBannerCarousel> {
  static const _loopCycles = 1000;

  late final PageController _controller;
  late final int _initialPage;
  Timer? _autoPlayTimer;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    final len = widget.banners.length;
    if (len <= 1) {
      _initialPage = 0;
      _controller = PageController();
    } else {
      _initialPage = _loopCycles * len;
      _controller = PageController(initialPage: _initialPage);
      _index = 0;
    }
    _scheduleAutoPlay();
  }

  @override
  void didUpdateWidget(SHOBannerCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 热重载后旧 widget 实例可能缺少新增字段，避免直接读取 oldWidget.autoPlay。
    _scheduleAutoPlay();
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  bool get _autoPlayEnabled {
    try {
      return widget.autoPlay;
    } catch (_) {
      return true;
    }
  }

  Duration get _resolvedAutoPlayInterval {
    try {
      return widget.autoPlayInterval;
    } catch (_) {
      return const Duration(seconds: 4);
    }
  }

  int _realIndex(int page) {
    final len = widget.banners.length;
    if (len == 0) return 0;
    return page % len;
  }

  void _scheduleAutoPlay() {
    _autoPlayTimer?.cancel();
    if (!_autoPlayEnabled || widget.banners.length <= 1) return;

    _autoPlayTimer = Timer.periodic(_resolvedAutoPlayInterval, (_) {
      if (!mounted || !_controller.hasClients) return;
      final current = _controller.page?.round() ?? _initialPage;
      _controller.animateToPage(
        current + 1,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.banners.isEmpty) return const SizedBox.shrink();

    final theme = context.shoTheme;
    final len = widget.banners.length;
    final looped = len > 1;

    final pageView = SizedBox(
      height: widget.height,
      child: PageView.builder(
        controller: _controller,
        itemCount: looped ? _loopCycles * len * 2 : len,
        onPageChanged: (i) => setState(() => _index = _realIndex(i)),
        itemBuilder: (context, index) {
          final banner = widget.banners[_realIndex(index)];
          final hasLink = banner.link.trim().isNotEmpty;

          final radius = widget.edgeToEdge
              ? BorderRadius.zero
              : BorderRadius.circular(SHOAppSpacing.cardRadius);

          return Padding(
            padding: widget.edgeToEdge
                ? EdgeInsets.zero
                : const EdgeInsets.symmetric(
                    horizontal: SHOAppSpacing.pagePadding,
                  ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: hasLink
                    ? () => SHORouteNavigator.followLink(context, banner.link)
                    : null,
                borderRadius: radius,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    SHOAppNetworkImage(
                      url: banner.imageUrl,
                      borderRadius: radius,
                      fit: BoxFit.cover,
                    ),
                    if (widget.showTitleOverlay)
                      Positioned(
                        left: SHOAppSpacing.md,
                        bottom: SHOAppSpacing.md,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
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
              ),
            ),
          );
        },
      ),
    );

    if (!widget.showIndicators) return pageView;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        pageView,
        const SizedBox(height: SHOAppSpacing.xs),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(len, (i) {
            final active = i == _index;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 2),
              width: active ? 14 : 6,
              height: 3,
              decoration: BoxDecoration(
                color: active ? SHOAppColors.accent : theme.border,
                borderRadius: BorderRadius.circular(2),
              ),
            );
          }),
        ),
      ],
    );
  }
}
