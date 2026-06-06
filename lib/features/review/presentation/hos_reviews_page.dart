import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/hos_spacing.dart';
import '../../../core/widgets/hos_loading_state.dart';
import '../../../l10n/app_localizations.dart';
import 'hos_review_controller.dart';
import 'hos_review_tile.dart';

class SHOReviewsPage extends ConsumerWidget {
  const SHOReviewsPage({super.key, required this.productId});

  final String productId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final reviewsAsync = ref.watch(productReviewsProvider(productId));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.reviewsTitle)),
      body: reviewsAsync.whenLoadingState(
        onRetry: () => ref.invalidate(productReviewsProvider(productId)),
        empty: (summary) => summary.items.isEmpty,
        data: (summary) => ListView.separated(
          padding: const EdgeInsets.all(SHOAppSpacing.pagePadding),
          itemCount: summary.items.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) =>
              SHOReviewTile(review: summary.items[index]),
        ),
      ),
    );
  }
}
