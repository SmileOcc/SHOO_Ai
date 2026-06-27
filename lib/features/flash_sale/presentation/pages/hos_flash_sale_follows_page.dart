import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:shoo/app/router/hos_routes.dart';
import 'package:shoo/core/theme/hos_colors.dart';
import 'package:shoo/core/theme/hos_spacing.dart';
import 'package:shoo/core/widgets/hos_empty_state.dart';
import 'package:shoo/core/widgets/hos_error_view.dart';
import 'package:shoo/core/widgets/hos_promo_badge.dart';
import 'package:shoo/features/flash_sale/domain/entities/hos_flash_sale_models.dart';
import 'package:shoo/features/flash_sale/presentation/state/hos_flash_sale_follow_controller.dart';
import 'package:shoo/l10n/app_localizations.dart';

class SHOFlashSaleFollowsPage extends ConsumerWidget {
  const SHOFlashSaleFollowsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final followsAsync = ref.watch(flashSaleFollowControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.profileActivityFlashSale,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: followsAsync.when(// 使用 .when() 模式匹配处理三种状态
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => SHOAppErrorView(
          message: error.toString(),
          onRetry: () =>
              ref.read(flashSaleFollowControllerProvider.notifier).syncFromServer(),
        ),
        data: (follows) {
          if (follows.isEmpty) {
            return SHOEmptyState(
              title: l10n.flashSaleFollowsEmpty,
              actionLabel: l10n.flashSaleTitle,
              onAction: () => context.push(SHOAppRoutes.flashSale),
            );
          }
          return RefreshIndicator(
            onRefresh: () =>
                ref.read(flashSaleFollowControllerProvider.notifier).syncFromServer(),
            child: ListView.separated(
              padding: const EdgeInsets.all(SHOAppSpacing.pagePadding),
              itemCount: follows.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: SHOAppSpacing.md),
              itemBuilder: (context, index) {
                final follow = follows[index];
                return _FollowTile(follow: follow);
              },
            ),
          );
        },
      ),
    );
  }
}

class _FollowTile extends StatelessWidget {
  const _FollowTile({required this.follow});

  final SHOFlashSaleFollow follow;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return InkWell(
      onTap: () => context.push(
        '${SHOAppRoutes.product(follow.productId)}?sessionId=${Uri.encodeComponent(follow.sessionId)}',
      ),
      borderRadius: BorderRadius.circular(SHOAppSpacing.cardRadius),
      child: Container(
        padding: const EdgeInsets.all(SHOAppSpacing.md),
        decoration: BoxDecoration(
          border: Border.all(color: SHOAppColors.border),
          borderRadius: BorderRadius.circular(SHOAppSpacing.cardRadius),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(SHOAppSpacing.cardRadius),
              child: CachedNetworkImage(
                imageUrl: follow.imageUrl,
                width: 64,
                height: 64,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: SHOAppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    follow.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: SHOAppSpacing.xs),
                  Text(
                    follow.sessionStartAt,
                    style: const TextStyle(
                      fontSize: 11,
                      color: SHOAppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            SHOPromoBadge(
              type: SHOPromoBadgeType.status,
              label: _statusLabel(follow.status, l10n),
              preset: SHOPromoBadgePreset.wrapTag,
              enabled: follow.status == SHOFlashSaleProductStatus.notStarted ||
                  follow.status == SHOFlashSaleProductStatus.ongoing,
            ),
          ],
        ),
      ),
    );
  }

  String _statusLabel(SHOFlashSaleProductStatus status, AppLocalizations l10n) {
    switch (status) {
      case SHOFlashSaleProductStatus.notStarted:
        return l10n.flashSaleStatusNotStarted;
      case SHOFlashSaleProductStatus.ongoing:
        return l10n.flashSaleStatusOngoing;
      case SHOFlashSaleProductStatus.ended:
        return l10n.flashSaleStatusEnded;
      case SHOFlashSaleProductStatus.soldOut:
        return l10n.flashSaleSoldOut;
    }
  }
}
