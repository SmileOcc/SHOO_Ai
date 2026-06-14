import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/hos_routes.dart';
import '../../config/hos_config.dart';
import '../../config/hos_environment.dart';
import '../../constants/hos_constants.dart';
import '../core/hos_runtime_env_provider.dart';
import '../../theme/hos_spacing.dart';
import '../../../l10n/app_localizations.dart';

/// Debug 调试面板：环境切换、Mock 延迟等（Release 包不可进入）。
class SHODebugPanelPage extends ConsumerWidget {
  const SHODebugPanelPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final config = ref.watch(effectiveConfigProvider);
    final override = ref.watch(runtimeEnvOverrideProvider);
    final showEnvBadge = ref.watch(showEnvBadgeProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.debugPanelTitle)),
      body: ListView(
        padding: const EdgeInsets.all(SHOAppSpacing.xl),
        children: [
          Text(l10n.debugPanelHint, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: SHOAppSpacing.xl),
          Text(l10n.debugEnvSection, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: SHOAppSpacing.xs),
          Text(l10n.debugEnvRestarting, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: SHOAppSpacing.md),
          ...SHOAppEnvironment.values.map((env) {
            final selected = (override ?? config.environment) == env;
            return RadioListTile<SHOAppEnvironment>(
              title: Text('${env.label} (${env.badgeLabel})'),
              subtitle: Text(SHOAppConfig.defaultApiBaseUrl(env)),
              value: env,
              groupValue: override ?? config.environment,
              onChanged: (v) {
                if (v != null) {
                  ref.read(runtimeEnvOverrideProvider.notifier).setOverride(v);
                }
              },
              selected: selected,
            );
          }),
          ListTile(
            title: Text(l10n.debugResetEnv),
            trailing: const Icon(Icons.restore),
            onTap: () => ref.read(runtimeEnvOverrideProvider.notifier).resetOverride(),
          ),
          SwitchListTile(
            title: Text(l10n.debugShowEnvBadge),
            subtitle: Text(l10n.debugShowEnvBadgeHint),
            value: showEnvBadge,
            onChanged: (v) =>
                ref.read(showEnvBadgeProvider.notifier).setEnabled(v),
          ),
          const Divider(height: SHOAppSpacing.xxxl),
          Text(l10n.debugToolsSection, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: SHOAppSpacing.md),
          ListTile(
            leading: const Icon(Icons.system_update),
            title: Text(l10n.debugUpdateEntry),
            subtitle: Text(l10n.debugUpdateEntryHint),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(SHOAppRoutes.debugUpdate),
          ),
          ListTile(
            leading: const Icon(Icons.campaign_outlined),
            title: Text(l10n.debugActivityEntry),
            subtitle: Text(l10n.debugActivityEntryHint),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(SHOAppRoutes.debugActivity),
          ),
          ListTile(
            leading: const Icon(Icons.article_outlined),
            title: Text(l10n.debugNetworkLogEntry),
            subtitle: Text(l10n.debugNetworkLogEntryHint),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(SHOAppRoutes.debugNetworkLog),
          ),
          ListTile(
            leading: const Icon(Icons.analytics_outlined),
            title: Text(l10n.debugAnalyticsEntry),
            subtitle: Text(l10n.debugAnalyticsEntryHint),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(SHOAppRoutes.debugAnalytics),
          ),
          ListTile(
            leading: const Icon(Icons.hourglass_top_outlined),
            title: Text(l10n.debugFeedbackEntry),
            subtitle: Text(l10n.debugFeedbackEntryHint),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(SHOAppRoutes.debugFeedback),
          ),
          ListTile(
            leading: const Icon(Icons.speed_outlined),
            title: Text(l10n.debugMicrotaskEntry),
            subtitle: Text(l10n.debugMicrotaskEntryHint),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(SHOAppRoutes.debugMicrotask),
          ),
          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: const Text('SHOO Brand / Icon'),
            subtitle: const Text('Preview and select app icon style'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(SHOAppRoutes.debugBrand),
          ),
          ListTile(
            leading: const Icon(Icons.developer_board_outlined),
            title: Text(l10n.debugNativeEntry),
            subtitle: Text(l10n.debugNativeEntryHint),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(SHOAppRoutes.debugNative),
          ),
          const Divider(height: SHOAppSpacing.xxxl),
          _SHOInfoTile(label: 'Build', value: SHOAppConstants.appVersion),
          _SHOInfoTile(label: 'API', value: config.apiBaseUrl),
          _SHOInfoTile(label: 'Mock API', value: '${config.useMockApi}'),
          _SHOInfoTile(label: 'Mock Delay', value: '${config.mockNetworkDelay.inMilliseconds}ms'),
          _SHOInfoTile(label: 'Debug Panel', value: '${config.isDebugPanelEnabled}'),
        ],
      ),
    );
  }
}

class _SHOInfoTile extends StatelessWidget {
  const _SHOInfoTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      trailing: Text(value, style: Theme.of(context).textTheme.bodySmall),
    );
  }
}
