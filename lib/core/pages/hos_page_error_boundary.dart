import 'dart:async';

import 'package:flutter/material.dart';

import 'package:shoo/core/pages/hos_page_load_reporter.dart';
import 'package:shoo/core/widgets/hos_error_view.dart';

/// 单页 build 异常降级：捕获子树 [ErrorWidget] 并替换为 [SHOAppErrorView]。
///
/// 通过全局 [ErrorWidget.builder] 作用域栈实现，适用于 [SHODataPage] / Shell 页 body。
class SHOPageErrorBoundary extends StatefulWidget {
  const SHOPageErrorBoundary({
    super.key,
    required this.pageName,
    required this.child,
    this.onRetry,
  });

  final String pageName;
  final Widget child;
  final VoidCallback? onRetry;

  @override
  State<SHOPageErrorBoundary> createState() => _SHOPageErrorBoundaryState();
}

class _SHOPageErrorBoundaryState extends State<SHOPageErrorBoundary> {
  FlutterErrorDetails? _errorDetails;
  var _generation = 0;

  @override
  void initState() {
    super.initState();
    _SHOPageErrorBoundaryController.ensureInstalled();
    _SHOPageErrorBoundaryController.push(this);
  }

  @override
  void dispose() {
    _SHOPageErrorBoundaryController.pop(this);
    super.dispose();
  }

  void capture(FlutterErrorDetails details) {
    if (!mounted || _errorDetails != null) return;
    setState(() => _errorDetails = details);
    unawaited(
      SHOPageLoadReporter.reportRenderError(
        pageName: widget.pageName,
        details: details,
      ),
    );
  }

  void _handleRetry() {
    setState(() {
      _errorDetails = null;
      _generation++;
    });
    widget.onRetry?.call();
  }

  @override
  Widget build(BuildContext context) {
    if (_errorDetails != null) {
      return SHOAppErrorView(
        message: _errorDetails!.exceptionAsString(),
        onRetry: _handleRetry,
      );
    }

    return KeyedSubtree(
      key: ValueKey(_generation),
      child: widget.child,
    );
  }
}

abstract final class _SHOPageErrorBoundaryController {
  static final _stack = <_SHOPageErrorBoundaryState>[];
  static var _installed = false;
  static ErrorWidgetBuilder? _defaultBuilder;

  static void ensureInstalled() {
    if (_installed) return;
    _installed = true;
    _defaultBuilder = ErrorWidget.builder;
    ErrorWidget.builder = (details) {
      final state = _stack.isEmpty ? null : _stack.last;
      if (state != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          state.capture(details);
        });
        return const SizedBox.shrink();
      }
      return (_defaultBuilder ?? ErrorWidget.builder)(details);
    };
  }

  static void push(_SHOPageErrorBoundaryState state) => _stack.add(state);

  static void pop(_SHOPageErrorBoundaryState state) {
    _stack.remove(state);
  }
}
