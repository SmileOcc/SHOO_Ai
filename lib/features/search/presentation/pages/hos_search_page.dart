import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:shoo/app/router/hos_routes.dart';
import 'package:shoo/core/analytics/hos_analytics.dart';
import 'package:shoo/core/analytics/hos_page_analytics.dart';
import 'package:shoo/core/feedback/hos_toast.dart';
import 'package:shoo/core/pages/hos_pages.dart';
import 'package:shoo/core/pagination/hos_paged_list_state.dart';
import 'package:shoo/core/theme/hos_spacing.dart';
import 'package:shoo/core/theme/hos_theme_extension.dart';
import 'package:shoo/core/utils/hos_debouncer.dart';
import 'package:shoo/core/widgets/hos_loading_state.dart';
import 'package:shoo/core/widgets/hos_product_card.dart';
import 'package:shoo/core/widgets/hos_text_field.dart';
import 'package:shoo/features/home/domain/entities/hos_product.dart';
import 'package:shoo/l10n/app_localizations.dart';
import 'package:shoo/features/search/presentation/state/hos_search_controller.dart';
import 'package:shoo/features/search/presentation/state/hos_search_history_provider.dart';
import 'package:shoo/features/search/presentation/state/hos_search_paged_controller.dart';

class SHOSearchPage extends ConsumerStatefulWidget {
  const SHOSearchPage({super.key, this.initialQuery});

  final String? initialQuery;

  @override
  ConsumerState<SHOSearchPage> createState() => _SHOSearchPageState();
}

class _SHOSearchPageState extends ConsumerState<SHOSearchPage>
    with SHOPageRouteAnalyticsMixin, SHOAppPageMixin, SHOAppTrackedPageMixin {
  late final TextEditingController _controller;
  late final SHODebouncer _debouncer;
  late final ScrollController _scrollController;
  String _query = '';

  @override
  String get pageName => 'search';

  @override
  Map<String, Object?> get pageAnalyticsExtra => {
    if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty)
      'initial_query': widget.initialQuery,
  };

  @override
  void initState() {
    super.initState();
    _query = widget.initialQuery ?? '';
    _controller = TextEditingController(text: _query);
    _debouncer = SHODebouncer();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _debouncer.dispose();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onQueryChanged(String value) {
    setState(() => _query = value);
    _debouncer.run(() {
      if (mounted) setState(() {});
    });
  }

  Future<void> _submitSearch(String value) async {
    final keyword = value.trim();
    if (keyword.isEmpty) return;
    setState(() => _query = keyword);
    FocusScope.of(context).unfocus();
    await ref.read(searchHistoryProvider.notifier).add(keyword);
    ref.invalidate(searchPagedProvider(keyword));
    await _trackSearch(keyword);
  }

  Future<void> _trackSearch(String keyword) async {
    var resultCount = 0;
    try {
      final paged = await ref.read(searchPagedProvider(keyword).future);
      resultCount = paged.items.length;
    } catch (_) {}
    await SHOAnalyticsManager.instance.trackEvent(SHOAnalyticsRegistry.search, {
      'keyword': keyword,
      'result_count': resultCount,
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final hotAsync = ref.watch(searchHotKeywordsProvider);
    final historyAsync = ref.watch(searchHistoryProvider);
    final trimmed = _query.trim();

    return buildTrackedPage(
      Scaffold(
        appBar: AppBar(
          titleSpacing: 0,
          backgroundColor: context.shoSurface,
          surfaceTintColor: Colors.transparent,
          scrolledUnderElevation: 0,
          title: Padding(
            padding: const EdgeInsets.only(right: SHOAppSpacing.pagePadding),
            child: SHOAppTextField(
              controller: _controller,
              hint: l10n.searchHint,
              prefixIcon: const Icon(Icons.search, size: 18),
              autofocus: true,
              onChanged: _onQueryChanged,
              onSubmitted: _submitSearch,
            ),
          ),
        ),
        body: trimmed.isEmpty
            ? _SHOSearchSuggestions(
                hotAsync: hotAsync,
                historyAsync: historyAsync,
                onKeywordTap: (keyword) {
                  _controller.text = keyword;
                  _submitSearch(keyword);
                },
                onClearHistory: () async {
                  await ref.read(searchHistoryProvider.notifier).clear();
                  SHOAppToast.info(l10n.searchHistoryCleared);
                },
              )
            : SHOSearchResultsPane(
                query: trimmed,
                scrollController: _scrollController,
              ),
      ),
      onRetry: trimmed.isEmpty
          ? null
          : () => ref.invalidate(searchPagedProvider(trimmed)),
    );
  }
}

class _SHOSearchSuggestions extends StatelessWidget {
  const _SHOSearchSuggestions({
    required this.hotAsync,
    required this.historyAsync,
    required this.onKeywordTap,
    required this.onClearHistory,
  });

  final AsyncValue<List<String>> hotAsync;
  final AsyncValue<List<String>> historyAsync;
  final ValueChanged<String> onKeywordTap;
  final VoidCallback onClearHistory;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.shoTheme;

    return ListView(
      padding: const EdgeInsets.all(SHOAppSpacing.pagePadding),
      children: [
        historyAsync.when(
          data: (history) {
            if (history.isEmpty) return const SizedBox.shrink();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.searchHistoryTitle,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ),
                    TextButton(
                      onPressed: onClearHistory,
                      child: Text(l10n.searchHistoryClear),
                    ),
                  ],
                ),
                const SizedBox(height: SHOAppSpacing.md),
                Wrap(
                  spacing: SHOAppSpacing.sm,
                  runSpacing: SHOAppSpacing.sm,
                  children: history
                      .map(
                        (keyword) => ActionChip(
                          avatar: const Icon(Icons.history, size: 16),
                          label: Text(keyword),
                          backgroundColor: context.shoSurface,
                          side: BorderSide(color: theme.border),
                          onPressed: () => onKeywordTap(keyword),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: SHOAppSpacing.xl),
              ],
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        ),
        Text(
          l10n.searchHotTitle,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: SHOAppSpacing.md),
        hotAsync.when(
          loading: () =>
              const SHOAppLoadingState(state: SHOLoadingState.loading),
          error: (_, __) => SHOAppLoadingState(
            state: SHOLoadingState.error,
            message: l10n.loadFailed,
            onRetry: null,
          ),
          data: (keywords) => Wrap(
            spacing: SHOAppSpacing.sm,
            runSpacing: SHOAppSpacing.sm,
            children: keywords
                .map(
                  (keyword) => ActionChip(
                    label: Text(keyword),
                    backgroundColor: theme.surfaceMuted,
                    side: BorderSide(color: theme.border),
                    onPressed: () => onKeywordTap(keyword),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}

class SHOSearchResultsPane extends SHOPagedDataPage<SHOProduct> {
  const SHOSearchResultsPane({
    super.key,
    required this.query,
    required this.scrollController,
  });

  final String query;
  final ScrollController scrollController;

  @override
  SHOPagedDataPageState<
    SHOProduct,
    SHOPagedListState<SHOProduct>,
    SHOSearchResultsPane
  >
  createState() => _SHOSearchResultsPaneState();
}

class _SHOSearchResultsPaneState
    extends
        SHOPagedDataPageState<
          SHOProduct,
          SHOPagedListState<SHOProduct>,
          SHOSearchResultsPane
        > {
  @override
  bool get embedInParentShell => true;

  @override
  bool get reportContentReadyLoadTime => false;

  @override
  String get pageName => 'search_results';

  @override
  ProviderListenable<AsyncValue<SHOPagedListState<SHOProduct>>>
  get pagedProvider => searchPagedProvider(widget.query);

  @override
  ScrollController? get scrollController => widget.scrollController;

  @override
  SliverGridDelegate get gridDelegate =>
      const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: SHOAppSpacing.lg,
        crossAxisSpacing: SHOAppSpacing.lg,
        childAspectRatio: SHOProductCard.gridChildAspectRatio,
      );

  @override
  void refreshPaged(WidgetRef ref) => ref
      .read(searchPagedProvider(widget.query).notifier)
      .refresh(widget.query);

  @override
  void loadMorePaged(WidgetRef ref) => ref
      .read(searchPagedProvider(widget.query).notifier)
      .loadMore(widget.query);

  @override
  String? emptyMessage(BuildContext context) =>
      AppLocalizations.of(context).searchNoResults;

  @override
  Widget? buildLoading(BuildContext context) {
    return const SHOAppLoadingState(
      state: SHOLoadingState.loading,
      loadingWidget: SHOAppListSkeleton(itemCount: 4, itemHeight: 200),
    );
  }

  @override
  Widget buildPagedItem(
    BuildContext context,
    WidgetRef ref,
    SHOProduct item,
    int index,
  ) {
    return SHOProductCard(
      product: item,
      onTap: () => context.push(SHOAppRoutes.product(item.id)),
    );
  }
}
