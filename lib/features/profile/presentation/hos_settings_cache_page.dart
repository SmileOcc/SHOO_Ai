import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/cache/hos_cache_cleanup_service.dart';
import '../../../core/logging/hos_log_manager.dart';
import '../../../core/theme/hos_spacing.dart';
import '../../../core/widgets/hos_dialog.dart';
import '../../../l10n/app_localizations.dart';

class SHOSettingsCachePage extends ConsumerStatefulWidget {
  const SHOSettingsCachePage({super.key});

  @override
  ConsumerState<SHOSettingsCachePage> createState() => _SHOSettingsCachePageState();
}

class _SHOSettingsCachePageState extends ConsumerState<SHOSettingsCachePage> {
  Map<SHOCacheCategory, int>? _sizes;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    setState(() => _loading = true);
    final service = ref.read(cacheCleanupServiceProvider);
    final sizes = await service.loadSizes();
    if (mounted) {
      setState(() {
        _sizes = sizes;
        _loading = false;
      });
    }
  }

  String _title(AppLocalizations l10n, SHOCacheCategoryInfo info) {
    return switch (info.titleKey) {
      'settingsCacheLogs' => l10n.settingsCacheLogs,
      'settingsCacheImages' => l10n.settingsCacheImages,
      'settingsCacheSearch' => l10n.settingsCacheSearch,
      'settingsCacheCart' => l10n.settingsCacheCart,
      'settingsCacheActivity' => l10n.settingsCacheActivity,
      'settingsCachePreferences' => l10n.settingsCachePreferences,
      _ => info.titleKey,
    };
  }

  String _subtitle(AppLocalizations l10n, SHOCacheCategoryInfo info) {
    return switch (info.subtitleKey) {
      'settingsCacheLogsHint' => l10n.settingsCacheLogsHint,
      'settingsCacheImagesHint' => l10n.settingsCacheImagesHint,
      'settingsCacheSearchHint' => l10n.settingsCacheSearchHint,
      'settingsCacheCartHint' => l10n.settingsCacheCartHint,
      'settingsCacheActivityHint' => l10n.settingsCacheActivityHint,
      'settingsCachePreferencesHint' => l10n.settingsCachePreferencesHint,
      _ => info.subtitleKey,
    };
  }

  Future<void> _clearCategory(SHOCacheCategory category) async {
    final l10n = AppLocalizations.of(context);
    final info = SHOCacheCleanupService.categories
        .firstWhere((e) => e.category == category);
    final ok = await SHOAppDialog.confirm(
      context,
      title: l10n.settingsCacheClearTitle,
      message: l10n.settingsCacheClearMessage(_title(l10n, info)),
      confirmLabel: l10n.settingsCacheClearConfirm,
      cancelLabel: l10n.dialogCancel,
      isDestructive: true,
    );
    if (!ok || !mounted) return;
    await ref.read(cacheCleanupServiceProvider).clear(category);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.settingsCacheCleared)),
    );
    await _reload();
  }

  Future<void> _clearAll() async {
    final l10n = AppLocalizations.of(context);
    final ok = await SHOAppDialog.confirm(
      context,
      title: l10n.settingsCacheClearAllTitle,
      message: l10n.settingsCacheClearAllMessage,
      confirmLabel: l10n.settingsCacheClearConfirm,
      cancelLabel: l10n.dialogCancel,
      isDestructive: true,
    );
    if (!ok || !mounted) return;
    await ref.read(cacheCleanupServiceProvider).clearAll();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.settingsCacheCleared)),
    );
    await _reload();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final total = _sizes?.values.fold<int>(0, (sum, v) => sum + v) ?? 0;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsCacheTitle)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(SHOAppSpacing.xl),
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.settingsCacheTotal),
                  trailing: Text(
                    SHOAppLogManager.formatSize(total),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                const SizedBox(height: SHOAppSpacing.md),
                ...SHOCacheCleanupService.categories.map((info) {
                  final bytes = _sizes?[info.category] ?? 0;
                  return ListTile(
                    title: Text(_title(l10n, info)),
                    subtitle: Text(_subtitle(l10n, info)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          SHOAppLogManager.formatSize(bytes),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, size: 20),
                          onPressed: bytes == 0
                              ? null
                              : () => _clearCategory(info.category),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: SHOAppSpacing.xl),
                FilledButton(
                  onPressed: total == 0 ? null : _clearAll,
                  child: Text(l10n.settingsCacheClearAll),
                ),
              ],
            ),
    );
  }
}
