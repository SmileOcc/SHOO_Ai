import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:shoo/core/deeplink/hos_deeplink_navigator.dart';
import 'package:shoo/core/deeplink/hos_deeplink_resolver.dart';
import 'package:shoo/core/feedback/hos_toast.dart';
import 'package:shoo/features/auth/presentation/state/hos_session_provider.dart';

/// 通用 WebView JS Bridge（调试页 / 活动 H5 共用协议子集）。
abstract final class SHOWebViewBridgeHandler {
  static Future<void> handle(
    BuildContext context,
    WidgetRef ref,
    WebViewController controller,
    String raw,
  ) async {
    Map<String, dynamic>? message;
    try {
      message = jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return;
    }

    final type = message['type']?.toString();
    if (type == 'deeplink') {
      final url = message['url']?.toString();
      if (url != null) {
        _openDeepLink(context, ref, url);
      }
      return;
    }

    final action = message['action']?.toString() ?? '';
    final data = message['data'];

    switch (action) {
      case 'hello':
        if (context.mounted) context.showToast('Bridge: hello');
      case 'toast':
        final text = data?.toString() ?? message['msg']?.toString() ?? '';
        if (text.isNotEmpty && context.mounted) context.showToast(text);
      case 'pay':
        if (context.mounted) context.showToast('Bridge: 支付事件（调试）');
      case 'close':
        if (context.mounted) context.pop();
      case 'share':
        final title = message['title']?.toString() ?? 'SHOO';
        await Share.share(title);
      case 'deeplink':
        final url = data?.toString() ?? message['url']?.toString();
        if (url != null) _openDeepLink(context, ref, url);
      case 'request_eval':
        await controller.runJavaScript(
          "window.updateFromFlutter && window.updateFromFlutter('Flutter 已执行 evaluateJavaScript');",
        );
      case 'custom':
        if (data is String) {
          try {
            final nested = jsonDecode(data) as Map<String, dynamic>;
            final nestedAction = nested['action']?.toString();
            if (nestedAction == 'share' && context.mounted) {
              context.showToast('分享: ${nested['title']}');
            }
          } catch (_) {}
        }
    }
  }

  static void _openDeepLink(BuildContext context, WidgetRef ref, String url) {
    SHODeepLinkNavigator.openFromWebView(
      context,
      url,
      session: ref.read(sessionProvider),
    );
  }

  static bool isDeepLinkUrl(String url) => SHODeepLinkResolver.isDeepLink(url);
}
