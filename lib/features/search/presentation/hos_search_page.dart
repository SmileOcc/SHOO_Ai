import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/hos_routes.dart';
import '../../../core/theme/hos_colors.dart';
import '../../../core/theme/hos_spacing.dart';
import '../../../core/utils/hos_debouncer.dart';
import '../../../core/widgets/hos_loading_state.dart';
import '../../../core/widgets/hos_product_card.dart';
import '../../../core/widgets/hos_text_field.dart';
import '../../../l10n/app_localizations.dart';
import 'hos_search_controller.dart';

class SHOSearchPage extends ConsumerStatefulWidget {
  const SHOSearchPage({super.key, this.initialQuery});

  final String? initialQuery;

  @override
  ConsumerState<SHOSearchPage> createState() => _SHOSearchPageState();
}

class _SHOSearchPageState extends ConsumerState<SHOSearchPage> {
  late final TextEditingController _controller;
  late final SHODebouncer _debouncer;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _query = widget.initialQuery ?? '';
    _controller = TextEditingController(text: _query);
    _debouncer = SHODebouncer();
  }

  @override
  void dispose() {
    _debouncer.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onQueryChanged(String value) {
    setState(() => _query = value);
    _debouncer.run(() {
      if (mounted) setState(() {});
    });
  }

  void _submitSearch(String value) {
    setState(() => _query = value.trim());
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final hotAsync = ref.watch(searchHotKeywordsProvider);
    final resultsAsync = _query.trim().isEmpty
        ? const AsyncValue<List<dynamic>>.data([])
        : ref.watch(searchResultsProvider(_query.trim()));

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
      body: _query.trim().isEmpty
          ? _SHOSearchSuggestions(
              hotAsync: hotAsync,
              onKeywordTap: (keyword) {
                _controller.text = keyword;
                _submitSearch(keyword);
              },
            )
          : resultsAsync.whenLoadingState(
              onRetry: () => ref.invalidate(searchResultsProvider(_query.trim())),
              empty: (items) => items.isEmpty,
              data: (products) => GridView.builder(
                padding: const EdgeInsets.all(SHOAppSpacing.pagePadding),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: SHOAppSpacing.gridGap,
                  crossAxisSpacing: SHOAppSpacing.gridGap,
                  childAspectRatio: 0.52,
                ),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return SHOProductCard(
                    product: product,
                    onTap: () => context.push(SHOAppRoutes.product(product.id)),
                  );
                },
              ),
            ),
    );
  }
}

class _SHOSearchSuggestions extends StatelessWidget {
  const _SHOSearchSuggestions({
    required this.hotAsync,
    required this.onKeywordTap,
  });

  final AsyncValue<List<String>> hotAsync;
  final ValueChanged<String> onKeywordTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return hotAsync.when(
      loading: () => const SHOAppLoadingState(state: SHOLoadingState.loading),
      error: (_, __) => SHOAppLoadingState(
        state: SHOLoadingState.error,
        message: l10n.loadFailed,
      ),
      data: (keywords) => ListView(
        padding: const EdgeInsets.all(SHOAppSpacing.pagePadding),
        children: [
          Text(
            l10n.searchHotTitle,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: SHOAppSpacing.md),
          Wrap(
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
        ],
      ),
    );
  }
}
