import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/hos_colors.dart';
import '../../../core/theme/hos_spacing.dart';
import '../../../core/theme/hos_theme_extension.dart';
import '../../../l10n/app_localizations.dart';
import '../../home/domain/hos_product.dart';
import 'hos_category_controller.dart';
import 'hos_category_sort.dart';

List<SHOProduct> applyCategoryProductFilters(
  List<SHOProduct> products, {
  required SHOCategorySort sort,
  required SHOCategoryProductFilter filter,
}) {
  var result = List<SHOProduct>.from(products);

  final min = filter.minPrice;
  final max = filter.maxPrice;
  if (min != null) {
    result = result.where((p) => p.price >= min).toList();
  }
  if (max != null) {
    result = result.where((p) => p.price <= max).toList();
  }

  switch (filter.priceSort) {
    case SHOCategoryPriceSort.defaultSort:
      return sortCategoryProducts(result, sort);
    case SHOCategoryPriceSort.highToLow:
      result.sort((a, b) => b.price.compareTo(a.price));
      return result;
    case SHOCategoryPriceSort.lowToHigh:
      result.sort((a, b) => a.price.compareTo(b.price));
      return result;
  }
}

bool isCategoryProductPriceRangeValid({
  int? minPrice,
  int? maxPrice,
}) {
  if (minPrice == null || maxPrice == null) return true;
  return maxPrice > minPrice;
}

class SHOCategoryFilterButton extends ConsumerWidget {
  const SHOCategoryFilterButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final panelOpen = ref.watch(categoryProductFilterPanelOpenProvider);
    final theme = context.shoTheme;
    final highlighted = panelOpen;

    return Material(
      color: highlighted
          ? SHOAppColors.accent.withValues(alpha: 0.12)
          : theme.surfaceMuted,
      borderRadius: BorderRadius.circular(SHOAppSpacing.cardRadius),
      child: InkWell(
        onTap: () {
          ref.read(categoryProductFilterPanelOpenProvider.notifier).state =
              !panelOpen;
        },
        borderRadius: BorderRadius.circular(SHOAppSpacing.cardRadius),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: SHOAppSpacing.md,
            vertical: SHOAppSpacing.sm,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.tune_rounded,
                size: 16,
                color: highlighted ? SHOAppColors.accent : theme.textSecondary,
              ),
              const SizedBox(width: SHOAppSpacing.xs),
              Text(
                l10n.categoryFilter,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight:
                          highlighted ? FontWeight.w700 : FontWeight.w500,
                      color:
                          highlighted ? SHOAppColors.accent : theme.textSecondary,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SHOCategoryProductFilterPanel extends ConsumerStatefulWidget {
  const SHOCategoryProductFilterPanel({super.key});

  @override
  ConsumerState<SHOCategoryProductFilterPanel> createState() =>
      _SHOCategoryProductFilterPanelState();
}

class _SHOCategoryProductFilterPanelState
    extends ConsumerState<SHOCategoryProductFilterPanel> {
  late final TextEditingController _minCtrl;
  late final TextEditingController _maxCtrl;
  String? _priceError;

  @override
  void initState() {
    super.initState();
    final filter = ref.read(categoryProductFilterProvider);
    _minCtrl = TextEditingController(
      text: filter.minPrice?.toString() ?? '',
    );
    _maxCtrl = TextEditingController(
      text: filter.maxPrice?.toString() ?? '',
    );
    _minCtrl.addListener(_onPriceChanged);
    _maxCtrl.addListener(_onPriceChanged);
  }

  @override
  void dispose() {
    _minCtrl
      ..removeListener(_onPriceChanged)
      ..dispose();
    _maxCtrl
      ..removeListener(_onPriceChanged)
      ..dispose();
    super.dispose();
  }

  int? _parsePrice(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    return int.tryParse(trimmed);
  }

  void _onPriceChanged() {
    final l10n = AppLocalizations.of(context);
    final min = _parsePrice(_minCtrl.text);
    final max = _parsePrice(_maxCtrl.text);

    if (!isCategoryProductPriceRangeValid(minPrice: min, maxPrice: max)) {
      setState(() {
        _priceError = l10n.categoryFilterPriceInvalid;
      });
      return;
    }

    setState(() => _priceError = null);
    ref.read(categoryProductFilterProvider.notifier).state =
        ref.read(categoryProductFilterProvider).copyWith(
              minPrice: () => min,
              maxPrice: () => max,
            );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.shoTheme;
    final filter = ref.watch(categoryProductFilterProvider);

    return Material(
      color: context.shoSurface,
      elevation: 2,
      shadowColor: Colors.black26,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(SHOAppSpacing.xl),
          bottomRight: Radius.circular(SHOAppSpacing.xl),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          SHOAppSpacing.pagePadding,
          SHOAppSpacing.md,
          SHOAppSpacing.pagePadding,
          SHOAppSpacing.lg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.categoryFilterPriceRange,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: SHOAppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: _PriceField(
                    controller: _minCtrl,
                    hint: l10n.categoryFilterMinPrice,
                    hasError: _priceError != null,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: SHOAppSpacing.md,
                  ),
                  child: Text(
                    '—',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: theme.textSecondary,
                        ),
                  ),
                ),
                Expanded(
                  child: _PriceField(
                    controller: _maxCtrl,
                    hint: l10n.categoryFilterMaxPrice,
                    hasError: _priceError != null,
                  ),
                ),
              ],
            ),
            if (_priceError != null) ...[
              const SizedBox(height: SHOAppSpacing.xs),
              Text(
                _priceError!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: SHOAppColors.error,
                    ),
              ),
            ],
            const SizedBox(height: SHOAppSpacing.lg),
            Text(
              l10n.categoryFilterSort,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: SHOAppSpacing.sm),
            Wrap(
              spacing: SHOAppSpacing.sm,
              runSpacing: SHOAppSpacing.sm,
              children: [
                _FilterSortChip(
                  label: l10n.categoryFilterSortDefault,
                  selected:
                      filter.priceSort == SHOCategoryPriceSort.defaultSort,
                  onTap: () => _setPriceSort(SHOCategoryPriceSort.defaultSort),
                ),
                _FilterSortChip(
                  label: l10n.categoryFilterSortPriceHigh,
                  selected: filter.priceSort == SHOCategoryPriceSort.highToLow,
                  onTap: () => _setPriceSort(SHOCategoryPriceSort.highToLow),
                ),
                _FilterSortChip(
                  label: l10n.categoryFilterSortPriceLow,
                  selected: filter.priceSort == SHOCategoryPriceSort.lowToHigh,
                  onTap: () => _setPriceSort(SHOCategoryPriceSort.lowToHigh),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _setPriceSort(SHOCategoryPriceSort sort) {
    ref.read(categoryProductFilterProvider.notifier).state =
        ref.read(categoryProductFilterProvider).copyWith(priceSort: sort);
  }
}

class _PriceField extends StatelessWidget {
  const _PriceField({
    required this.controller,
    required this.hint,
    required this.hasError,
  });

  final TextEditingController controller;
  final String hint;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    final theme = context.shoTheme;

    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        hintText: hint,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: SHOAppSpacing.lg,
          vertical: SHOAppSpacing.md,
        ),
        filled: true,
        fillColor: theme.surfaceMuted,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SHOAppSpacing.cardRadius),
          borderSide: BorderSide(color: theme.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SHOAppSpacing.cardRadius),
          borderSide: BorderSide(
            color: hasError ? SHOAppColors.error : theme.border,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SHOAppSpacing.cardRadius),
          borderSide: BorderSide(
            color: hasError ? SHOAppColors.error : SHOAppColors.accent,
          ),
        ),
      ),
    );
  }
}

class _FilterSortChip extends StatelessWidget {
  const _FilterSortChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = context.shoTheme;

    return Material(
      color: selected
          ? SHOAppColors.accent.withValues(alpha: 0.12)
          : theme.surfaceMuted,
      borderRadius: BorderRadius.circular(SHOAppSpacing.cardRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(SHOAppSpacing.cardRadius),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: SHOAppSpacing.lg,
            vertical: SHOAppSpacing.sm,
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected ? SHOAppColors.accent : theme.textSecondary,
                ),
          ),
        ),
      ),
    );
  }
}

class SHOCategoryProductFilterOverlay extends ConsumerWidget {
  const SHOCategoryProductFilterOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final open = ref.watch(categoryProductFilterPanelOpenProvider);
    if (!open) return const SizedBox.shrink();

    void close() {
      ref.read(categoryProductFilterPanelOpenProvider.notifier).state = false;
    }

    final dimColor = Colors.black.withValues(alpha: 0.45);

    return Positioned.fill(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Stack(
            children: [
              Positioned.fill(
                child: ColoredBox(color: dimColor),
              ),
              GestureDetector(
                onTap: () {},
                child: const SHOCategoryProductFilterPanel(),
              ),
            ],
          ),
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: close,
              child: ColoredBox(color: dimColor),
            ),
          ),
        ],
      ),
    );
  }
}
