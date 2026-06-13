import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../errors/hos_exception.dart';
import '../../../feedback/hos_global_error.dart';
import '../../../feedback/hos_overlay_loading.dart';
import '../../../theme/hos_spacing.dart';
import '../../../theme/hos_theme_extension.dart';
import '../../../../l10n/app_localizations.dart';

/// Debug：全局 Loading 遮罩与全局错误处理试玩页。
class SHODebugFeedbackPage extends ConsumerStatefulWidget {
  const SHODebugFeedbackPage({super.key});

  @override
  ConsumerState<SHODebugFeedbackPage> createState() =>
      _SHODebugFeedbackPageState();
}

class _SHODebugFeedbackPageState extends ConsumerState<SHODebugFeedbackPage> {
  var _lastAction = '';

  void _note(String text) => setState(() => _lastAction = text);

  Future<void> _loadingBasic() async {
    _note('loading: 2s');
    await ref.withGlobalLoading(
      () => Future<void>.delayed(const Duration(seconds: 2)),
    );
    _note('loading: done');
  }

  Future<void> _loadingWithMessage() async {
    _note('loading: message 3s');
    await ref.withGlobalLoading(
      () => Future<void>.delayed(const Duration(seconds: 3)),
      message: 'Processing order...',
    );
    _note('loading: message done');
  }

  Future<void> _loadingConcurrent() async {
    _note('loading: concurrent x2');
    final a = ref.withGlobalLoading(
      () => Future<void>.delayed(const Duration(seconds: 2)),
      message: 'Task A',
    );
    final b = ref.withGlobalLoading(
      () => Future<void>.delayed(const Duration(seconds: 3)),
      message: 'Task B',
    );
    await Future.wait([a, b]);
    _note('loading: concurrent done');
  }

  void _errorToast() {
    ref.showGlobalError(
      const SHOServerException('Debug: payment declined', code: 402),
    );
    _note('error: toast');
  }

  void _errorDialog() {
    ref.showGlobalError(
      const SHOUnknownException('Debug: critical failure'),
      presentation: SHOGlobalErrorPresentation.dialog,
      title: 'Debug Error',
    );
    _note('error: dialog');
  }

  void _errorNetworkToast() {
    ref.showGlobalError(const SHONetworkException('Connection timed out'));
    _note('error: network toast');
  }

  void _errorStaticReport() {
    SHOGlobalError.report(
      const SHOCacheException('Debug: static report (no WidgetRef)'),
    );
    _note('error: static report');
  }

  Future<void> _loadingThenError() async {
    try {
      await ref.withGlobalLoading(
        () => Future<void>.delayed(const Duration(seconds: 1)),
        message: 'Submitting...',
      );
      throw const SHOServerException('Debug: submit failed after loading');
    } catch (error) {
      ref.showGlobalError(error);
      _note('loading + error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final overlayCount = ref.watch(overlayLoadingProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.debugFeedbackTitle)),
      body: ListView(
        padding: const EdgeInsets.all(SHOAppSpacing.xl),
        children: [
          Text(
            l10n.debugFeedbackHint,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: context.shoTheme.textSecondary,
                ),
          ),
          const SizedBox(height: SHOAppSpacing.lg),
          _StatusCard(
            overlayCount: overlayCount,
            lastAction: _lastAction,
          ),
          const SizedBox(height: SHOAppSpacing.xl),
          Text(
            l10n.debugFeedbackLoadingSection,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: SHOAppSpacing.sm),
          _ActionButton(
            icon: Icons.hourglass_top,
            label: l10n.debugFeedbackLoadingBasic,
            onPressed: _loadingBasic,
          ),
          _ActionButton(
            icon: Icons.message_outlined,
            label: l10n.debugFeedbackLoadingMessage,
            onPressed: _loadingWithMessage,
          ),
          _ActionButton(
            icon: Icons.layers_outlined,
            label: l10n.debugFeedbackLoadingConcurrent,
            onPressed: _loadingConcurrent,
          ),
          _ActionButton(
            icon: Icons.sync_problem,
            label: l10n.debugFeedbackLoadingThenError,
            onPressed: _loadingThenError,
          ),
          const Divider(height: SHOAppSpacing.xxxl),
          Text(
            l10n.debugFeedbackErrorSection,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: SHOAppSpacing.sm),
          _ActionButton(
            icon: Icons.error_outline,
            label: l10n.debugFeedbackErrorToast,
            onPressed: _errorToast,
          ),
          _ActionButton(
            icon: Icons.report_outlined,
            label: l10n.debugFeedbackErrorDialog,
            onPressed: _errorDialog,
          ),
          _ActionButton(
            icon: Icons.wifi_off,
            label: l10n.debugFeedbackErrorNetwork,
            onPressed: _errorNetworkToast,
          ),
          _ActionButton(
            icon: Icons.cloud_off_outlined,
            label: l10n.debugFeedbackErrorStatic,
            onPressed: _errorStaticReport,
          ),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.overlayCount,
    required this.lastAction,
  });

  final int overlayCount;
  final String lastAction;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(SHOAppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.debugFeedbackStatusTitle,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: SHOAppSpacing.sm),
            Text(l10n.debugFeedbackOverlayCount(overlayCount)),
            const SizedBox(height: SHOAppSpacing.xs),
            Text(
              lastAction.isEmpty
                  ? l10n.debugFeedbackLastActionEmpty
                  : l10n.debugFeedbackLastAction(lastAction),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: SHOAppSpacing.sm),
      child: FilledButton.tonalIcon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          alignment: Alignment.centerLeft,
        ),
      ),
    );
  }
}
