import 'package:flutter/material.dart';

import 'package:shoo/core/theme/hos_colors.dart';
import 'package:shoo/core/theme/hos_spacing.dart';
import 'package:shoo/core/theme/hos_theme_extension.dart';
import 'package:shoo/features/address/domain/entities/hos_region_node.dart';
import 'package:shoo/features/address/presentation/widgets/hos_address_region_picker_sheet.dart';
import 'package:shoo/features/address/presentation/widgets/hos_address_text_field.dart';
import 'package:shoo/l10n/app_localizations.dart';

class SHOAddressRegionField extends StatelessWidget {
  const SHOAddressRegionField({
    super.key,
    required this.selection,
    required this.onChanged,
    required this.configs,
    this.validator,
  });

  final SHOAddressRegionSelection selection;
  final ValueChanged<SHOAddressRegionSelection> onChanged;
  final List<SHORegionCountryConfig> configs;
  final String? Function(SHOAddressRegionSelection?)? validator;

  SHORegionCountryConfig? get _activeConfig {
    for (final config in configs) {
      if (config.countryCode == selection.countryCode) return config;
    }
    return null;
  }

  List<int> get _visibleLevels {
    final config = _activeConfig;
    if (config == null) return const [1];
    final levels = <int>[1];
    for (final level in config.requiredLevels) {
      if (level > 1 && !levels.contains(level)) {
        levels.add(level);
      }
    }
    levels.sort();
    return levels;
  }

  String _levelLabel(AppLocalizations l10n, int level) {
    final config = _activeConfig;
    final fromConfig = config?.labels['$level'];
    if (fromConfig != null && fromConfig.isNotEmpty) return fromConfig;
    return switch (level) {
      1 => l10n.addressRegionLevelCountry,
      2 => l10n.addressRegionLevelProvince,
      3 => l10n.addressRegionLevelCity,
      4 => l10n.addressRegionLevelDistrict,
      _ => l10n.addressRegionLabel,
    };
  }

  String _levelValue(int level) {
    return switch (level) {
      1 => selection.countryName,
      2 => selection.regionL2Name,
      3 => selection.regionL3Name,
      4 => selection.regionL4Name,
      _ => '',
    };
  }

  bool _shouldShowLevel(int level) {
    if (level == 1) return true;
    if (selection.countryCode.isEmpty) return false;
    return _visibleLevels.contains(level);
  }

  Future<void> _openPicker(
    BuildContext context,
    int level,
    FormFieldState<SHOAddressRegionSelection> state,
  ) async {
    final result = await SHOAddressRegionPickerSheet.show(
      context,
      initial: selection,
      initialPickLevel: level,
    );
    if (result == null) return;
    onChanged(result);
    state.didChange(result);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.shoTheme;
    final textTheme = Theme.of(context).textTheme;
    final radius = BorderRadius.circular(SHOAddressTextField.borderRadius);

    return FormField<SHOAddressRegionSelection>(
      initialValue: selection,
      validator: validator,
      builder: (state) {
        final rows = <Widget>[];
        for (final level in _visibleLevels) {
          if (!_shouldShowLevel(level)) continue;
          final value = _levelValue(level);
          rows.add(
            _RegionLevelRow(
              label: _levelLabel(l10n, level),
              value: value,
              placeholder: l10n.addressRegionSelectHint,
              onTap: () => _openPicker(context, level, state),
            ),
          );
          if (level != _visibleLevels.last) {
            rows.add(const SizedBox(height: SHOAppSpacing.sm));
          }
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l10n.addressRegionLabel, style: textTheme.labelLarge),
                Text(
                  ' *',
                  style: textTheme.labelLarge?.copyWith(
                    color: SHOAppColors.error,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: SHOAppSpacing.xs),
            Container(
              decoration: BoxDecoration(
                color: theme.surfaceMuted,
                borderRadius: radius,
                border: Border.all(
                  color: state.hasError ? SHOAppColors.error : theme.border,
                ),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: SHOAppSpacing.lg,
                vertical: SHOAppSpacing.sm,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: rows,
              ),
            ),
            if (state.errorText != null) ...[
              const SizedBox(height: SHOAppSpacing.xs),
              Text(
                state.errorText!,
                style: textTheme.bodySmall?.copyWith(
                  color: SHOAppColors.error,
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _RegionLevelRow extends StatelessWidget {
  const _RegionLevelRow({
    required this.label,
    required this.value,
    required this.placeholder,
    required this.onTap,
  });

  final String label;
  final String value;
  final String placeholder;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final hasValue = value.isNotEmpty;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(SHOAddressTextField.borderRadius),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: SHOAppSpacing.sm),
        child: Row(
          children: [
            SizedBox(
              width: 72,
              child: Text(
                label,
                style: textTheme.bodyMedium?.copyWith(
                  color: context.shoTheme.textSecondary,
                ),
              ),
            ),
            Expanded(
              child: Text(
                hasValue ? value : placeholder,
                style: textTheme.bodyLarge?.copyWith(
                  color: hasValue
                      ? Theme.of(context).colorScheme.onSurface
                      : context.shoTheme.textMuted,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 20,
              color: context.shoTheme.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}

String? validateAddressRegion(
  AppLocalizations l10n,
  SHOAddressRegionSelection? value,
  List<SHORegionCountryConfig> configs,
) {
  if (value == null || value.countryCode.isEmpty) {
    return l10n.addressRegionIncomplete;
  }
  SHORegionCountryConfig? config;
  for (final item in configs) {
    if (item.countryCode == value.countryCode) {
      config = item;
      break;
    }
  }
  if (config == null || !value.isCompleteFor(config)) {
    return l10n.addressRegionIncomplete;
  }
  return null;
}
