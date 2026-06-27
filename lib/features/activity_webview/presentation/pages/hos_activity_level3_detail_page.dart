import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shoo/core/pages/hos_pages.dart';
import 'package:shoo/features/activity_webview/domain/entities/hos_activity_detail.dart';
import 'package:shoo/features/activity_webview/presentation/state/hos_activity_config_provider.dart';

class SHOActivityLevel3DetailPage extends SHODataPage<SHOActivityLevel3Detail> {
  const SHOActivityLevel3DetailPage({super.key});

  @override
  SHODataPageState<SHOActivityLevel3Detail, SHOActivityLevel3DetailPage>
      createState() => _SHOActivityLevel3DetailPageState();
}

class _SHOActivityLevel3DetailPageState
    extends SHODataPageState<SHOActivityLevel3Detail, SHOActivityLevel3DetailPage> {
  @override
  ProviderListenable<AsyncValue<SHOActivityLevel3Detail>> get dataProvider =>
      activityLevel3DetailProvider;

  @override
  void invalidateData(WidgetRef ref) =>
      ref.invalidate(activityLevel3DetailProvider);

  @override
  String get pageName => 'activity_level3_detail';

  @override
  PreferredSizeWidget? buildPageAppBar(BuildContext context, WidgetRef ref) {
    return AppBar(title: const Text('三级详情'));
  }

  @override
  Widget buildContent(
    BuildContext context,
    WidgetRef ref,
    SHOActivityLevel3Detail detail,
  ) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          detail.title,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          detail.summary,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 20),
        ...detail.items.map(
          (item) => Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (item.time != null && item.time!.isNotEmpty)
                    Text(
                      item.time!,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  if (item.time != null && item.time!.isNotEmpty)
                    const SizedBox(height: 4),
                  Text(
                    item.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.content,
                    style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
