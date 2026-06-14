import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';

enum SHOPaymentMethod {
  wechat,
  alipay,
  bankCard,
}

extension SHOPaymentMethodUi on SHOPaymentMethod {
  String label(AppLocalizations l10n) => switch (this) {
        SHOPaymentMethod.wechat => l10n.paymentMethodWechat,
        SHOPaymentMethod.alipay => l10n.paymentMethodAlipay,
        SHOPaymentMethod.bankCard => l10n.paymentMethodBankCard,
      };

  IconData get icon => switch (this) {
        SHOPaymentMethod.wechat => Icons.chat_bubble_outline_rounded,
        SHOPaymentMethod.alipay => Icons.account_balance_wallet_outlined,
        SHOPaymentMethod.bankCard => Icons.credit_card_outlined,
      };

  Color get tint => switch (this) {
        SHOPaymentMethod.wechat => const Color(0xFF07C160),
        SHOPaymentMethod.alipay => const Color(0xFF1677FF),
        SHOPaymentMethod.bankCard => const Color(0xFF6B5B95),
      };
}

const kPaymentMethods = SHOPaymentMethod.values;
