import 'package:flutter/material.dart';
import 'package:shoo/core/theme/hos_colors.dart';
import 'package:shoo/core/widgets/hos_countdown_ticker.dart';
import 'package:shoo/l10n/app_localizations.dart';

/// 待支付订单倒计时条（列表/详情/收银台复用）。
class SHOOrderPaymentCountdown extends StatefulWidget {
  const SHOOrderPaymentCountdown({
    super.key,
    required this.deadline,
    this.compact = false,
    this.onExpired,
  });

  final DateTime deadline;
  final bool compact;
  final VoidCallback? onExpired;

  @override
  State<SHOOrderPaymentCountdown> createState() =>
      _SHOOrderPaymentCountdownState();
}

class _SHOOrderPaymentCountdownState extends State<SHOOrderPaymentCountdown>
    with SHOCountdownTickerMixin {
  @override
  void initState() {
    super.initState();
    startCountdown(widget.deadline, onComplete: widget.onExpired);
  }

  @override
  void didUpdateWidget(covariant SHOOrderPaymentCountdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.deadline != widget.deadline) {
      startCountdown(widget.deadline, onComplete: widget.onExpired);
    }
  }

  @override
  void dispose() {
    disposeCountdownTicker();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final timeLabel = formatCountdownDuration(
      countdownRemaining,
      format: SHOCountdownFormat.ms,
    );
    final text = countdownExpired
        ? l10n.orderPaymentExpired
        : l10n.orderPaymentCountdown(timeLabel);
    final style = widget.compact
        ? Theme.of(context).textTheme.bodySmall
        : Theme.of(context).textTheme.bodyMedium;

    return Text(
      text,
      style: style?.copyWith(
        color: countdownExpired ? SHOAppColors.textMuted : SHOAppColors.sale,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
