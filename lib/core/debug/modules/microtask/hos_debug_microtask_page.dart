import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../theme/hos_spacing.dart';
import '../../../theme/hos_theme_extension.dart';

/// Debug：Future.microtask 执行顺序调试演示页。
class SHODebugMicrotaskPage extends ConsumerStatefulWidget {
  const SHODebugMicrotaskPage({super.key});

  @override
  ConsumerState<SHODebugMicrotaskPage> createState() =>
      _SHODebugMicrotaskPageState();
}

class _SHODebugMicrotaskPageState extends ConsumerState<SHODebugMicrotaskPage> {
  final List<_LogEntry> _logs = [];
  int _runCount = 0;

  void _clearLogs() => setState(() => _logs.clear());

  void _log(String phase, String message) {
    setState(() {
      _logs.add(
        _LogEntry(time: DateTime.now(), phase: phase, message: message),
      );
    });
  }

  /// 执行演示：展示同步代码、微任务、宏任务的执行顺序
  Future<void> _runDemo() async {
    _runCount++;
    _clearLogs();
    _log('sync', '>>> runDemo #$_runCount 开始');

    // 1. 同步代码最先执行
    _log('sync', '1. 同步代码 A');
    _log('sync', '2. 同步代码 B');

    // 2. scheduleMicrotask - 与 Future.microtask 等价
    scheduleMicrotask(() {
      _log('microtask', '3. scheduleMicrotask (microtask)');
    });

    // 3. Future.microtask
    Future.microtask(() {
      _log('microtask', '4. Future.microtask (microtask)');
    });

    // 4. Future.value - 立即 resolved 的 Future，then 也在 microtask 执行
    Future.value().then((_) {
      _log('microtask', '5. Future.value().then (microtask)');
    });

    // 5. async/await - await 之后的代码在 microtask 执行
    _log('sync', '6. async/await 之前 (sync)');
    await Future(() {});
    _log('microtask', '7. async/await 之后 (microtask)');

    // 6. Future.delayed - 在下一个事件循环执行
    Future.delayed(Duration.zero, () {
      _log('macrotask', '8. Future.delayed(Duration.zero) (macrotask)');
    });

    // 7. Timer.run - 使用 scheduleTask
    Timer.run(() {
      _log('macrotask', '9. Timer.run (macrotask)');
    });

    // 8. postFrameCallback - 在当前帧渲染后执行
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _log('postFrame', '10. addPostFrameCallback (postFrame)');
    });

    _log('sync', '--- runDemo #$_runCount 同步部分完成 ---');

    // 等待所有异步任务完成
    await Future.delayed(const Duration(milliseconds: 100));
    _log('sync', '>>> runDemo #$_runCount 完成');
  }

  /// 演示 routerProvider 中的 microtask 使用场景
  Future<void> _runRouterScenario() async {
    _runCount++;
    _clearLogs();
    _log('sync', '>>> routerProvider 场景模拟 #$_runCount');

    _log('sync', '1. Provider 构建开始');
    _log('sync', '2. GoRouter 实例创建');
    _log('sync', '3. addListener 注册监听器');
    _log('sync', '4. onDispose 注册清理回调');

    Future.microtask(() {
      _log('microtask', '5. Future.microtask - 初始化同步音乐状态');
      _log('microtask', '   （对应 routerProvider 中的 microtask）');
    });

    _log('sync', '6. Provider 构建完成，返回 router');
    _log('sync', '--- 同步部分结束，等待事件循环 ---');

    await Future.delayed(const Duration(milliseconds: 50));
    _log('sync', '>>> routerProvider 场景模拟 #$_runCount 完成');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.shoTheme;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.debugMicrotaskTitle)),
      body: Column(
        children: [
          // 操作按钮区
          Padding(
            padding: const EdgeInsets.all(SHOAppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.debugMicrotaskHint,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: theme.textSecondary),
                ),
                const SizedBox(height: SHOAppSpacing.md),
                FilledButton.tonalIcon(
                  onPressed: _runDemo,
                  icon: const Icon(Icons.play_arrow),
                  label: Text(l10n.debugMicrotaskRunDemo),
                ),
                const SizedBox(height: SHOAppSpacing.sm),
                FilledButton.tonalIcon(
                  onPressed: _runRouterScenario,
                  icon: const Icon(Icons.router),
                  label: Text(l10n.debugMicrotaskRunRouterScenario),
                ),
              ],
            ),
          ),

          // 代码示例区
          Card(
            margin: const EdgeInsets.symmetric(horizontal: SHOAppSpacing.lg),
            child: Padding(
              padding: const EdgeInsets.all(SHOAppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.debugMicrotaskCodeExample,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: SHOAppSpacing.sm),
                  SelectableText(
                    '''
// routerProvider 中的典型用法
router.routerDelegate.addListener(syncMusicRoute);
ref.onDispose(() =>
  router.routerDelegate.removeListener(syncMusicRoute));
Future.microtask(syncMusicRoute); // ← 初始化同步
return router;''',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: SHOAppSpacing.md),

          // 日志输出区
          Expanded(
            child: Card(
              margin: const EdgeInsets.fromLTRB(
                SHOAppSpacing.lg,
                0,
                SHOAppSpacing.lg,
                SHOAppSpacing.lg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(SHOAppSpacing.md),
                    child: Row(
                      children: [
                        Text(
                          l10n.debugMicrotaskLog,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const Spacer(),
                        Text(
                          '${l10n.debugMicrotaskLogCount(_logs.length)} ',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        IconButton(
                          icon: const Icon(Icons.clear_all, size: 20),
                          onPressed: _clearLogs,
                          tooltip: l10n.debugMicrotaskClear,
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: _logs.isEmpty
                        ? Center(
                            child: Text(
                              l10n.debugMicrotaskEmpty,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          )
                        : ListView.builder(
                            itemCount: _logs.length,
                            padding: const EdgeInsets.symmetric(
                              vertical: SHOAppSpacing.sm,
                            ),
                            itemBuilder: (context, index) {
                              final entry = _logs[index];
                              return _LogEntryTile(entry: entry);
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LogEntry {
  const _LogEntry({
    required this.time,
    required this.phase,
    required this.message,
  });

  final DateTime time;
  final String phase;
  final String message;
}

class _LogEntryTile extends StatelessWidget {
  const _LogEntryTile({required this.entry});

  final _LogEntry entry;

  Color _phaseColor(BuildContext context) {
    switch (entry.phase) {
      case 'sync':
        return context.shoTheme.textSecondary;
      case 'microtask':
        return Colors.blue;
      case 'macrotask':
        return Colors.orange;
      case 'postFrame':
        return Colors.purple;
      default:
        return context.shoTheme.textMuted;
    }
  }

  IconData _phaseIcon() {
    switch (entry.phase) {
      case 'sync':
        return Icons.bolt;
      case 'microtask':
        return Icons.fast_forward;
      case 'macrotask':
        return Icons.hourglass_top;
      case 'postFrame':
        return Icons.animation;
      default:
        return Icons.circle;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _phaseColor(context);
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: SHOAppSpacing.md,
        vertical: SHOAppSpacing.xs,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(_phaseIcon(), size: 14, color: color),
          const SizedBox(width: SHOAppSpacing.sm),
          Text(
            entry.phase.toUpperCase().padRight(9),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontFamily: 'monospace',
              fontWeight: FontWeight.w600,
            ),
          ),
          Expanded(
            child: Text(
              entry.message,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

/*
┌─────────────────────────────────────────────────────────────┐
│                    Dart 事件循环执行顺序                       │
└─────────────────────────────────────────────────────────────┘

同步代码
    │
    ├── 立即执行
    │
    ▼
Microtask Queue (微任务队列)
    │
    ├── Future.microtask()
    ├── scheduleMicrotask()
    ├── Future.value().then()
    ├── async/await 之后的代码
    │
    ▼
Microtask Queue 空 → 渲染帧

    ▼
Macrotask Queue (宏任务队列)
    │
    ├── Future.delayed()
    ├── Timer.run()
    │
    ▼
下一事件循环

┌─────────────────────────────────────────────────────────────┐
│                    典型使用场景                              │
└─────────────────────────────────────────────────────────────┘

1. Future.microtask() - routerProvider 初始化
   → 延迟到当前事件循环末尾，确保 router 完全初始化

2. WidgetsBinding.instance.addPostFrameCallback()
   → 当前帧渲染完成后执行，用于获取布局信息

3. Future.delayed(Duration.zero)
   → 延迟到下一个事件循环，用于让出 UI 线程

4. scheduleMicrotask() - 等同于 Future.microtask()
   → 用于调度微任务

*/
