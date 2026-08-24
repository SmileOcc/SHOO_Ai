import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:shoo/app/router/hos_routes.dart';
import 'package:shoo/core/analytics/hos_page_analytics.dart';
import 'package:shoo/core/constants/hos_constants.dart';
import 'package:shoo/core/pages/hos_pages.dart';
import 'package:shoo/core/theme/hos_spacing.dart';
import 'package:shoo/core/theme/hos_theme_extension.dart';
import 'package:shoo/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

class SHOSettingsHelpPage extends ConsumerStatefulWidget {
  const SHOSettingsHelpPage({super.key});

  @override
  ConsumerState<SHOSettingsHelpPage> createState() => _SHOSettingsHelpPageState();
}

class _SHOSettingsHelpPageState extends ConsumerState<SHOSettingsHelpPage>
    with SHOPageRouteAnalyticsMixin, SHOAppPageMixin, SHOAppTrackedPageMixin {
  @override
  String get pageName => 'settings_help';

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  List<({String question, String answer})> _faqItems(AppLocalizations l10n) {
    return [
      (
        question: l10n.settingsHelpFaqOrderTrackQ,
        answer: l10n.settingsHelpFaqOrderTrackA,
      ),
      (
        question: l10n.settingsHelpFaqRefundQ,
        answer: l10n.settingsHelpFaqRefundA,
      ),
      (
        question: l10n.settingsHelpFaqCouponQ,
        answer: l10n.settingsHelpFaqCouponA,
      ),
      (
        question: l10n.settingsHelpFaqAddressQ,
        answer: l10n.settingsHelpFaqAddressA,
      ),
      (
        question: l10n.settingsHelpFaqPaymentQ,
        answer: l10n.settingsHelpFaqPaymentA,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.shoTheme;
    final faqItems = _faqItems(l10n);

    return buildTrackedPage(
      Scaffold(
        appBar: AppBar(title: Text(l10n.settingsHelpTitle)),
        body: ListView(
          padding: const EdgeInsets.only(bottom: SHOAppSpacing.xxxl),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                SHOAppSpacing.pagePadding,
                SHOAppSpacing.lg,
                SHOAppSpacing.pagePadding,
                SHOAppSpacing.sm,
              ),
              child: Text(
                l10n.settingsHelpSubtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: theme.textSecondary,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: SHOAppSpacing.pagePadding,
              ),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: context.shoSurface,
                  borderRadius: BorderRadius.circular(SHOAppSpacing.cardRadius),
                  border: Border.all(color: theme.border),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.chat_bubble_outline, size: 20),
                      title: Text(l10n.settingsHelpContact),
                      subtitle: Text(l10n.settingsHelpContactHint),
                      trailing: Icon(
                        Icons.chevron_right,
                        size: 18,
                        color: theme.textMuted,
                      ),
                      onTap: () => context.push(SHOAppRoutes.messages),
                    ),
                    Divider(height: 1, color: theme.divider, indent: 16),
                    ListTile(
                      leading: const Icon(Icons.replay_outlined, size: 20),
                      title: Text(l10n.settingsHelpAfterSale),
                      trailing: Icon(
                        Icons.chevron_right,
                        size: 18,
                        color: theme.textMuted,
                      ),
                      onTap: () => context.push(SHOAppRoutes.afterSales),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                SHOAppSpacing.xl,
                SHOAppSpacing.xl,
                SHOAppSpacing.xl,
                SHOAppSpacing.sm,
              ),
              child: Text(
                l10n.settingsHelpFaqTitle,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: theme.textMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: SHOAppSpacing.pagePadding,
              ),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: context.shoSurface,
                  borderRadius: BorderRadius.circular(SHOAppSpacing.cardRadius),
                  border: Border.all(color: theme.border),
                ),
                child: Column(
                  children: [
                    for (var i = 0; i < faqItems.length; i++) ...[
                      if (i > 0) Divider(height: 1, color: theme.divider),
                      Theme(
                        data: Theme.of(context).copyWith(
                          dividerColor: Colors.transparent,
                        ),
                        child: ExpansionTile(
                          tilePadding: const EdgeInsets.symmetric(
                            horizontal: SHOAppSpacing.lg,
                          ),
                          childrenPadding: const EdgeInsets.fromLTRB(
                            SHOAppSpacing.lg,
                            0,
                            SHOAppSpacing.lg,
                            SHOAppSpacing.lg,
                          ),
                          title: Text(
                            faqItems[i].question,
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(fontSize: 14),
                          ),
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                faqItems[i].answer,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: theme.textSecondary,
                                      height: 1.5,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: SHOAppSpacing.xl),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: SHOAppSpacing.pagePadding,
              ),
              child: DecoratedBox(
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
            ),
          ],
        ),
      ),
    );
  }
}
