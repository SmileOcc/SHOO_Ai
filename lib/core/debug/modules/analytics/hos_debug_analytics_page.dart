import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shoo/core/analytics/hos_analytics.dart';
import 'package:shoo/core/pages/hos_pages.dart';
import 'package:shoo/core/theme/hos_spacing.dart';
import 'package:shoo/core/theme/hos_theme_extension.dart';
import 'package:shoo/l10n/app_localizations.dart';

class SHODebugAnalyticsPage extends ConsumerStatefulWidget {
  const SHODebugAnalyticsPage({super.key});

  @override
  ConsumerState<SHODebugAnalyticsPage> createState() =>
      _SHODebugAnalyticsPageState();
}

class _SHODebugAnalyticsPageState extends ConsumerState<SHODebugAnalyticsPage>
    with SHOPageRouteAnalyticsMixin, SHOAppPageMixin, SHOAppTrackedPageMixin {
  @override
  String get pageName => 'debug_analytics';

  int _refreshTick = 0;

  void _refresh() => setState(() => _refreshTick++);

  Future<void> _fireSample(SHOAnalyticsEventDef event) async {
    final manager = ref.read(analyticsManagerProvider);
    await manager.trackEvent(event, event.sampleOrDefault());
    _refresh();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppLocalizations.of(context).debugAnalyticsFired(event.key),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final manager = ref.watch(analyticsManagerProvider);
    // ignore: unused_local_variable
    final _ = _refreshTick;
    final history = manager.history;
    final mockRemote = manager.mockRemoteBackend;

    return buildTrackedPage(
      DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            title: Text(l10n.debugAnalyticsEntry),
            bottom: TabBar(
              tabs: [
                Tab(text: l10n.debugAnalyticsTabEvents),
                Tab(text: l10n.debugAnalyticsTabBackends),
                Tab(text: l10n.debugAnalyticsTabHistory),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              _EventsTab(events: manager.events, onFire: _fireSample),
              _BackendsTab(
                backends: manager.backends,
                mockRemoteCount: mockRemote?.sent.length ?? 0,
              ),
              _HistoryTab(
                history: history,
                onClear: () {
                  manager.clearHistory();
                  _refresh();
                },
                onFireBridgeErrorSample: () =>
                    _fireSample(SHOAnalyticsRegistry.bridgeError),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EventsTab extends StatelessWidget {
  const _EventsTab({required this.events, required this.onFire});

  final List<SHOAnalyticsEventDef> events;
  final Future<void> Function(SHOAnalyticsEventDef event) onFire;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return ListView.separated(
      padding: const EdgeInsets.all(SHOAppSpacing.xl),
      itemCount: events.length,
      separatorBuilder: (_, __) => const SizedBox(height: SHOAppSpacing.md),
      itemBuilder: (context, index) {
        final event = events[index];
        return Card(
          child: ExpansionTile(
            title: Text(event.title),
            subtitle: Text('${l10n.debugAnalyticsEventKey}: ${event.key}'),
            children: [
              if (event.description.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    SHOAppSpacing.lg,
                    0,
                    SHOAppSpacing.lg,
                    SHOAppSpacing.sm,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      event.description,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: SHOAppSpacing.lg,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    l10n.debugAnalyticsFields,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
              ),
              ...event.fields.map(
                (field) => ListTile(
                  dense: true,
                  title: Text(field.name),
                  subtitle: Text(
                    '${field.type.name}${field.required ? ' *' : ''}'
                    '${field.description.isNotEmpty ? ' — ${field.description}' : ''}',
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(SHOAppSpacing.lg),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        event.sampleOrDefault().toString(),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontFamily: 'monospace',
                          color: context.shoTheme.textMuted,
                        ),
                      ),
                    ),
                    const SizedBox(width: SHOAppSpacing.md),
                    FilledButton(
                      onPressed: () => onFire(event),
                      child: Text(l10n.debugAnalyticsFire),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _BackendsTab extends StatelessWidget {
  const _BackendsTab({required this.backends, required this.mockRemoteCount});

  final List<SHOAnalyticsBackend> backends;
  final int mockRemoteCount;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return ListView(
      padding: const EdgeInsets.all(SHOAppSpacing.xl),
      children: [
        Text(
          l10n.debugAnalyticsBackendsHint,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: SHOAppSpacing.lg),
        ...backends.map(
          (backend) => ListTile(
            title: Text(backend.title),
            subtitle: Text('${backend.id} — ${backend.description}'),
            trailing: Chip(
              label: Text(
                backend.enabled
                    ? l10n.debugAnalyticsBackendOn
                    : l10n.debugAnalyticsBackendOff,
              ),
            ),
          ),
        ),
        if (mockRemoteCount > 0) ...[
          const Divider(),
          ListTile(
            title: Text(l10n.debugAnalyticsMockRemoteQueue),
            trailing: Text('$mockRemoteCount'),
          ),
        ],
      ],
    );
  }
}

class _HistoryTab extends StatelessWidget {
  const _HistoryTab({
    required this.history,
    required this.onClear,
    required this.onFireBridgeErrorSample,
  });

  final List<SHOAnalyticsRecord> history;
  final VoidCallback onClear;
  final VoidCallback onFireBridgeErrorSample;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final bridgeErrors = history
        .where((r) => r.eventKey == SHOAnalyticsRegistry.bridgeError.key)
        .take(8)
        .toList();

    if (history.isEmpty) {
      return Column(
        children: [
          _BridgeErrorSection(
            records: bridgeErrors,
            onFireSample: onFireBridgeErrorSample,
          ),
          Expanded(child: Center(child: Text(l10n.debugAnalyticsHistoryEmpty))),
        ],
      );
    }

    return Column(
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: onClear,
            child: Text(l10n.debugAnalyticsClearHistory),
          ),
        ),
        _BridgeErrorSection(
          records: bridgeErrors,
          onFireSample: onFireBridgeErrorSample,
        ),
        const Divider(height: SHOAppSpacing.xxxl),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: SHOAppSpacing.xl),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              l10n.debugAnalyticsTabHistory,
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
        ),
        const SizedBox(height: SHOAppSpacing.sm),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: SHOAppSpacing.xl),
            itemCount: history.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final record = history[index];
              return _HistoryRecordTile(record: record, l10n: l10n);
            },
          ),
        ),
      ],
    );
  }
}

class _BridgeErrorSection extends StatelessWidget {
  const _BridgeErrorSection({
    required this.records,
    required this.onFireSample,
  });

  final List<SHOAnalyticsRecord> records;
  final VoidCallback onFireSample;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        SHOAppSpacing.xl,
        0,
        SHOAppSpacing.xl,
        SHOAppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.debugAnalyticsBridgeErrorRecent,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              TextButton(
                onPressed: onFireSample,
                child: Text(l10n.debugAnalyticsFire),
              ),
            ],
          ),
          Text(
            l10n.debugAnalyticsBridgeErrorHint,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: SHOAppSpacing.md),
          if (records.isEmpty)
            Text(
              l10n.debugAnalyticsBridgeErrorEmpty,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: context.shoTheme.textMuted,
              ),
            )
          else
            ...records.map((record) => _BridgeErrorRecordTile(record: record)),
        ],
      ),
    );
  }
}

class _BridgeErrorRecordTile extends StatelessWidget {
  const _BridgeErrorRecordTile({required this.record});

  final SHOAnalyticsRecord record;

  @override
  Widget build(BuildContext context) {
    final pageName = record.params['page_name']?.toString() ?? '-';
    final error = record.params['error']?.toString() ?? '-';
    final bridgeType = record.params['bridge_type']?.toString();
    final bridgeAction = record.params['bridge_action']?.toString();
    final detail = [
      error,
      if (bridgeType != null && bridgeType.isNotEmpty) 'type=$bridgeType',
      if (bridgeAction != null && bridgeAction.isNotEmpty)
        'action=$bridgeAction',
    ].join(' · ');

    return ListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      leading: const Icon(Icons.warning_amber_outlined, size: 20),
      title: Text(pageName),
      subtitle: Text(detail),
      trailing: Text(
        _formatRecordTime(record.timestamp),
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }
}

class _HistoryRecordTile extends StatelessWidget {
  const _HistoryRecordTile({required this.record, required this.l10n});

  final SHOAnalyticsRecord record;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final isBridgeError =
        record.eventKey == SHOAnalyticsRegistry.bridgeError.key;

    if (isBridgeError) {
      return _BridgeErrorRecordTile(record: record);
    }

    return ListTile(
      title: Text(record.eventKey),
      subtitle: Text(
        '${record.timestamp.toIso8601String()}\n'
        '${record.params}\n'
        '${l10n.debugAnalyticsBackendsUsed}: ${record.backendIds.join(', ')}'
        '${record.error != null ? '\n${record.error}' : ''}',
      ),
      isThreeLine: true,
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
