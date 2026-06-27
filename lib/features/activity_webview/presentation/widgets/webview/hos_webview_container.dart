import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:shoo/core/platform/webview/hos_webview_config.dart';
import 'package:shoo/core/platform/webview/hos_webview_navigation_policy.dart';
import 'package:shoo/features/activity_webview/presentation/widgets/webview/hos_generic_webview_container.dart';

/// 活动 H5 专用 WebView 容器（旧 API，内部委托 [SHOGenericWebViewContainer]）。
///
/// 新代码请使用 [SHOWebViewShellPage] + [SHOWebViewConfig.activity]。
@Deprecated('Use SHOWebViewShellPage with SHOWebViewConfig.activity')
class SHOWebViewContainer extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    return SHOGenericWebViewContainer(
      config: SHOWebViewConfig.activity(
        url: initialUrl ?? '',
        loadAsset: loadAsset,
        title: title,
      ),
      onControllerReady: onControllerReady,
    );
  }
}
