import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shoo/core/pages/hos_pages.dart';
import 'package:shoo/core/theme/hos_spacing.dart';
import 'package:shoo/core/theme/hos_theme_extension.dart';
import 'package:shoo/l10n/app_localizations.dart';
import 'package:shoo/features/review/presentation/widgets/hos_review_submit_sheet.dart';
import 'package:shoo/features/review/presentation/widgets/hos_review_tile.dart';
import 'package:shoo/features/review/presentation/state/hos_reviews_paged_controller.dart';
import 'package:shoo/features/review/domain/entities/hos_review.dart';

class SHOReviewsPage extends SHOPagedDataPage<SHOProductReview> {
  const SHOReviewsPage({super.key, required this.productId});

  final String productId;

  @override
  SHOPagedDataPageState<SHOProductReview, SHOReviewsPagedState, SHOReviewsPage>
      createState() => _SHOReviewsPageState();
}

class _SHOReviewsPageState extends SHOPagedDataPageState<SHOProductReview,
    SHOReviewsPagedState, SHOReviewsPage> {
  final _scrollController = ScrollController();

  @override
  ProviderListenable<AsyncValue<SHOReviewsPagedState>> get pagedProvider =>
      reviewsPagedProvider(widget.productId);

  @override
  String get pageName => 'reviews';

  @override
  Map<String, Object?> get pageAnalyticsExtra => {'product_id': widget.productId};

  @override
  ScrollController? get scrollController => _scrollController;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void refreshPaged(WidgetRef ref) =>
      ref.read(reviewsPagedProvider(widget.productId).notifier).refresh(
            widget.productId,
          );

  @override
  void loadMorePaged(WidgetRef ref) =>
      ref.read(reviewsPagedProvider(widget.productId).notifier).loadMore(
            widget.productId,
          );

  @override
  PreferredSizeWidget? buildPageAppBar(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return AppBar(title: Text(l10n.reviewsTitle));
  }

  @override
  Widget? buildFloatingActionButton(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return FloatingActionButton.extended(
      onPressed: () => SHOReviewSubmitSheet.show(
        context,
        productId: widget.productId,
      ),
      icon: const Icon(Icons.rate_review_outlined),
      label: Text(l10n.reviewSubmitAction),
    );
  }

  @override
  String? emptyMessage(BuildContext context) =>
      AppLocalizations.of(context).reviewsEmpty;

  @override
  Widget? buildListHeader(
    BuildContext context,
    WidgetRef ref,
    SHOReviewsPagedState paged,
  ) {
    final summary = paged.summary;
    if (summary == null) return null;
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        SHOAppSpacing.pagePadding,
        SHOAppSpacing.pagePadding,
        SHOAppSpacing.pagePadding,
        SHOAppSpacing.sm,
      ),
      child: Row(
        children: [
          Text(
            '${summary.averageRating}',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(width: SHOAppSpacing.sm),
          Text(
            l10n.reviewsCount(summary.totalCount),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  @override
  IndexedWidgetBuilder? get separatorBuilder =>
      (_, __) => Divider(height: 1, color: context.shoTheme.divider);

  @override
  Widget buildPagedItem(
    BuildContext context,
    WidgetRef ref,
    SHOProductReview item,
    int index,
  ) {
    return SHOReviewTile(review: item);
  }
}
