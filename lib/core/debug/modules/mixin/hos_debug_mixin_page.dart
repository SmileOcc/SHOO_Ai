import 'package:flutter/material.dart';

import 'package:shoo/core/debug/modules/mixin/hos_debug_mixin_demos.dart';
import 'package:shoo/core/theme/hos_spacing.dart';

/// Mixin 调试页：线性化链、同名方法冲突、业务 Mixin 实现。
class SHODebugMixinPage extends StatefulWidget {
  const SHODebugMixinPage({super.key});

  @override
  State<SHODebugMixinPage> createState() => _SHODebugMixinPageState();
}

class _SHODebugMixinPageState extends State<SHODebugMixinPage> {
  String _chainResult = '';
  String _collisionResult = '';
  String _bizResult = '';
  String _bizTrace = '';

  void _runChainDemo() {
    final duck = SHODebugDuck();
    final reversed = SHODebugDuckReversed();
    setState(() {
      _chainResult =
          'class Duck extends Animal\n'
          '    with Walkable, Swimmable, Flyable\n\n'
          'describe() →\n${duck.describe()}\n\n'
          '— 交换 with 顺序 —\n'
          'class DuckReversed extends Animal\n'
          '    with Flyable, Swimmable, Walkable\n\n'
          'describe() →\n${reversed.describe()}\n\n'
          '规则：with A,B,C → 最右 C 离实例最近，\n'
          'super 沿 MRO 向左追溯，构成线性化链。';
    });
  }

  void _runCollisionDemo() {
    final svc = SHODebugService();
    final svcRev = SHODebugServiceReversed();
    setState(() {
      _collisionResult =
          'with LoggerA, LoggerB, LoggerC\n'
          '→ 最右 LoggerC 覆盖同名 log()\n'
          'log() = ${svc.log()}\n\n'
          '— 调换顺序 —\n'
          'with LoggerC, LoggerB, LoggerA\n'
          '→ 最右 LoggerA 覆盖\n'
          'log() = ${svcRev.log()}\n\n'
          '规则：多个 Mixin 有同名 非 super 方法时，\n'
          '最右侧的胜出，前面的被完全覆盖。';
    });
  }

  void _runBizDemo() {
    final form = SHODebugBizForm();
    final ok = form.submit(username: 'Alice', password: '123456');
    final fail = form.submit(username: '', password: '');
    setState(() {
      _bizResult =
          '业务 Form 聚合了 3 个 Mixin：\n'
          '  • SHODebugValidatable → 表单校验\n'
          '  • SHODebugLoadable → 加载状态\n'
          '  • SHODebugTraceable → 调用链追踪\n\n'
          'submit(Alice, 123456) → $ok\n'
          'submit(空, 空) → $fail\n\n'
          '一个类 with 多个职责单一的 Mixin，\n'
          '无需深层继承即可获得组合能力。';
      _bizTrace = form.trace.join('\n');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mixin 调试')),
      body: ListView(
        padding: const EdgeInsets.all(SHOAppSpacing.xl),
        children: [
          _section(
            '1. 线性化链',
            '自定义 Mixin 的 super 链式调用，验证 with 声明顺序决定 MRO',
            '运行线性化链 Demo',
            Icons.account_tree_outlined,
            _runChainDemo,
            _chainResult,
          ),
          _section(
            '2. 多个 Mixin 同名方法',
            'LogerA / LoggerB / LoggerC 都有 log()，演示最右侧覆盖规则',
            '运行同名方法冲突 Demo',
            Icons.merge_type,
            _runCollisionDemo,
            _collisionResult,
          ),
          _section(
            '3. 业务 Form Mixin 聚合',
            'Validatable + Loadable + Traceable 组合成一个 Form 类',
            '运行业务 Mixin Demo',
            Icons.business_outlined,
            _runBizDemo,
            _bizResult,
            trace: _bizTrace,
          ),
        ],
      ),
    );
  }

  Widget _section(
    String title,
    String subtitle,
    String buttonLabel,
    IconData icon,
    VoidCallback onTap,
    String result, {
    String? trace,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: SHOAppSpacing.xs),
        Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: SHOAppSpacing.md),
        FilledButton.tonalIcon(
          onPressed: onTap,
          icon: Icon(icon),
          label: Text(buttonLabel),
        ),
        if (result.isNotEmpty) ...[
          const SizedBox(height: SHOAppSpacing.md),
          Material(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(SHOAppSpacing.md),
              child: Text(
                result,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontFamily: 'monospace',
                      fontSize: 12,
                      height: 1.5,
                    ),
              ),
            ),
          ),
        ],
        if (trace != null && trace.isNotEmpty) ...[
          const SizedBox(height: SHOAppSpacing.sm),
          Text('Trace:', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: SHOAppSpacing.xs),
          Material(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(SHOAppSpacing.md),
              child: Text(
                trace,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontFamily: 'monospace',
                      fontSize: 11,
                      height: 1.5,
                    ),
              ),
            ),
          ),
        ],
        const Divider(height: SHOAppSpacing.xxxl),
      ],
    );
  }
}
