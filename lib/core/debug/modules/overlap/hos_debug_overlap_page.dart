import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// 重叠视图点击事件调试页。
///
/// 核心规则（同一 Stack 重叠区域）：
// GlobalKey _bKey = GlobalKey();
//  // 注册布局回调，获取 B 的实际位置和大小
// WidgetsBinding.instance.addPostFrameCallback((_) {
//   print("获取B的实际大小");
//   _calculateClickableAreas();
// });

class SHODebugOverlapPage extends StatefulWidget {
  const SHODebugOverlapPage({super.key});

  @override
  State<SHODebugOverlapPage> createState() => _SHODebugOverlapPageState();
}

enum _LogKind { detail, header, summary }

class _LogEntry {
  const _LogEntry(this.text, this.kind);

  final String text;
  final _LogKind kind;
}

class _SHODebugOverlapPageState extends State<SHODebugOverlapPage> {
  final _entries = <_LogEntry>[];
  final _scrollController = ScrollController();

  String? _activeCase;
  final _pointerDownOrder = <String>[];
  final _tapLayers = <String>[];
  Timer? _finalizeTimer;
  var _seq = 0;
  var _tapId = 0;

  final GlobalKey _bKey = GlobalKey();
  final GlobalKey _aKey = GlobalKey();

  // B 的可见区域（排除与 A 重叠的部分）
  final List<Rect> _bClickableAreas = [];

  @override
  void initState() {
    super.initState();
    // 注册布局回调，获取 B 的实际位置和大小
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print("获取B的实际大小");
      _calculateClickableAreas();
      // 如果首次获取失败，延迟重试（处理异步布局情况）
      if (_bClickableAreas.isEmpty) {
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) {
            _calculateClickableAreas();
          }
        });
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 在依赖变化时重新计算（确保 context 已就绪）

    // 首次 build() 之前，在 initState() 之后立即调用
    // 之后每次依赖的 InheritedWidget 发生变化时调用
    if (_bClickableAreas.isEmpty) {
      _calculateClickableAreas();
    }
  }

  void _calculateClickableAreas() {
    final bRenderBox = _bKey.currentContext?.findRenderObject() as RenderBox?;
    final aRenderBox = _aKey.currentContext?.findRenderObject() as RenderBox?;

    print("获取B的实际大小bRenderBox: $bRenderBox");
    print("获取A的实际大小aRenderBox: $aRenderBox");

    if (bRenderBox == null || aRenderBox == null) return;

    // 1. 获取 A 和 B 的全局位置和大小
    final bGlobalOffset = bRenderBox.localToGlobal(Offset.zero);
    final bSize = bRenderBox.size;
    final Rect bRect = Rect.fromLTWH(
      bGlobalOffset.dx,
      bGlobalOffset.dy,
      bSize.width,
      bSize.height,
    );

    final aGlobalOffset = aRenderBox.localToGlobal(Offset.zero);
    final aSize = aRenderBox.size;
    final Rect aRect = Rect.fromLTWH(
      aGlobalOffset.dx,
      aGlobalOffset.dy,
      aSize.width,
      aSize.height,
    );

    print('A 区域: $aRect');
    print('B 区域: $bRect');

    // 假设 A 和 B 重叠区域已知（可以根据业务计算）
    // 2. 计算 A 和 B 的重叠区域
    final Rect? overlapRect = _calculateOverlap(aRect, bRect);

    if (overlapRect == null || overlapRect.isEmpty) {
      // 没有重叠，B 的所有区域都可点击
      print('A 和 B 没有重叠');
      _bClickableAreas.clear();
      _bClickableAreas.add(bRect);
      return;
    }

    print('重叠区域: $overlapRect');

    // 3. 从 B 中排除重叠区域，得到 B 的可点击区域
    _bClickableAreas.clear();
    _bClickableAreas.addAll(_excludeOverlapFromB(bRect, overlapRect));
    print('B 的可点击区域: $_bClickableAreas');
  }

  /// 计算两个矩形的重叠区域
  Rect? _calculateOverlap(Rect rect1, Rect rect2) {
    final left = rect1.left > rect2.left ? rect1.left : rect2.left;
    final top = rect1.top > rect2.top ? rect1.top : rect2.top;
    final right = rect1.right < rect2.right ? rect1.right : rect2.right;
    final bottom = rect1.bottom < rect2.bottom ? rect1.bottom : rect2.bottom;

    if (left < right && top < bottom) {
      return Rect.fromLTRB(left, top, right, bottom);
    }
    return null; // 没有重叠
  }

  /// 从 B 中排除重叠区域，返回 B 中不与 A 重叠的部分
  List<Rect> _excludeOverlapFromB(Rect bRect, Rect overlap) {
    final List<Rect> clickableAreas = [];

    // 将 B 分成最多 4 个非重叠区域：
    // ┌─────────────────┐
    // │      上          │
    // ├──────┬──────────┤
    // │  左  │ 重叠区域  │ 右
    // ├──────┴──────────┤
    // │      下          │
    // └─────────────────┘

    // 上方区域（如果存在）
    if (overlap.top > bRect.top) {
      clickableAreas.add(
        Rect.fromLTRB(bRect.left, bRect.top, bRect.right, overlap.top),
      );
    }

    // 下方区域（如果存在）
    if (overlap.bottom < bRect.bottom) {
      clickableAreas.add(
        Rect.fromLTRB(bRect.left, overlap.bottom, bRect.right, bRect.bottom),
      );
    }

    // 左侧区域（如果存在）
    if (overlap.left > bRect.left) {
      clickableAreas.add(
        Rect.fromLTRB(bRect.left, overlap.top, overlap.left, overlap.bottom),
      );
    }

    // 右侧区域（如果存在）
    if (overlap.right < bRect.right) {
      clickableAreas.add(
        Rect.fromLTRB(overlap.right, overlap.top, bRect.right, overlap.bottom),
      );
    }

    return clickableAreas;
  }

  /// 判断点击位置是否在 B 的可点击区域内
  bool _isInBClickableArea(Offset globalPosition) {
    return _bClickableAreas.any((rect) => rect.contains(globalPosition));
  }

  @override
  void dispose() {
    _finalizeTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _beginCase(String caseId) {
    if (_activeCase != caseId) {
      _finalizeSession();
      _activeCase = caseId;
      _pointerDownOrder.clear();
      _tapLayers.clear();
      _tapId++;
      _push(
        '━━━━━━━━ 点击 #${_tapId.toString().padLeft(2, '0')} [$caseId] ━━━━━━━━',
        _LogKind.header,
      );
    }
  }

  void _onPointerDown(String caseId, String layer) {
    _beginCase(caseId);
    if (!_pointerDownOrder.contains(layer)) {
      _pointerDownOrder.add(layer);
    }
    _logDetail(caseId, layer, 'Listener', 'pointerDown');
    _scheduleFinalize();
  }

  void _onTap(String caseId, String layer) {
    _beginCase(caseId);
    if (!_tapLayers.contains(layer)) {
      _tapLayers.add(layer);
    }
    _logDetail(caseId, layer, 'GestureDetector', 'onTap ✅');
    _scheduleFinalize();
  }

  void _logDetail(String caseId, String layer, String source, String event) {
    final line =
        '[${(++_seq).toString().padLeft(3, '0')}] [$caseId] $layer $source → $event';
    debugPrint('[Overlap] $line');
    _push(line, _LogKind.detail);
  }

  void _scheduleFinalize() {
    _finalizeTimer?.cancel();
    _finalizeTimer = Timer(const Duration(milliseconds: 180), _finalizeSession);
  }

  void _finalizeSession() {
    if (_activeCase == null) return;

    final caseId = _activeCase!;
    final pointer = _pointerDownOrder.isEmpty
        ? '（无）'
        : _pointerDownOrder.join(' → ');
    final taps = _tapLayers.isEmpty ? '（无）' : _tapLayers.join(' → ');

    final summary =
        '''
📋 总结 [$caseId]
  pointerDown 顺序: $pointer
  onTap  响应层: $taps
  规则核对: ${_ruleCheck(caseId)}''';

    debugPrint('[Overlap]\n$summary');
    for (final line in summary.split('\n')) {
      if (line.trim().isEmpty) continue;
      _push(line, _LogKind.summary);
    }
    _push('', _LogKind.summary);

    _activeCase = null;
    _pointerDownOrder.clear();
    _tapLayers.clear();
  }

  String _ruleCheck(String caseId) {
    final onlyA = _tapLayers.length == 1 && _tapLayers.first == 'A';
    final onlyB = _tapLayers.length == 1 && _tapLayers.first == 'B';
    final none = _tapLayers.isEmpty;

    return switch (caseId) {
      '场景7' =>
        onlyA
            ? '✅ 重叠区 → A（B 自定义命中排除）'
            : onlyB
            ? '✅ B 独占区 → B（自定义命中区域内）'
            : '⚠️ 预期重叠区 A / B 独占区 B',
      _ => '—',
    };
  }

  void _push(String text, _LogKind kind) {
    setState(() => _entries.insert(0, _LogEntry(text, kind)));
  }

  void _clearLogs() {
    _finalizeTimer?.cancel();
    setState(() {
      _entries.clear();
      _activeCase = null;
      _pointerDownOrder.clear();
      _tapLayers.clear();
      _seq = 0;
      _tapId = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('重叠视图点击事件调试'),
        actions: [
          IconButton(icon: const Icon(Icons.clear_all), onPressed: _clearLogs),
        ],
      ),
      body: Column(
        children: [
          _buildLegend(),
          Expanded(
            flex: 3,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [const SizedBox(height: 16), _buildCase7()],
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(flex: 2, child: _buildLogArea()),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('重叠区域点击规则', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Text(
            '• 场景7：自定义 RenderObject 按区域命中\n'
            '  B 整块在上层，仅 B 独占矩形参与命中 → 重叠区落到 A',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(height: 1.45),
          ),
        ],
      ),
    );
  }

  void _handleAClick() {
    print('执行 A 的逻辑');
  }

  void _handleBClick() {
    print('执行 B 的逻辑');
  }

  /// 场景7：自定义 RenderObject，B 全屏在上但仅独占区参与命中测试
  Widget _buildCase7() {
    return _buildDemoCard(
      title: '场景7：自定义命中区域（RenderObject）',
      subtitle: 'B 整块压住 A；hitTest 仅 B 独占矩形 → 重叠 A / 独占 B',
      child: _partialOverlapCustomHitTestLayout(
        caseId: '场景7',
        aColor: Colors.red.shade400,
        bColor: Colors.blue.shade400,
      ),
    );
  }

  /// B 在上层完整绘制；[_RegionHitTestWidget] 使 B 的 GestureDetector 仅在独占区命中。
  Widget _partialOverlapCustomHitTestLayout({
    required String caseId,
    required Color aColor,
    required Color bColor,
  }) {
    const top = 24.0;
    const boxHeight = 90.0;
    const aWidth = 200.0;
    const bLeft = 120.0;
    const bWidth = 180.0;
    final isEnableA = ValueNotifier<bool>(false);

    return SizedBox(
      height: 150,
      child: Listener(
        behavior: HitTestBehavior.opaque,
        onPointerDown: (event) {
          // 全局监听点击
          final position = event.position;
          _logDetail(
            caseId,
            "_partialOverlap",
            'Listener',
            'pointerDown 区域被点击 position $position',
          );

          // 判断是否在 B 的可点击区域内
          bool inB = _bClickableAreas.any((rect) => rect.contains(position));
          _logDetail(
            caseId,
            "Overlap",
            'Listener',
            'pointerDown 区域被点击 inB $inB',
          );

          isEnableA.value = !inB;
          _logDetail(
            caseId,
            "Overlap",
            'Listener',
            'pointerDown 结果>>： isEnableA ${isEnableA.value}',
          );

          if (inB) {
            _handleBClick();
          } else {
            _handleAClick();
          }
        },
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: 0,
              top: top,
              width: aWidth,
              height: boxHeight,
              child: GestureDetector(
                key: _aKey,
                onTap: () {
                  _logDetail(
                    caseId,
                    "_partialOverlap",
                    'Listener',
                    'onTap 底层 onTap 触发 isEnableA ${isEnableA.value}',
                  );
                },
                child: // A 视图
                Container(
                  color: Colors.blue.withOpacity(0.3),
                ),
              ),
            ),
            Positioned(
              left: bLeft,
              top: top,
              width: bWidth,
              height: boxHeight,
              child: GestureDetector(
                key: _bKey,
                onTap: () {
                  _logDetail(
                    caseId,
                    "_partialOverlap",
                    'Listener',
                    'onTap 上层 onTap 触发 isEnableA ${isEnableA.value}',
                  );
                },
                child: Container(
                  width: bWidth,
                  height: boxHeight,
                  decoration: BoxDecoration(
                    color: bColor.withValues(alpha: 0.72),
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x44000000),
                        blurRadius: 4,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(left: 8),
                  child: const Text(
                    'B 上层',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// A 先绘制（底层），B 后绘制压在 A 上。
  /// B 整块为视觉层 [IgnorePointer]；场景5 在 B 独占段再叠一层可点击区域。
  Widget _partialOverlapLayout({
    required String caseId,
    required bool aHasTap,
    required bool bHasTap,
    required Color aColor,
    required Color bColor,
  }) {
    const top = 24.0;
    const boxHeight = 90.0;
    const aWidth = 200.0;
    const bLeft = 120.0;
    const bWidth = 180.0;
    const overlapEnd = aWidth;
    const bExclusiveWidth = bLeft + bWidth - overlapEnd;

    return SizedBox(
      height: 130,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // ① A 底层
          Positioned(
            left: 0,
            top: top,
            child: _overlapLayer(
              caseId: caseId,
              layer: 'A',
              hasTap: aHasTap,
              width: aWidth,
              height: boxHeight,
              color: aColor.withValues(alpha: 0.9),
              label: 'A 底层\n有 onTap',
            ),
          ),
          // ② B 视觉层（后添加，盖住 A；不参与命中）
          Positioned(
            left: bLeft,
            top: top,
            child: _overlapVisualLayer(
              width: bWidth,
              height: boxHeight,
              color: bColor.withValues(alpha: 0.72),
              label: 'B 上层\n(仅视觉)',
            ),
          ),
          // ③ B 独占区点击层（最上层，仅场景5）
          if (bHasTap)
            Positioned(
              left: overlapEnd,
              top: top,
              child: _overlapLayer(
                caseId: caseId,
                layer: 'B',
                hasTap: true,
                width: bExclusiveWidth,
                height: boxHeight,
                color: bColor.withValues(alpha: 0.35),
                label: 'B 独占\nonTap',
              ),
            ),
          Positioned(
            left: 150,
            top: 4,
            child: _zoneMarker(
              label: '重叠',
              hint: '点这里 → A',
              color: Colors.amber.shade200,
            ),
          ),
          Positioned(
            right: 0,
            top: 52,
            child: _zoneMarker(
              label: 'B独占',
              hint: bHasTap ? '点这里 → B' : '点这里 → 无',
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  /// B 压在 A 上的纯视觉层，不拦截点击（重叠区事件落到 A）。
  Widget _overlapVisualLayer({
    required double width,
    required double height,
    required Color color,
    required String label,
  }) {
    return IgnorePointer(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: color,
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: const [
            BoxShadow(
              color: Color(0x44000000),
              blurRadius: 4,
              offset: Offset(2, 2),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 11,
          ),
        ),
      ),
    );
  }

  Widget _zoneMarker({
    required String label,
    required String hint,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.black26),
          ),
          child: Text(
            label,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
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

  Widget _overlapStack({
    required String caseId,
    required Color bColor,
    required Widget Function(String caseId) aBuilder,
  }) {
    return Stack(
      children: [
        _overlapLayer(
          caseId: caseId,
          layer: 'B',
          hasTap: true,
          height: 100,
          color: bColor,
          label: 'B 底层\n有 onTap',
        ),
        Positioned(left: 20, top: 20, right: 20, child: aBuilder(caseId)),
      ],
    );
  }

  Widget _overlapLayer({
    required String caseId,
    required String layer,
    required bool hasTap,
    required Color color,
    required String label,
    double? width,
    double? height,
  }) {
    Widget box = Container(
      width: width,
      height: height ?? 60,
      color: color == Colors.transparent ? null : color,
      alignment: label.isEmpty ? null : Alignment.center,
      child: label.isEmpty
          ? null
          : Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: layer == 'B' ? 12 : 11,
              ),
            ),
    );

    box = Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: (_) => _onPointerDown(caseId, layer),
      child: box,
    );

    if (hasTap) {
      box = GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _onTap(caseId, layer),
        child: box,
      );
    }

    return box;
  }

  Widget _buildDemoCard({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Padding(padding: const EdgeInsets.all(12), child: child),
        ],
      ),
    );
  }

  Widget _buildLogArea() {
    return ColoredBox(
      color: Colors.black,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
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
                    return const Text(
                      '点击各场景演示区查看日志…\n\n'
                      '场景6：B 视觉压住 A，重叠 → A；B 独占 → 无 onTap\n'
                      '场景7：B 整块在上，RenderObject 限定命中区\n'
                      '  重叠 → A；B 独占黄框区 → B',
                      style: TextStyle(
                        color: Colors.greenAccent,
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

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: Text(
                      entry.text,
                      style: TextStyle(
                        color: color,
                        fontFamily: 'Menlo',
                        fontSize: 11.5,
                        height: 1.35,
                        fontWeight: entry.text.startsWith('📋')
                            ? FontWeight.w700
                            : FontWeight.normal,
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

/// 仅在 [hitTestRegion]（本地坐标）内参与命中测试，其余点击穿透到下层。
class _RegionHitTestWidget extends SingleChildRenderObjectWidget {
  const _RegionHitTestWidget({
    required this.hitTestRegion,
    required super.child,
  });

  final Rect hitTestRegion;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RegionHitTestRenderBox()..hitTestRegion = hitTestRegion;
  }

  @override
  void updateRenderObject(
    BuildContext context,
    _RegionHitTestRenderBox renderObject,
  ) {
    renderObject.hitTestRegion = hitTestRegion;
  }
}

class _RegionHitTestRenderBox extends RenderProxyBox {
  Rect hitTestRegion = Rect.zero;

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    if (!size.contains(position)) return false;
    if (!hitTestRegion.contains(position)) return false;
    return super.hitTest(result, position: position);
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Rect>('hitTestRegion', hitTestRegion));
  }
}
