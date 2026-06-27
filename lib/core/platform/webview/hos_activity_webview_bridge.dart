import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:shoo/core/feedback/hos_toast.dart';
import 'package:shoo/core/platform/webview/hos_activity_native_dispatcher.dart';
import 'package:shoo/core/platform/webview/hos_payment_handler.dart';
import 'package:shoo/core/platform/webview/hos_url_decision.dart';
import 'package:shoo/core/platform/webview/hos_url_navigator.dart';
import 'package:shoo/core/platform/webview/hos_url_router_service.dart';
import 'package:shoo/core/platform/webview/hos_webview_capture.dart';
import 'package:shoo/core/platform/webview/hos_webview_navigation_policy.dart';
import 'package:shoo/core/platform/webview/hos_webview_security.dart';
import 'package:shoo/features/activity_webview/presentation/state/hos_activity_config_provider.dart';
import 'package:shoo/features/activity_webview/presentation/state/hos_dialog_provider.dart';
import 'package:shoo/features/activity_webview/presentation/state/hos_image_preview_provider.dart';
import 'package:shoo/features/activity_webview/presentation/state/hos_share_provider.dart';

/// 活动 H5 JS Bridge（`FlutterBridge` 通道，与 [SHOWebViewBridgeHandler] 协议不同）。
abstract final class SHOActivityWebViewBridge {
  static const _dispatcher = SHOActivityNativeDispatcher();
  static const _router = SHOURLRouterService();

  static Future<void> handle(
    BuildContext context,
    WidgetRef ref,
    WebViewController controller,
    String raw,
  ) async {
    final message = parseBridgeMessage(raw);
    if (message == null || !context.mounted) return;

    final type = message['type']?.toString() ?? '';
    final action = message['action']?.toString() ?? '';
    final params = Map<String, dynamic>.from(message['params'] as Map? ?? const {});

    switch (type) {
      case 'flutter':
        _handleFlutterEvent(ref, action);
      case 'native':
        await _dispatcher.dispatch(context, action, params);
      case 'preview':
        await _handlePreview(context, ref, params);
      case 'navigate':
        if (action == 'openRoute') {
          final path = params['path']?.toString();
          if (path != null && path.isNotEmpty && context.mounted) {
            await context.push(path);
          }
        } else {
          final url = params['url']?.toString();
          if (url != null) {
            await _openUrl(context, ref, controller, url);
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
        if (context.mounted) context.showToast('页面已就绪');
    }
  }

  static NavigationDecision resolveNavigation(
    BuildContext context,
    WidgetRef ref,
    String url, {
    SHOWebViewNavigationPolicy policy = SHOWebViewNavigationPolicy.whitelist,
  }) {
    final scheme = Uri.parse(url).scheme.toLowerCase();

    if (SHOWebViewSecurity.isBlockedScheme(scheme)) {
      unawaited(SHOURLNavigator.open(context, ref, url, router: _router));
      return NavigationDecision.prevent;
    }

    if (policy == SHOWebViewNavigationPolicy.inApp) {
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

  static void _handleFlutterEvent(WidgetRef ref, String action) {
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

  static Future<void> _openUrl(
    BuildContext context,
    WidgetRef ref,
    WebViewController controller,
    String url,
  ) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;

    final scheme = uri.scheme.toLowerCase();
    if (scheme == 'http' || scheme == 'https') {
      final decision = _router.resolve(url);
      if (decision.target == SHOURLTarget.payment) {
        await SHOPaymentHandler.openPaymentUrl(url);
        return;
      }
      await controller.loadRequest(uri);
      return;
    }

    await SHOURLNavigator.open(context, ref, url, router: _router);
  }

  static Future<void> _handlePreview(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> params,
  ) async {
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
}

Map<String, dynamic>? parseBridgeMessage(String raw) {
  try {
    return jsonDecode(raw) as Map<String, dynamic>;
  } catch (_) {
    return null;
  }
}
