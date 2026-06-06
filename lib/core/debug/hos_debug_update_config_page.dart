import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/hos_spacing.dart';
import '../update/hos_update_dialog.dart';
import '../update/hos_update_service.dart';
import '../../l10n/app_localizations.dart';
import 'hos_debug_flow_status_banner.dart';
import 'hos_debug_update_config_provider.dart';
import 'models/hos_debug_update_config.dart';

class SHODebugUpdateConfigPage extends ConsumerStatefulWidget {
  const SHODebugUpdateConfigPage({super.key});

  @override
  ConsumerState<SHODebugUpdateConfigPage> createState() => _SHODebugUpdateConfigPageState();
}

class _SHODebugUpdateConfigPageState extends ConsumerState<SHODebugUpdateConfigPage> {
  late final TextEditingController _versionCtrl;
  late final TextEditingController _notesCtrl;
  late final TextEditingController _urlCtrl;
  bool _overrideEnabled = false;
  bool _forceUpdate = false;

  @override
  void initState() {
    super.initState();
    final config = ref.read(debugUpdateConfigProvider);
    _versionCtrl = TextEditingController(text: config.latestVersion);
    _notesCtrl = TextEditingController(text: config.releaseNotes);
    _urlCtrl = TextEditingController(text: config.updateUrl);
    _overrideEnabled = config.overrideEnabled;
    _forceUpdate = config.forceUpdate;
  }

  @override
  void dispose() {
    ref.read(debugUpdateConfigProvider.notifier).save(_buildConfig());
    _versionCtrl.dispose();
    _notesCtrl.dispose();
    _urlCtrl.dispose();
    super.dispose();
  }

  SHODebugUpdateConfig _buildConfig() {
    return SHODebugUpdateConfig(
      overrideEnabled: _overrideEnabled,
      latestVersion: _versionCtrl.text.trim(),
      releaseNotes: _notesCtrl.text,
      forceUpdate: _forceUpdate,
      updateUrl: _urlCtrl.text.trim(),
    );
  }

  Future<void> _save({String? snackMessage}) async {
    final l10n = AppLocalizations.of(context);
    await ref.read(debugUpdateConfigProvider.notifier).save(_buildConfig());
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(snackMessage ?? l10n.debugConfigSaved)),
      );
    }
  }

  Future<void> _onOverrideChanged(bool value) async {
    setState(() => _overrideEnabled = value);
    final l10n = AppLocalizations.of(context);
    await _save(
      snackMessage: value ? l10n.debugOverrideActiveNow : l10n.debugOverrideInactiveNow,
    );
  }

  Future<void> _preview() async {
    final l10n = AppLocalizations.of(context);
    await ref.read(debugUpdateConfigProvider.notifier).save(_buildConfig());
    if (!mounted) return;

    final info = await ref.read(appUpdateServiceProvider).checkUpdate();
    if (!mounted) return;

    if (!info.hasUpdate) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.debugPreviewNoUpdate)),
      );
      return;
    }

    await SHOAppUpdateDialog.show(context, ref, info: info);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.debugUpdateTitle)),
      body: ListView(
        padding: const EdgeInsets.all(SHOAppSpacing.xl),
        children: [
          SHODebugFlowStatusBanner(overrideEnabled: _overrideEnabled),
          const SizedBox(height: SHOAppSpacing.lg),
          SwitchListTile(
            title: Text(l10n.debugOverrideEnabled),
            subtitle: Text(l10n.debugUpdateOverrideHint),
            value: _overrideEnabled,
            onChanged: _onOverrideChanged,
          ),
          const SizedBox(height: SHOAppSpacing.lg),
          TextField(
            controller: _versionCtrl,
            decoration: InputDecoration(
              labelText: l10n.debugUpdateVersion,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: SHOAppSpacing.lg),
          TextField(
            controller: _notesCtrl,
            minLines: 3,
            maxLines: 8,
            decoration: InputDecoration(
              labelText: l10n.debugUpdateNotes,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: SHOAppSpacing.lg),
          SwitchListTile(
            title: Text(l10n.debugUpdateForce),
            value: _forceUpdate,
            onChanged: (v) => setState(() => _forceUpdate = v),
          ),
          TextField(
            controller: _urlCtrl,
            decoration: InputDecoration(
              labelText: l10n.debugUpdateUrl,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: SHOAppSpacing.xxxl),
          FilledButton(onPressed: _save, child: Text(l10n.debugSaveConfig)),
          const SizedBox(height: SHOAppSpacing.md),
          OutlinedButton(onPressed: _preview, child: Text(l10n.debugPreviewPopup)),
        ],
      ),
    );
  }
}
