import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shoo/core/pages/hos_pages.dart';
import 'package:shoo/core/theme/hos_colors.dart';
import 'package:shoo/core/theme/hos_spacing.dart';
import 'package:shoo/core/theme/hos_theme_extension.dart';
import 'package:shoo/features/checkout/domain/entities/hos_payment_method.dart';
import 'package:shoo/features/checkout/presentation/state/hos_payment_prefs_provider.dart';
import 'package:shoo/features/profile/presentation/widgets/hos_settings_group.dart';
import 'package:shoo/l10n/app_localizations.dart';

class SHOSettingsPaymentPage extends ConsumerStatefulWidget {
  const SHOSettingsPaymentPage({super.key});

  @override
  ConsumerState<SHOSettingsPaymentPage> createState() =>
      _SHOSettingsPaymentPageState();
}

class _SHOSettingsPaymentPageState extends ConsumerState<SHOSettingsPaymentPage>
    with SHOPageRouteAnalyticsMixin, SHOAppPageMixin, SHOAppTrackedPageMixin {
  @override
  String get pageName => 'settings_payment';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final prefs = ref.watch(paymentPrefsProvider);
    final notifier = ref.read(paymentPrefsProvider.notifier);

    return buildTrackedPage(
      Scaffold(
        appBar: AppBar(title: Text(l10n.settingsPaymentTitle)),
        body: ListView(
          padding: const EdgeInsets.only(bottom: SHOAppSpacing.xxxl),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                SHOAppSpacing.xl,
                SHOAppSpacing.lg,
                SHOAppSpacing.xl,
                SHOAppSpacing.sm,
              ),
              child: Text(
                l10n.settingsPaymentHint,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: context.shoTheme.textSecondary,
                ),
              ),
            ),
            SHOSettingsGroup(
              title: l10n.paymentMethodsTitle,
              children: [
                for (final method in kPaymentMethods)
                  _PaymentMethodOptionTile(
                    method: method,
                    selected: prefs.defaultMethod == method,
                    onSelect: () => notifier.setDefaultMethod(method),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                SHOAppSpacing.pagePadding,
                SHOAppSpacing.lg,
                SHOAppSpacing.pagePadding,
                0,
              ),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: context.shoTheme.surfaceMuted,
                  borderRadius: BorderRadius.circular(SHOAppSpacing.cardRadius),
                  border: Border.all(color: context.shoTheme.border),
                ),
                child: ListTile(
                  leading: const Icon(Icons.credit_card_outlined, size: 20),
                  title: Text(l10n.settingsPaymentBankCards),
                  subtitle: Text(l10n.settingsPaymentBankCardsHint),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: SHOAppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      l10n.settingsComingSoon,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: SHOAppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentMethodOptionTile extends StatelessWidget {
  const _PaymentMethodOptionTile({
    required this.method,
    required this.selected,
    required this.onSelect,
  });

  final SHOPaymentMethod method;
  final bool selected;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: SHOAppSpacing.lg),
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: method.tint.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(method.icon, color: method.tint, size: 20),
      ),
      title: Text(method.label(l10n)),
      subtitle: selected ? Text(l10n.settingsPaymentDefaultBadge) : null,
      trailing: Radio<SHOPaymentMethod>(
        value: method,
        groupValue: selected ? method : null,
        onChanged: (_) => onSelect(),
      ),
      onTap: onSelect,
    );
  }
}
