import 'package:flutter/material.dart';

class SHOSlideActionTile extends StatefulWidget {
  const SHOSlideActionTile({
    super.key,
    required this.child,
    required this.action,
    required this.actionWidth,
    required this.onAction,
  });

  final Widget child;
  final Widget action;
  final double actionWidth;
  final VoidCallback onAction;

  @override
  State<SHOSlideActionTile> createState() => _SHOSlideActionTileState();
}

class _SHOSlideActionTileState extends State<SHOSlideActionTile> {
  var _dragOffset = 0.0;

  void _close() => setState(() => _dragOffset = 0);

  @override
  Widget build(BuildContext context) {
    final offset = _dragOffset.clamp(0.0, widget.actionWidth);

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        children: [
          Positioned.fill(
            child: Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                width: widget.actionWidth,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      _close();
                      widget.onAction();
                    },
                    child: widget.action,
                  ),
                ),
              ),
            ),
          ),
          GestureDetector(
            onHorizontalDragUpdate: (details) {
              setState(() {
                _dragOffset = (_dragOffset - details.delta.dx)
                    .clamp(0.0, widget.actionWidth);
              });
            },
            onHorizontalDragEnd: (_) {
              setState(() {
                _dragOffset = _dragOffset > widget.actionWidth * 0.4
                    ? widget.actionWidth
                    : 0;
              });
            },
            child: Transform.translate(
              offset: Offset(-offset, 0),
              child: widget.child,
            ),
          ),
        ],
      ),
    );
  }
}
