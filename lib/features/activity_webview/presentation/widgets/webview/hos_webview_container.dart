import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:go_router/go_router.dart';

import 'package:shoo/core/feedback/hos_toast.dart';
import 'package:shoo/core/platform/webview/hos_webview_capture.dart';
import 'package:shoo/core/platform/webview/hos_activity_native_dispatcher.dart';
import 'package:shoo/core/platform/webview/hos_url_navigator.dart';
import 'package:shoo/core/platform/webview/hos_url_router_service.dart';
import 'package:shoo/core/platform/webview/hos_payment_handler.dart';
import 'package:shoo/core/platform/webview/hos_url_decision.dart';
import 'package:shoo/core/platform/webview/hos_webview_navigation_policy.dart';
import 'package:shoo/core/platform/webview/hos_webview_security.dart';
import 'package:shoo/features/activity_webview/presentation/state/hos_activity_config_provider.dart';
import 'package:shoo/features/activity_webview/presentation/state/hos_dialog_provider.dart';
import 'package:shoo/features/activity_webview/presentation/state/hos_image_preview_provider.dart';
import 'package:shoo/features/activity_webview/presentation/state/hos_share_provider.dart';
import 'package:shoo/features/activity_webview/presentation/state/hos_webview_loading_provider.dart';
import 'package:shoo/features/activity_webview/presentation/widgets/webview/hos_webview_error_widget.dart';
import 'package:shoo/features/activity_webview/presentation/widgets/webview/hos_webview_loading_overlay.dart';
import 'package:shoo/features/activity_webview/presentation/widgets/webview/hos_webview_progress_bar.dart';

class SHOWebViewContainer extends ConsumerStatefulWidget {
  const SHOWebViewContainer({
    super.key,
    this.initialUrl,
    this.loadAsset,
    this.title,
    this.onControllerReady,
    this.navigationPolicy = SHOWebViewNavigationPolicy.whitelist,
  });

  final String? initialUrl;
  final String? loadAsset;
  final String? title;
  final void Function(WebViewController controller)? onControllerReady;
  final SHOWebViewNavigationPolicy navigationPolicy;

  @override
  ConsumerState<SHOWebViewContainer> createState() => _SHOWebViewContainerState();
}

class _SHOWebViewContainerState extends ConsumerState<SHOWebViewContainer> {
  WebViewController? _controller;
  bool _initializing = false;
  final _dispatcher = const SHOActivityNativeDispatcher();
  final _router = const SHOURLRouterService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _ensureController());
  }

  void _ensureController() {
    if (!mounted || _controller != null || _initializing) return;
    _initializing = true;
    ref.read(webviewLoadingProvider.notifier).reset();
    final controller = _buildController();
    if (!mounted) return;
    setState(() {
      _controller = controller;
      _initializing = false;
    });
  }

  SHOWebViewLoadingNotifier get _loading =>
      ref.read(webviewLoadingProvider.notifier);

  WebViewController _buildController() {
    WebViewController? holder;
    holder = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..addJavaScriptChannel(
        'FlutterBridge',
        onMessageReceived: (message) => _onBridgeMessage(message.message),
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (progress) => _loading.updateProgress(progress),
          onPageStarted: (_) {
            _loading.updateProgress(0);
            _loading.clearError();
          },
          onPageFinished: (url) async {
            _loading.updateProgress(100);
            final web = holder;
            if (web == null) return;
            final canGoBack = await web.canGoBack();
            _loading.setCanGoBack(canGoBack);
            if (widget.title != null) {
              _loading.setPageTitle(widget.title);
            } else {
              final title = await web.getTitle();
              _loading.setPageTitle(title);
            }
          },
          onWebResourceError: (error) {
            _loading.setError(
              error.description,
              error.errorCode,
            );
          },
          onNavigationRequest: (request) =>
              _handleNavigationRequest(request.url),
        ),
      );

    final controller = holder ?? (throw StateError('WebViewController init failed'));
    if (widget.loadAsset != null) {
      unawaited(controller.loadFlutterAsset(widget.loadAsset!));
    } else if (widget.initialUrl != null) {
      unawaited(controller.loadRequest(Uri.parse(widget.initialUrl!)));
    }

    widget.onControllerReady?.call(controller);
    return controller;
  }

  NavigationDecision _handleNavigationRequest(String url) {
    final scheme = Uri.parse(url).scheme.toLowerCase();

    if (SHOWebViewSecurity.isBlockedScheme(scheme)) {
      unawaited(SHOURLNavigator.open(context, ref, url, router: _router));
      return NavigationDecision.prevent;
    }

    if (widget.navigationPolicy == SHOWebViewNavigationPolicy.inApp) {
      if (scheme == 'http' || scheme == 'https') {
        final decision = _router.resolve(url);
        if (decision.target == SHOURLTarget.payment) {
          unawaited(SHOPaymentHandler.openPaymentUrl(url));
          return NavigationDecision.prevent;
        }
        return NavigationDecision.navigate;
      }
      unawaited(SHOURLNavigator.open(context, ref, url, router: _router));
      return NavigationDecision.prevent;
    }

    if (!_router.shouldAllowWebViewNavigation(url)) {
      unawaited(SHOURLNavigator.open(context, ref, url, router: _router));
      return NavigationDecision.prevent;
    }
    return NavigationDecision.navigate;
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;

    if (widget.navigationPolicy == SHOWebViewNavigationPolicy.inApp) {
      final scheme = uri.scheme.toLowerCase();
      if (scheme == 'http' || scheme == 'https') {
        final decision = _router.resolve(url);
        if (decision.target == SHOURLTarget.payment) {
          await SHOPaymentHandler.openPaymentUrl(url);
          return;
        }
        await _controller?.loadRequest(uri);
        return;
      }
    }

    await SHOURLNavigator.open(context, ref, url, router: _router);
  }

  Future<void> _onBridgeMessage(String raw) async {
    final message = parseBridgeMessage(raw);
    if (message == null || !mounted) return;

    final type = message['type']?.toString() ?? '';
    final action = message['action']?.toString() ?? '';
    final params = Map<String, dynamic>.from(message['params'] as Map? ?? const {});

    switch (type) {
      case 'flutter':
        _handleFlutterEvent(action, params);
      case 'native':
        await _dispatcher.dispatch(context, action, params);
      case 'preview':
        await _handlePreview(params);
      case 'navigate':
        if (action == 'openRoute') {
          final path = params['path']?.toString();
          if (path != null && path.isNotEmpty && context.mounted) {
            await context.push(path);
          }
        } else {
          final url = params['url']?.toString();
          if (url != null) {
            await _openUrl(url);
          }
        }
      case 'screenshot':
        final dataUrl = params['data']?.toString();
        if (action == 'captured' && dataUrl != null) {
          ref.read(shareProvider.notifier).completeScreenshot(
                SHOWebViewCapture.decodeDataUrl(dataUrl),
              );
        } else {
          ref.read(shareProvider.notifier).completeScreenshot(null);
        }
      case 'pageReady':
        if (mounted) context.showToast('页面已就绪');
    }
  }

  void _handleFlutterEvent(String action, Map<String, dynamic> params) {
    switch (action) {
      case 'showCouponDialog':
        showActivityDialog(ref, 'coupon');
      case 'showLotteryDialog':
        showActivityDialog(ref, 'lottery');
      case 'showRulesDialog':
        showActivityDialog(ref, 'rules');
      case 'showPrizeDialog':
        showActivityDialog(ref, 'prize');
      default:
        showActivityDialog(ref, action);
    }
  }

  Future<void> _handlePreview(Map<String, dynamic> params) async {
    final url = params['url']?.toString();
    if (url == null) return;
    final title = params['title']?.toString() ?? '';
    final config = ref.read(activityConfigProvider).valueOrNull;
    final galleryImages = config?.images
            .map((e) => SHOImagePreviewItem(url: e.url, title: e.title))
            .toList() ??
        <SHOImagePreviewItem>[];
    final promoImages = config?.promoBlocks
            .where((b) => b.type == 'image' && (b.url?.isNotEmpty ?? false))
            .map((b) => SHOImagePreviewItem(url: b.url!, title: b.caption ?? ''))
            .toList() ??
        <SHOImagePreviewItem>[];
    final images = [...galleryImages, ...promoImages];
    if (images.isEmpty) {
      images.add(SHOImagePreviewItem(url: url, title: title));
    }
    final index = images.indexWhere((e) => e.url == url);
    await SHOURLNavigator.openImagePreview(
      context,
      ref,
      images: images,
      index: index >= 0 ? index : 0,
    );
  }

  Future<void> _reload() async {
    final loading = ref.read(webviewLoadingProvider.notifier);
    if (!loading.retry() && mounted) {
      context.showToast('已达最大重试次数');
      return;
    }
    await _controller?.reload();
  }

  @override
  Widget build(BuildContext context) {
    final loading = ref.watch(webviewLoadingProvider);
    final controller = _controller;
    if (controller == null) {
      return const SHOWebViewLoadingOverlay();
    }

    final showError = loading.error != null && loading.error!.isNotEmpty;

    return Column(
      children: [
        SHOWebViewProgressBar(
          progress: loading.progress,
          visible: loading.isLoading && loading.progress < 100,
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              await controller.reload();
              if (!context.mounted) return;
              context.showToast('刷新成功');
            },
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (!showError)
                  WebViewWidget(controller: controller)
                else
                  SHOWebViewErrorWidget(
                    errorCode: loading.errorCode,
                    message: loading.error ?? '',
                    onRetry: () => unawaited(_reload()),
                    onBack: () => Navigator.of(context).maybePop(),
                  ),
                if (loading.isLoading && loading.progress < 30 && !showError)
                  const SHOWebViewLoadingOverlay(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
