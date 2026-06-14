import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../errors/hos_error_mapper.dart';
import '../theme/hos_spacing.dart';
import 'hos_overlay_loading.dart';
import 'hos_toast.dart';

const _kGlobalDialogRadius = 12.0;

/// 全局错误展示方式。
enum SHOGlobalErrorPresentation {
  /// 底部 Toast（自动消失，默认，适合大多数业务错误）。
  toast,

  /// 居中对话框（适合需用户确认的严重错误）。
  dialog,
}

/// 错误事件数据结构。
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
  // 维护当前错误状态 (SHOGlobalErrorEvent?)
  // 维护待处理队列 (_pending)
  // 为什么使用静态变量:
  // 跨实例共享: Provider 可能重建，但静态变量始终保持
  // 生命周期独立: 不依赖 Widget 树生命周期
  // 静态变量不会被 GC 回收，需注意内存管理（通过 unbind 释放）
  static final List<SHOGlobalErrorEvent> _pending = [];
  static SHOGlobalErrorController? _bound;

  var _seq = 0; // 事件序列号（用于区分同一毫秒内的多个事件）

  /// 生成事件ID：毫秒时间戳 × 1000 + 序号
  int _nextId() =>
      DateTime.now().millisecondsSinceEpoch * 1000 + (++_seq % 1000);

  @override
  SHOGlobalErrorEvent? build() => null;

  /// 上报 Object 类型错误（自动映射为用户消息）
  void report(
    Object error, {
    SHOGlobalErrorPresentation presentation = SHOGlobalErrorPresentation.toast,
    String? title,
  }) {
    _emit(
      SHOGlobalErrorEvent(
        id: _nextId(),
        message: messageFromAny(error), // 自动映射为用户可读消息
        title: title,
        presentation: presentation,
        source: error,
      ),
    );
  }

  /// 直接上报字符串消息（无需映射）
  void reportMessage(
    String message, {
    SHOGlobalErrorPresentation presentation = SHOGlobalErrorPresentation.toast,
    String? title,
  }) {
    _emit(
      SHOGlobalErrorEvent(
        id: _nextId(),
        message: message,
        title: title,
        presentation: presentation,
      ),
    );
  }

  // 发射错误事件：若已绑定则立即展示，否则加入等待队列
  void _emit(SHOGlobalErrorEvent event) {
    if (_bound == null) {
      _pending.add(event); // Widget 未初始化，排队等待
      return;
    }
    state = event; // 更新状态，触发 Listener 响应
  }

  /// 消费错误（展示完成后清除状态）
  void consume() => state = null;

  // 绑定 Controller + 处理等待队列
  static void bind(SHOGlobalErrorController controller) {
    _bound = controller;
    if (_pending.isEmpty) return;
    /**
     * 避免错误风暴: 启动阶段可能连续发生多个错误，只展示最紧急的最后一条
     * 用户体验: 避免多个 Toast/Dialog 同时弹出
     * 性能优化: 减少不必要的 UI 更新
     */
    final event = _pending.last; // 只取最后一条，
    _pending.clear();
    if (event.source != null) {
      // 重新发射排队的错误
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

class _SHOGlobalErrorListenerState
    extends ConsumerState<SHOGlobalErrorListener> {
  SHOGlobalErrorController? _controller;
  SHOGlobalErrorEvent? _dialogEvent;

  @override
  void initState() {
    super.initState();
    // 首帧后绑定 Controller，处理等待队列
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

  // 本场景选择 listen 的原因:
  // 错误事件不需要直接在 build 中使用
  // 避免不必要的 Widget 重建（提升性能）
  // 只需要在错误发生时触发展示逻辑
  @override
  Widget build(BuildContext context) {
    // 监听错误事件（使用 ref.listen 避免不必要的 Widget 重建）
    //(ref.watch 返回值 + 监听变化，需要根据 Provider 值构建 UI, 重建Widget)
    ref.listen<SHOGlobalErrorEvent?>(globalErrorProvider, (previous, next) {
      if (next == null) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _present(next); // 展示错误
        ref.read(globalErrorProvider.notifier).consume();
      });
    });

    // 构建 UI：Stack 叠加 Dialog 遮罩
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

  // ← 异步操作带 Loading
  Future<T> withGlobalLoading<T>(Future<T> Function() task, {String? message}) {
    if (message != null) {
      read(overlayLoadingMessageProvider.notifier).state = message;
    }
    //等待task完成，再隐藏loading
    return read(overlayLoadingProvider.notifier).run(task).whenComplete(() {
      if (message != null) {
        read(overlayLoadingMessageProvider.notifier).state = null;
      }
    });
  }
}


/**
 应用启动
    ↓
bootstrap() 执行（可能发生错误）
    ↓ （此时 SHOGlobalErrorListener 还未初始化）
SHOGlobalError.report(error)  ← 错误发生
    ↓
_bound == null  ← 还未绑定
    ↓
_pending.add(event)  ← 加入等待队列
    ↓
Widget 树构建完成
    ↓
SHOGlobalErrorListener.initState()  执行
    ↓
SHOGlobalErrorController.bind(_controller!)
    ↓
处理 _pending 队列中的错误
    ↓
用户看到 Toast/Dialog
 */


/**
 ┌─────────────────────────────────────────────────────────────┐
│              全局错误处理工作流                               │
└─────────────────────────────────────────────────────────────┘

【错误发生】
    ↓
┌─────────────────────────────────────────────────────────────┐
│         错误上报方式选择                                     │
├─────────────────────────────────────────────────────────────┤
│  Widget 中:     ref.showGlobalError(error)                   │
│  Bootstrap 中:  SHOGlobalError.report(error)                 │
│  Zone 捕获:    SHOGlobalError.report(error)                 │
└─────────────────────────────────────────────────────────────┘
    ↓
┌─────────────────────────────────────────────────────────────┐
│         Controller._emit()  分发错误                        │
├─────────────────────────────────────────────────────────────┤
│  _bound != null?                                            │
│  ├─ 是 → state = event  (立即触发 Listener 响应)            │
│  └─ 否 → _pending.add(event)  (加入等待队列)                │
└─────────────────────────────────────────────────────────────┘
    ↓
    ↓ 【场景 A: Widget 已初始化】
    ├─ ref.listen 检测到 state 变化
    ├─ addPostFrameCallback 等待帧完成
    ├─ _present(event) 展示 Toast/Dialog
    └─ consume() 清除 state
    ↓
    ↓ 【场景 B: Widget 未初始化（Bootstrap 阶段）】
    ├─ 错误进入 _pending 队列
    ├─ SHOGlobalErrorListener.initState() 执行
    ├─ SHOGlobalErrorController.bind(controller)
    ├─ 处理 _pending 队列
    └─ 展示最后一条错误
    ↓
【用户看到 Toast/Dialog】
    ↓
【用户点击 OK（仅 Dialog）】
    ↓
setState(() => _dialogEvent = null)
    ↓
Dialog 关闭
 */


/*
1. 对比传统 try-catch 分散处理
维度	全局错误处理	分散 try-catch
代码复用	✅ 统一 API，一处定义到处使用	❌ 每个地方写一遍 Toast 调用
用户体验	✅ 统一视觉风格，一致的错误提示	⚠️ 不同页面风格可能不一致
启动阶段错误	✅ 排队机制，Widget 就绪后自动展示	❌ 可能无法展示（Scaffold 未就绪）
错误统计	✅ 可轻松接入埋点统计	❌ 需手动添加统计代码
学习成本	⭐⭐⭐⭐⭐ 极低	⭐⭐ 需记住各种 Toast API
维护成本	⭐⭐⭐⭐⭐ 一处修改，全局生效	⭐⭐⭐ 需遍历所有调用点
*/