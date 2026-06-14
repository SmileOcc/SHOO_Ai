import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../errors/hos_exception.dart';
import '../../../feedback/hos_global_error.dart';
import '../../../theme/hos_spacing.dart';
import '../../../theme/hos_theme_extension.dart';
import '../../../../l10n/app_localizations.dart';

/// 下次请求是否失败（Debug 用）。
final debugFeedbackOrdersFailProvider = StateProvider<bool>((ref) => false);

/// 模拟订单列表 AsyncValue 数据源。
final debugFeedbackOrdersProvider = FutureProvider<List<String>>((ref) async {
  await Future<void>.delayed(const Duration(milliseconds: 1200));
  if (ref.watch(debugFeedbackOrdersFailProvider)) {
    throw const SHOServerException('Debug: orders load failed', code: 500);
  }
  return const ['Order #1001', 'Order #1002', 'Order #1003'];
});

/// Debug：演示 Riverpod [AsyncValue.when] + [WidgetRef.showGlobalError]。
class SHODebugFeedbackAsyncDemo extends ConsumerWidget {
  const SHODebugFeedbackAsyncDemo({
    super.key,
    required this.onAction,
  });

  final ValueChanged<String> onAction;

  static const _codeSnippetEn = '''
final ordersAsync = ref.watch(ordersProvider);

return ordersAsync.when(
  data: (list) => OrderList(list: list),
  loading: () => const Center(child: CircularProgressIndicator()),
  error: (error, stackTrace) {
    ref.showGlobalError(error);
    return ErrorRetryView(
      message: 'Load failed',
      onRetry: () => ref.invalidate(ordersProvider),
    );
  },
);''';

  static const _codeSnippetZh = '''
final ordersAsync = ref.watch(ordersProvider);

return ordersAsync.when(
  data: (list) => OrderList(list: list),
  loading: () => const Center(child: CircularProgressIndicator()),
  error: (error, stackTrace) {
    ref.showGlobalError(error);
    return ErrorRetryView(
      message: '加载失败',
      onRetry: () => ref.invalidate(ordersProvider),
    );
  },
);''';

  void _reload(WidgetRef ref, {required bool fail}) {
    ref.read(debugFeedbackOrdersFailProvider.notifier).state = fail;
    ref.invalidate(debugFeedbackOrdersProvider);
    onAction(fail ? 'async: reload (fail)' : 'async: reload (success)');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final ordersAsync = ref.watch(debugFeedbackOrdersProvider);
    final codeSnippet = Localizations.localeOf(context).languageCode == 'zh'
        ? _codeSnippetZh
        : _codeSnippetEn;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.debugFeedbackAsyncHint,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: context.shoTheme.textSecondary,
              ),
        ),
        const SizedBox(height: SHOAppSpacing.sm),
        _CodeSnippetCard(text: codeSnippet),
        const SizedBox(height: SHOAppSpacing.md),
        Row(
          children: [
            Expanded(
              child: FilledButton.tonalIcon(
                onPressed: () => _reload(ref, fail: false),
                icon: const Icon(Icons.check_circle_outline),
                label: Text(l10n.debugFeedbackAsyncLoadSuccess),
              ),
            ),
            const SizedBox(width: SHOAppSpacing.sm),
            Expanded(
              child: FilledButton.tonalIcon(
                onPressed: () => _reload(ref, fail: true),
                icon: const Icon(Icons.error_outline),
                label: Text(l10n.debugFeedbackAsyncLoadFail),
              ),
            ),
          ],
        ),
        const SizedBox(height: SHOAppSpacing.md),
        Card(
          child: SizedBox(
            height: 200,
            child: ordersAsync.when(
              data: (list) => _OrderListPanel(items: list),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => _AsyncErrorPanel(
                error: error,
                message: l10n.debugFeedbackAsyncLoadFailed,
                retryLabel: l10n.debugFeedbackAsyncRetry,
                onRetry: () {
                  onAction('async: retry');
                  ref.invalidate(debugFeedbackOrdersProvider);
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _OrderListPanel extends StatelessWidget {
  const _OrderListPanel({required this.items});

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: SHOAppSpacing.sm),
      itemCount: items.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        return ListTile(
          dense: true,
          leading: const Icon(Icons.receipt_long_outlined, size: 20),
          title: Text(items[index]),
        );
      },
    );
  }
}

/// 错误态：首次进入时上报全局错误，避免 [when] 重建重复弹 Toast。
class _AsyncErrorPanel extends ConsumerStatefulWidget {
  const _AsyncErrorPanel({
    required this.error,
    required this.message,
    required this.retryLabel,
    required this.onRetry,
  });

  final Object error;
  final String message;
  final String retryLabel;
  final VoidCallback onRetry;

  @override
  ConsumerState<_AsyncErrorPanel> createState() => _AsyncErrorPanelState();
}

class _AsyncErrorPanelState extends ConsumerState<_AsyncErrorPanel> {
  @override
  void initState() {
    super.initState();
    _reportError(widget.error);
  }

  @override
  void didUpdateWidget(_AsyncErrorPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.error != widget.error) {
      _reportError(widget.error);
    }
  }

  void _reportError(Object error) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.showGlobalError(error);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(SHOAppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_off_outlined,
              size: 36,
              color: context.shoTheme.textSecondary,
            ),
            const SizedBox(height: SHOAppSpacing.sm),
            Text(
              widget.message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: SHOAppSpacing.md),
            FilledButton.tonal(
              onPressed: widget.onRetry,
              child: Text(widget.retryLabel),
            ),
          ],
        ),
      ),
    );
  }
}

class _CodeSnippetCard extends StatelessWidget {
  const _CodeSnippetCard({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(SHOAppSpacing.md),
        child: SelectableText(
          text,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontFamily: 'monospace',
                height: 1.45,
              ),
        ),
      ),
    );
  }
}
