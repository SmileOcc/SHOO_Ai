import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shoo/core/theme/hos_colors.dart';
import 'package:shoo/core/theme/hos_spacing.dart';
import 'package:shoo/features/theme_activity/presentation/navigation/hos_theme_activity_link_handler.dart';
import 'package:shoo/features/theme_activity/presentation/style/hos_module_style.dart';

class SHOThemeMarqueeModule extends StatefulWidget {
  const SHOThemeMarqueeModule({
    super.key,
    required this.raw,
    required this.style,
  });

  final Map<String, dynamic> raw;
  final Map<String, dynamic> style;

  @override
  State<SHOThemeMarqueeModule> createState() => _SHOThemeMarqueeModuleState();
}

class _SHOThemeMarqueeModuleState extends State<SHOThemeMarqueeModule>
    with SingleTickerProviderStateMixin {
  Timer? _timer;
  AnimationController? _controller;
  var _index = 0;
  var _paused = false;

  List<Map<String, dynamic>> get _items {
    final raw = widget.raw['items'];
    if (raw is! List) return const [];
    return raw.whereType<Map<String, dynamic>>().toList();
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller?.stop();
    _controller?.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    if (_items.length <= 1) return;
    final speed = widget.raw['speed'];
    final interval = switch (speed) {
      'slow' => const Duration(seconds: 4),
      'fast' => const Duration(seconds: 2),
      _ => const Duration(seconds: 3),
    };
    _timer = Timer.periodic(interval, (_) => _next());
  }

  Future<void> _next() async {
    if (_paused || _items.length <= 1) return;
    final controller = _controller;
    if (controller == null || controller.isAnimating) return;
    await controller.forward(from: 0);
    if (!mounted) return;
    setState(() => _index = (_index + 1) % _items.length);
    controller.reset();
  }

  void _onTap(Map<String, dynamic> item) {
    if (widget.raw['pauseOnTap'] == true) {
      setState(() => _paused = !_paused);
    }
    final link = item['link'] as String?;
    if (link != null && link.isNotEmpty) {
      if (!mounted) return;
      SHOThemeActivityLinkHandler.open(
        context,
        link,
        moduleId: widget.raw['moduleId'] as String?,
        itemId: item['itemId'] as String?,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = _items;
    if (items.isEmpty) return const SizedBox.shrink();

    final direction = widget.raw['direction'] as String? ?? 'horizontal';
    final height = themeNumber(widget.raw['height'], fallback: 36);
    final bodyColor = parseThemeColor(
      widget.style['bodyColor'] as String?,
      fallback: SHOAppColors.accent,
    );

    if (direction == 'vertical') {
      return _VerticalMarquee(
        items: items,
        height: height,
        textColor: bodyColor,
        onTap: _onTap,
      );
    }

    final current = items[_index];
    final next = items[(_index + 1) % items.length];
    final lineHeight = height;

    return Material(
      color: bodyColor?.withValues(alpha: 0.08) ?? SHOAppColors.accent.withValues(alpha: 0.08),
      child: InkWell(
        onTap: () => _onTap(current),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: SHOAppSpacing.pagePadding,
          ),
          child: SizedBox(
            height: lineHeight,
            child: items.length > 1
                ? ClipRect(
                    child: OverflowBox(
                      maxHeight: lineHeight * 2,
                      alignment: Alignment.topCenter,
                      child: AnimatedBuilder(
                        animation: _controller!,
                        builder: (context, child) {
                          final progress = Curves.easeInOut.transform(
                            _controller!.value,
                          );
                          return Transform.translate(
                            offset: Offset(0, -progress * lineHeight),
                            child: child,
                          );
                        },
                        child: Column(
                          children: [
                            _line(current, bodyColor),
                            _line(next, bodyColor),
                          ],
                        ),
                      ),
                    ),
                  )
                : _line(current, bodyColor),
          ),
        ),
      ),
    );
  }

  Widget _line(Map<String, dynamic> item, Color? color) {
    return SizedBox(
      height: themeNumber(widget.raw['height'], fallback: 36),
      child: Row(
        children: [
          Icon(Icons.campaign_outlined, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              item['text'] as String? ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VerticalMarquee extends StatefulWidget {
  const _VerticalMarquee({
    required this.items,
    required this.height,
    required this.onTap,
    this.textColor,
  });

  final List<Map<String, dynamic>> items;
  final double height;
  final void Function(Map<String, dynamic> item) onTap;
  final Color? textColor;

  @override
  State<_VerticalMarquee> createState() => _VerticalMarqueeState();
}

class _VerticalMarqueeState extends State<_VerticalMarquee>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  var _index = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _timer = Timer.periodic(const Duration(seconds: 3), (_) => _next());
  }

  Future<void> _next() async {
    if (widget.items.length <= 1 || _controller.isAnimating) return;
    await _controller.forward(from: 0);
    if (!mounted) return;
    setState(() => _index = (_index + 1) % widget.items.length);
    _controller.reset();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.stop();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final current = widget.items[_index];
    final next = widget.items[(_index + 1) % widget.items.length];
    return SizedBox(
      height: widget.height,
      child: ClipRect(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final progress = Curves.easeInOut.transform(_controller.value);
            return Transform.translate(
              offset: Offset(0, -progress * widget.height),
              child: child,
            );
          },
          child: Column(
            children: [
              _row(current),
              _row(next),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(Map<String, dynamic> item) {
    return InkWell(
      onTap: () => widget.onTap(item),
      child: SizedBox(
        height: widget.height,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            item['text'] as String? ?? '',
            style: TextStyle(color: widget.textColor),
          ),
        ),
      ),
    );
  }
}
