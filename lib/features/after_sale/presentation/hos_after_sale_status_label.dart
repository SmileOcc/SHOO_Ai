import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../domain/hos_after_sale.dart';

String shoAfterSaleStatusLabel(BuildContext context, SHOAfterSaleStatus status) {
  final l10n = AppLocalizations.of(context);
  return switch (status) {
    SHOAfterSaleStatus.pending => l10n.afterSaleStatusPending,
    SHOAfterSaleStatus.approved => l10n.afterSaleStatusApproved,
    SHOAfterSaleStatus.rejected => l10n.afterSaleStatusRejected,
    SHOAfterSaleStatus.completed => l10n.afterSaleStatusCompleted,
  };
}

String shoAfterSaleTypeLabel(BuildContext context, SHOAfterSaleType type) {
  final l10n = AppLocalizations.of(context);
  return switch (type) {
    SHOAfterSaleType.refund => l10n.afterSaleTypeRefund,
    SHOAfterSaleType.returnRefund => l10n.afterSaleTypeReturnRefund,
  };
}
