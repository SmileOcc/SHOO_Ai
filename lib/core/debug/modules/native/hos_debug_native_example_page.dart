import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../platform/hos_native_stream_service.dart';
import '../../../theme/hos_spacing.dart';
import 'hos_debug_native_examples.dart';
import 'hos_debug_native_l10n.dart';
import 'hos_debug_native_runner.dart';

/// 单个原生调试示例：执行调用并展示结果 / 事件流。
class SHODebugNativeExamplePage extends StatefulWidget {
  const SHODebugNativeExamplePage({super.key, required this.example});

  final SHONativeDebugExample example;

  @override
  State<SHODebugNativeExamplePage> createState() => _SHODebugNativeExamplePageState();
}

class _SHODebugNativeExamplePageState extends State<SHODebugNativeExamplePage> {
  final _messageCtrl = TextEditingController(text: 'hello from flutter');
  final _eventLog = <String>[];

  bool _loading = false;
  String? _result;
  String? _error;
  StreamSubscription<Map<String, dynamic>>? _eventSub;
  bool _streaming = false;

  bool get _isEventExample => widget.example.id == SHONativeDebugExampleId.eventTick;

  @override
  void dispose() {
    _stopEventStream();
    _messageCtrl.dispose();
    super.dispose();
  }

  Future<void> _runOnce() async {
    setState(() {
      _loading = true;
      _error = null;
      _result = null;
    });

    try {
      final output = await SHONativeDebugRunner.run(
        widget.example.id,
        messageInput: _messageCtrl.text,
      );
      if (!mounted) return;
      setState(() {
        _result = output;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = SHONativeDebugRunner.formatError(e);
        _loading = false;
      });
    }
  }

  void _startEventStream() {
    _stopEventStream();
    setState(() {
      _streaming = true;
      _error = null;
      _eventLog.clear();
    });

    _eventSub = SHONativeDebugRunner.debugEventStream().listen(
      (event) {
        if (!mounted) return;
        setState(() {
          _eventLog.insert(
            0,
            '#${_eventLog.length + 1} tick=${event['tick']} '
            'platform=${event['platform']} '
            'ts=${event['timestamp']}',
          );
          if (_eventLog.length > 20) {
            _eventLog.removeRange(20, _eventLog.length);
          }
        });
      },
      onError: (Object e) {
        if (!mounted) return;
        setState(() {
          _error = SHONativeDebugRunner.formatError(e);
          _streaming = false;
        });
      },
    );
  }

  void _stopEventStream() {
    _eventSub?.cancel();
    _eventSub = null;
    if (_streaming && mounted) {
      setState(() => _streaming = false);
    }
  }

  Future<void> _copyResult() async {
    final text = _isEventExample ? _eventLog.join('\n') : (_result ?? _error ?? '');
    if (text.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context).debugNativeCopied)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final example = widget.example;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.nativeExampleTitle(example.id))),
      body: ListView(
        padding: const EdgeInsets.all(SHOAppSpacing.xl),
        children: [
          Text(l10n.nativeExampleDesc(example.id)),
          const SizedBox(height: SHOAppSpacing.xl),
          if (example.id == SHONativeDebugExampleId.messageEcho) ...[
            TextField(
              controller: _messageCtrl,
              decoration: InputDecoration(
                labelText: l10n.debugNativeInputHint,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: SHOAppSpacing.lg),
          ],
          if (_isEventExample) ...[
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _streaming ? null : _startEventStream,
                    icon: const Icon(Icons.play_arrow),
                    label: Text(l10n.debugNativeStartStream),
                  ),
                ),
                const SizedBox(width: SHOAppSpacing.md),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _streaming ? _stopEventStream : null,
                    icon: const Icon(Icons.stop),
                    label: Text(l10n.debugNativeStopStream),
                  ),
                ),
              ],
            ),
          ] else
            FilledButton.icon(
              onPressed: _loading ? null : _runOnce,
              icon: _loading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.play_arrow),
              label: Text(l10n.debugNativeRun),
            ),
          const SizedBox(height: SHOAppSpacing.xl),
          Row(
            children: [
              Text(
                _isEventExample ? l10n.debugNativeStreamLog : l10n.debugNativeResult,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: _copyResult,
                icon: const Icon(Icons.copy, size: 18),
                label: Text(l10n.debugNativeCopy),
              ),
            ],
          ),
          const SizedBox(height: SHOAppSpacing.sm),
          if (_error != null)
            _ResultBox(
              text: _error!,
              isError: true,
            )
          else if (_isEventExample)
            _ResultBox(
              text: _eventLog.isEmpty
                  ? (_streaming ? l10n.debugNativeWaiting : l10n.debugNativeStreamIdle)
                  : _eventLog.join('\n'),
              isError: false,
            )
          else
            _ResultBox(
              text: _result ?? (_loading ? l10n.debugNativeWaiting : l10n.debugNativeNoResult),
              isError: false,
            ),
        ],
      ),
    );
  }
}

class _ResultBox extends StatelessWidget {
  const _ResultBox({required this.text, required this.isError});

  final String text;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(SHOAppSpacing.lg),
      decoration: BoxDecoration(
        color: isError ? colors.errorContainer : colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(SHOAppSpacing.sm),
      ),
      child: SelectableText(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontFamily: 'monospace',
              color: isError ? colors.onErrorContainer : null,
            ),
      ),
    );
  }
}

/// EventChannel 示例用的流服务封装（演示 [SHONativeStreamService] 用法）。
class SHONativeDebugEventService extends SHONativeStreamService<Map<String, dynamic>> {
  @override
  Stream<Map<String, dynamic>> get stream => SHONativeDebugRunner.debugEventStream();
}
