import 'package:flutter/material.dart';

import 'package:shoo/core/platform/webview/hos_webview_config.dart';
import 'package:shoo/features/activity_webview/presentation/pages/hos_webview_page.dart';

/// 百宝箱 → Web 调试：加载本地 mock HTML，验证通用 WebView 能力。
class SHOToolboxWebDebugPage extends StatelessWidget {
  const SHOToolboxWebDebugPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SHOWebViewPage(config: SHOWebViewConfig.debug());
  }
}
