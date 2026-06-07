import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../theme/hos_spacing.dart';
import '../../../../l10n/app_localizations.dart';
import 'hos_debug_network_log_config.dart';
import 'hos_debug_network_log_config_provider.dart';

class SHODebugNetworkLogPage extends ConsumerStatefulWidget {
  const SHODebugNetworkLogPage({super.key});

  @override
  ConsumerState<SHODebugNetworkLogPage> createState() =>
      _SHODebugNetworkLogPageState();
}

class _SHODebugNetworkLogPageState extends ConsumerState<SHODebugNetworkLogPage> {
  late final TextEditingController _pathsCtrl;
  bool _enabled = true;
  bool _logRequest = true;
  bool _logResponse = true;
  bool _filterEnabled = false;
  bool _useMockRemote = false;

  @override
  void initState() {
    super.initState();
    final config = ref.read(debugNetworkLogConfigProvider);
    _enabled = config.enabled;
    _logRequest = config.logRequestParams;
    _logResponse = config.logResponseParams;
    _filterEnabled = config.filterPathsEnabled;
    _useMockRemote = config.useMockRemoteLog;
    _pathsCtrl = TextEditingController(text: config.pathFilters);
  }

  @override
  void dispose() {
    _pathsCtrl.dispose();
    super.dispose();
  }

  SHODebugNetworkLogConfig _buildConfig() {
    return SHODebugNetworkLogConfig(
      enabled: _enabled,
      logRequestParams: _logRequest,
      logResponseParams: _logResponse,
      filterPathsEnabled: _filterEnabled,
      pathFilters: _pathsCtrl.text,
      useMockRemoteLog: _useMockRemote,
    );
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    await ref.read(debugNetworkLogConfigProvider.notifier).save(_buildConfig());
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.debugConfigSaved)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.debugNetworkLogTitle)),
      body: ListView(
        padding: const EdgeInsets.all(SHOAppSpacing.xl),
        children: [
          Text(
            l10n.debugNetworkLogHint,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: SHOAppSpacing.xl),
          SwitchListTile(
            title: Text(l10n.debugNetworkLogEnabled),
            subtitle: Text(l10n.debugNetworkLogEnabledHint),
            value: _enabled,
            onChanged: (v) => setState(() => _enabled = v),
          ),
          SwitchListTile(
            title: Text(l10n.debugNetworkLogRequest),
            subtitle: Text(l10n.debugNetworkLogRequestHint),
            value: _logRequest,
            onChanged: _enabled ? (v) => setState(() => _logRequest = v) : null,
          ),
          SwitchListTile(
            title: Text(l10n.debugNetworkLogResponse),
            subtitle: Text(l10n.debugNetworkLogResponseHint),
            value: _logResponse,
            onChanged: _enabled ? (v) => setState(() => _logResponse = v) : null,
          ),
          const Divider(height: SHOAppSpacing.xxxl),
          SwitchListTile(
            title: Text(l10n.debugNetworkLogMockRemote),
            subtitle: Text(l10n.debugNetworkLogMockRemoteHint),
            value: _useMockRemote,
            onChanged: (v) => setState(() => _useMockRemote = v),
          ),
          if (!_useMockRemote)
            Padding(
              padding: const EdgeInsets.only(bottom: SHOAppSpacing.lg),
              child: Text(
                l10n.debugNetworkLogRemoteHint,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          const Divider(height: SHOAppSpacing.xxxl),
          SwitchListTile(
            title: Text(l10n.debugNetworkLogFilterEnabled),
            subtitle: Text(l10n.debugNetworkLogFilterEnabledHint),
            value: _filterEnabled,
            onChanged: _enabled ? (v) => setState(() => _filterEnabled = v) : null,
          ),
          const SizedBox(height: SHOAppSpacing.md),
          TextField(
            controller: _pathsCtrl,
            enabled: _enabled && _filterEnabled,
            minLines: 3,
            maxLines: 6,
            decoration: InputDecoration(
              labelText: l10n.debugNetworkLogFilterPaths,
              hintText: l10n.debugNetworkLogFilterPathsHint,
              border: const OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: SHOAppSpacing.xxxl),
          FilledButton(
            onPressed: _save,
            child: Text(l10n.debugSaveConfig),
          ),
        ],
      ),
    );
  }
}
