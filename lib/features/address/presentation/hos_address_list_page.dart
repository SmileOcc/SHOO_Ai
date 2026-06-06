import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/hos_spacing.dart';
import '../../../core/widgets/hos_loading_state.dart';
import '../../../l10n/app_localizations.dart';
import 'hos_address_controller.dart';

class SHOAddressListPage extends ConsumerWidget {
  const SHOAddressListPage({super.key, this.selectMode = false});

  final bool selectMode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final addressesAsync = ref.watch(addressesProvider);
    final selectedId = ref.watch(selectedAddressIdProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          selectMode ? l10n.addressSelectTitle : l10n.addressListTitle,
        ),
      ),
      body: addressesAsync.whenLoadingState(
        onRetry: () => ref.invalidate(addressesProvider),
        empty: (list) => list.isEmpty,
        data: (addresses) => ListView.separated(
          padding: const EdgeInsets.all(SHOAppSpacing.pagePadding),
          itemCount: addresses.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final address = addresses[index];
            final selected = (selectedId ?? address.id) == address.id;

            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_off,
                size: 20,
              ),
              title: Text(
                '${address.name}  ${address.phone}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
              ),
              subtitle: Text(
                address.fullLine,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              onTap: () async {
                await ref.read(selectedAddressIdProvider.notifier).select(address.id);
                if (context.mounted) context.pop();
              },
            );
          },
        ),
      ),
    );
  }
}
