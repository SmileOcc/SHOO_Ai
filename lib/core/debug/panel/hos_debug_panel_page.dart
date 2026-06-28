import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shoo/app/root/hos_runtime_env_provider.dart';
import 'package:shoo/app/router/hos_routes.dart';
import 'package:shoo/core/analytics/hos_analytics_provider.dart';
import 'package:shoo/core/analytics/hos_analytics_registry.dart';
import 'package:shoo/core/config/hos_config.dart';
import 'package:shoo/core/config/hos_environment.dart';
import 'package:shoo/core/constants/hos_constants.dart';
import 'package:shoo/core/pages/hos_pages.dart';
import 'package:shoo/core/theme/hos_spacing.dart';
import 'package:shoo/l10n/app_localizations.dart';

/// Debug 调试面板：环境切换、Mock 延迟等（Release 包不可进入）。
class SHODebugPanelPage extends ConsumerStatefulWidget {
  const SHODebugPanelPage({super.key});

  @override
  ConsumerState<SHODebugPanelPage> createState() => _SHODebugPanelPageState();
}

class _SHODebugPanelPageState extends ConsumerState<SHODebugPanelPage>
    with SHOPageRouteAnalyticsMixin, SHOAppPageMixin, SHOAppTrackedPageMixin {
  @override
  String get pageName => 'debug_panel';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final config = ref.watch(effectiveConfigProvider);
    final override = ref.watch(runtimeEnvOverrideProvider);
    final showEnvBadge = ref.watch(showEnvBadgeProvider);
    final consoleLogEnabled = ref.watch(consoleLogEnabledProvider);
    final pageLoadRecords = ref
        .watch(analyticsManagerProvider)
        .history
        .where((r) => r.eventKey == SHOAnalyticsRegistry.pageLoadTime.key)
        .take(8)
        .toList();

    return buildTrackedPage(
      Scaffold(
        appBar: AppBar(title: Text(l10n.debugPanelTitle)),
        body: ListView(
          padding: const EdgeInsets.all(SHOAppSpacing.xl),
          children: [
            Text(
              l10n.debugPanelHint,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: SHOAppSpacing.xl),
            Text(
              l10n.debugEnvSection,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: SHOAppSpacing.xs),
            Text(
              l10n.debugEnvRestarting,
              style: Theme.of(context).textTheme.bodySmall,
            ),
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
                    ref
                        .read(runtimeEnvOverrideProvider.notifier)
                        .setOverride(v);
                  }
                },
                selected: selected,
              );
            }),
            ListTile(
              title: Text(l10n.debugResetEnv),
              trailing: const Icon(Icons.restore),
              onTap: () =>
                  ref.read(runtimeEnvOverrideProvider.notifier).resetOverride(),
            ),
            SwitchListTile(
              title: Text(l10n.debugShowEnvBadge),
              subtitle: Text(l10n.debugShowEnvBadgeHint),
              value: showEnvBadge,
              onChanged: (v) =>
                  ref.read(showEnvBadgeProvider.notifier).setEnabled(v),
            ),
            SwitchListTile(
              title: Text(l10n.debugConsoleLog),
              subtitle: Text(l10n.debugConsoleLogHint),
              value: consoleLogEnabled,
              onChanged: (v) =>
                  ref.read(consoleLogEnabledProvider.notifier).setEnabled(v),
            ),
            const Divider(height: SHOAppSpacing.xxxl),
            Text(
              l10n.debugToolsSection,
              style: Theme.of(context).textTheme.titleMedium,
            ),
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
              leading: const Icon(Icons.notifications_active_outlined),
              title: const Text('抢购活动通知调试'),
              subtitle: const Text('弹窗预览、延时 8 秒通知、活动 ID'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(SHOAppRoutes.debugFlashSaleReminder),
            ),
            ListTile(
              leading: const Icon(Icons.article_outlined),
              title: Text(l10n.debugNetworkLogEntry),
              subtitle: Text(l10n.debugNetworkLogEntryHint),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(SHOAppRoutes.debugNetworkLog),
            ),
            ListTile(
              leading: const Icon(Icons.security_outlined),
              title: const Text('安全网络 / 加密调试'),
              subtitle: const Text('RSA/AES 加密、GET/POST 接口调试'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(SHOAppRoutes.debugSecureNetwork),
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
              leading: const Icon(Icons.touch_app_outlined),
              title: const Text('HitTestBehavior'),
              subtitle: const Text('调试手势事件传递行为'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(SHOAppRoutes.debugHitTest),
            ),
            ListTile(
              leading: const Icon(Icons.layers_outlined),
              title: const Text('重叠视图点击事件'),
              subtitle: const Text('调试A有点击→A响应；A无→B响应'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(SHOAppRoutes.debugOverlap),
            ),
            ListTile(
              leading: const Icon(Icons.hub_outlined),
              title: const Text('Mixin 调试'),
              subtitle: const Text('线性化链 / 同名方法 / 业务聚合'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(SHOAppRoutes.debugMixin),
            ),
            ListTile(
              leading: const Icon(Icons.link_outlined),
              title: const Text('InheritedWidget 依赖监听'),
              subtitle: const Text('监听所有 InheritedWidget 变化'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(SHOAppRoutes.debugDependencies),
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
            Text(
              'Recent page_load_time',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: SHOAppSpacing.md),
            if (pageLoadRecords.isEmpty)
              Text(
                'No page_load_time events yet',
                style: Theme.of(context).textTheme.bodySmall,
              )
            else
              ...pageLoadRecords.map((record) {
                final pageName = record.params['page_name']?.toString() ?? '-';
                final phase = record.params['load_phase']?.toString() ?? '-';
                final durationMs =
                    record.params['duration_ms']?.toString() ?? '-';
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(pageName),
                  subtitle: Text('$phase · ${durationMs}ms'),
                  trailing: Text(
                    _formatRecordTime(record.timestamp),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                );
              }),
            const Divider(height: SHOAppSpacing.xxxl),
            _SHOInfoTile(label: 'Build', value: SHOAppConstants.appVersion),
            _SHOInfoTile(label: 'API', value: config.apiBaseUrl),
            _SHOInfoTile(label: 'Mock API', value: '${config.useMockApi}'),
            _SHOInfoTile(
              label: 'Mock Delay',
              value: '${config.mockNetworkDelay.inMilliseconds}ms',
            ),
            _SHOInfoTile(
              label: 'Debug Panel',
              value: '${config.isDebugPanelEnabled}',
            ),
          ],
        ),
      ),
    );
  }
}

String _formatRecordTime(DateTime timestamp) {
  final local = timestamp.toLocal();
  final h = local.hour.toString().padLeft(2, '0');
  final m = local.minute.toString().padLeft(2, '0');
  final s = local.second.toString().padLeft(2, '0');
  return '$h:$m:$s';
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
