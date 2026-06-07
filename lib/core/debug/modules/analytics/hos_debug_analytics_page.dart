import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../analytics/hos_analytics.dart';
import '../../../theme/hos_spacing.dart';
import '../../../theme/hos_theme_extension.dart';
import '../../../../l10n/app_localizations.dart';

class SHODebugAnalyticsPage extends ConsumerStatefulWidget {
  const SHODebugAnalyticsPage({super.key});

  @override
  ConsumerState<SHODebugAnalyticsPage> createState() => _SHODebugAnalyticsPageState();
}

class _SHODebugAnalyticsPageState extends ConsumerState<SHODebugAnalyticsPage> {
  int _refreshTick = 0;

  void _refresh() => setState(() => _refreshTick++);

  Future<void> _fireSample(SHOAnalyticsEventDef event) async {
    final manager = ref.read(analyticsManagerProvider);
    await manager.trackEvent(event, event.sampleOrDefault());
    _refresh();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context).debugAnalyticsFired(event.key)),
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

    return DefaultTabController(
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
            _EventsTab(
              events: manager.events,
              onFire: _fireSample,
            ),
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
            ),
          ],
        ),
      ),
    );
  }
}

class _EventsTab extends StatelessWidget {
  const _EventsTab({
    required this.events,
    required this.onFire,
  });

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
                padding: const EdgeInsets.symmetric(horizontal: SHOAppSpacing.lg),
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
  const _BackendsTab({
    required this.backends,
    required this.mockRemoteCount,
  });

  final List<SHOAnalyticsBackend> backends;
  final int mockRemoteCount;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return ListView(
      padding: const EdgeInsets.all(SHOAppSpacing.xl),
      children: [
        Text(l10n.debugAnalyticsBackendsHint, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: SHOAppSpacing.lg),
        ...backends.map(
          (backend) => ListTile(
            title: Text(backend.title),
            subtitle: Text('${backend.id} — ${backend.description}'),
            trailing: Chip(
              label: Text(
                backend.enabled ? l10n.debugAnalyticsBackendOn : l10n.debugAnalyticsBackendOff,
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
  });

  final List<SHOAnalyticsRecord> history;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (history.isEmpty) {
      return Center(child: Text(l10n.debugAnalyticsHistoryEmpty));
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
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: SHOAppSpacing.xl),
            itemCount: history.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final record = history[index];
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
            },
          ),
        ),
      ],
    );
  }
}
