import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/hos_routes.dart';
import '../../../core/auth/hos_auth_guard.dart';
import '../../../core/feedback/hos_toast.dart';
import '../../../core/theme/hos_colors.dart';
import '../../../core/theme/hos_spacing.dart';
import '../../../core/theme/hos_theme_extension.dart';
import '../../../core/widgets/hos_empty_state.dart';
import '../../../core/widgets/hos_error_view.dart';
import '../../../core/widgets/hos_skeleton_box.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/hos_profile_activity_product.dart';
import 'hos_profile_activity_product_tile.dart';
import 'hos_profile_controller.dart';

class SHOProfileActivityListPage extends ConsumerStatefulWidget {
  const SHOProfileActivityListPage({
    super.key,
    required this.kind,
  });

  final SHOProfileActivityListKind kind;

  @override
  ConsumerState<SHOProfileActivityListPage> createState() =>
      _SHOProfileActivityListPageState();
}

class _SHOProfileActivityListPageState
    extends ConsumerState<SHOProfileActivityListPage> {
  var _editing = false;
  final _selected = <String>{};

  bool get _isFootprints => widget.kind == SHOProfileActivityListKind.footprints;

  void _invalidateItems() {
    if (_isFootprints) {
      ref.invalidate(profileFootprintActivityProductsProvider);
    } else {
      ref.invalidate(profileFavoriteActivityProductsProvider);
    }
  }

  String _title(AppLocalizations l10n) =>
      _isFootprints ? l10n.profileFootprints : l10n.profileFavorites;

  String _emptyMessage(AppLocalizations l10n) => _isFootprints
      ? l10n.profileFootprintsEmpty
      : l10n.profileFavoritesEmpty;

  void _enterEditMode() {
    setState(() {
      _editing = true;
      _selected.clear();
    });
  }

  void _exitEditMode() {
    setState(() {
      _editing = false;
      _selected.clear();
    });
  }

  void _toggleSelect(String id) {
    setState(() {
      if (_selected.contains(id)) {
        _selected.remove(id);
      } else {
        _selected.add(id);
      }
    });
  }

  void _toggleSelectAll(List<String> ids) {
    setState(() {
      if (_selected.length == ids.length) {
        _selected.clear();
      } else {
        _selected
          ..clear()
          ..addAll(ids);
      }
    });
  }

  Future<void> _deleteSelected() async {
    if (_selected.isEmpty) return;
    final l10n = AppLocalizations.of(context);
    final ids = List<String>.from(_selected);
    final notifier = ref.read(profileActivityProvider.notifier);
    if (_isFootprints) {
      await notifier.removeFootprints(ids);
    } else {
      await notifier.removeFavorites(ids);
    }
    _invalidateItems();
    _exitEditMode();
    if (!mounted) return;
    SHOAppToast.success(l10n.profileActivityDeleted(ids.length));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.shoTheme;
    final itemsAsync = _isFootprints
        ? ref.watch(profileFootprintActivityProductsProvider)
        : ref.watch(profileFavoriteActivityProductsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _editing
              ? l10n.profileActivitySelected(_selected.length)
              : _title(l10n),
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        leading: _editing
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: _exitEditMode,
              )
            : null,
        actions: [
          if (_editing)
            TextButton(
              onPressed: itemsAsync.maybeWhen(
                data: (items) => items.isEmpty
                    ? null
                    : () => _toggleSelectAll(
                          items.map((e) => e.id).toList(),
                        ),
                orElse: () => null,
              ),
              child: Text(l10n.profileActivitySelectAll),
            )
          else
            TextButton(
              onPressed: itemsAsync.maybeWhen(
                data: (items) => items.isEmpty ? null : _enterEditMode,
                orElse: () => null,
              ),
              child: Text(l10n.profileActivityDelete),
            ),
        ],
      ),
      body: itemsAsync.when(
        loading: () => ListView.separated(
          itemCount: 6,
          separatorBuilder: (_, __) => Divider(height: 1, color: theme.divider),
          itemBuilder: (_, __) => const Padding(
            padding: EdgeInsets.all(SHOAppSpacing.pagePadding),
            child: SHOSkeletonBox(height: 88),
          ),
        ),
        error: (error, _) => SHOAppErrorView(
          message: error.toString(),
          onRetry: _invalidateItems,
        ),
        data: (List<SHOProfileActivityProduct> items) {
          if (items.isEmpty) {
            return SHOEmptyState(
              title: _emptyMessage(l10n),
              actionLabel: l10n.cartEmptyAction,
              onAction: () => context.go(SHOAppRoutes.home),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  itemCount: items.length,
                  separatorBuilder: (_, __) =>
                      Divider(height: 1, color: theme.divider),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return SHOProfileActivityProductTile(
                      item: item,
                      editing: _editing,
                      selected: _selected.contains(item.id),
                      onToggleSelect: () => _toggleSelect(item.id),
                      onTap: () {
                        if (!SHOAuthGuard.requireAuth(context, ref)) return;
                        context.push(SHOAppRoutes.product(item.id));
                      },
                    );
                  },
                ),
              ),
              if (_editing)
                _DeleteBar(
                  count: _selected.length,
                  onDelete: _selected.isEmpty ? null : _deleteSelected,
                ),
            ],
          );
        },
      ),
    );
  }
}

class _DeleteBar extends StatelessWidget {
  const _DeleteBar({
    required this.count,
    required this.onDelete,
  });

  final int count;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.shoTheme;

    return Material(
      color: theme.surfaceMuted,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: SHOAppSpacing.pagePadding,
            vertical: SHOAppSpacing.md,
          ),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onDelete,
              style: FilledButton.styleFrom(
                backgroundColor:
                    onDelete == null ? theme.textMuted : SHOAppColors.error,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: SHOAppSpacing.lg),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(SHOAppSpacing.cardRadius),
                ),
              ),
              child: Text(
                l10n.profileActivityDeleteSelected(count),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
