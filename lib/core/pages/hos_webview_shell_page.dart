import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:shoo/core/analytics/hos_page_route_analytics_mixin.dart';
import 'package:shoo/core/feedback/hos_toast.dart';
import 'package:shoo/core/pages/hos_app_page_mixin.dart';
import 'package:shoo/core/pages/hos_page_error_boundary.dart';
import 'package:shoo/core/pages/hos_page_load_reporter.dart';
import 'package:shoo/core/platform/webview/hos_webview_config.dart';
import 'package:shoo/core/platform/webview/hos_webview_service.dart';
import 'package:shoo/features/activity_webview/presentation/widgets/webview/hos_generic_webview_container.dart';

/// 统一 WebView 页面壳：Scaffold + RouteAware 埋点 + 加载耗时上报。
class SHOWebViewShellPage extends ConsumerStatefulWidget {
  const SHOWebViewShellPage({
    super.key,
    required this.config,
    this.additionalAppBarActions,
    this.onControllerReady,
    this.pageNameOverride,
  });

  final SHOWebViewConfig config;

  /// 追加到 AppBar actions（如活动页分享按钮）。
  final List<Widget>? additionalAppBarActions;

  final void Function(WebViewController controller)? onControllerReady;

  /// 覆盖默认 pageName（活动页用 `activity`）。
  final String? pageNameOverride;

  @override
  ConsumerState<SHOWebViewShellPage> createState() =>
      _SHOWebViewShellPageState();
}

class _SHOWebViewShellPageState extends ConsumerState<SHOWebViewShellPage>
    with
        SHOPageRouteAnalyticsMixin<SHOWebViewShellPage>,
        SHOAppPageMixin<SHOWebViewShellPage> {
  final _service = SHOWebViewService.instance;

  WebViewController? _controller;
  String? _dynamicTitle;
  String _currentUrl = '';
  bool _webCanGoBack = false;
  Stopwatch? _webLoadStopwatch;
  var _webLoadReported = false;

  SHOWebViewConfig get _config => widget.config;

  bool get _hasUrl => _config.hasContent;

  String get _displayTitle =>
      _config.title ?? _dynamicTitle ?? _currentUrlOrFallback;

  String get _currentUrlOrFallback =>
      _currentUrl.isNotEmpty ? _currentUrl : _config.url;

  @override
  String get pageName => widget.pageNameOverride ?? 'webview';

  @override
  Map<String, Object?> get pageAnalyticsExtra => {
    'url': _config.url,
    'webview_mode': _config.mode.name,
  };

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

  void _onWebLoadStarted(String url) {
    _webLoadStopwatch = Stopwatch()..start();
    _webLoadReported = false;
  }

  Future<void> _onWebLoadFinished(String url) async {
    if (_webLoadReported || _webLoadStopwatch == null) return;
    _webLoadReported = true;
    _webLoadStopwatch!.stop();

    await SHOPageLoadReporter.reportWebView(
      url: url,
      durationMs: _webLoadStopwatch!.elapsedMilliseconds,
      success: true,
    );
    await SHOPageLoadReporter.report(
      pageName: pageName,
      durationMs: _webLoadStopwatch!.elapsedMilliseconds,
      phase: SHOPageLoadPhase.webViewFinished,
      extra: {...pageAnalyticsExtra, 'loaded_url': url},
    );
  }

  Future<void> _onWebLoadFailed(
    String url,
    int? errorCode,
    String? message,
  ) async {
    if (_webLoadReported || _webLoadStopwatch == null) return;
    _webLoadReported = true;
    _webLoadStopwatch!.stop();

    await SHOPageLoadReporter.reportWebView(
      url: url,
      durationMs: _webLoadStopwatch!.elapsedMilliseconds,
      success: false,
      errorCode: errorCode,
      errorMessage: message,
    );
  }

  Widget _buildWebBody() {
    return SHOPageErrorBoundary(
      pageName: pageName,
      onRetry: () => unawaited(_controller?.reload()),
      child: SHOGenericWebViewContainer(
        config: _config,
        onControllerReady: (controller) {
          _controller = controller;
          widget.onControllerReady?.call(controller);
        },
        onTitleChanged: (title) {
          if (mounted) setState(() => _dynamicTitle = title);
        },
        onUrlChanged: (url) {
          if (mounted) setState(() => _currentUrl = url);
        },
        onCanGoBackChanged: (canGoBack) {
          if (mounted) setState(() => _webCanGoBack = canGoBack);
        },
        onPageLoadStarted: _onWebLoadStarted,
        onPageLoadFinished: (url) => unawaited(_onWebLoadFinished(url)),
        onPageLoadFailed: (url, code, message) =>
            unawaited(_onWebLoadFailed(url, code, message)),
      ),
    );
  }

  Widget _wrapPopScope(Widget child) {
    return PopScope(
      canPop: !_webCanGoBack,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        await _handlePop();
      },
      child: child,
    );
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

    final body = _buildWebBody();

    if (!_config.showAppBar) {
      return _wrapPopScope(Scaffold(body: body));
    }

    return _wrapPopScope(
      Scaffold(
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
            ...?widget.additionalAppBarActions,
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
