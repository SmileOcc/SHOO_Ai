import 'package:flutter/material.dart';

class SHOMusicMarqueeText extends StatefulWidget {
  const SHOMusicMarqueeText({
    super.key,
    required this.text,
    required this.style,
  });

  final String text;
  final TextStyle style;

  @override
  State<SHOMusicMarqueeText> createState() => _SHOMusicMarqueeTextState();
}

class _SHOMusicMarqueeTextState extends State<SHOMusicMarqueeText>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  var _textWidth = 0.0;
  var _viewWidth = 0.0;

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant SHOMusicMarqueeText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text || oldWidget.style != widget.style) {
      _controller?.dispose();
      _controller = null;
      _textWidth = 0;
      _viewWidth = 0;
    }
  }

  void _ensureAnimation(double textWidth, double viewWidth) {
    if (textWidth <= viewWidth) {
      if (_controller != null) {
        _controller!.dispose();
        _controller = null;
      }
      return;
    }

    if (_controller != null &&
        _textWidth == textWidth &&
        _viewWidth == viewWidth) {
      return;
    }

    _controller?.dispose();
    _textWidth = textWidth;
    _viewWidth = viewWidth;

    const gap = 48.0;
    final distance = textWidth + gap;
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: (distance * 28).round().clamp(4000, 14000)),
    )..repeat();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final painter = TextPainter(
          text: TextSpan(text: widget.text, style: widget.style),
          textDirection: Directionality.of(context),
          maxLines: 1,
        )..layout(maxWidth: double.infinity);

        _ensureAnimation(painter.width, maxWidth);

        if (_controller == null) {
          return Text(
            widget.text,
            style: widget.style,
            maxLines: 1,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          );
        }

        const gap = 48.0;
        final lineHeight = painter.height;

        return SizedBox(
          width: maxWidth,
          height: lineHeight,
          child: ClipRect(
            child: AnimatedBuilder(
              animation: _controller!,
              builder: (context, _) {
                final offset = _controller!.value * (painter.width + gap);
                return Transform.translate(
                  offset: Offset(-offset, 0),
                  child: OverflowBox(
                    alignment: Alignment.centerLeft,
                    maxWidth: double.infinity,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.text,
                          style: widget.style,
                          maxLines: 1,
                          softWrap: false,
                        ),
                        const SizedBox(width: gap),
                        Text(
                          widget.text,
                          style: widget.style,
                          maxLines: 1,
                          softWrap: false,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
