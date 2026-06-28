import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:shoo/app/router/hos_routes.dart';
import 'package:shoo/core/analytics/hos_page_analytics.dart';
import 'package:shoo/core/pages/hos_pages.dart';
import 'package:shoo/core/theme/hos_spacing.dart';
import 'package:shoo/core/widgets/hos_button.dart';
import 'package:shoo/core/widgets/hos_empty_state.dart';
import 'package:shoo/l10n/app_localizations.dart';

/// 全局 404 页，由 [GoRouter.errorBuilder] 渲染。
class SHONotFoundPage extends ConsumerStatefulWidget {
  const SHONotFoundPage({super.key, this.location});

  final String? location;

  @override
  ConsumerState<SHONotFoundPage> createState() => _SHONotFoundPageState();
}

class _SHONotFoundPageState extends ConsumerState<SHONotFoundPage>
    with SHOPageRouteAnalyticsMixin, SHOAppPageMixin, SHOAppTrackedPageMixin {
  @override
  String get pageName => 'not_found';

  @override
  Map<String, Object?> get pageAnalyticsExtra => {
    if (widget.location != null && widget.location!.isNotEmpty)
      'location': widget.location,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return buildTrackedPage(
      Scaffold(
        appBar: AppBar(title: Text(l10n.notFoundTitle)),
        body: Padding(
          padding: const EdgeInsets.all(SHOAppSpacing.pagePadding),
          child: SHOEmptyState(
            icon: Icons.travel_explore_outlined,
            title: l10n.notFoundTitle,
            subtitle: widget.location == null || widget.location!.isEmpty
                ? l10n.notFoundMessage
                : l10n.notFoundLocation(widget.location!),
            actionLabel: l10n.notFoundGoHome,
            onAction: () => context.go(SHOAppRoutes.home),
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(SHOAppSpacing.pagePadding),
            child: SHOAppButton(
              label: l10n.notFoundGoHome,
              isExpanded: true,
              onPressed: () => context.go(SHOAppRoutes.home),
            ),
          ),
        ),
      ),
    );
  }
}
