import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shoo/core/pages/hos_pages.dart';

/// HitTestBehavior 调试页：对比 deferToChild / opaque / translucent 的命中与点击传递。
class SHODebugHitTestPage extends ConsumerStatefulWidget {
  const SHODebugHitTestPage({super.key});

  @override
  ConsumerState<SHODebugHitTestPage> createState() =>
      _SHODebugHitTestPageState();
}

enum _LogKind { detail, header, summary }

class _LogEntry {
  const _LogEntry(this.text, this.kind);

  final String text;
  final _LogKind kind;
}

class _HitEvent {
  const _HitEvent({
    required this.layer,
    required this.widget,
    required this.event,
    this.position,
  });

  final String layer;
  final String widget;
  final String event;
  final Offset? position;
}

class _GestureSession {
  _GestureSession({required this.zone, required this.tapId});

  final String zone;
  final int tapId;
  final List<_HitEvent> events = [];
}

class _SHODebugHitTestPageState extends ConsumerState<SHODebugHitTestPage>
    with SHOPageRouteAnalyticsMixin, SHOAppPageMixin, SHOAppTrackedPageMixin {
  @override
  String get pageName => 'debug_hittest';

  final _entries = <_LogEntry>[];
  final _scrollController = ScrollController();
  final _sessions = <String, _GestureSession>{};
  final _finalizeTimers = <String, Timer>{};

  var _seq = 0;
  var _tapId = 0;
  var _showPointerMove = false;

  static const _allLayers = ['子按钮', '父层', '底层'];

  @override
  void dispose() {
    for (final timer in _finalizeTimers.values) {
      timer.cancel();
    }
    _scrollController.dispose();
    super.dispose();
  }

  void _log(String zone, String source, String event, {Offset? position}) {
    if (event == 'pointerMove' && !_showPointerMove) return;

    final parsed = _parseSource(source);
    final session = _sessions.putIfAbsent(zone, () {
      final s = _GestureSession(zone: zone, tapId: ++_tapId);
      _pushEntry(
        '━━━━━━━━ 点击 #${s.tapId.toString().padLeft(2, '0')} [$zone] ━━━━━━━━',
        _LogKind.header,
      );
      return s;
    });

    session.events.add(
      _HitEvent(
        layer: parsed.layer,
        widget: parsed.widget,
        event: event,
        position: position,
      ),
    );

    final time = TimeOfDay.fromDateTime(DateTime.now()).format(context);
    final pos = position == null
        ? ''
        : ' @(${position.dx.toStringAsFixed(0)}, ${position.dy.toStringAsFixed(0)})';
    final line =
        '[${(++_seq).toString().padLeft(3, '0')}] $time  [$zone] $source → $event$pos';
    debugPrint('[HitTest] $line');
    _pushEntry(line, _LogKind.detail);

    if (event != 'pointerMove') {
      _scheduleFinalize(zone);
    }
  }

  ({String layer, String widget}) _parseSource(String source) {
    final listener = source.endsWith(' Listener');
    final gesture = source.endsWith(' GestureDetector');
    if (listener) {
      return (layer: source.replaceAll(' Listener', ''), widget: 'Listener');
    }
    if (gesture) {
      return (
        layer: source.replaceAll(' GestureDetector', ''),
        widget: 'GestureDetector',
      );
    }
    return (layer: source, widget: 'Unknown');
  }

  void _scheduleFinalize(String zone) {
    _finalizeTimers[zone]?.cancel();
    _finalizeTimers[zone] = Timer(const Duration(milliseconds: 200), () {
      _finalizeSession(zone);
    });
  }

  void _finalizeSession(String zone) {
    final session = _sessions.remove(zone);
    _finalizeTimers.remove(zone)?.cancel();
    if (session == null || session.events.isEmpty) return;

    final summary = _buildSummary(session);
    debugPrint('[HitTest]\n$summary');
    for (final line in summary.split('\n')) {
      if (line.trim().isEmpty) continue;
      _pushEntry(line, _LogKind.summary);
    }
    _pushEntry('', _LogKind.summary);
  }

  String _buildSummary(_GestureSession session) {
    final pointerDownOrder = <String>[];
    final pointerUpOrder = <String>[];
    final tapDownOrder = <String>[];
    final tapUpOrder = <String>[];
    final tapOrder = <String>[];
    final tapCancelOrder = <String>[];

    void appendUnique(List<String> list, String layer) {
      if (!list.contains(layer)) list.add(layer);
    }

    for (final event in session.events) {
      switch (event.event) {
        case 'pointerDown':
          if (event.widget == 'Listener')
            appendUnique(pointerDownOrder, event.layer);
        case 'pointerUp':
          if (event.widget == 'Listener')
            appendUnique(pointerUpOrder, event.layer);
        case 'onTapDown':
          appendUnique(tapDownOrder, event.layer);
        case 'onTapUp':
          appendUnique(tapUpOrder, event.layer);
        case 'onTap':
          appendUnique(tapOrder, event.layer);
        case 'onTapCancel':
          appendUnique(tapCancelOrder, event.layer);
      }
    }

    final pointerDownSet = pointerDownOrder.toSet();
    final tapDownSet = tapDownOrder.toSet();
    final tapSet = tapOrder.toSet();

    final pointerOnly = _allLayers
        .where(
          (layer) =>
              pointerDownSet.contains(layer) && !tapDownSet.contains(layer),
        )
        .toList();
    final tapCompetedLost = _allLayers
        .where((layer) => tapDownSet.contains(layer) && !tapSet.contains(layer))
        .toList();
    final noPointer = _allLayers
        .where((layer) => !pointerDownSet.contains(layer))
        .toList();

    String fmt(List<String> items) => items.isEmpty ? '（无）' : items.join(' → ');

    return '''
📋 总结 #${session.tapId.toString().padLeft(2, '0')} [${session.zone}]
  ① pointerDown 响应顺序: ${fmt(pointerDownOrder)}
  ② pointerUp   响应顺序: ${fmt(pointerUpOrder)}
  ③ onTapDown  参与顺序: ${fmt(tapDownOrder)}
  ④ onTapUp    响应顺序: ${fmt(tapUpOrder)}
  ⑤ onTap      最终响应: ${fmt(tapOrder)}
  ⑥ onTapCancel 取消层: ${fmt(tapCancelOrder)}
  ── 分层结论 ──
  · 收到 pointerDown 的层: ${fmt(pointerDownOrder)}
  · 进入 Tap 竞争的层(onTapDown): ${fmt(tapDownOrder)}
  · 最终触发 onTap 的层: ${fmt(tapOrder)}
  · 仅有 pointer、未进 Tap: ${fmt(pointerOnly)}
  · 参与 Tap 但未 onTap: ${fmt(tapCompetedLost)}
  · 完全未参与本次点击: ${fmt(noPointer)}''';
  }

  void _pushEntry(String text, _LogKind kind) {
    setState(() => _entries.insert(0, _LogEntry(text, kind)));
  }

  void _clearLog() {
    for (final timer in _finalizeTimers.values) {
      timer.cancel();
    }
    setState(() {
      _entries.clear();
      _sessions.clear();
      _finalizeTimers.clear();
      _seq = 0;
      _tapId = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return buildTrackedPage(
      Scaffold(
        appBar: AppBar(
          title: const Text('HitTestBehavior 调试'),
          actions: [
            IconButton(
              tooltip: '清空日志',
              icon: const Icon(Icons.clear_all),
              onPressed: _clearLog,
            ),
          ],
        ),
        body: Column(
          children: [
            _buildLegend(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                children: [
                  _BehaviorDemoCard(
                    behavior: HitTestBehavior.deferToChild,
                    title: 'deferToChild',
                    subtitle: '仅子组件命中时，父层才参与命中测试',
                    parentColor: Colors.red,
                    onLog: (source, event, position) =>
                        _log('deferToChild', source, event, position: position),
                    showPointerMove: _showPointerMove,
                  ),
                  const SizedBox(height: 12),
                  _BehaviorDemoCard(
                    behavior: HitTestBehavior.opaque,
                    title: 'opaque',
                    subtitle: '父层参与命中并阻挡下层，独占事件',
                    parentColor: Colors.blue,
                    onLog: (source, event, position) =>
                        _log('opaque', source, event, position: position),
                    showPointerMove: _showPointerMove,
                  ),
                  const SizedBox(height: 12),
                  _BehaviorDemoCard(
                    behavior: HitTestBehavior.translucent,
                    title: 'translucent',
                    subtitle: '父层参与命中，同时允许事件继续传给下层',
                    parentColor: Colors.green,
                    onLog: (source, event, position) =>
                        _log('translucent', source, event, position: position),
                    showPointerMove: _showPointerMove,
                  ),
                  const SizedBox(height: 12),
                  // ========== opaque 阻断效果演示 ==========
                  _OpaqueBlockingDemo(
                    onLog: (source, event, position) =>
                        _log('opaque阻断', source, event, position: position),
                    showPointerMove: _showPointerMove,
                  ),
                  const SizedBox(height: 12),
                  // ========== translucent 穿透效果演示 ==========
                  _TranslucentPenetrateDemo(
                    onLog: (source, event, position) => _log(
                      'translucent穿透',
                      source,
                      event,
                      position: position,
                    ),
                    showPointerMove: _showPointerMove,
                  ),

                  // ========== other  穿透无效果演示 ==========
                  _OtherPenetrateDemo(
                    onLog: (source, event, position) => _log(
                      'translucent不穿透',
                      source,
                      event,
                      position: position,
                    ),
                    showPointerMove: _showPointerMove,
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            SizedBox(height: 280, child: _buildLogArea()),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '// ============================================\n// 使用 GestureDetector（走竞技场）\n// ============================================',
            ),
            Text(
              '// ============================================\n// 使用 Listener（不走竞技场）\n// ============================================',
            ),
            Text(
              '每组演示：底层灰板 + 半透明父层 + 中央子按钮',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 6),
            Text(
              '① 点子按钮  ② 点父层空白  ③ 点底层露出区域 — 每次点击结束自动输出总结',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              title: const Text('记录 pointerMove'),
              value: _showPointerMove,
              onChanged: (value) => setState(() => _showPointerMove = value),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogArea() {
    return ColoredBox(
      color: Colors.black,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
            child: Row(
              children: [
                const Icon(Icons.terminal, color: Colors.greenAccent, size: 18),
                const SizedBox(width: 8),
                Text(
                  '事件日志 (${_entries.length})',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Text(
                  '青色=总结',
                  style: TextStyle(
                    color: Colors.cyanAccent.withValues(alpha: 0.8),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Scrollbar(
              controller: _scrollController,
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                itemCount: _entries.isEmpty ? 1 : _entries.length,
                itemBuilder: (context, index) {
                  if (_entries.isEmpty) {
                    return Text(
                      '点击上方演示区…\n\n'
                      '每次点击会输出：\n'
                      '· 逐条事件（Listener / GestureDetector）\n'
                      '· 📋 总结：pointerDown / onTapDown / onTap 的响应顺序\n'
                      '· 哪些层参与了命中、哪些层最终触发了 onTap',
                      style: TextStyle(
                        color: Colors.greenAccent.withValues(alpha: 0.7),
                        fontFamily: 'Menlo',
                        fontSize: 12,
                        height: 1.45,
                      ),
                    );
                  }

                  final entry = _entries[index];
                  if (entry.text.isEmpty) return const SizedBox(height: 6);

                  final color = switch (entry.kind) {
                    _LogKind.header => Colors.amberAccent,
                    _LogKind.summary => Colors.cyanAccent,
                    _LogKind.detail => Colors.greenAccent,
                  };
                  final weight =
                      entry.kind == _LogKind.summary &&
                          entry.text.startsWith('📋')
                      ? FontWeight.w700
                      : FontWeight.normal;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: Text(
                      entry.text,
                      style: TextStyle(
                        color: color,
                        fontFamily: 'Menlo',
                        fontSize: entry.kind == _LogKind.summary ? 11 : 11.5,
                        height: 1.35,
                        fontWeight: weight,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

typedef _HitTestLog =
    void Function(String source, String event, Offset? position);

class _BehaviorDemoCard extends StatelessWidget {
  const _BehaviorDemoCard({
    required this.behavior,
    required this.title,
    required this.subtitle,
    required this.parentColor,
    required this.onLog,
    required this.showPointerMove,
  });

  final HitTestBehavior behavior;
  final String title;
  final String subtitle;
  final Color parentColor;
  final _HitTestLog onLog;
  final bool showPointerMove;

  static const _cardHeight = 260.0;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 10),

            testBuilder(),

            SizedBox(
              height: _cardHeight,
              width: double.infinity,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  _HitLayer(
                    label: '底层',
                    behavior: HitTestBehavior.opaque,
                    color: Colors.grey.shade700,
                    onLog: onLog,
                    showPointerMove: showPointerMove,
                    child: const Center(
                      child: Text(
                        '底层灰板\n(opaque)',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white54, fontSize: 11),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 12,
                    top: 12,
                    // right: 56,
                    // bottom: 12,
                    width: 150,
                    height: 110,
                    child: _HitLayer(
                      label: '父层',
                      behavior: behavior,
                      color: parentColor.withValues(alpha: 0.45),
                      borderColor: parentColor,
                      onLog: onLog,
                      showPointerMove: showPointerMove,
                      child: Center(
                        child: _HitLayer(
                          label: '子按钮',
                          behavior: HitTestBehavior.deferToChild,
                          color: parentColor,
                          width: 72,
                          height: 72,
                          onLog: onLog,
                          showPointerMove: showPointerMove,
                          child: const Text(
                            '①\n子按钮',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  Positioned(
                    left: 12,
                    top: 140,
                    right: 56,
                    bottom: 12,
                    // width: 80,
                    // height: 120,
                    child: _HitLayer(
                      label: '父层2',
                      behavior: behavior,
                      color: parentColor.withValues(alpha: 0.45),
                      borderColor: Colors.blue,
                      onLog: onLog,
                      showPointerMove: showPointerMove,
                      child: Center(
                        child: Row(
                          children: [
                            GestureDetector(
                              behavior: HitTestBehavior.opaque, // ← 关键
                              onTap: () =>
                                  onLog('2--1 GestureDetector', 'onTap', null),
                              child: GestureDetector(
                                onTap: () => onLog(
                                  '子2--1 onTap ❌ 永远不会打印',
                                  'onTap',
                                  null,
                                ), // 永远不会执行
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                            GestureDetector(
                              behavior: HitTestBehavior.opaque, // ← 关键
                              onTap: () =>
                                  onLog('2--2 GestureDetector', 'onTap', null),
                              child: GestureDetector(
                                onTap: () => onLog(
                                  '子2--2 onTap ❌ 永远不会打印',
                                  'onTap',
                                  null,
                                ), // 永远不会执行
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  color: const Color.fromARGB(255, 54, 244, 70),
                                ),
                              ),
                            ),
                            GestureDetector(
                              behavior: HitTestBehavior.opaque, // ← 关键
                              onTap: () =>
                                  onLog('2--3 GestureDetector', 'onTap', null),
                              child: GestureDetector(
                                onTap: () => onLog(
                                  '子2--3 onTap ❌ 永远不会打印',
                                  'onTap',
                                  null,
                                ), // 永远不会执行
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  color: const Color.fromARGB(255, 54, 86, 244),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const Positioned(
                    right: 8,
                    child: _SpotMarker(label: '②', hint: '父层空白'),
                  ),
                  const Positioned(
                    right: 8,
                    bottom: 8,
                    child: _SpotMarker(label: '③', hint: '底层露出'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget testBuilder() {
    return Container(
      width: 300,
      height: 350,
      color: const Color.fromARGB(255, 54, 212, 244),
      child: Column(
        children: [
          const Text('opaque 2-1'),
          Row(
            children: [
              GestureDetector(
                //deferToChild
                onPanStart: (details) => onLog(
                  'kkkkkkkk-1 GestureDetector',
                  'onPanStart',
                  details.localPosition,
                ),
                onPanDown: (details) => onLog(
                  'kkkkkkkk-1 GestureDetector',
                  'onPanDown',
                  details.localPosition,
                ),
                behavior: HitTestBehavior.deferToChild, // ← 关键
                onTap: () => onLog(
                  'kkkkkkkk-1 deferToChild GestureDetector',
                  'onTap',
                  null,
                ),
                child: GestureDetector(
                  onTap: () => onLog(
                    '子 kkkkk-1-1 onTap 打开：侧 kkkkkkkk-1  onTap ❌ 永远不会打印',
                    'onTap',
                    null,
                  ), // 永远不会执行
                  onPanStart: (details) => onLog(
                    'kkkkkkkk-1-1 GestureDetector',
                    'onPanStart',
                    details.localPosition,
                  ),
                  onPanDown: (details) => onLog(
                    'kkkkkkkk-1-1 GestureDetector',
                    'onPanEnd',
                    details.localPosition,
                  ),
                  child: Container(
                    width: 80,
                    height: 80,
                    color: const Color.fromARGB(255, 200, 54, 244),
                    child: const Text('deferToChild 1-1'),
                  ),
                ),
              ),

              GestureDetector(
                //deferToChild
                onPanStart: (details) => onLog(
                  'kkkkkkkk-2 GestureDetector',
                  'onPanStart',
                  details.localPosition,
                ),
                onPanDown: (details) => onLog(
                  'kkkkkkkk-2 GestureDetector',
                  'onPanDown',
                  details.localPosition,
                ),
                behavior: HitTestBehavior.opaque, // ← 关键
                onTap: () =>
                    onLog('kkkkkkkk-2 opaque GestureDetector', 'onTap', null),
                child: GestureDetector(
                  onTap: () => onLog(
                    '子 kkkkk-2-1 onTap 打开：侧 kkkkkkkk-2  onTap ❌ 永远不会打印',
                    'onTap',
                    null,
                  ), // 永远不会执行
                  onPanStart: (details) => onLog(
                    'kkkkkkkk-2-1 GestureDetector',
                    'onPanStart',
                    details.localPosition,
                  ),
                  onPanDown: (details) => onLog(
                    'kkkkkkkk-2-1 GestureDetector',
                    'onPanEnd',
                    details.localPosition,
                  ),
                  child: Container(
                    width: 80,
                    height: 80,
                    color: const Color.fromARGB(255, 79, 244, 54),
                    child: const Text('opaque 2-1'),
                  ),
                ),
              ),

              GestureDetector(
                //translucent
                onPanStart: (details) => onLog(
                  'kkkkkkkk-3 GestureDetector',
                  'onPanStart',
                  details.localPosition,
                ),
                onPanDown: (details) => onLog(
                  'kkkkkkkk-3 GestureDetector',
                  'onPanDown',
                  details.localPosition,
                ),
                behavior: HitTestBehavior.translucent, // ← 关键
                onTap: () => onLog('kkkkkkkk-3 GestureDetector', 'onTap', null),
                child: GestureDetector(
                  onTap: () => onLog(
                    '子 kkkkk-3-1 onTap 打开：侧 kkkkkkkk-3  onTap ❌ 永远不会打印',
                    'onTap',
                    null,
                  ), // 永远不会执行
                  onPanStart: (details) => onLog(
                    'kkkkkkkk-3-1 GestureDetector',
                    'onPanStart',
                    details.localPosition,
                  ),
                  onPanDown: (details) => onLog(
                    'kkkkkkkk-3-1 GestureDetector',
                    'onPanEnd',
                    details.localPosition,
                  ),
                  child: Container(
                    width: 80,
                    height: 80,
                    color: const Color.fromARGB(255, 200, 54, 244),
                    child: const Text('translucent 3-1'),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 200,
            width: double.infinity,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  left: 12,
                  top: 10,
                  width: 80,
                  height: 80,
                  child: GestureDetector(
                    //translucent
                    onPanStart: (details) => onLog(
                      'Positioned -1 GestureDetector',
                      'onPanStart',
                      details.localPosition,
                    ),
                    onPanDown: (details) => onLog(
                      'Positioned -1 GestureDetector',
                      'onPanDown',
                      details.localPosition,
                    ),
                    behavior: HitTestBehavior.translucent, // ← 关键
                    onTap: () =>
                        onLog('Positioned -1 GestureDetector', 'onTap', null),
                    child: GestureDetector(
                      onTap: () => onLog(
                        '子 Positioned -1-1 onTap 打开：侧 Positioned -1  onTap ❌ 永远不会打印',
                        'onTap',
                        null,
                      ), // 永远不会执行
                      onPanStart: (details) => onLog(
                        'Positioned -1-1 GestureDetector',
                        'onPanStart',
                        details.localPosition,
                      ),
                      onPanDown: (details) => onLog(
                        'Positioned -1-1 GestureDetector',
                        'onPanEnd',
                        details.localPosition,
                      ),
                      child: Container(
                        width: 70,
                        height: 70,
                        color: const Color.fromARGB(255, 200, 54, 244),
                        child: const Text('deferToChild 1-1-1'),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 80,
                  top: 10,
                  width: 80,
                  height: 80,
                  child: GestureDetector(
                    //translucent
                    onPanStart: (details) => onLog(
                      'Positioned -2 supGestureDetector',
                      'onPanStart',
                      details.localPosition,
                    ),
                    onTapUp: (details) => onLog(
                      'Positioned -2 sup GestureDetector',
                      'onTapUp',
                      details.localPosition,
                    ),
                    onPanDown: (details) => onLog(
                      'Positioned -2 sup GestureDetector',
                      'onPanDown',
                      details.localPosition,
                    ),
                    behavior: HitTestBehavior.opaque, // ← 关键
                    // onTap: () =>
                    //     onLog('Positioned -2 GestureDetector', 'onTap', null),
                    child: GestureDetector(
                      onTap: () => onLog(
                        '子 Positioned -2-1 onTap 打开：侧 kPositioned -2  onTap ❌ 永远不会打印',
                        'onTap',
                        null,
                      ), // 永远不会执行
                      behavior: HitTestBehavior.deferToChild,
                      onPanStart: (details) => onLog(
                        'Positioned -2-1 GestureDetector',
                        'onPanStart',
                        details.localPosition,
                      ),
                      onTapUp: (details) => onLog(
                        'Positioned -2-1 GestureDetector',
                        'onTapUp',
                        details.localPosition,
                      ),
                      onPanDown: (details) => onLog(
                        'Positioned -2-1 GestureDetector',
                        'onPanDown',
                        details.localPosition,
                      ),
                      child: Container(
                        width: 70,
                        height: 70,
                        color: const Color.fromARGB(
                          255,
                          54,
                          244,
                          152,
                        ).withAlpha(125),
                        child: GestureDetector(
                          behavior: HitTestBehavior.deferToChild,
                          onTap: () => onLog(
                            '子 Positioned -3-2 onTap 打开：侧 Positioned -2-1 onTap ❌ 永远不会打印',
                            'onTap',
                            null,
                          ),
                          onPanStart: (details) => onLog(
                            'Positioned -3-1 GestureDetector',
                            'onPanStart',
                            details.localPosition,
                          ),
                          onTapUp: (details) => onLog(
                            'Positioned -3-1 GestureDetector',
                            'onTapUp',
                            details.localPosition,
                          ),
                          onPanDown: (details) => onLog(
                            'Positioned -3-1 GestureDetector',
                            'onPanDown',
                            details.localPosition,
                          ),
                          child: Container(
                            margin: EdgeInsets.all(20),
                            width: 40,
                            height: 40,
                            color: const Color.fromARGB(255, 244, 133, 54),
                            child: const Text('deferToChild 3-2-11'),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// opaque 阻断效果演示：两层完全重叠，顶层 opaque 会阻断底层事件
class _OpaqueBlockingDemo extends StatelessWidget {
  const _OpaqueBlockingDemo({
    required this.onLog,
    required this.showPointerMove,
  });

  final _HitTestLog onLog;
  final bool showPointerMove;

  static const _cardHeight = 220.0;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('opaque 阻断效果', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 2),
            Text(
              '顶层 opaque 完全覆盖底层，阻断所有事件 ===>OK',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 10),
            // 点击测试区域
            SizedBox(
              height: _cardHeight,
              width: double.infinity,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // ========== 底层（蓝色）==========
                  Positioned.fill(
                    child: _HitLayer(
                      label: '底层',
                      behavior: HitTestBehavior.opaque,
                      color: Colors.blue,
                      onLog: onLog,
                      showPointerMove: showPointerMove,
                      child: const Center(
                        child: Text(
                          '底层\n（蓝色）',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ),
                    ),
                  ),

                  // ========== 顶层（红色 opaque）==========
                  // 关键：opaque 会阻断事件，不传递给底层
                  Positioned(
                    top: 30,
                    left: 30,
                    width: 100,
                    height: 100,
                    child: _HitLayer(
                      label: '顶层',
                      behavior: HitTestBehavior.opaque,
                      color: Colors.red.withValues(alpha: 0.5),
                      borderColor: Colors.red,
                      onLog: onLog,
                      showPointerMove: showPointerMove,
                      child: const Center(
                        child: Text(
                          '顶层 opaque\n（阻断底层）',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // 标注
                  const Positioned(
                    left: 8,
                    top: 8,
                    child: Text(
                      '点击任意位置',
                      style: TextStyle(color: Colors.white60, fontSize: 10),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // 预期结果说明
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: Colors.amber),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '预期：无论点击哪里，都只有"顶层"响应，因为 opaque 阻断了底层',
                      style: TextStyle(fontSize: 11, color: Colors.amber),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// translucent 穿透效果演示：顶层 translucent 允许事件穿透到底层
class _TranslucentPenetrateDemo extends StatelessWidget {
  const _TranslucentPenetrateDemo({
    required this.onLog,
    required this.showPointerMove,
  });

  final _HitTestLog onLog;
  final bool showPointerMove;

  static const _cardHeight = 220.0;

  final String descResult = """
当属性设置为HitTestBehavior.deferToChild控制台输出结果

我们这里演示每次都是先点击绿色盒子在点击文字，以便大家能更好的分辨出这三个属性的使用区别

flutter: 绿色盒子被点击了
flutter: 文字点击事件回调

当属性设置为HitTestBehavior.opaque:
flutter: 文字点击事件回调
flutter: 文字点击事件回调

当属性设置为HitTestBehavior.translucent:
flutter: 文字点击事件回调
flutter: 绿色盒子被点击了
flutter: 文字点击事件回调
""";

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$descResult'),
            const SizedBox(height: 10),
            // 点击测试区域
            SizedBox(
              height: _cardHeight,
              width: double.infinity,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Listener(
                    child: ConstrainedBox(
                      constraints: BoxConstraints.tight(Size(400, 200)),
                      child: Container(color: Colors.greenAccent),
                    ),
                    onPointerDown: (event) => print("绿色盒子被点击了"),
                  ),
                  Listener(
                    child: ConstrainedBox(
                      constraints: BoxConstraints.tight(Size(200, 200)),
                      child: Center(
                        child: Text(
                          "点击文字",
                          style: TextStyle(color: Colors.white, fontSize: 30),
                        ),
                      ),
                    ),
                    onPointerDown: (event) => print("文字点击事件回调"),
                    behavior: HitTestBehavior.translucent,
                    // behavior: HitTestBehavior.opaque,
                    // behavior: HitTestBehavior.translucent,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OtherPenetrateDemo extends StatelessWidget {
  const _OtherPenetrateDemo({
    required this.onLog,
    required this.showPointerMove,
  });

  final _HitTestLog onLog;
  final bool showPointerMove;

  static const _cardHeight = 220.0;

  final String descResult = """

""";

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$descResult'),
            const SizedBox(height: 10),
            // 点击测试区域
            SizedBox(
              height: _cardHeight,
              width: double.infinity,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // ========== 底层（蓝色）==========
                  Positioned(
                    left: 100,
                    top: 100,
                    child: GestureDetector(
                      onTap: () => print('A'),
                      child: Container(
                        color: Colors.blue,
                        width: 100,
                        height: 100,
                      ),
                    ),
                  ),

                  // Positioned(
                  //   left: 150,
                  //   top: 150,
                  //   child: IgnorePointer( // 这种可以
                  //     // ← 关键：B 完全不参与命中测试
                  //     child: Container(
                  //       width: 100,
                  //       height: 100,
                  //       color: Colors.red.withValues(alpha: 0.5),
                  //     ),
                  //   ),
                  // ),
                  // Positioned(
                  //   left: 150,
                  //   top: 150,
                  //   child: Listener(
                  //     behavior: HitTestBehavior.translucent,
                  //     onPointerDown: (event) {
                  //       // 在这里自己写逻辑，决定是否要处理
                  //       // 如果处理，可以做标记；如果不处理，A的 GestureDetector 仍会正常响应
                  //       print('B - onPointerDown at ${event.localPosition}');
                  //     },
                  //     child: Container(
                  //       width: 100,
                  //       height: 100,
                  //       color: const Color.fromARGB(
                  //         255,
                  //         54,
                  //         244,
                  //         76,
                  //       ).withValues(alpha: 0.5),
                  //     ),
                  //   ),
                  // ),
                  Positioned(
                    left: 150,
                    top: 150,
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      //onTap: () => print('B'),//打不打开，底部重叠也不会触发底层事件
                      child: Container(
                        width: 100,
                        height: 100,
                        color: Colors.red.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HitLayer extends StatelessWidget {
  const _HitLayer({
    required this.label,
    required this.behavior,
    required this.color,
    required this.onLog,
    required this.showPointerMove,
    required this.child,
    this.borderColor,
    this.width,
    this.height,
  });

  final String label;
  final HitTestBehavior behavior;
  final Color color;
  final Color? borderColor;
  final _HitTestLog onLog;
  final bool showPointerMove;
  final Widget child;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    Widget content = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        border: borderColor == null
            ? null
            : Border.all(color: borderColor!, width: 2),
        borderRadius: borderRadius(width != null || height != null ? 10 : 0),
      ),
      child: child,
    );

    content = Listener(
      behavior: behavior,
      onPointerDown: (event) =>
          onLog('$label Listener', 'pointerDown', event.localPosition),
      onPointerUp: (event) =>
          onLog('$label Listener', 'pointerUp', event.localPosition),
      onPointerCancel: (event) =>
          onLog('$label Listener', 'pointerCancel', event.localPosition),
      onPointerMove: showPointerMove
          ? (event) =>
                onLog('$label Listener', 'pointerMove', event.localPosition)
          : null,
      child: GestureDetector(
        behavior: behavior,
        onTap: () => onLog('$label GestureDetector', 'onTap', null),
        onTapDown: (details) =>
            onLog('$label GestureDetector', 'onTapDown', details.localPosition),
        onTapUp: (details) =>
            onLog('$label GestureDetector', 'onTapUp', details.localPosition),
        onTapCancel: () => onLog('$label GestureDetector', 'onTapCancel', null),
        child: content,
      ),
    );

    return content;
  }

  BorderRadius? borderRadius(double radius) {
    if (radius <= 0) return null;
    return BorderRadius.circular(radius);
  }
}

class _SpotMarker extends StatelessWidget {
  const _SpotMarker({required this.label, required this.hint});

  final String label;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          hint,
          style: TextStyle(
            fontSize: 9,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
