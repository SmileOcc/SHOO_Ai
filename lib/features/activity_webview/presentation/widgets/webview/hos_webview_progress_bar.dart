import 'package:flutter/material.dart';

class SHOWebViewProgressBar extends StatefulWidget {
  const SHOWebViewProgressBar({
    super.key,
    required this.progress,
    required this.visible,
  });

  final int progress;
  final bool visible;

  @override
  State<SHOWebViewProgressBar> createState() => _SHOWebViewProgressBarState();
}

class _SHOWebViewProgressBarState extends State<SHOWebViewProgressBar> {
  bool _showBar = false;

  @override
  void didUpdateWidget(covariant SHOWebViewProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.visible) {
      _showBar = true;
    } else if (oldWidget.visible && !widget.visible) {
      Future<void>.delayed(const Duration(milliseconds: 300), () {
        if (mounted) setState(() => _showBar = false);
      });
    }
  }

  Color _colorForProgress(int value) {
    if (value >= 90) return const Color(0xFF2DBE7E);
    if (value >= 60) return const Color(0xFF4A90E2);
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    if (!_showBar && !widget.visible) return const SizedBox.shrink();
    return AnimatedOpacity(
      opacity: widget.visible ? 1 : 0,
      duration: const Duration(milliseconds: 300),
      child: LinearProgressIndicator(
        value: widget.progress <= 0 ? null : widget.progress / 100,
        minHeight: 3,
        backgroundColor: Colors.black12,
        color: _colorForProgress(widget.progress),
      ),
    );
  }
}
