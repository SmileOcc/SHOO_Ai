import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/router/hos_route_navigator.dart';
import '../../../core/theme/hos_colors.dart';
import '../../../core/theme/hos_spacing.dart';
import '../../../core/theme/hos_theme_extension.dart';
import '../domain/hos_cart_marquee.dart';
import 'hos_cart_marquee_controller.dart';

class SHOCartMarqueeBanner extends ConsumerWidget {
  const SHOCartMarqueeBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final marqueeAsync = ref.watch(cartMarqueeProvider);

    return marqueeAsync.maybeWhen(
      data: (items) {
        if (items.isEmpty) return const SizedBox.shrink();
        return _SHOCartMarqueeTicker(items: items);
      },
      orElse: () => const SizedBox.shrink(),
    );
  }
}

class _SHOCartMarqueeTicker extends StatefulWidget {
  const _SHOCartMarqueeTicker({required this.items});

  final List<SHOCartMarqueeItem> items;

  @override
  State<_SHOCartMarqueeTicker> createState() => _SHOCartMarqueeTickerState();
}

class _SHOCartMarqueeTickerState extends State<_SHOCartMarqueeTicker>
    with SingleTickerProviderStateMixin {
  static const _interval = Duration(seconds: 3);
  static const _duration = Duration(milliseconds: 500);
  static const _lineHeight = 36.0;

  Timer? _timer;
  AnimationController? _controller;

  var _index = 0;

  bool get _canScroll => widget.items.length > 1;

  int get _nextIndex => (_index + 1) % widget.items.length;

  AnimationController get _activeController {
    final existing = _controller;
    if (existing != null) return existing;
    final created = AnimationController(vsync: this, duration: _duration);
    _controller = created;
    return created;
  }

  @override
  void initState() {
    super.initState();
    _activeController;
    _startTimer();
  }

  @override
  void reassemble() {
    super.reassemble();
    _activeController;
    _restartTimer();
  }

  @override
  void didUpdateWidget(covariant _SHOCartMarqueeTicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items.length != widget.items.length) {
      _index = 0;
      _activeController.reset();
      _restartTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller?.dispose();
    _controller = null;
    super.dispose();
  }

  void _restartTimer() {
    _timer?.cancel();
    _startTimer();
  }

  void _startTimer() {
    if (!_canScroll) return;
    _timer = Timer.periodic(_interval, (_) {
      final controller = _controller;
      if (!mounted || controller == null || controller.isAnimating) return;
      _playNext();
    });
  }

  Future<void> _playNext() async {
    final controller = _activeController;
    if (!_canScroll || controller.isAnimating) return;

    await controller.forward(from: 0);
    if (!mounted) return;

    setState(() => _index = _nextIndex);
    controller.reset();
  }

  void _openLink(SHOCartMarqueeItem item) {
    if (item.link.isEmpty) return;
    SHORouteNavigator.followLink(context, item.link);
  }

  Widget _buildLine(SHOCartMarqueeItem item) {
    return SizedBox(
      height: _lineHeight,
      child: Row(
        children: [
          const Icon(
            Icons.campaign_outlined,
            size: 16,
            color: SHOAppColors.accent,
          ),
          const SizedBox(width: SHOAppSpacing.sm),
          Expanded(
            child: Text(
              item.text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: SHOAppColors.accent,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          const SizedBox(width: SHOAppSpacing.xs),
          const Icon(
            Icons.chevron_right,
            size: 16,
            color: SHOAppColors.accent,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.shoTheme;
    final current = widget.items[_index];

    return DecoratedBox(
      decoration: BoxDecoration(
        color: SHOAppColors.accent.withValues(alpha: 0.08),
        border: Border(bottom: BorderSide(color: theme.border)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _openLink(current),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: SHOAppSpacing.pagePadding,
            ),
            child: ClipRect(
              child: SizedBox(
                height: _lineHeight,
                child: _canScroll
                    ? OverflowBox(
                        maxHeight: _lineHeight * 2,
                        alignment: Alignment.topCenter,
                        child: AnimatedBuilder(
                          animation: _activeController,
                          builder: (context, child) {
                            final progress = Curves.easeInOut
                                .transform(_activeController.value);
                            return Transform.translate(
                              offset: Offset(0, -progress * _lineHeight),
                              child: child,
                            );
                          },
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildLine(widget.items[_index]),
                              _buildLine(widget.items[_nextIndex]),
                            ],
                          ),
                        ),
                      )
                    : _buildLine(current),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
