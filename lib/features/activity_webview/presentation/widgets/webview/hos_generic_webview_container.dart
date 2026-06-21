import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:shoo/core/platform/webview/hos_webview_config.dart';
import 'package:shoo/core/platform/webview/hos_webview_route_mapper.dart';
import 'package:shoo/core/platform/webview/hos_webview_service.dart';
import 'package:shoo/features/activity_webview/presentation/widgets/webview/hos_webview_error_widget.dart';
import 'package:shoo/features/activity_webview/presentation/widgets/webview/hos_webview_loading_overlay.dart';
import 'package:shoo/features/activity_webview/presentation/widgets/webview/hos_webview_progress_bar.dart';

enum _SHOWebViewLoadingState { loading, finished, error }

/// 通用 WebView 容器（技术方案 WebViewContainer 的 SHOO 实现，不含 Scaffold）。
class SHOGenericWebViewContainer extends StatefulWidget {
  const SHOGenericWebViewContainer({
    super.key,
    required this.config,
    this.onTitleChanged,
    this.onUrlChanged,
    this.onCanGoBackChanged,
    this.onControllerReady,
  });

  final SHOWebViewConfig config;
  final void Function(String title)? onTitleChanged;
  final void Function(String url)? onUrlChanged;
  final void Function(bool canGoBack)? onCanGoBackChanged;
  final void Function(WebViewController controller)? onControllerReady;

  @override
  State<SHOGenericWebViewContainer> createState() =>
      _SHOGenericWebViewContainerState();
}

class _SHOGenericWebViewContainerState extends State<SHOGenericWebViewContainer> {
  WebViewController? _controller;
  final _service = SHOWebViewService.instance;

  int _progress = 0;
  _SHOWebViewLoadingState _loadingState = _SHOWebViewLoadingState.loading;
  String? _errorMessage;
  int? _errorCode;
  double _scrollY = 0;
  Timer? _timeoutTimer;
  bool _initializing = true;

  static const _scrollBridgeChannel = 'SHOWebViewScrollBridge';

  @override
  void initState() {
    super.initState();
    unawaited(_initController());
  }

  @override
  void dispose() {
    _timeoutTimer?.cancel();
    unawaited(_controller?.clearCache());
    super.dispose();
  }

  Future<void> _initController() async {
    final controller = WebViewController();

    await controller.setJavaScriptMode(
      widget.config.javascriptEnabled
          ? JavaScriptMode.unrestricted
          : JavaScriptMode.disabled,
    );
    await controller.setBackgroundColor(Colors.white);

    if (widget.config.javascriptEnabled) {
      try {
        final defaultUA = await controller.getUserAgent();
        if (defaultUA != null && defaultUA.isNotEmpty) {
          await controller.setUserAgent('$defaultUA SHOOApp/1.0');
        }
      } catch (_) {}
    }

    controller.setNavigationDelegate(
      NavigationDelegate(
        onPageStarted: (url) {
          _cancelTimeout();
          setState(() {
            _loadingState = _SHOWebViewLoadingState.loading;
            _errorMessage = null;
            _errorCode = null;
            _progress = 0;
          });
          _startTimeout();
          widget.onUrlChanged?.call(url);
        },
        onProgress: (progress) {
          if (!mounted) return;
          setState(() => _progress = progress);
        },
        onPageFinished: (url) async {
          _cancelTimeout();
          if (!mounted) return;
          setState(() {
            _loadingState = _SHOWebViewLoadingState.finished;
            _progress = 100;
          });
          widget.onUrlChanged?.call(url);

          if (widget.config.cookies != null) {
            await _service.syncCookiesToWebView(controller, widget.config.cookies!);
          }
          if (widget.config.injectedJavaScript != null) {
            await controller.runJavaScript(widget.config.injectedJavaScript!);
          }

          final title = await controller.getTitle();
          if (title != null && title.isNotEmpty) {
            widget.onTitleChanged?.call(title);
          }

          final canGoBack = await controller.canGoBack();
          widget.onCanGoBackChanged?.call(canGoBack);

          if (widget.config.pullToRefresh) {
            await _injectScrollListener(controller);
          }
        },
        onWebResourceError: (error) {
          _cancelTimeout();
          if (!mounted) return;
          setState(() {
            _loadingState = _SHOWebViewLoadingState.error;
            _errorMessage = error.description;
            _errorCode = error.errorCode;
          });
        },
        onNavigationRequest: (request) => _resolveNavigation(request.url),
      ),
    );

    for (final channel in widget.config.javaScriptChannels ?? const []) {
      controller.addJavaScriptChannel(
        channel.name,
        onMessageReceived: (msg) => channel.onMessage?.call(msg.message),
      );
    }

    if (widget.config.pullToRefresh) {
      controller.addJavaScriptChannel(
        _scrollBridgeChannel,
        onMessageReceived: (msg) {
          try {
            final data = jsonDecode(msg.message) as Map<String, dynamic>;
            if (data['event'] == 'scroll' && mounted) {
              setState(() => _scrollY = (data['y'] as num).toDouble());
            }
          } catch (_) {}
        },
      );
    }

    await _loadUrl(controller, widget.config.url);

    if (!mounted) return;
    setState(() {
      _controller = controller;
      _initializing = false;
    });
    widget.onControllerReady?.call(controller);
  }

  Future<void> _injectScrollListener(WebViewController controller) async {
    await controller.runJavaScript('''
      if (!window.__shoScrollBound) {
        window.__shoScrollBound = true;
        window.addEventListener('scroll', function() {
          $_scrollBridgeChannel.postMessage(JSON.stringify({event: 'scroll', y: window.scrollY}));
        }, {passive: true});
      }
    ''');
  }

  Future<NavigationDecision> _resolveNavigation(String url) async {
    final interceptors = widget.config.interceptors;
    if (interceptors != null && interceptors.isNotEmpty) {
      final result = await _service.handleInterception(url, interceptors);
      if (!result.allowed) {
        if (result.nativeUrl != null && mounted) {
          final route = SHOWebViewRouteMapper.toAppRoute(result.nativeUrl!);
          if (route != null) {
            await context.push(route);
          }
        }
        return NavigationDecision.prevent;
      }
    }

    if (_service.shouldOpenExternally(url, widget.config.mode)) {
      await _service.openInSystemBrowser(url);
      return NavigationDecision.prevent;
    }

    final customHeaders = widget.config.customHeaders;
    if (customHeaders != null && customHeaders.isNotEmpty) {
      final controller = _controller;
      if (controller != null) {
        await controller.loadRequest(
          Uri.parse(url),
          headers: _service.buildRequestHeaders(widget.config),
        );
      }
      return NavigationDecision.prevent;
    }

    return NavigationDecision.navigate;
  }

  Future<void> _loadUrl(WebViewController controller, String url) async {
    final headers = _service.buildRequestHeaders(widget.config);
    await controller.loadRequest(Uri.parse(url), headers: headers);
  }

  void _startTimeout() {
    _cancelTimeout();
    if (widget.config.timeout <= 0) return;
    _timeoutTimer = Timer(Duration(milliseconds: widget.config.timeout), () {
      if (!mounted) return;
      if (_loadingState == _SHOWebViewLoadingState.loading) {
        setState(() {
          _loadingState = _SHOWebViewLoadingState.error;
          _errorMessage = '加载超时，请稍后重试';
          _errorCode = -8;
        });
      }
    });
  }

  void _cancelTimeout() {
    _timeoutTimer?.cancel();
    _timeoutTimer = null;
  }

  Future<void> reload() async {
    final controller = _controller;
    if (controller == null) return;
    setState(() {
      _loadingState = _SHOWebViewLoadingState.loading;
      _errorMessage = null;
      _errorCode = null;
      _progress = 0;
    });
    await controller.reload();
  }

  @override
  Widget build(BuildContext context) {
    if (_initializing || _controller == null) {
      return const SHOWebViewLoadingOverlay();
    }

    final controller = _controller!;
    final showError = _loadingState == _SHOWebViewLoadingState.error;
    final showProgress =
        widget.config.showProgressBar && _progress < 100 && !showError;

    Widget webView = WebViewWidget(controller: controller);

    if (widget.config.pullToRefresh && !showError) {
      webView = RefreshIndicator(
        onRefresh: reload,
        displacement: 40,
        notificationPredicate: _scrollY <= 0 ? (_) => true : (_) => false,
        child: webView,
      );
    }

    return Column(
      children: [
        SHOWebViewProgressBar(progress: _progress, visible: showProgress),
        Expanded(
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (!showError) webView,
              if (showError)
                SHOWebViewErrorWidget(
                  errorCode: _errorCode,
                  message: _errorMessage ?? '加载失败',
                  onRetry: () => unawaited(reload()),
                  onBack: () => context.pop(),
                ),
              if (_loadingState == _SHOWebViewLoadingState.loading &&
                  _progress < 30 &&
                  !showError &&
                  !widget.config.showProgressBar)
                const SHOWebViewLoadingOverlay(),
            ],
          ),
        ),
      ],
    );
  }
}
