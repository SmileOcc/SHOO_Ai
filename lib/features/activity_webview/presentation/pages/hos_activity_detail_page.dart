import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:shoo/app/router/hos_routes.dart';
import 'package:shoo/core/widgets/hos_error_view.dart';
import 'package:shoo/features/activity_webview/presentation/state/hos_activity_config_provider.dart';
import 'package:shoo/features/activity_webview/presentation/widgets/hos_activity_promo_section.dart';

class SHOActivityDetailPage extends ConsumerWidget {
  const SHOActivityDetailPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(activityDetailProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('活动详情')),
      body: detailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => SHOAppErrorView(
          message: error.toString(),
          onRetry: () => ref.invalidate(activityDetailProvider),
        ),
        data: (detail) {
          final theme = Theme.of(context);
          return ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              if (detail.bannerUrl != null && detail.bannerUrl!.isNotEmpty)
                AspectRatio(
                  aspectRatio: 2.5,
                  child: Image.network(
                    detail.bannerUrl!,
                    fit: BoxFit.cover,
                  ),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  detail.title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  detail.summary,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SHOActivityPromoSection(blocks: detail.promoBlocks),
              ...detail.sections.map(
                (section) => Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        section.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        section.content,
                        style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                child: FilledButton.icon(
                  onPressed: () => context.push(SHOAppRoutes.activityLevel3Detail),
                  icon: const Icon(Icons.layers_outlined),
                  label: const Text('查看三级详情页'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
