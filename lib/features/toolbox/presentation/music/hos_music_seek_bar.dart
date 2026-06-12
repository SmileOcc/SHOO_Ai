import 'package:flutter/material.dart';

class SHOMusicSeekBar extends StatefulWidget {
  const SHOMusicSeekBar({
    super.key,
    required this.position,
    required this.duration,
    required this.onSeekCommitted,
    required this.formatDuration,
  });

  final Duration position;
  final Duration duration;
  final ValueChanged<Duration> onSeekCommitted;
  final String Function(Duration duration) formatDuration;

  @override
  State<SHOMusicSeekBar> createState() => _SHOMusicSeekBarState();
}

class _SHOMusicSeekBarState extends State<SHOMusicSeekBar> {
  double? _dragValue;
  var _isDragging = false;

  double get _maxMs => widget.duration.inMilliseconds > 0
      ? widget.duration.inMilliseconds.toDouble()
      : 1;

  double get _displayValue {
    if (_isDragging && _dragValue != null) {
      return _dragValue!.clamp(0.0, 1.0);
    }
    return (widget.position.inMilliseconds / _maxMs).clamp(0.0, 1.0);
  }

  Duration get _displayPosition {
    if (_isDragging && _dragValue != null) {
      return Duration(milliseconds: (_dragValue! * _maxMs).round());
    }
    return widget.position;
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.duration > Duration.zero;

    return Column(
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 3,
            thumbShape: _ScalingThumbShape(
              enabledRadius: 6,
              pressedRadius: 12,
              isPressed: _isDragging,
            ),
            overlayShape: SliderComponentShape.noOverlay,
            activeTrackColor: Colors.white,
            inactiveTrackColor: Colors.white.withValues(alpha: 0.25),
            thumbColor: Colors.white,
          ),
          child: Slider(
            value: _displayValue,
            onChangeStart: enabled
                ? (_) => setState(() => _isDragging = true)
                : null,
            onChanged: enabled
                ? (value) => setState(() => _dragValue = value)
                : null,
            onChangeEnd: enabled
                ? (value) {
                    widget.onSeekCommitted(
                      Duration(milliseconds: (value * _maxMs).round()),
                    );
                    setState(() {
                      _isDragging = false;
                      _dragValue = null;
                    });
                  }
                : null,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.formatDuration(_displayPosition),
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 12,
                ),
              ),
              Text(
                widget.formatDuration(widget.duration),
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ScalingThumbShape extends SliderComponentShape {
  const _ScalingThumbShape({
    required this.enabledRadius,
    required this.pressedRadius,
    required this.isPressed,
  });

  final double enabledRadius;
  final double pressedRadius;
  final bool isPressed;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    final radius = isPressed ? pressedRadius : enabledRadius;
    return Size.fromRadius(radius);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final canvas = context.canvas;
    final radius = isPressed ? pressedRadius : enabledRadius;
    final color = sliderTheme.thumbColor ?? Colors.white;
    canvas.drawCircle(center, radius, Paint()..color = color);
  }
}
