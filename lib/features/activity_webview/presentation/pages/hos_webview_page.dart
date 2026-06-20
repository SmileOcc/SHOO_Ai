import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:shoo/features/activity_webview/presentation/state/hos_webview_loading_provider.dart';
import 'package:shoo/features/activity_webview/presentation/widgets/webview/hos_webview_container.dart';

class SHOWebViewPage extends ConsumerStatefulWidget {
  const SHOWebViewPage({
    super.key,
    required this.url,
    this.title,
  });

  final String url;
  final String? title;

  @override
  ConsumerState<SHOWebViewPage> createState() => _SHOWebViewPageState();
}

class _SHOWebViewPageState extends ConsumerState<SHOWebViewPage> {
  WebViewController? _controller;

  @override
  Widget build(BuildContext context) {
    final loading = ref.watch(webviewLoadingProvider);
    final title = widget.title ?? loading.pageTitle ?? '网页';

    return PopScope(
      canPop: !loading.canGoBack,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (_controller != null && await _controller!.canGoBack()) {
          await _controller!.goBack();
          final canGoBack = await _controller!.canGoBack();
          ref.read(webviewLoadingProvider.notifier).setCanGoBack(canGoBack);
        } else if (context.mounted) {
          context.pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(title: Text(title)),
        body: SHOWebViewContainer(
          initialUrl: widget.url,
          title: widget.title,
          onControllerReady: (controller) => _controller = controller,
        ),
      ),
    );
  }
}
