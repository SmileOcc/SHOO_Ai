import 'package:flutter/material.dart';

/// 全局 [RouteObserver]，供 [RouteAware] 页面订阅 push / pop / cover / resume。
///
/// 在 [GoRouter.observers] 中注册：
/// ```dart
/// observers: [shoPageRouteObserver, ...],
/// ```
final shoPageRouteObserver = SHOPageRouteObserver();

class SHOPageRouteObserver extends RouteObserver<ModalRoute<void>> {}
