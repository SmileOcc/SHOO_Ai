import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shoo/core/pages/hos_pages.dart';
import 'package:shoo/core/theme/hos_spacing.dart';
import 'package:shoo/features/profile/presentation/state/hos_notification_prefs_provider.dart';
import 'package:shoo/features/profile/presentation/widgets/hos_settings_group.dart';
import 'package:shoo/l10n/app_localizations.dart';

class SHOSettingsNotificationsPage extends ConsumerStatefulWidget {
  const SHOSettingsNotificationsPage({super.key});

  @override
  ConsumerState<SHOSettingsNotificationsPage> createState() =>
      _SHOSettingsNotificationsPageState();
}

class _SHOSettingsNotificationsPageState
    extends ConsumerState<SHOSettingsNotificationsPage>
    with SHOPageRouteAnalyticsMixin, SHOAppPageMixin, SHOAppTrackedPageMixin {
  @override
  String get pageName => 'settings_notifications';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final prefs = ref.watch(notificationPrefsProvider);
    final notifier = ref.read(notificationPrefsProvider.notifier);

    return buildTrackedPage(
      Scaffold(
        appBar: AppBar(title: Text(l10n.settingsNotificationsTitle)),
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
                l10n.settingsNotificationsHint,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            SHOSettingsGroup(
              title: l10n.settingsNotificationsGroup,
              children: [
                _NotificationSwitchTile(
                  title: l10n.settingsNotifyOrderUpdates,
                  subtitle: l10n.settingsNotifyOrderUpdatesHint,
                  value: prefs.orderUpdates,
                  onChanged: notifier.setOrderUpdates,
                ),
                _NotificationSwitchTile(
                  title: l10n.settingsNotifyPromotions,
                  subtitle: l10n.settingsNotifyPromotionsHint,
                  value: prefs.promotions,
                  onChanged: notifier.setPromotions,
                ),
                _NotificationSwitchTile(
                  title: l10n.settingsNotifyFlashSale,
                  subtitle: l10n.settingsNotifyFlashSaleHint,
                  value: prefs.flashSaleReminders,
                  onChanged: notifier.setFlashSaleReminders,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationSwitchTile extends StatelessWidget {
  const _NotificationSwitchTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: SHOAppSpacing.lg),
      title: Text(title, style: Theme.of(context).textTheme.bodyLarge),
      subtitle: Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
      value: value,
      onChanged: onChanged,
    );
  }
}
