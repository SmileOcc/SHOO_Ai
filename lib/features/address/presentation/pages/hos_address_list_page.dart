import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:shoo/app/router/hos_routes.dart';
import 'package:shoo/core/pages/hos_pages.dart';
import 'package:shoo/core/theme/hos_colors.dart';
import 'package:shoo/core/theme/hos_spacing.dart';
import 'package:shoo/core/theme/hos_theme_extension.dart';
import 'package:shoo/core/widgets/hos_dialog.dart';
import 'package:shoo/core/widgets/hos_empty_state.dart';
import 'package:shoo/core/widgets/hos_profile_section_card.dart';
import 'package:shoo/l10n/app_localizations.dart';
import 'package:shoo/features/address/domain/entities/hos_address.dart';
import 'package:shoo/features/address/presentation/state/hos_address_controller.dart';

class SHOAddressListPage extends SHOSelectorPage<SHOAddress> {
  const SHOAddressListPage({super.key, required super.selectMode});

  @override
  SHOSelectorPageState<SHOAddress, SHOAddressListPage> createState() =>
      _SHOAddressListPageState();
}

class _SHOAddressListPageState
    extends SHOSelectorPageState<SHOAddress, SHOAddressListPage> {
  @override
  ProviderListenable<AsyncValue<List<SHOAddress>>> get dataProvider =>
      addressesProvider;

  @override
  void invalidateData(WidgetRef ref) =>
      ref.read(addressesProvider.notifier).refresh();

  @override
  String get pageName => 'address_list';

  Future<void> _confirmDelete(SHOAddress address) async {
    final l10n = AppLocalizations.of(context);
    final ok = await SHOAppDialog.confirm(
      context,
      title: l10n.addressDeleteConfirmTitle,
      message: l10n.addressDeleteConfirmMessage,
      confirmLabel: l10n.addressDelete,
      cancelLabel: l10n.dialogCancel,
      isDestructive: true,
    );
    if (!ok || !mounted) return;
    await ref.read(addressesProvider.notifier).delete(address.id);
    if (!mounted) return;
    final deleteMode = ref.read(addressListDeleteModeProvider);
    if (deleteMode && (ref.read(addressesProvider).valueOrNull?.isEmpty ?? true)) {
      ref.read(addressListDeleteModeProvider.notifier).state = false;
    }
  }

  Future<void> _selectAddress(SHOAddress address) async {
    await ref.read(selectedAddressIdProvider.notifier).select(address.id);
    if (!mounted) return;
    popSelectResult(address);
  }

  void _openForm({SHOAddress? address}) {
    if (address == null) {
      context.push(SHOAppRoutes.addressForm);
      return;
    }
    context.push(SHOAppRoutes.addressEdit(address.id));
  }

  @override
  PreferredSizeWidget? buildPageAppBar(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final deleteMode = ref.watch(addressListDeleteModeProvider);

    return AppBar(
      title: Text(
        selectorTitle(
          selectTitle: l10n.addressSelectTitle,
          listTitle: l10n.addressListTitle,
        ),
        style: const TextStyle(fontWeight: FontWeight.w800),
      ),
      leading: deleteMode
          ? IconButton(
              icon: const Icon(Icons.close),
              onPressed: () =>
                  ref.read(addressListDeleteModeProvider.notifier).state =
                      false,
            )
          : null,
      automaticallyImplyLeading: !deleteMode,
      actions: [
        if (!widget.selectMode && !deleteMode)
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () =>
                ref.read(addressListDeleteModeProvider.notifier).state = true,
          ),
      ],
    );
  }

  @override
  SHOAppShellPage buildShell(
    BuildContext context,
    WidgetRef ref, {
    required PreferredSizeWidget? appBar,
    required Widget body,
  }) {
    final l10n = AppLocalizations.of(context);

    return SHOAppShellPage(
      appBar: appBar,
      body: body,
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            SHOAppSpacing.pagePadding,
            SHOAppSpacing.sm,
            SHOAppSpacing.pagePadding,
            SHOAppSpacing.pagePadding,
          ),
          child: Material(
            color: context.shoSurface,
            borderRadius: BorderRadius.circular(SHOProfileSectionCard.radius),
            child: InkWell(
              onTap: () => _openForm(),
              borderRadius: BorderRadius.circular(SHOProfileSectionCard.radius),
              child: Container(
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(SHOProfileSectionCard.radius),
                  border: Border.all(
                    color: context.shoTheme.border,
                    width: SHOProfileSectionCard.borderWidth,
                  ),
                ),
                child: Text(
                  l10n.addressAddNew,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: SHOAppColors.accent,
                      ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget buildContent(
    BuildContext context,
    WidgetRef ref,
    List<SHOAddress> addresses,
  ) {
    if (addresses.isEmpty) {
      return SHOEmptyState(title: AppLocalizations.of(context).addressEmpty);
    }

    final selectedId = ref.watch(selectedAddressIdProvider);
    final deleteMode = ref.watch(addressListDeleteModeProvider);

    final activeId = selectedId ??
        addresses
            .firstWhere(
              (item) => item.isDefault,
              orElse: () => addresses.first,
            )
            .id;

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        SHOAppSpacing.pagePadding,
        SHOAppSpacing.pagePadding,
        SHOAppSpacing.pagePadding,
        88,
      ),
      itemCount: addresses.length,
      separatorBuilder: (_, __) => const SizedBox(height: SHOAppSpacing.lg),
      itemBuilder: (context, index) {
        final address = addresses[index];
        final selected = activeId == address.id;

        return _AddressCard(
          address: address,
          selectMode: widget.selectMode,
          selected: selected,
          deleteMode: deleteMode,
          onTap: () {
            if (deleteMode) return;
            if (widget.selectMode) {
              _selectAddress(address);
              return;
            }
            _openForm(address: address);
          },
          onDelete: () => _confirmDelete(address),
        );
      },
    );
  }
}

class _AddressCard extends StatelessWidget {
  const _AddressCard({
    required this.address,
    required this.selectMode,
    required this.selected,
    required this.deleteMode,
    required this.onTap,
    required this.onDelete,
  });

  final SHOAddress address;
  final bool selectMode;
  final bool selected;
  final bool deleteMode;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.shoTheme;
    final borderColor = selectMode && selected
        ? SHOAppColors.accent
        : theme.border;
    final borderWidth =
        selectMode && selected ? 1.5 : SHOProfileSectionCard.borderWidth;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.shoSurface,
        borderRadius: BorderRadius.circular(SHOProfileSectionCard.radius),
        border: Border.all(color: borderColor, width: borderWidth),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(SHOProfileSectionCard.radius),
          child: Padding(
            padding: const EdgeInsets.all(SHOAppSpacing.lg),
            child: Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (selectMode) ...[
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Icon(
                          selected
                              ? Icons.radio_button_checked
                              : Icons.radio_button_off,
                          size: 20,
                          color: selected
                              ? SHOAppColors.accent
                              : theme.textSecondary,
                        ),
                      ),
                      const SizedBox(width: SHOAppSpacing.md),
                    ],
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          right: deleteMode ? 22 : 0,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    address.name,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 13,
                                        ),
                                  ),
                                ),
                                if (address.isDefault) ...[
                                  const SizedBox(width: SHOAppSpacing.sm),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: SHOAppSpacing.sm,
                                      vertical: SHOAppSpacing.xxs,
                                    ),
                                    decoration: BoxDecoration(
                                      color: SHOAppColors.accent
                                          .withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(
                                        SHOAppSpacing.cardRadius,
                                      ),
                                    ),
                                    child: Text(
                                      l10n.addressDefaultTag,
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall
                                          ?.copyWith(
                                            color: SHOAppColors.accent,
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: SHOAppSpacing.xs),
                            Text(
                              address.phone,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: theme.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                            const SizedBox(height: SHOAppSpacing.xs),
                            Text(
                              address.fullLine,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: theme.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                if (deleteMode)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: InkWell(
                      onTap: onDelete,
                      borderRadius:
                          BorderRadius.circular(SHOAppSpacing.cardRadius),
                      child: Icon(
                        Icons.close,
                        size: 18,
                        color: theme.textSecondary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
