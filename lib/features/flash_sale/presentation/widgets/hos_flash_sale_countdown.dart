import 'package:flutter/material.dart';
import 'package:shoo/core/theme/hos_colors.dart';
import 'package:shoo/core/widgets/hos_countdown_ticker.dart';

class SHOFlashSaleCountdown extends StatefulWidget {
  const SHOFlashSaleCountdown({
    super.key,
    required this.targetIso,
    required this.prefix,
    this.onComplete,
    this.accentColor,
    this.prefixColor,
  });

  final String targetIso;
  final String prefix;
  final VoidCallback? onComplete;
  final Color? accentColor;
  final Color? prefixColor;

  @override
  State<SHOFlashSaleCountdown> createState() => _SHOFlashSaleCountdownState();
}

class _SHOFlashSaleCountdownState extends State<SHOFlashSaleCountdown>
    with SHOCountdownTickerMixin<SHOFlashSaleCountdown> {
  @override
  void initState() {
    super.initState();
    _restart();
  }

  @override
  void didUpdateWidget(SHOFlashSaleCountdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.targetIso != widget.targetIso) _restart();
  }

  void _restart() {
    final target = DateTime.tryParse(widget.targetIso)?.toLocal();
    startCountdown(target, onComplete: widget.onComplete);
  }

  @override
  void dispose() {
    disposeCountdownTicker();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = widget.accentColor ?? SHOAppColors.accent;
    final prefixClr = widget.prefixColor ?? SHOAppColors.textSecondary;

    if (countdownExpired || countdownRemaining <= Duration.zero) {
      return Text(
        widget.prefix,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: SHOAppColors.textMuted,
        ),
      );
    }

    final digits = formatCountdownDuration(countdownRemaining);

    return RichText(
      text: TextSpan(
        style: TextStyle(fontSize: 12, color: prefixClr),
        children: [
          TextSpan(text: '${widget.prefix} '),
          TextSpan(
            text: digits,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: accent,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
