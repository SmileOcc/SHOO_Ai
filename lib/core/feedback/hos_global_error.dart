import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../errors/hos_error_mapper.dart';
import '../theme/hos_spacing.dart';
import 'hos_overlay_loading.dart';
import 'hos_toast.dart';

const _kGlobalDialogRadius = 12.0;

/// 全局错误展示方式。
enum SHOGlobalErrorPresentation {
  /// 底部 Toast（默认，适合大多数业务错误）。
  toast,

  /// 居中对话框（适合需用户确认的严重错误）。
  dialog,
}

/// 一次待展示的全局错误事件。
class SHOGlobalErrorEvent {
  const SHOGlobalErrorEvent({
    required this.id,
    required this.message,
    this.title,
    this.presentation = SHOGlobalErrorPresentation.toast,
    this.source,
  });

  final int id;
  final String message;
  final String? title;
  final SHOGlobalErrorPresentation presentation;
  final Object? source;
}

class SHOGlobalErrorController extends Notifier<SHOGlobalErrorEvent?> {
  static final List<SHOGlobalErrorEvent> _pending = [];
  static SHOGlobalErrorController? _bound;

  var _seq = 0;

  @override
  SHOGlobalErrorEvent? build() => null;

  void report(
    Object error, {
    SHOGlobalErrorPresentation presentation = SHOGlobalErrorPresentation.toast,
    String? title,
  }) {
    _emit(
      SHOGlobalErrorEvent(
        id: ++_seq,
        message: messageFromAny(error),
        title: title,
        presentation: presentation,
        source: error,
      ),
    );
  }

  void reportMessage(
    String message, {
    SHOGlobalErrorPresentation presentation = SHOGlobalErrorPresentation.toast,
    String? title,
  }) {
    _emit(
      SHOGlobalErrorEvent(
        id: ++_seq,
        message: message,
        title: title,
        presentation: presentation,
      ),
    );
  }

  void _emit(SHOGlobalErrorEvent event) {
    if (_bound == null) {
      _pending.add(event);
      return;
    }
    state = event;
  }

  void consume() => state = null;

  static void bind(SHOGlobalErrorController controller) {
    _bound = controller;
    if (_pending.isEmpty) return;
    final event = _pending.last;
    _pending.clear();
    if (event.source != null) {
      controller.report(
        event.source!,
        presentation: event.presentation,
        title: event.title,
      );
    } else {
      controller.reportMessage(
        event.message,
        presentation: event.presentation,
        title: event.title,
      );
    }
  }

  static void unbind(SHOGlobalErrorController controller) {
    if (_bound == controller) _bound = null;
  }
}

final globalErrorProvider =
    NotifierProvider<SHOGlobalErrorController, SHOGlobalErrorEvent?>(
  SHOGlobalErrorController.new,
);

/// 无 [WidgetRef] 场景（bootstrap / zone guard）上报全局错误。
abstract final class SHOGlobalError {
  static void report(
    Object error, {
    SHOGlobalErrorPresentation presentation = SHOGlobalErrorPresentation.toast,
    String? title,
  }) {
    final controller = SHOGlobalErrorController._bound;
    if (controller != null) {
      controller.report(error, presentation: presentation, title: title);
      return;
    }
    SHOGlobalErrorController._pending.add(
      SHOGlobalErrorEvent(
        id: 0,
        message: messageFromAny(error),
        title: title,
        presentation: presentation,
        source: error,
      ),
    );
  }
}

/// 监听 [globalErrorProvider] 并展示 Toast / Dialog。
class SHOGlobalErrorListener extends ConsumerStatefulWidget {
  const SHOGlobalErrorListener({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<SHOGlobalErrorListener> createState() =>
      _SHOGlobalErrorListenerState();
}

class _SHOGlobalErrorListenerState extends ConsumerState<SHOGlobalErrorListener> {
  SHOGlobalErrorController? _controller;
  SHOGlobalErrorEvent? _dialogEvent;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _controller = ref.read(globalErrorProvider.notifier);
      SHOGlobalErrorController.bind(_controller!);
    });
  }

  @override
  void dispose() {
    final controller = _controller;
    if (controller != null) {
      SHOGlobalErrorController.unbind(controller);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<SHOGlobalErrorEvent?>(globalErrorProvider, (previous, next) {
      if (next == null) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _present(next);
        ref.read(globalErrorProvider.notifier).consume();
      });
    });

    return Stack(
      fit: StackFit.expand,
      children: [
        widget.child,
        if (_dialogEvent != null)
          _GlobalErrorDialogOverlay(
            event: _dialogEvent!,
            onDismiss: () => setState(() => _dialogEvent = null),
          ),
      ],
    );
  }

  void _present(SHOGlobalErrorEvent event) {
    switch (event.presentation) {
      case SHOGlobalErrorPresentation.toast:
        SHOAppToast.error(event.message);
      case SHOGlobalErrorPresentation.dialog:
        setState(() => _dialogEvent = event);
    }
  }
}

class _GlobalErrorDialogOverlay extends StatelessWidget {
  const _GlobalErrorDialogOverlay({
    required this.event,
    required this.onDismiss,
  });

  final SHOGlobalErrorEvent event;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Material(
        color: Colors.black.withValues(alpha: 0.45),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: SHOAppSpacing.xl),
              child: Material(
                color: Theme.of(context).cardColor,
                elevation: 8,
                shadowColor: Colors.black26,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(_kGlobalDialogRadius),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    SHOAppSpacing.xl,
                    SHOAppSpacing.xl,
                    SHOAppSpacing.xl,
                    SHOAppSpacing.md,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        event.title ?? 'Error',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: SHOAppSpacing.sm),
                      Text(
                        event.message,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: SHOAppSpacing.md),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: onDismiss,
                          child: const Text('OK'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// [WidgetRef] 便捷 API：全局错误 + 全局 Loading。
extension SHOGlobalFeedbackRef on WidgetRef {
  SHOGlobalErrorController get globalError =>
      read(globalErrorProvider.notifier);

  void showGlobalError(
    Object error, {
    SHOGlobalErrorPresentation presentation = SHOGlobalErrorPresentation.toast,
    String? title,
  }) {
    globalError.report(error, presentation: presentation, title: title);
  }

  Future<T> withGlobalLoading<T>(
    Future<T> Function() task, {
    String? message,
  }) {
    if (message != null) {
      read(overlayLoadingMessageProvider.notifier).state = message;
    }
    return read(overlayLoadingProvider.notifier).run(task).whenComplete(() {
      if (message != null) {
        read(overlayLoadingMessageProvider.notifier).state = null;
      }
    });
  }
}
