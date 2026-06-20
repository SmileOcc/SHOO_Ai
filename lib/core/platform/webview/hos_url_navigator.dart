import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:shoo/app/router/hos_routes.dart';
import 'package:shoo/core/platform/webview/hos_payment_handler.dart';
import 'package:shoo/core/platform/webview/hos_url_decision.dart';
import 'package:shoo/core/platform/webview/hos_url_router_service.dart';
import 'package:shoo/features/activity_webview/presentation/state/hos_image_preview_provider.dart';

final urlRouterServiceProvider = Provider<SHOURLRouterService>(
  (ref) => const SHOURLRouterService(),
);

class SHOURLNavigator {
  SHOURLNavigator._();

  static Future<void> open(
    BuildContext context,
    WidgetRef ref,
    String url, {
    String? title,
    SHOURLRouterService? router,
  }) async {
    final SHOURLRouterService service =
        router ?? ref.read(urlRouterServiceProvider);
    final decision = service.resolve(url);
    switch (decision.target) {
      case SHOURLTarget.inAppWebView:
        await openInWebView(context, url, title: title);
      case SHOURLTarget.payment:
        await SHOPaymentHandler.openPaymentUrl(decision.url);
      case SHOURLTarget.externalBrowser:
        await openInExternalBrowser(decision.url);
    }
  }

  static Future<void> openInWebView(
    BuildContext context,
    String url, {
    String? title,
  }) async {
    if (!context.mounted) return;
    await context.push(
      SHOAppRoutes.activityWebviewFor(url, title: title),
    );
  }

  static Future<void> openInExternalBrowser(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  static Future<void> openImagePreview(
    BuildContext context,
    WidgetRef ref, {
    required List<SHOImagePreviewItem> images,
    int index = 0,
  }) async {
    ref.read(imagePreviewProvider.notifier).setImages(images, index: index);
    if (!context.mounted) return;
    await context.push(SHOAppRoutes.activityImagePreviewFor(index: index));
  }
}
