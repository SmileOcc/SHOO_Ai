import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:shoo/core/analytics/hos_page_analytics.dart';
import 'package:shoo/core/feedback/hos_toast.dart';
import 'package:shoo/core/pages/hos_pages.dart';
import 'package:shoo/core/platform/webview/hos_webview_config.dart';
import 'package:shoo/features/activity_webview/domain/entities/hos_activity_config.dart';
import 'package:shoo/features/activity_webview/presentation/state/hos_activity_config_provider.dart';
import 'package:shoo/features/activity_webview/presentation/state/hos_dialog_provider.dart';
import 'package:shoo/features/activity_webview/presentation/state/hos_mock_server_provider.dart';
import 'package:shoo/features/activity_webview/presentation/state/hos_share_provider.dart';
import 'package:shoo/features/activity_webview/presentation/widgets/dialogs/hos_activity_dialog_host.dart';

class SHOActivityPage extends ConsumerStatefulWidget {
  const SHOActivityPage({super.key});

  @override
  ConsumerState<SHOActivityPage> createState() => _SHOActivityPageState();
}

class _SHOActivityPageState extends ConsumerState<SHOActivityPage>
    with SHOPageRouteAnalyticsMixin, SHOAppPageMixin, SHOAppTrackedPageMixin {
  WebViewController? _controller;

  @override
  String get pageName => 'activity';

  @override
  Widget build(BuildContext context) {
    final configAsync = ref.watch(activityConfigProvider);
    final serverAsync = ref.watch(activityMockServerUrlProvider);
    final fallbackTitle = configAsync.valueOrNull?.title ?? '活动页';

    ref.listen(activityConfigProvider, (_, next) {
      if (!mounted) return;
      final controller = _controller;
      if (controller == null) return;
      next.whenData((config) => unawaited(_injectConfig(controller, config)));
    });

    ref.listen(activityDialogProvider, (_, __) {
      if (!mounted) return;
      _syncWebViewInteraction();
    });
    ref.listen(shareProvider, (_, __) {
      if (!mounted) return;
      _syncWebViewInteraction();
    });

    return SHOActivityDialogHost(
      child: serverAsync.when(
        loading: () => buildTrackedPage(
          Scaffold(
            appBar: AppBar(title: Text(fallbackTitle)),
            body: const Center(child: CircularProgressIndicator()),
          ),
        ),
        error: (_, __) => SHOWebViewShellPage(
          pageNameOverride: pageName,
          config: SHOWebViewConfig.activity(
            loadAsset: 'assets/activity/index.html',
            title: fallbackTitle,
          ),
          additionalAppBarActions: [_buildShareAction()],
          onControllerReady: _onControllerReady,
        ),
        data: (url) {
          final hasServer = url != null && url.isNotEmpty;
          final pageUrl = hasServer ? (url.endsWith('/') ? url : '$url/') : '';
          return SHOWebViewShellPage(
            pageNameOverride: pageName,
            config: hasServer
                ? SHOWebViewConfig.activity(url: pageUrl, title: fallbackTitle)
                : SHOWebViewConfig.activity(
                    loadAsset: 'assets/activity/index.html',
                    title: fallbackTitle,
                  ),
            additionalAppBarActions: [_buildShareAction()],
            onControllerReady: _onControllerReady,
          );
        },
      ),
    );
  }

  void _onControllerReady(WebViewController controller) {
    _controller = controller;
    if (!mounted) return;
    final config = ref.read(activityConfigProvider).valueOrNull;
    if (config != null) {
      unawaited(_injectConfig(controller, config));
    }
    _syncWebViewInteraction();
  }

  Widget _buildShareAction() {
    final capturing = ref.watch(shareProvider).capturing;
    return IconButton(
      icon: capturing
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.share_outlined),
      onPressed: capturing ? null : () => unawaited(_onSharePressed()),
    );
  }

  Future<void> _onSharePressed() async {
    if (!mounted) return;
    final controller = _controller;
    if (controller == null) {
      context.showToast('页面尚未加载完成');
      return;
    }
    await ref.read(shareProvider.notifier).captureFromWebView(controller);
    if (!mounted) return;
    final share = ref.read(shareProvider);
    if (!share.visible && !share.capturing) {
      context.showToast('截图失败，请稍后重试');
    }
  }

  Future<void> _injectConfig(
    WebViewController controller,
    SHOActivityConfig config,
  ) async {
    final json = jsonEncode(_configToMap(config));
    await controller.runJavaScript(
      'window.renderActivity && window.renderActivity($json);',
    );
  }

  void _syncWebViewInteraction() {
    final dialog = ref.read(activityDialogProvider);
    final share = ref.read(shareProvider);
    final enabled = dialog == null && !share.visible && !share.capturing;
    final controller = _controller;
    if (controller == null) return;
    unawaited(_setWebViewPageInteraction(controller, enabled));
  }

  Future<void> _setWebViewPageInteraction(
    WebViewController controller,
    bool enabled,
  ) async {
    final script = enabled
        ? '''
(function() {
  document.documentElement.style.overflow = '';
  document.body.style.overflow = '';
  document.body.style.pointerEvents = '';
})();
'''
        : '''
(function() {
  document.documentElement.style.overflow = 'hidden';
  document.body.style.overflow = 'hidden';
  document.body.style.pointerEvents = 'none';
})();
''';
    try {
      await controller.runJavaScript(script);
    } catch (_) {}
  }

  Map<String, dynamic> _configToMap(SHOActivityConfig config) {
    return {
      'id': config.id,
      'title': config.title,
      'subtitle': config.subtitle,
      'shareTitle': config.shareTitle,
      'shareDesc': config.shareDesc,
      'shareUrl': config.shareUrl,
      'paymentTestUrl': config.paymentTestUrl,
      'modules': config.modules
          .map(
            (m) => {
              'id': m.id,
              'icon': m.icon,
              'title': m.title,
              'desc': m.desc,
              'type': m.type,
              'action': m.action,
              'params': m.params,
            },
          )
          .toList(),
      'images': config.images
          .map(
            (i) => {
              'url': i.url,
              'title': i.title,
              'width': i.width,
              'height': i.height,
            },
          )
          .toList(),
      'rules': config.rules,
      'navigation': config.navigation == null
          ? null
          : {
              'productListLeafId': config.navigation!.productListLeafId,
              'productListTitle': config.navigation!.productListTitle,
              'sampleProductId': config.navigation!.sampleProductId,
            },
      'promoBlocks': config.promoBlocks
          .map(
            (b) => {
              'type': b.type,
              if (b.segments.isNotEmpty)
                'segments': b.segments
                    .map(
                      (s) => {
                        'type': s.type,
                        if (s.content != null) 'content': s.content,
                        if (s.text != null) 'text': s.text,
                        if (s.url != null) 'url': s.url,
                      },
                    )
                    .toList(),
              if (b.url != null) 'url': b.url,
              if (b.caption != null) 'caption': b.caption,
              if (b.width != null) 'width': b.width,
              if (b.height != null) 'height': b.height,
            },
          )
          .toList(),
    };
  }
}
