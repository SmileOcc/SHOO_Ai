import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../theme/hos_colors.dart';

/// 全局半透明 Loading 遮罩（引用计数，支持并发请求）。
class SHOOverlayLoadingController extends StateNotifier<int> {
  SHOOverlayLoadingController() : super(0);

  void show() => state = state + 1;

  void hide() {
    if (state > 0) state = state - 1;
  }

  Future<T> run<T>(Future<T> Function() task) async {
    show();
    try {
      return await task();
    } finally {
      hide();
    }
  }
}

final overlayLoadingProvider =
    StateNotifierProvider<SHOOverlayLoadingController, int>((ref) {
  return SHOOverlayLoadingController();
});

final overlayLoadingMessageProvider = StateProvider<String?>((ref) => null);

/// 叠在页面之上的全局 Loading。
class SHOGlobalLoadingOverlay extends ConsumerWidget {
  const SHOGlobalLoadingOverlay({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(overlayLoadingProvider);
    final message = ref.watch(overlayLoadingMessageProvider);
    final visible = count > 0;

    return Stack(
      children: [
        child,
        if (visible)
          Positioned.fill(
            child: AbsorbPointer(
              child: ColoredBox(
                color: Colors.black.withValues(alpha: 0.25),
                child: Center(
                  child: _LoadingCard(message: message),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard({this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(SHOAppColors.accent),
            ),
            const SizedBox(height: 12),
            Text(
              message ?? MaterialLocalizations.of(context).dialogLabel,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
