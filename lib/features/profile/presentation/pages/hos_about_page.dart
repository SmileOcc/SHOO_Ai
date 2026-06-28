import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:shoo/core/analytics/hos_page_analytics.dart';
import 'package:shoo/core/constants/hos_constants.dart';
import 'package:shoo/core/pages/hos_pages.dart';
import 'package:shoo/core/theme/hos_spacing.dart';
import 'package:shoo/core/theme/hos_theme_extension.dart';
import 'package:shoo/l10n/app_localizations.dart';

class SHOAboutPage extends ConsumerStatefulWidget {
  const SHOAboutPage({super.key});

  @override
  ConsumerState<SHOAboutPage> createState() => _SHOAboutPageState();
}

class _SHOAboutPageState extends ConsumerState<SHOAboutPage>
    with SHOPageRouteAnalyticsMixin, SHOAppPageMixin, SHOAppTrackedPageMixin {
  @override
  String get pageName => 'about';

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.shoTheme;

    return buildTrackedPage(
      Scaffold(
        appBar: AppBar(title: Text(l10n.settingsAbout)),
        body: ListView(
          padding: const EdgeInsets.all(SHOAppSpacing.pagePadding),
          children: [
            const SizedBox(height: SHOAppSpacing.xl),
            Center(
              child: Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: theme.surfaceMuted,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: theme.border),
                ),
                child: Icon(
                  Icons.shopping_bag_outlined,
                  size: 44,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: SHOAppSpacing.lg),
            Center(
              child: Text(
                SHOAppConstants.appName,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(height: SHOAppSpacing.xs),
            Center(
              child: Text(
                'v${SHOAppConstants.appVersion}',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: theme.textMuted),
              ),
            ),
            const SizedBox(height: SHOAppSpacing.xl),
            Text(
              l10n.settingsAboutDescription,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 14,
                height: 1.6,
                color: theme.textSecondary,
              ),
            ),
            const SizedBox(height: SHOAppSpacing.xxxl),
            DecoratedBox(
              decoration: BoxDecoration(
                color: context.shoSurface,
                borderRadius: BorderRadius.circular(SHOAppSpacing.cardRadius),
                border: Border.all(color: theme.border),
              ),
              child: Column(
                children: [
                  ListTile(
                    title: Text(l10n.settingsPrivacyPolicy),
                    trailing: Icon(
                      Icons.open_in_new,
                      size: 18,
                      color: theme.textMuted,
                    ),
                    onTap: () => _openUrl(SHOAppConstants.privacyPolicyUrl),
                  ),
                  Divider(height: 1, color: theme.divider, indent: 16),
                  ListTile(
                    title: Text(l10n.settingsTermsOfService),
                    trailing: Icon(
                      Icons.open_in_new,
                      size: 18,
                      color: theme.textMuted,
                    ),
                    onTap: () => _openUrl(SHOAppConstants.termsOfServiceUrl),
                  ),
                ],
              ),
            ),
            const SizedBox(height: SHOAppSpacing.xxxl),
            Center(
              child: Text(
                l10n.settingsCompanyName,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: theme.textMuted,
                  letterSpacing: 0.8,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: SHOAppSpacing.xxxl),
          ],
        ),
      ),
    );
  }
}
