import 'package:flutter/material.dart';

/// 可选 Scaffold 壳：统一 AppBar / body / FAB / 返回拦截。
///
/// 不传 [appBar] 且未传 [title] 时不渲染 AppBar。
class SHOAppShellPage extends StatelessWidget {
  const SHOAppShellPage({
    super.key,
    this.appBar,
    this.title,
    this.titleWidget,
    this.actions,
    required this.body,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.backgroundColor,
    this.canPop = true,
    this.onPopInvokedWithResult,
  });

  final PreferredSizeWidget? appBar;
  final String? title;
  final Widget? titleWidget;
  final List<Widget>? actions;
  final Widget body;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final Color? backgroundColor;
  final bool canPop;
  final PopInvokedWithResultCallback? onPopInvokedWithResult;

  PreferredSizeWidget? _resolveAppBar() {
    if (appBar != null) return appBar;
    if (titleWidget == null && title == null && actions == null) return null;
    return AppBar(
      title: titleWidget ?? (title != null ? Text(title!) : null),
      actions: actions,
    );
  }

  @override
  Widget build(BuildContext context) {
    final scaffold = Scaffold(
      backgroundColor: backgroundColor,
      appBar: _resolveAppBar(),
      body: body,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
    );

    if (onPopInvokedWithResult == null && canPop) {
      return scaffold;
    }

    return PopScope(
      canPop: canPop,
      onPopInvokedWithResult: onPopInvokedWithResult,
      child: scaffold,
    );
  }
}
