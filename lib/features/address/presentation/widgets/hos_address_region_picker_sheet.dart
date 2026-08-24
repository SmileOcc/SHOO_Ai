import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shoo/core/theme/hos_colors.dart';
import 'package:shoo/core/theme/hos_spacing.dart';
import 'package:shoo/core/theme/hos_theme_extension.dart';
import 'package:shoo/features/address/domain/entities/hos_region_node.dart';
import 'package:shoo/features/address/presentation/state/hos_region_controller.dart';
import 'package:shoo/l10n/app_localizations.dart';

/// 地址多级联动选择弹窗。
class SHOAddressRegionPickerSheet extends ConsumerStatefulWidget {
  const SHOAddressRegionPickerSheet({
    super.key,
    this.initial,
    this.initialPickLevel,
  });

  final SHOAddressRegionSelection? initial;
  final int? initialPickLevel;

  static Future<SHOAddressRegionSelection?> show(
    BuildContext context, {
    SHOAddressRegionSelection? initial,
    int? initialPickLevel,
  }) {
    return showModalBottomSheet<SHOAddressRegionSelection>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => SHOAddressRegionPickerSheet(
        initial: initial,
        initialPickLevel: initialPickLevel,
      ),
    );
  }

  @override
  ConsumerState<SHOAddressRegionPickerSheet> createState() =>
      _SHOAddressRegionPickerSheetState();
}

class _SHOAddressRegionPickerSheetState
    extends ConsumerState<SHOAddressRegionPickerSheet> {
  late SHOAddressRegionSelection _selection;
  String _parentCode = '';
  int _pickLevel = 1;

  @override
  void initState() {
    super.initState();
    _selection = widget.initial ?? const SHOAddressRegionSelection();
    if (widget.initialPickLevel != null) {
      _pickLevel = widget.initialPickLevel!.clamp(1, 4);
      _parentCode = _parentCodeForLevel(_pickLevel, _selection);
    } else if (_selection.countryCode.isNotEmpty) {
      _pickLevel = _nextIncompleteLevel(_selection, const []);
      _parentCode = _parentCodeForLevel(_pickLevel, _selection);
    }
  }

  String _parentCodeForLevel(int level, SHOAddressRegionSelection value) {
    switch (level) {
      case 1:
        return '';
      case 2:
        return value.countryCode;
      case 3:
        return value.regionL2Code;
      case 4:
        return value.regionL3Code;
      default:
        return '';
    }
  }

  int _nextIncompleteLevel(
    SHOAddressRegionSelection value,
    List<SHORegionCountryConfig> configs,
  ) {
    if (value.countryCode.isEmpty) return 1;
    if (value.regionL2Code.isEmpty) return 2;
    if (value.regionL3Code.isEmpty) return 3;
    final config = _configFor(value.countryCode, configs);
    if (config != null &&
        config.requiredLevels.contains(4) &&
        value.regionL4Code.isEmpty) {
      return 4;
    }
    return 4;
  }

  SHORegionCountryConfig? _configFor(
    String countryCode,
    List<SHORegionCountryConfig> configs,
  ) {
    for (final config in configs) {
      if (config.countryCode == countryCode) return config;
    }
    return null;
  }

  bool _canConfirm(List<SHORegionCountryConfig> configs) {
    final config = _configFor(_selection.countryCode, configs);
    if (config == null) return false;
    return _selection.isCompleteFor(config);
  }

  void _applyNodeToSelection(SHORegionNode node) {
    if (node.level == 1) {
      _selection = SHOAddressRegionSelection(
        countryCode: node.code,
        countryName: node.name,
      );
      return;
    }
    if (node.level == 2) {
      _selection = _selection.copyWith(
        regionL2Code: node.code,
        regionL2Name: node.name,
        regionL3Code: '',
        regionL3Name: '',
        regionL4Code: '',
        regionL4Name: '',
      );
      return;
    }
    if (node.level == 3) {
      _selection = _selection.copyWith(
        regionL3Code: node.code,
        regionL3Name: node.name,
        regionL4Code: '',
        regionL4Name: '',
      );
      return;
    }
    if (node.level == 4) {
      _selection = _selection.copyWith(
        regionL4Code: node.code,
        regionL4Name: node.name,
      );
    }
  }

  void _onPick(SHORegionNode node, List<SHORegionCountryConfig> configs) {
    setState(() {
      _applyNodeToSelection(node);

      if (!node.hasChildren) {
        // 叶子节点：选择完成，不再请求下一级。
        _pickLevel = node.level;
        return;
      }

      _parentCode = node.code;
      _pickLevel = node.level + 1;
    });
  }

  void _onBreadcrumbTap(int level) {
    setState(() {
      if (level == 1) {
        _selection = const SHOAddressRegionSelection();
        _parentCode = '';
        _pickLevel = 1;
        return;
      }
      if (level == 2) {
        _selection = _selection.copyWith(
          regionL2Code: '',
          regionL2Name: '',
          regionL3Code: '',
          regionL3Name: '',
          regionL4Code: '',
          regionL4Name: '',
        );
        _parentCode = _selection.countryCode;
        _pickLevel = 2;
        return;
      }
      if (level == 3) {
        _selection = _selection.copyWith(
          regionL3Code: '',
          regionL3Name: '',
          regionL4Code: '',
          regionL4Name: '',
        );
        _parentCode = _selection.regionL2Code;
        _pickLevel = 3;
        return;
      }
      if (level == 4) {
        _selection = _selection.copyWith(
          regionL4Code: '',
          regionL4Name: '',
        );
        _parentCode = _selection.regionL3Code;
        _pickLevel = 4;
      }
    });
  }

  String? _selectedCodeAtLevel(int level) {
    return switch (level) {
      1 => _selection.countryCode,
      2 => _selection.regionL2Code,
      3 => _selection.regionL3Code,
      4 => _selection.regionL4Code,
      _ => null,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final metaAsync = ref.watch(regionMetaCountriesProvider);

    return metaAsync.when(
      loading: () => const SizedBox(
        height: 360,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => SizedBox(
        height: 240,
        child: Center(child: Text(error.toString())),
      ),
      data: (configs) {
        final Widget body;
        if (_pickLevel == 1) {
          body = _RegionCountryList(
            configs: configs,
            pickLevel: _pickLevel,
            selectedCode: _selectedCodeAtLevel(_pickLevel),
            onPick: (node) => _onPick(node, configs),
          );
        } else if (_parentCode.isEmpty) {
          body = _buildCompleteHint(context, l10n, configs);
        } else {
          body = _RegionChildrenList(
            countryCode: _selection.countryCode.isEmpty
                ? 'CN'
                : _selection.countryCode,
            parentCode: _parentCode,
            configs: configs,
            pickLevel: _pickLevel,
            selectedCode: _selectedCodeAtLevel(_pickLevel),
            onPick: (node) => _onPick(node, configs),
          );
        }

        return _buildShell(context, l10n, configs, body);
      },
    );
  }

  Widget _buildCompleteHint(
    BuildContext context,
    AppLocalizations l10n,
    List<SHORegionCountryConfig> configs,
  ) {
    if (!_canConfirm(configs)) {
      return Center(
        child: Text(
          l10n.addressRegionIncomplete,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(SHOAppSpacing.pagePadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 48,
              color: SHOAppColors.primary,
            ),
            const SizedBox(height: SHOAppSpacing.md),
            Text(
              _selection.summary(),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShell(
    BuildContext context,
    AppLocalizations l10n,
    List<SHORegionCountryConfig> configs,
    Widget body,
  ) {
    final canSave = _canConfirm(configs);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.72,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                SHOAppSpacing.pagePadding,
                SHOAppSpacing.md,
                SHOAppSpacing.pagePadding,
                SHOAppSpacing.sm,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.addressRegionPickerTitle,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  if (canSave)
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(_selection),
                      child: Text(
                        l10n.addressRegionSave,
                        style: TextStyle(
                          color: SHOAppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            _Breadcrumb(
              selection: _selection,
              pickLevel: _pickLevel,
              onTap: _onBreadcrumbTap,
            ),
            const Divider(height: 1),
            Expanded(child: body),
          ],
        ),
      ),
    );
  }
}

class _RegionCountryList extends ConsumerWidget {
  const _RegionCountryList({
    required this.configs,
    required this.pickLevel,
    required this.selectedCode,
    required this.onPick,
  });

  final List<SHORegionCountryConfig> configs;
  final int pickLevel;
  final String? selectedCode;
  final ValueChanged<SHORegionNode> onPick;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countriesAsync = ref.watch(regionCountriesProvider);
    return countriesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text(e.toString())),
      data: (items) => _RegionNodeList(
        items: items,
        pickLevel: pickLevel,
        selectedCode: selectedCode,
        onPick: onPick,
      ),
    );
  }
}

class _RegionChildrenList extends ConsumerWidget {
  const _RegionChildrenList({
    required this.countryCode,
    required this.parentCode,
    required this.configs,
    required this.pickLevel,
    required this.selectedCode,
    required this.onPick,
  });

  final String countryCode;
  final String parentCode;
  final List<SHORegionCountryConfig> configs;
  final int pickLevel;
  final String? selectedCode;
  final ValueChanged<SHORegionNode> onPick;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final childrenAsync = ref.watch(
      regionChildrenProvider((
        countryCode: countryCode,
        parentCode: parentCode,
      )),
    );
    return childrenAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text(e.toString())),
      data: (result) => _RegionNodeList(
        items: result.items,
        pickLevel: pickLevel,
        selectedCode: selectedCode,
        onPick: onPick,
      ),
    );
  }
}

class _RegionNodeList extends StatelessWidget {
  const _RegionNodeList({
    required this.items,
    required this.pickLevel,
    required this.selectedCode,
    required this.onPick,
  });

  final List<SHORegionNode> items;
  final int pickLevel;
  final String? selectedCode;
  final ValueChanged<SHORegionNode> onPick;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(
        child: Text(
          AppLocalizations.of(context).loadFailed,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: SHOAppSpacing.sm),
      itemCount: items.length,
      separatorBuilder: (_, __) => const Divider(height: 1, indent: 16),
      itemBuilder: (context, index) {
        final item = items[index];
        final isSelected = selectedCode == item.code;
        return ListTile(
          title: Text(
            item.name,
            style: isSelected
                ? TextStyle(
                    color: SHOAppColors.primary,
                    fontWeight: FontWeight.w700,
                  )
                : null,
          ),
          trailing: isSelected
              ? Icon(Icons.check, color: SHOAppColors.primary, size: 20)
              : item.hasChildren
              ? Icon(Icons.chevron_right, color: context.shoTheme.textMuted)
              : null,
          onTap: () => onPick(item),
        );
      },
    );
  }
}

class _Breadcrumb extends StatelessWidget {
  const _Breadcrumb({
    required this.selection,
    required this.pickLevel,
    required this.onTap,
  });

  final SHOAddressRegionSelection selection;
  final int pickLevel;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final crumbs = <({int level, String label})>[
      (
        level: 1,
        label: selection.countryName.isEmpty ? '…' : selection.countryName,
      ),
      if (selection.countryCode.isNotEmpty)
        (
          level: 2,
          label: selection.regionL2Name.isEmpty ? '…' : selection.regionL2Name,
        ),
      if (selection.regionL2Code.isNotEmpty)
        (
          level: 3,
          label: selection.regionL3Name.isEmpty ? '…' : selection.regionL3Name,
        ),
      if (selection.regionL3Code.isNotEmpty)
        (
          level: 4,
          label: selection.regionL4Name.isEmpty ? '…' : selection.regionL4Name,
        ),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(
        horizontal: SHOAppSpacing.pagePadding,
        vertical: SHOAppSpacing.sm,
      ),
      child: Row(
        children: [
          for (var i = 0; i < crumbs.length; i++) ...[
            if (i > 0)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Icon(
                  Icons.chevron_right,
                  size: 16,
                  color: context.shoTheme.textMuted,
                ),
              ),
            InkWell(
              onTap: () => onTap(crumbs[i].level),
              child: Text(
                crumbs[i].label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: crumbs[i].level == pickLevel
                      ? SHOAppColors.primary
                      : context.shoTheme.textSecondary,
                  fontWeight: crumbs[i].level == pickLevel
                      ? FontWeight.w700
                      : FontWeight.w500,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
