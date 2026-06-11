import 'dart:math' as math;

import 'package:flutter/material.dart';

class SHOVideoDanmakuController {
  void Function(String text)? _spawn;

  void bind(void Function(String text) spawn) => _spawn = spawn;

  void unbind() => _spawn = null;

  void spawn(String text) {
    final handler = _spawn;
    if (handler == null || text.trim().isEmpty) return;
    handler(text.trim());
  }
}

class SHOVideoDanmakuOverlay extends StatefulWidget {
  const SHOVideoDanmakuOverlay({
    super.key,
    required this.enabled,
    required this.controller,
  });

  final bool enabled;
  final SHOVideoDanmakuController controller;

  @override
  State<SHOVideoDanmakuOverlay> createState() => _SHOVideoDanmakuOverlayState();
}

class _SHOVideoDanmakuOverlayState extends State<SHOVideoDanmakuOverlay>
    with TickerProviderStateMixin {
  static const _trackCount = 8;
  final _random = math.Random();
  final _activeTracks = <int>{};
  final _items = <_DanmakuItem>[];

  @override
  void initState() {
    super.initState();
    widget.controller.bind(_enqueue);
  }

  @override
  void didUpdateWidget(covariant SHOVideoDanmakuOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.unbind();
      widget.controller.bind(_enqueue);
    }
  }

  @override
  void dispose() {
    widget.controller.unbind();
    for (final item in _items) {
      item.controller.dispose();
    }
    super.dispose();
  }

  void _enqueue(String text) {
    if (!widget.enabled || !mounted) return;

    final track = _pickTrack();
    final durationMs = 7000 + _random.nextInt(4000);
    final controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: durationMs),
    );
    final item = _DanmakuItem(
      text: text,
      track: track,
      controller: controller,
    );

    setState(() => _items.add(item));
    _activeTracks.add(track);

    controller.forward().whenComplete(() {
      if (!mounted) return;
      setState(() {
        _items.remove(item);
        _activeTracks.remove(track);
      });
      controller.dispose();
    });
  }

  int _pickTrack() {
    for (var attempt = 0; attempt < 12; attempt++) {
      final track = _random.nextInt(_trackCount);
      if (!_activeTracks.contains(track)) return track;
    }
    return _random.nextInt(_trackCount);
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled || _items.isEmpty) {
      return const SizedBox.shrink();
    }

    return IgnorePointer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final height = constraints.maxHeight;
          return Stack(
            clipBehavior: Clip.none,
            children: [
              for (final item in _items)
                AnimatedBuilder(
                  animation: item.controller,
                  builder: (context, child) {
                    final progress = Curves.linear.transform(item.controller.value);
                    final x = width - progress * (width + 240);
                    final top = height * (0.08 + item.track * 0.1);
                    return Positioned(
                      left: x,
                      top: top,
                      child: child!,
                    );
                  },
                  child: _DanmakuText(text: item.text),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _DanmakuItem {
  _DanmakuItem({
    required this.text,
    required this.track,
    required this.controller,
  });

  final String text;
  final int track;
  final AnimationController controller;
}

class _DanmakuText extends StatelessWidget {
  const _DanmakuText({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Text(
          text,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2
              ..color = Colors.black.withValues(alpha: 0.65),
          ),
        ),
        Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
