import 'package:flutter/material.dart';

import '../../../core/dialogs/hos_card_dialog_shell.dart';
import '../../../core/theme/hos_colors.dart';
import '../../../core/theme/hos_spacing.dart';
import '../../../core/utils/hos_price_formatter.dart';
import '../../../core/widgets/hos_button.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/hos_payment_method.dart';

enum SHOPaymentDialogResult { cancelled, confirmed }

/// 模拟支付弹窗：取消返回购物车，确认后由调用方处理支付成功。
class SHOPaymentDialog extends StatefulWidget {
  const SHOPaymentDialog({
    super.key,
    required this.method,
    required this.amountCents,
    required this.orderNo,
  });

  final SHOPaymentMethod method;
  final int amountCents;
  final String orderNo;

  static Future<SHOPaymentDialogResult?> show(
    BuildContext context, {
    required SHOPaymentMethod method,
    required int amountCents,
    required String orderNo,
  }) {
    return showDialog<SHOPaymentDialogResult>(
      context: context,
      barrierDismissible: false,
      builder: (_) => SHOPaymentDialog(
        method: method,
        amountCents: amountCents,
        orderNo: orderNo,
      ),
    );
  }

  @override
  State<SHOPaymentDialog> createState() => _SHOPaymentDialogState();
}

class _SHOPaymentDialogState extends State<SHOPaymentDialog> {
  var _paying = false;

  void _cancel() {
    if (_paying) return;
    Navigator.of(context).pop(SHOPaymentDialogResult.cancelled);
  }

  Future<void> _confirm() async {
    if (_paying) return;
    setState(() => _paying = true);
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    Navigator.of(context).pop(SHOPaymentDialogResult.confirmed);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SHOCardDialogShell(
      onClose: _cancel,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: SHOAppSpacing.xxl),
            child: Text(
              l10n.paymentDialogTitle,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
          const SizedBox(height: SHOAppSpacing.lg),
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: widget.method.tint.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  widget.method.icon,
                  color: widget.method.tint,
                ),
              ),
              const SizedBox(width: SHOAppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.method.label(l10n),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${l10n.orderNoLabel}: ${widget.orderNo}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: SHOAppSpacing.lg),
          Text(
            l10n.paymentAmountDue,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: SHOAppSpacing.xs),
          Text(
            priceFormatter.formatCents(widget.amountCents),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: SHOAppColors.sale,
                ),
          ),
          const SizedBox(height: SHOAppSpacing.sm),
          Text(
            l10n.paymentMockHint,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).hintColor,
                ),
          ),
          const SizedBox(height: SHOAppSpacing.xl),
          Row(
            children: [
              Expanded(
                child: SHOAppButton(
                  label: l10n.paymentCancelPay,
                  variant: SHOAppButtonVariant.outline,
                  onPressed: _paying ? null : _cancel,
                ),
              ),
              const SizedBox(width: SHOAppSpacing.md),
              Expanded(
                child: SHOAppButton(
                  label: l10n.paymentConfirmPay,
                  isLoading: _paying,
                  onPressed: _paying ? null : _confirm,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
