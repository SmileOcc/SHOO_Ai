import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/hos_routes.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../theme/hos_spacing.dart';
import 'hos_debug_native_examples.dart';
import 'hos_debug_native_l10n.dart';

/// 原生交互调试入口：按 Channel 类型分组列出示例。
class SHODebugNativeHubPage extends StatelessWidget {
  const SHODebugNativeHubPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.debugNativeHubTitle)),
      body: ListView(
        padding: const EdgeInsets.all(SHOAppSpacing.xl),
        children: [
          Text(l10n.debugNativeHubHint, style: Theme.of(context).textTheme.bodySmall),
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
                  onTap: () => context.push(SHOAppRoutes.debugNativeExample(example.routeId)),
                ),
              );
            }),
            const SizedBox(height: SHOAppSpacing.lg),
          ],
        ],
      ),
    );
  }
}
