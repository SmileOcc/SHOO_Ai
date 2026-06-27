import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:shoo/core/pages/hos_route_args.dart';
import 'package:shoo/core/pages/hos_webview_shell_page.dart';
import 'package:shoo/core/platform/webview/hos_webview_config.dart';

/// 通用 WebView 页（GoRouter `/webview` 入口）。
///
/// 实现已迁移至 [SHOWebViewShellPage]（统一壳 + 埋点 + 加载耗时）。
class SHOWebViewPage extends StatelessWidget {
  const SHOWebViewPage({super.key, required this.config});

  final SHOWebViewConfig config;

  factory SHOWebViewPage.fromRoute(GoRouterState state) {
    return SHOWebViewPage(config: SHOWebViewRouteArgs.fromState(state).config);
  }

  @override
  Widget build(BuildContext context) => SHOWebViewShellPage(config: config);
}
