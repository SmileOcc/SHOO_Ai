import 'dart:io';

import 'package:flutter/material.dart';

class SHOMusicRotatingCover extends StatefulWidget {
  const SHOMusicRotatingCover({
    super.key,
    required this.isPlaying,
    required this.coverColor,
    this.coverUrl,
    this.coverPath,
    this.size = 260,
  });

  final bool isPlaying;
  final int coverColor;
  final String? coverUrl;
  final String? coverPath;
  final double size;

  @override
  State<SHOMusicRotatingCover> createState() => _SHOMusicRotatingCoverState();
}

class _SHOMusicRotatingCoverState extends State<SHOMusicRotatingCover>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    );
    if (widget.isPlaying) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant SHOMusicRotatingCover oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.isPlaying && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = Color(widget.coverColor);

    return RotationTransition(
      turns: _controller,
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color.withValues(alpha: 0.95),
              color.withValues(alpha: 0.55),
              const Color(0xFF1A1A1A),
            ],
            stops: const [0.35, 0.72, 1],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 28,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            _buildCoverImage(color),
            Container(
              width: widget.size * 0.18,
              height: widget.size * 0.18,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF111111),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoverImage(Color color) {
    final coverPath = widget.coverPath;
    if (coverPath != null && File(coverPath).existsSync()) {
      return ClipOval(
        child: Image.file(
          File(coverPath),
          width: widget.size,
          height: widget.size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildFallback(color),
        ),
      );
    }

    if (widget.coverUrl != null) {
      return ClipOval(
        child: Image.network(
          widget.coverUrl!,
          width: widget.size,
          height: widget.size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildFallback(color),
        ),
      );
    }

    return _buildFallback(color);
  }

  Widget _buildFallback(Color color) {
    return Icon(
      Icons.music_note_rounded,
      size: widget.size * 0.28,
      color: Colors.white.withValues(alpha: 0.92),
    );
  }
}
