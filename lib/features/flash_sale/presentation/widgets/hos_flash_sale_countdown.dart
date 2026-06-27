import 'dart:async';

import 'package:flutter/material.dart';

import 'package:shoo/core/theme/hos_colors.dart';

class SHOFlashSaleCountdown extends StatefulWidget {
  const SHOFlashSaleCountdown({
    super.key,
    required this.targetIso,
    required this.prefix,
    this.onComplete,
  });

  final String targetIso;
  final String prefix;
  final VoidCallback? onComplete;

  @override
  State<SHOFlashSaleCountdown> createState() => _SHOFlashSaleCountdownState();
}

class _SHOFlashSaleCountdownState extends State<SHOFlashSaleCountdown> {
  Timer? _timer;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _tick();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  @override
  void didUpdateWidget(SHOFlashSaleCountdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.targetIso != widget.targetIso) _tick();
  }

  void _tick() {
    final target = DateTime.tryParse(widget.targetIso)?.toLocal();
    if (target == null) return;
    final diff = target.difference(DateTime.now());
    if (!mounted) return;
    if (diff.isNegative) {
      _timer?.cancel();
      setState(() => _remaining = Duration.zero);
      widget.onComplete?.call();
      return;
    }
    setState(() => _remaining = diff);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_remaining <= Duration.zero) {
      return Text(
        widget.prefix,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: SHOAppColors.textMuted,
        ),
      );
    }

    final h = _remaining.inHours.remainder(24).toString().padLeft(2, '0');
    final m = _remaining.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = _remaining.inSeconds.remainder(60).toString().padLeft(2, '0');

    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 12, color: SHOAppColors.textSecondary),
        children: [
          TextSpan(text: '${widget.prefix} '),
          TextSpan(
            text: '$h:$m:$s',
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: SHOAppColors.accent,
            ),
          ),
        ],
      ),
    );
  }
}
