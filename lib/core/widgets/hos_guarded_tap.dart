import 'package:flutter/material.dart';

import '../constants/hos_constants.dart';

class SHOTapGuard {
  SHOTapGuard({Duration? interval})
      : _interval = interval ?? SHOAppConstants.debounceDuration;

  final Duration _interval;
  DateTime? _lastTap;

  bool tryAcquire() {
    final now = DateTime.now();
    if (_lastTap != null && now.difference(_lastTap!) < _interval) {
      return false;
    }
    _lastTap = now;
    return true;
  }

  Future<void> run(Future<void> Function() action) async {
    if (!tryAcquire()) return;
    await action();
  }

  void runSync(VoidCallback action) {
    if (!tryAcquire()) return;
    action();
  }
}

class SHOGuardedIconButton extends StatefulWidget {
  const SHOGuardedIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.color,
    this.iconSize,
    this.tooltip,
    this.padding,
    this.constraints,
    this.interval,
  });

  final Widget icon;
  final Future<void> Function()? onPressed;
  final Color? color;
  final double? iconSize;
  final String? tooltip;
  final EdgeInsetsGeometry? padding;
  final BoxConstraints? constraints;
  final Duration? interval;

  @override
  State<SHOGuardedIconButton> createState() => _SHOGuardedIconButtonState();
}

class _SHOGuardedIconButtonState extends State<SHOGuardedIconButton> {
  late final SHOTapGuard _guard = SHOTapGuard(interval: widget.interval);

  Future<void> _handle() async {
    final action = widget.onPressed;
    if (action == null) return;
    await _guard.run(action);
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: widget.onPressed == null ? null : _handle,
      icon: widget.icon,
      color: widget.color,
      iconSize: widget.iconSize,
      tooltip: widget.tooltip,
      padding: widget.padding,
      constraints: widget.constraints,
    );
  }
}

class SHOGuardedTap extends StatefulWidget {
  const SHOGuardedTap({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.behavior,
    this.interval,
  });

  final Widget child;
  final Future<void> Function()? onTap;
  final VoidCallback? onLongPress;
  final HitTestBehavior? behavior;
  final Duration? interval;

  @override
  State<SHOGuardedTap> createState() => _SHOGuardedTapState();
}

class _SHOGuardedTapState extends State<SHOGuardedTap> {
  late final SHOTapGuard _guard = SHOTapGuard(interval: widget.interval);

  Future<void> _handleTap() async {
    final action = widget.onTap;
    if (action == null) return;
    await _guard.run(action);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: widget.behavior,
      onLongPress: widget.onLongPress,
      onTap: widget.onTap == null
          ? null
          : () {
              _handleTap();
            },
      child: widget.child,
    );
  }
}
