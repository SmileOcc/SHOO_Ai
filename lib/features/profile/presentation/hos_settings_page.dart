import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/hos_routes.dart';
import '../../../core/l10n/hos_locale_provider.dart';
import '../../../core/permissions/hos_permission_service.dart';
import '../../../core/theme/hos_spacing.dart';
import '../../../core/theme/hos_theme_extension.dart';
import '../../../core/theme/hos_theme_mode_provider.dart';
import '../../../features/auth/presentation/hos_session_provider.dart';
import '../../../l10n/app_localizations.dart';
import 'hos_settings_group.dart';

class SHOSettingsPage extends ConsumerWidget {
  const SHOSettingsPage({super.key});

  String _themeLabel(AppLocalizations l10n, ThemeMode mode) {
    return switch (mode) {
      ThemeMode.system => l10n.settingsThemeSystem,
      ThemeMode.light => l10n.settingsThemeLight,
      ThemeMode.dark => l10n.settingsThemeDark,
    };
  }

  String _localeLabel(AppLocalizations l10n, Locale? locale) {
    final code = locale?.languageCode ?? 'en';
    return code == 'zh' ? l10n.settingsLanguageZh : l10n.settingsLanguageEn;
  }

  Future<void> _showThemePicker(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final current = ref.read(themeModeProvider);

    final selected = await showModalBottomSheet<ThemeMode>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final mode in ThemeMode.values)
              RadioListTile<ThemeMode>(
                title: Text(_themeLabel(l10n, mode)),
                value: mode,
                groupValue: current,
                onChanged: (value) => Navigator.pop(context, value),
              ),
          ],
        ),
      ),
    );

    if (selected != null) {
      ref.read(themeModeProvider.notifier).setThemeMode(selected);
    }
  }

  Future<void> _showLocalePicker(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final current = ref.read(localeProvider)?.languageCode ?? 'en';

    final selected = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: Text(l10n.settingsLanguageEn),
              value: 'en',
              groupValue: current,
              onChanged: (value) => Navigator.pop(context, value),
            ),
            RadioListTile<String>(
              title: Text(l10n.settingsLanguageZh),
              value: 'zh',
              groupValue: current,
              onChanged: (value) => Navigator.pop(context, value),
            ),
          ],
        ),
      ),
    );

    if (selected != null) {
      ref.read(localeProvider.notifier).setLocale(Locale(selected));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);
    final session = ref.watch(sessionProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.only(bottom: SHOAppSpacing.xxxl),
        children: [
          SHOSettingsGroup(
            title: l10n.settingsGroupGeneral,
            children: [
              SHOSettingsTile(
                title: l10n.settingsTheme,
                subtitle: _themeLabel(l10n, themeMode),
                leading: const Icon(Icons.palette_outlined, size: 20),
                onTap: () => _showThemePicker(context, ref),
              ),
              SHOSettingsTile(
                title: l10n.settingsLanguage,
                subtitle: _localeLabel(l10n, locale),
                leading: const Icon(Icons.language_outlined, size: 20),
                onTap: () => _showLocalePicker(context, ref),
              ),
            ],
          ),
          const SizedBox(height: SHOAppSpacing.lg),
          SHOSettingsGroup(
            title: l10n.settingsGroupAccount,
            children: [
              SHOSettingsTile(
                title: l10n.profileAddresses,
                leading: const Icon(Icons.location_on_outlined, size: 20),
                onTap: () => context.push(SHOAppRoutes.addresses),
              ),
              SHOSettingsTile(
                title: l10n.profileCameraPermission,
                leading: const Icon(Icons.camera_alt_outlined, size: 20),
                trailing: const SizedBox.shrink(),
                onTap: () => ref.read(permissionServiceProvider).requestCamera(),
              ),
            ],
          ),
          const SizedBox(height: SHOAppSpacing.lg),
          SHOSettingsGroup(
            title: l10n.settingsGroupAbout,
            children: [
              SHOSettingsTile(
                title: l10n.settingsAbout,
                leading: const Icon(Icons.info_outline, size: 20),
                onTap: () => context.push(SHOAppRoutes.settingsAbout),
              ),
            ],
          ),
          if (session.isAuthenticated) ...[
            const SizedBox(height: SHOAppSpacing.xxxl),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: SHOAppSpacing.pagePadding),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: context.shoSurface,
                  borderRadius: BorderRadius.circular(SHOAppSpacing.cardRadius),
                  border: Border.all(color: context.shoTheme.border),
                ),
                child: SHOSettingsTile(
                  title: l10n.logout,
                  titleColor: Theme.of(context).colorScheme.error,
                  trailing: const SizedBox.shrink(),
                  onTap: () => ref.read(sessionProvider.notifier).logout(),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
