import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../marketing/hos_activity_popup_service.dart';
import '../../../marketing/hos_activity_prefetch_service.dart';
import '../../../theme/hos_spacing.dart';
import '../../../widgets/hos_activity_popup_dialog.dart';
import '../../../../l10n/app_localizations.dart';
import 'hos_debug_activity_config_provider.dart';
import '../../core/hos_debug_flow_status_banner.dart';
import 'hos_debug_activity_config.dart';

class SHODebugActivityConfigPage extends ConsumerStatefulWidget {
  const SHODebugActivityConfigPage({super.key});

  @override
  ConsumerState<SHODebugActivityConfigPage> createState() => _SHODebugActivityConfigPageState();
}

class _SHODebugActivityConfigPageState extends ConsumerState<SHODebugActivityConfigPage> {
  late final TextEditingController _idCtrl;
  late final TextEditingController _delayCtrl;
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _imageCtrl;
  late final TextEditingController _linkCtrl;
  late final TextEditingController _buttonCtrl;
  late final TextEditingController _maxDailyCtrl;

  bool _overrideEnabled = false;
  bool _prefetchEnabled = false;
  DateTime? _startAt;
  DateTime? _endAt;

  final _dateFormat = DateFormat('yyyy-MM-dd HH:mm');

  @override
  void initState() {
    super.initState();
    final c = ref.read(debugActivityConfigProvider);
    _idCtrl = TextEditingController(text: c.id);
    _delayCtrl = TextEditingController(text: '${c.delaySeconds}');
    _titleCtrl = TextEditingController(text: c.title);
    _descCtrl = TextEditingController(text: c.description);
    _imageCtrl = TextEditingController(text: c.imageUrl);
    _linkCtrl = TextEditingController(text: c.link);
    _buttonCtrl = TextEditingController(text: c.buttonText);
    _maxDailyCtrl = TextEditingController(text: '${c.maxDailyShows}');
    _overrideEnabled = c.overrideEnabled;
    _prefetchEnabled = c.prefetchEnabled;
    _startAt = c.startAt;
    _endAt = c.endAt;
  }

  @override
  void dispose() {
    _idCtrl.dispose();
    _delayCtrl.dispose();
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _imageCtrl.dispose();
    _linkCtrl.dispose();
    _buttonCtrl.dispose();
    _maxDailyCtrl.dispose();
    super.dispose();
  }

  SHODebugActivityConfig _buildConfig() {
    return SHODebugActivityConfig(
      overrideEnabled: _overrideEnabled,
      id: _idCtrl.text.trim(),
      delaySeconds: int.tryParse(_delayCtrl.text.trim()) ?? 0,
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text,
      imageUrl: _imageCtrl.text.trim(),
      link: _linkCtrl.text.trim(),
      buttonText: _buttonCtrl.text.trim(),
      startAt: _startAt,
      endAt: _endAt,
      prefetchEnabled: _prefetchEnabled,
      maxDailyShows: int.tryParse(_maxDailyCtrl.text.trim()) ?? 1,
    );
  }

  Future<void> _pickDateTime({required bool isStart}) async {
    final base = (isStart ? _startAt : _endAt) ?? DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: base,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(base),
    );
    if (time == null) return;

    final picked = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    setState(() {
      if (isStart) {
        _startAt = picked;
      } else {
        _endAt = picked;
      }
    });
  }

  Future<void> _save({String? snackMessage}) async {
    final l10n = AppLocalizations.of(context);
    await ref.read(debugActivityConfigProvider.notifier).save(_buildConfig());
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
    await ref.read(debugActivityConfigProvider.notifier).save(_buildConfig());
    if (!mounted) return;

    final activity = await ref.read(activityPopupServiceProvider).fetchActive();
    if (!mounted) return;

    if (activity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.debugPreviewNoActivity)),
      );
      return;
    }

    var popup = activity;
    if (activity.prefetchEnabled) {
      await ref.read(activityPrefetchServiceProvider).prefetch(activity);
      final cached = await ref.read(activityPrefetchServiceProvider).loadPrefetched(activity.id);
      if (cached != null) popup = cached;
    }
    if (!mounted) return;
    await SHOActivityPopupDialog.show(context, activity: popup);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.debugActivityTitle)),
      body: ListView(
        padding: const EdgeInsets.all(SHOAppSpacing.xl),
        children: [
          SHODebugFlowStatusBanner(overrideEnabled: _overrideEnabled),
          const SizedBox(height: SHOAppSpacing.lg),
          SwitchListTile(
            title: Text(l10n.debugOverrideEnabled),
            subtitle: Text(l10n.debugActivityOverrideHint),
            value: _overrideEnabled,
            onChanged: _onOverrideChanged,
          ),
          const SizedBox(height: SHOAppSpacing.md),
          TextField(
            controller: _delayCtrl,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: l10n.debugActivityDelay,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: SHOAppSpacing.lg),
          TextField(
            controller: _titleCtrl,
            decoration: InputDecoration(
              labelText: l10n.debugActivityPopupTitle,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: SHOAppSpacing.lg),
          TextField(
            controller: _descCtrl,
            minLines: 4,
            maxLines: 12,
            decoration: InputDecoration(
              labelText: l10n.debugActivityDescription,
              helperText: l10n.debugActivityDescScrollHint,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: SHOAppSpacing.lg),
          TextField(
            controller: _imageCtrl,
            decoration: InputDecoration(
              labelText: l10n.debugActivityImageUrl,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: SHOAppSpacing.lg),
          TextField(
            controller: _idCtrl,
            decoration: InputDecoration(
              labelText: l10n.debugActivityId,
              border: const OutlineInputBorder(),
            ),
          ),
          TextField(
            controller: _linkCtrl,
            decoration: InputDecoration(
              labelText: l10n.debugActivityLink,
              border: const OutlineInputBorder(),
            ),
          ),
          TextField(
            controller: _buttonCtrl,
            decoration: InputDecoration(
              labelText: l10n.debugActivityButton,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: SHOAppSpacing.lg),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.debugActivityStartAt),
            subtitle: Text(_startAt == null ? l10n.debugActivityDateUnset : _dateFormat.format(_startAt!)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_startAt != null)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () => setState(() => _startAt = null),
                  ),
                IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () => _pickDateTime(isStart: true),
                ),
              ],
            ),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.debugActivityEndAt),
            subtitle: Text(_endAt == null ? l10n.debugActivityDateUnset : _dateFormat.format(_endAt!)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_endAt != null)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () => setState(() => _endAt = null),
                  ),
                IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () => _pickDateTime(isStart: false),
                ),
              ],
            ),
          ),
          SwitchListTile(
            title: Text(l10n.debugActivityPrefetch),
            subtitle: Text(l10n.debugActivityPrefetchHint),
            value: _prefetchEnabled,
            onChanged: (v) => setState(() => _prefetchEnabled = v),
          ),
          TextField(
            controller: _maxDailyCtrl,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: l10n.debugActivityMaxDaily,
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
