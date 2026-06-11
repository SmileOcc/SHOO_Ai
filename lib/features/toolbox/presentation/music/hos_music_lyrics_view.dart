import 'package:flutter/material.dart';

import '../../domain/hos_lrc_parser.dart';

class SHOMusicLyricsView extends StatefulWidget {
  const SHOMusicLyricsView({
    super.key,
    required this.lines,
    required this.activeIndex,
    this.emptyText = '暂无歌词',
  });

  final List<SHOLrcLine> lines;
  final int activeIndex;
  final String emptyText;

  @override
  State<SHOMusicLyricsView> createState() => _SHOMusicLyricsViewState();
}

class _SHOMusicLyricsViewState extends State<SHOMusicLyricsView> {
  final _scrollController = ScrollController();
  int _lastScrolledIndex = -1;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant SHOMusicLyricsView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.activeIndex != oldWidget.activeIndex) {
      _scrollToActiveLine();
    }
  }

  void _scrollToActiveLine() {
    final index = widget.activeIndex;
    if (index < 0 || index == _lastScrolledIndex) return;
    _lastScrolledIndex = index;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      const lineHeight = 42.0;
      final target = (index * lineHeight) -
          (_scrollController.position.viewportDimension / 2) +
          (lineHeight / 2);
      final max = _scrollController.position.maxScrollExtent;
      _scrollController.animateTo(
        target.clamp(0, max),
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.lines.isEmpty) {
      return Center(
        child: Text(
          widget.emptyText,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.45),
            fontSize: 15,
          ),
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      itemCount: widget.lines.length,
      itemBuilder: (context, index) {
        final line = widget.lines[index];
        final isActive = index == widget.activeIndex;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            style: TextStyle(
              fontSize: isActive ? 20 : 16,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              color: isActive
                  ? Colors.white
                  : Colors.white.withValues(alpha: isActive ? 1 : 0.42),
              height: 1.45,
            ),
            child: Text(
              line.text,
              textAlign: TextAlign.center,
            ),
          ),
        );
      },
    );
  }
}
