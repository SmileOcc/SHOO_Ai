import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shoo/app/router/hos_routes.dart';
import 'package:shoo/core/config/hos_config.dart';
import 'package:shoo/core/theme/hos_spacing.dart';
import 'package:shoo/features/theme_activity/domain/entities/hos_theme_activity_config.dart';

class SHOThemeActivityTemplatesPage extends ConsumerWidget {
  const SHOThemeActivityTemplatesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = SHOAppConfig.instance;
    final sourceLabel = config.useMockApi
        ? 'Mock 本地 JSON'
        : '远程 API · ${config.apiBaseUrl}';

    return Scaffold(
      appBar: AppBar(title: const Text('主题活动 ThemeActivity')),
      body: ListView.separated(
        padding: const EdgeInsets.all(SHOAppSpacing.pagePadding),
        itemCount: SHOThemeActivityTemplate.presets.length + 1,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          if (index == 0) {
            return Card(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: ListTile(
                leading: Icon(
                  config.useMockApi ? Icons.storage_outlined : Icons.cloud_outlined,
                ),
                title: const Text('配置来源'),
                subtitle: Text(sourceLabel),
                trailing: config.useMockApi
                    ? const Chip(label: Text('Mock'))
                    : const Chip(label: Text('Remote')),
              ),
            );
          }

          final item = SHOThemeActivityTemplate.presets[index - 1];
          return Card(
            child: ListTile(
              title: Text(item.title),
              subtitle: Text(item.description),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(
                SHOAppRoutes.themeActivityFor(item.activityId),
              ),
            ),
          );
        },
      ),
    );
  }
}
