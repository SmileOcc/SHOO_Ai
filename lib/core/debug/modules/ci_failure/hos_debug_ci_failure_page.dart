import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shoo/core/debug/modules/ci_failure/hos_debug_ci_failure_registry.dart';
import 'package:shoo/core/pages/hos_pages.dart';
import 'package:shoo/core/theme/hos_spacing.dart';

/// Debug：CI 失败演示 — 说明如何故意触发 GitHub Actions 各检查项。
///
/// triggers/ 下代码默认被 [analysis_options.yaml] exclude，不影响日常 CI。
/// 按页内步骤启用后提交 PR，可验证 format / analyze / test 流水线。
class SHODebugCiFailurePage extends ConsumerStatefulWidget {
  const SHODebugCiFailurePage({super.key});

  @override
  ConsumerState<SHODebugCiFailurePage> createState() =>
      _SHODebugCiFailurePageState();
}

class _SHODebugCiFailurePageState extends ConsumerState<SHODebugCiFailurePage>
    with SHOPageRouteAnalyticsMixin, SHOAppPageMixin, SHOAppTrackedPageMixin {
  @override
  String get pageName => 'debug_ci_failure';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return buildTrackedPage(
      Scaffold(
        appBar: AppBar(
          title: const Text('CI 失败演示'),
        ),
        body: ListView(
          padding: const EdgeInsets.all(SHOAppSpacing.xl),
          children: [
            _WarningBanner(theme: theme),
            const SizedBox(height: SHOAppSpacing.lg),
            Text(
              '启用步骤',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: SHOAppSpacing.sm),
            ...SHOCiFailureDemoRegistry.activationSteps.asMap().entries.map(
              (e) => Padding(
                padding: const EdgeInsets.only(bottom: SHOAppSpacing.xs),
                child: Text('${e.key + 1}. ${e.value}'),
              ),
            ),
            const SizedBox(height: SHOAppSpacing.xl),
            Text(
              'CI 检查项（${SHOCiFailureDemoRegistry.items.length} 项）',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: SHOAppSpacing.md),
            ...SHOCiFailureDemoRegistry.items.map(
              (item) => _CiDemoCard(item: item),
            ),
            const SizedBox(height: SHOAppSpacing.xl),
            Text(
              '本地预检命令',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: SHOAppSpacing.sm),
            const _CopyableCommand(
              label: 'Format',
              command: 'dart format --output=none --set-exit-if-changed .',
            ),
            const _CopyableCommand(
              label: 'Analyze',
              command:
                  'flutter analyze --fatal-warnings --no-fatal-infos',
            ),
            const _CopyableCommand(
              label: 'Test',
              command: 'flutter test',
            ),
          ],
        ),
      ),
    );
  }
}

class _WarningBanner extends StatelessWidget {
  const _WarningBanner({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(SHOAppSpacing.lg),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: theme.colorScheme.onErrorContainer,
              ),
              const SizedBox(width: SHOAppSpacing.sm),
              Text(
                '仅供 CI 流水线验证',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.onErrorContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: SHOAppSpacing.sm),
          Text(
            'triggers/ 目录代码含故意错误，默认已从静态分析排除。\n'
            '启用后请勿合并到 main/master，验证完毕请恢复 exclude。',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onErrorContainer,
            ),
          ),
        ],
      ),
    );
  }
}

class _CiDemoCard extends StatelessWidget {
  const _CiDemoCard({required this.item});

  final SHOCiFailureDemoItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: SHOAppSpacing.md),
      child: ExpansionTile(
        leading: CircleAvatar(
          child: Text(item.id),
        ),
        title: Text(item.title),
        subtitle: Text(
          item.severity,
          style: TextStyle(
            color: item.severity.contains('不失败')
                ? theme.colorScheme.primary
                : theme.colorScheme.error,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              SHOAppSpacing.lg,
              0,
              SHOAppSpacing.lg,
              SHOAppSpacing.lg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _LabelValue('CI 步骤', item.ciStep),
                _LabelValue('文件', item.filePath),
                _LabelValue('说明', item.summary),
                _LabelValue('激活', item.activationHint),
                const SizedBox(height: SHOAppSpacing.sm),
                Text(
                  '包含问题',
                  style: theme.textTheme.labelLarge,
                ),
                ...item.issues.map(
                  (issue) => Padding(
                    padding: const EdgeInsets.only(
                      top: SHOAppSpacing.xxs,
                      left: SHOAppSpacing.sm,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('• '),
                        Expanded(child: Text(issue)),
                      ],
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

class _LabelValue extends StatelessWidget {
  const _LabelValue(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: SHOAppSpacing.xs),
      child: RichText(
        text: TextSpan(
          style: DefaultTextStyle.of(context).style,
          children: [
            TextSpan(
              text: '$label：',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}

class _CopyableCommand extends StatelessWidget {
  const _CopyableCommand({
    required this.label,
    required this.command,
  });

  final String label;
  final String command;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      subtitle: SelectableText(
        command,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontFamily: 'monospace',
            ),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.copy, size: 20),
        tooltip: '复制',
        onPressed: () {
          Clipboard.setData(ClipboardData(text: command));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('已复制：$label')),
          );
        },
      ),
    );
  }
}
