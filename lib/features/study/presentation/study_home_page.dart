import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/analytics/hos_page_analytics.dart';
import '../../../app/router/hos_routes.dart';
import '../../../core/theme/hos_spacing.dart';
import '../../../core/theme/hos_theme_extension.dart';
import '../../../core/widgets/hos_profile_section_card.dart';
import '../../../l10n/app_localizations.dart';
import '../data/study_catalog.dart';
import '../domain/study_article.dart';

class SHOStudyHomePage extends StatelessWidget {
  const SHOStudyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SHOPageAnalyticsBinder(
      pageName: 'SHOStudyHomePage',
      child: Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.studyTitle,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(SHOAppSpacing.pagePadding),
        children: [
          Text(
            l10n.studyHomeSubtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: context.shoTheme.textSecondary,
                ),
          ),
          const SizedBox(height: SHOAppSpacing.lg),
          _StudySection(
            title: l10n.studySectionFlutterMobile,
            articles: SHOStudyCatalog.articles
                .where(
                  (article) =>
                      article.category == SHOStudyCatalog.flutterMobileCategory,
                )
                .toList(),
          ),
        ],
      ),
      ),
    );
  }
}

class _StudySection extends StatelessWidget {
  const _StudySection({
    required this.title,
    required this.articles,
  });

  final String title;
  final List<SHOStudyArticle> articles;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: SHOAppSpacing.xs,
            bottom: SHOAppSpacing.sm,
          ),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
        ),
        SHOProfileSectionCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (var i = 0; i < articles.length; i++) ...[
                if (i > 0) const Divider(height: 1),
                _StudyArticleTile(article: articles[i]),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _StudyArticleTile extends StatelessWidget {
  const _StudyArticleTile({required this.article});

  final SHOStudyArticle article;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: article.color.withValues(alpha: 0.15),
        child: Icon(article.icon, color: article.color, size: 22),
      ),
      title: Text(
        article.title,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      subtitle: Text(article.subtitle),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: () => context.push(SHOAppRoutes.toolboxStudyArticleFor(article.id)),
    );
  }
}
