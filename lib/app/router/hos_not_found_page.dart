import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/hos_spacing.dart';
import '../../core/widgets/hos_button.dart';
import '../../core/widgets/hos_empty_state.dart';
import '../../l10n/app_localizations.dart';
import 'hos_routes.dart';

/// 全局 404 页，由 [GoRouter.errorBuilder] 渲染。
class SHONotFoundPage extends StatelessWidget {
  const SHONotFoundPage({super.key, this.location});

  final String? location;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.notFoundTitle)),
      body: Padding(
        padding: const EdgeInsets.all(SHOAppSpacing.pagePadding),
        child: SHOEmptyState(
          icon: Icons.travel_explore_outlined,
          title: l10n.notFoundTitle,
          subtitle: location == null || location!.isEmpty
              ? l10n.notFoundMessage
              : l10n.notFoundLocation(location!),
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
    );
  }
}
