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
    if (widget.isPlaying && _hasCoverImage) {
      _controller.repeat();
    }
  }

  bool get _hasCoverImage {
    final coverPath = widget.coverPath;
    if (coverPath != null && File(coverPath).existsSync()) return true;
    return widget.coverUrl != null && widget.coverUrl!.trim().isNotEmpty;
  }

  @override
  void didUpdateWidget(covariant SHOMusicRotatingCover oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying && _hasCoverImage && !_controller.isAnimating) {
      _controller.repeat();
    } else if ((!widget.isPlaying || !_hasCoverImage) && _controller.isAnimating) {
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
    if (!_hasCoverImage) {
      return _buildFlatFallback(Color(widget.coverColor));
    }

    final cover = _buildCoverImage();
    return RotationTransition(
      turns: _controller,
      child: cover,
    );
  }

  Widget _buildCoverImage() {
    final coverPath = widget.coverPath;
    if (coverPath != null && File(coverPath).existsSync()) {
      return ClipOval(
        child: Image.file(
          File(coverPath),
          width: widget.size,
          height: widget.size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
              _buildFlatFallback(Color(widget.coverColor)),
        ),
      );
    }

    return ClipOval(
      child: Image.network(
        widget.coverUrl!,
        width: widget.size,
        height: widget.size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            _buildFlatFallback(Color(widget.coverColor)),
      ),
    );
  }

  Widget _buildFlatFallback(Color color) {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
      alignment: Alignment.center,
      child: Icon(
        Icons.music_note_rounded,
        size: widget.size * 0.28,
        color: Colors.white.withValues(alpha: 0.9),
      ),
    );
  }
}
