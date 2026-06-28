import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:shoo/app/router/hos_routes.dart';
import 'package:shoo/core/pages/hos_pages.dart';
import 'package:shoo/l10n/app_localizations.dart';
import 'package:shoo/core/theme/hos_spacing.dart';
import 'package:shoo/core/debug/modules/native/hos_debug_native_examples.dart';
import 'package:shoo/core/debug/modules/native/hos_debug_native_l10n.dart';

/// 原生交互调试入口：按 Channel 类型分组列出示例。
class SHODebugNativeHubPage extends ConsumerStatefulWidget {
  const SHODebugNativeHubPage({super.key});

  @override
  ConsumerState<SHODebugNativeHubPage> createState() =>
      _SHODebugNativeHubPageState();
}

class _SHODebugNativeHubPageState extends ConsumerState<SHODebugNativeHubPage>
    with SHOPageRouteAnalyticsMixin, SHOAppPageMixin, SHOAppTrackedPageMixin {
  @override
  String get pageName => 'debug_native_hub';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return buildTrackedPage(
      Scaffold(
        appBar: AppBar(title: Text(l10n.debugNativeHubTitle)),
        body: ListView(
          padding: const EdgeInsets.all(SHOAppSpacing.xl),
          children: [
            Text(
              l10n.debugNativeHubHint,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: SHOAppSpacing.xl),
            for (final category in SHONativeDebugCategory.values) ...[
              Text(
                l10n.nativeCategoryTitle(category),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: SHOAppSpacing.sm),
              ...nativeDebugExamplesByCategory(category).map((example) {
                return Card(
                  margin: const EdgeInsets.only(bottom: SHOAppSpacing.md),
                  child: ListTile(
                    leading: Icon(example.icon),
                    title: Text(l10n.nativeExampleTitle(example.id)),
                    subtitle: Text(
                      l10n.nativeExampleDesc(example.id),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push(
                      SHOAppRoutes.debugNativeExample(example.routeId),
                    ),
                  ),
                );
              }),
              const SizedBox(height: SHOAppSpacing.lg),
            ],
          ],
        ),
      ),
    );
  }
}
