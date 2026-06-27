import 'package:flutter/material.dart';

/// Tab 根页 / [TabBarView] 子页保活封装。
///
/// - 配合 [StatefulShellRoute.indexedStack] 时显式声明保活约定；
/// - 在 [TabBarView] 内使用时需 mixin [SHOTabKeepAliveMixin] 并在 `build` 中调用 `super.build`。
class SHOTabKeepAlivePage extends StatefulWidget {
  const SHOTabKeepAlivePage({super.key, required this.child});

  final Widget child;

  @override
  State<SHOTabKeepAlivePage> createState() => _SHOTabKeepAlivePageState();
}

class _SHOTabKeepAlivePageState extends State<SHOTabKeepAlivePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}

/// [TabBarView] 子页 State 保活 mixin。
///
/// ```dart
/// class _TabState extends ConsumerState<MyTab> with SHOTabKeepAliveMixin {
///   @override
///   Widget build(BuildContext context) {
///     super.build(context); // 必须
///     return ...;
///   }
/// }
/// ```
mixin SHOTabKeepAliveMixin<T extends StatefulWidget>
    on State<T>, AutomaticKeepAliveClientMixin<T> {
  @override
  bool get wantKeepAlive => true;
}
