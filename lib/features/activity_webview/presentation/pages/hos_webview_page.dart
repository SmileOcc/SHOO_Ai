import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:shoo/core/feedback/hos_toast.dart';
import 'package:shoo/core/platform/webview/hos_webview_config.dart';
import 'package:shoo/core/platform/webview/hos_webview_service.dart';
import 'package:shoo/features/activity_webview/presentation/widgets/webview/hos_generic_webview_container.dart';

/// 通用 WebView 页（GoRouter `/webview` 入口，对应技术方案 WebViewContainer 页面壳）。
class SHOWebViewPage extends StatefulWidget {
  const SHOWebViewPage({
    super.key,
    required this.config,
  });

  final SHOWebViewConfig config;

  /// 从 GoRouter [GoRouterState] 解析路由参数。
  factory SHOWebViewPage.fromRoute(GoRouterState state) {
    return SHOWebViewPage(
      config: SHOWebViewConfig.fromQueryParameters(state.uri.queryParameters),
    );
  }

  @override
  State<SHOWebViewPage> createState() => _SHOWebViewPageState();
}

class _SHOWebViewPageState extends State<SHOWebViewPage> {
  final _service = SHOWebViewService.instance;

  WebViewController? _controller;
  String? _dynamicTitle;
  String _currentUrl = '';
  bool _webCanGoBack = false;

  SHOWebViewConfig get _config => widget.config;

  bool get _hasUrl => _config.hasContent;

  String get _displayTitle =>
      _config.title ?? _dynamicTitle ?? _currentUrlOrFallback;

  String get _currentUrlOrFallback =>
      _currentUrl.isNotEmpty ? _currentUrl : _config.url;

  Future<void> _reload() async {
    await _controller?.reload();
    if (mounted) context.showToast('已刷新');
  }

  Future<void> _openInBrowser() async {
    final ok = await _service.openInSystemBrowser(_currentUrlOrFallback);
    if (!ok && mounted) context.showToast('无法打开外部浏览器');
  }

  Future<void> _shareUrl() async {
    if (!_hasUrl) return;
    await Share.share(_currentUrlOrFallback);
  }

  Future<void> _handlePop() async {
    final controller = _controller;
    if (controller != null && await controller.canGoBack()) {
      await controller.goBack();
      final canGoBack = await controller.canGoBack();
      if (mounted) setState(() => _webCanGoBack = canGoBack);
      return;
    }
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasUrl) {
      return Scaffold(
        appBar: AppBar(title: const Text('网页')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.link_off, size: 48),
                const SizedBox(height: 12),
                const Text('未提供有效网址'),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => context.pop(),
                  child: const Text('返回'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final body = SHOGenericWebViewContainer(
      config: _config,
      onControllerReady: (controller) => _controller = controller,
      onTitleChanged: (title) {
        if (mounted) setState(() => _dynamicTitle = title);
      },
      onUrlChanged: (url) {
        if (mounted) setState(() => _currentUrl = url);
      },
      onCanGoBackChanged: (canGoBack) {
        if (mounted) setState(() => _webCanGoBack = canGoBack);
      },
    );

    if (!_config.showAppBar) {
      return PopScope(
        canPop: !_webCanGoBack,
        onPopInvokedWithResult: (didPop, _) async {
          if (didPop) return;
          await _handlePop();
        },
        child: Scaffold(body: body),
      );
    }

    return PopScope(
      canPop: !_webCanGoBack,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        await _handlePop();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: _config.canGoBack
              ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => unawaited(_handlePop()),
                )
              : null,
          title: Text(
            _displayTitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          actions: [
            IconButton(
              tooltip: '刷新',
              icon: const Icon(Icons.refresh),
              onPressed: () => unawaited(_reload()),
            ),
            IconButton(
              tooltip: '浏览器打开',
              icon: const Icon(Icons.open_in_new),
              onPressed: () => unawaited(_openInBrowser()),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'share':
                    unawaited(_shareUrl());
                  case 'close':
                    context.pop();
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: 'share',
                  child: ListTile(
                    leading: Icon(Icons.share_outlined),
                    title: Text('分享链接'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                PopupMenuItem(
                  value: 'close',
                  child: ListTile(
                    leading: Icon(Icons.close),
                    title: Text('关闭'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ],
        ),
        body: body,
      ),
    );
  }
}
