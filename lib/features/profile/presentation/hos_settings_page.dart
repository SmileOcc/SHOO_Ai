import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/hos_locale_provider.dart';
import '../../../core/theme/hos_spacing.dart';
import '../../../core/theme/hos_theme_mode_provider.dart';
import '../../../l10n/app_localizations.dart';

class SHOSettingsPage extends ConsumerWidget {
  const SHOSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        children: [
          _SHOSectionTitle(title: l10n.settingsTheme),
          RadioListTile<ThemeMode>(
            title: Text(l10n.settingsThemeSystem),
            value: ThemeMode.system,
            groupValue: themeMode,
            onChanged: (v) {
              if (v != null) ref.read(themeModeProvider.notifier).setThemeMode(v);
            },
          ),
          RadioListTile<ThemeMode>(
            title: Text(l10n.settingsThemeLight),
            value: ThemeMode.light,
            groupValue: themeMode,
            onChanged: (v) {
              if (v != null) ref.read(themeModeProvider.notifier).setThemeMode(v);
            },
          ),
          RadioListTile<ThemeMode>(
            title: Text(l10n.settingsThemeDark),
            value: ThemeMode.dark,
            groupValue: themeMode,
            onChanged: (v) {
              if (v != null) ref.read(themeModeProvider.notifier).setThemeMode(v);
            },
          ),
          const Divider(height: SHOAppSpacing.xxxl),
          _SHOSectionTitle(title: l10n.settingsLanguage),
          RadioListTile<String>(
            title: Text(l10n.settingsLanguageEn),
            value: 'en',
            groupValue: locale?.languageCode,
            onChanged: (_) => ref.read(localeProvider.notifier).setLocale(const Locale('en')),
          ),
          RadioListTile<String>(
            title: Text(l10n.settingsLanguageZh),
            value: 'zh',
            groupValue: locale?.languageCode ?? 'en',
            onChanged: (_) => ref.read(localeProvider.notifier).setLocale(const Locale('zh')),
          ),
        ],
      ),
    );
  }
}

class _SHOSectionTitle extends StatelessWidget {
  const _SHOSectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        SHOAppSpacing.xl,
        SHOAppSpacing.lg,
        SHOAppSpacing.xl,
        SHOAppSpacing.sm,
      ),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
      ),
    );
  }
}
