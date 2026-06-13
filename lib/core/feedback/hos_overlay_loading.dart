import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../theme/hos_colors.dart';
import '../theme/hos_spacing.dart';

/// 全局 Loading 卡片圆角。
const _kLoadingCardRadius = 12.0;

/// 全局半透明 Loading 遮罩（引用计数，支持并发请求）。
class SHOOverlayLoadingController extends Notifier<int> {
  @override
  int build() => 0;

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
    NotifierProvider<SHOOverlayLoadingController, int>(
  SHOOverlayLoadingController.new,
);

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
    return Material(
      color: Theme.of(context).cardColor,
      elevation: 6,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_kLoadingCardRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: SHOAppSpacing.xxxl,
          vertical: SHOAppSpacing.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(SHOAppColors.accent),
            ),
            const SizedBox(height: SHOAppSpacing.md),
            Text(
              message ?? 'Loading...',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
