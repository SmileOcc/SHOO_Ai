import 'package:flutter/material.dart';

import '../../../core/widgets/hos_empty_state.dart';
import '../../../l10n/app_localizations.dart';

class SHOCartPage extends StatelessWidget {
  const SHOCartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SHOEmptyState(
      title: l10n.cartEmptyTitle,
      subtitle: l10n.cartEmptySubtitle,
      icon: Icons.shopping_bag_outlined,
      actionLabel: l10n.cartEmptyAction,
    );
  }
}
