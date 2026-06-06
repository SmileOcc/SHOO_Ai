import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../domain/hos_order.dart';

String shoOrderStatusLabel(BuildContext context, SHOOrderStatus status) {
  final l10n = AppLocalizations.of(context);
  return switch (status) {
    SHOOrderStatus.pendingPayment => l10n.orderStatusPendingPayment,
    SHOOrderStatus.paid => l10n.orderStatusPaid,
    SHOOrderStatus.shipped => l10n.orderStatusShipped,
    SHOOrderStatus.delivered => l10n.orderStatusDelivered,
    SHOOrderStatus.cancelled => l10n.orderStatusCancelled,
  };
}
