import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/hos_routes.dart';
import '../../../core/feedback/hos_toast.dart';
import '../../../core/theme/hos_colors.dart';
import '../../../core/theme/hos_spacing.dart';
import '../../../core/utils/hos_debouncer.dart';
import '../../../core/widgets/hos_loading_state.dart';
import '../../../core/widgets/hos_paged_scroll_view.dart';
import '../../../core/widgets/hos_product_card.dart';
import '../../../core/widgets/hos_text_field.dart';
import '../../../l10n/app_localizations.dart';
import 'hos_search_controller.dart';
import 'hos_search_history_provider.dart';
import 'hos_search_paged_controller.dart';

class SHOSearchPage extends ConsumerStatefulWidget {
  const SHOSearchPage({super.key, this.initialQuery});

  final String? initialQuery;

  @override
  ConsumerState<SHOSearchPage> createState() => _SHOSearchPageState();
}

class _SHOSearchPageState extends ConsumerState<SHOSearchPage> {
  late final TextEditingController _controller;
  late final SHODebouncer _debouncer;
  late final ScrollController _scrollController;
  String _query = '';

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
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final hotAsync = ref.watch(searchHotKeywordsProvider);
    final historyAsync = ref.watch(searchHistoryProvider);
    final trimmed = _query.trim();
    final resultsAsync = trimmed.isEmpty
        ? null
        : ref.watch(searchPagedProvider(trimmed));

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
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
          : resultsAsync!.when(
              loading: () => const SHOAppLoadingState(
                state: SHOLoadingState.loading,
                loadingWidget: SHOAppListSkeleton(itemCount: 4, itemHeight: 200),
              ),
              error: (error, _) => SHOAppLoadingState(
                state: SHOLoadingState.error,
                message: error.toString(),
                onRetry: () => ref.invalidate(searchPagedProvider(trimmed)),
              ),
              data: (paged) {
                if (paged.items.isEmpty) {
                  return SHOAppLoadingState(
                    state: SHOLoadingState.empty,
                    message: l10n.searchNoResults,
                  );
                }
                return SHOPagedGridView(
                  controller: _scrollController,
                  itemCount: paged.items.length,
                  onRefresh: () =>
                      ref.read(searchPagedProvider(trimmed).notifier).refresh(trimmed),
                  onLoadMore: () =>
                      ref.read(searchPagedProvider(trimmed).notifier).loadMore(trimmed),
                  isLoadingMore: paged.isLoadingMore,
                  hasMore: paged.hasMore,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: SHOAppSpacing.gridGap,
                    crossAxisSpacing: SHOAppSpacing.gridGap,
                    childAspectRatio: 0.52,
                  ),
                  itemBuilder: (context, index) {
                    final product = paged.items[index];
                    return SHOProductCard(
                      product: product,
                      onTap: () => context.push(SHOAppRoutes.product(product.id)),
                    );
                  },
                );
              },
            ),
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
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
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
                          backgroundColor: SHOAppColors.surface,
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
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: SHOAppSpacing.md),
        hotAsync.when(
          loading: () => const SHOAppLoadingState(state: SHOLoadingState.loading),
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
                    backgroundColor: SHOAppColors.surfaceMuted,
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
