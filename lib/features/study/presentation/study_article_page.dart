import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../../../core/analytics/hos_page_analytics.dart';
import '../../../core/theme/hos_colors.dart';
import '../../../core/theme/hos_spacing.dart';
import '../../../core/theme/hos_theme_extension.dart';
import '../../../core/widgets/hos_empty_state.dart';
import '../data/study_catalog.dart';

class SHOStudyArticlePage extends StatefulWidget {
  const SHOStudyArticlePage({super.key, required this.articleId});

  final String articleId;

  @override
  State<SHOStudyArticlePage> createState() => _SHOStudyArticlePageState();
}

class _SHOStudyArticlePageState extends State<SHOStudyArticlePage>
    with SHOPageRouteAnalyticsMixin {
  String? _markdown;
  String? _error;
  var _loading = true;

  @override
  String get pageAnalyticsName => 'SHOStudyArticlePage';

  @override
  Map<String, Object?> get pageAnalyticsExtra => {
        'article_id': widget.articleId,
      };

  @override
  void initState() {
    super.initState();
    _loadArticle();
  }

  Future<void> _loadArticle() async {
    final article = SHOStudyCatalog.findById(widget.articleId);
    if (article == null) {
      setState(() {
        _loading = false;
        _error = 'not_found';
      });
      return;
    }

    try {
      final content = await rootBundle.loadString(article.assetPath);
      if (!mounted) return;
      setState(() {
        _markdown = content;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final article = SHOStudyCatalog.findById(widget.articleId);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          article?.title ?? '学习',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: _buildBody(theme),
    );
  }

  Widget _buildBody(ThemeData theme) {
    final shoTheme = context.shoTheme;
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null || _markdown == null) {
      return SHOEmptyState(title: '内容加载失败');
    }

    return Markdown(
      data: _markdown!,
      selectable: true,
      padding: const EdgeInsets.all(SHOAppSpacing.pagePadding),
      styleSheet: MarkdownStyleSheet(
        h1: theme.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w800,
        ),
        h2: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w800,
          height: 1.4,
        ),
        h3: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        p: theme.textTheme.bodyMedium?.copyWith(height: 1.6),
        blockquote: theme.textTheme.bodyMedium?.copyWith(
          color: shoTheme.textSecondary,
        ),
        code: theme.textTheme.bodySmall?.copyWith(
          fontFamily: 'monospace',
          backgroundColor: shoTheme.surfaceMuted,
        ),
        tableHead: theme.textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w700,
        ),
        tableBody: theme.textTheme.bodySmall,
        horizontalRuleDecoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: shoTheme.border),
          ),
        ),
        blockquoteDecoration: BoxDecoration(
          color: SHOAppColors.accent.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(SHOAppSpacing.cardRadius),
          border: Border(
            left: BorderSide(color: SHOAppColors.accent, width: 3),
          ),
        ),
      ),
    );
  }
}
