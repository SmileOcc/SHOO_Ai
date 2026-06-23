import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shoo/core/deeplink/hos_deeplink_navigator.dart';
import 'package:shoo/features/auth/presentation/state/hos_session_provider.dart';

/// 统一 in-app / 深链导航（活动弹窗 CTA、Banner 等）。
abstract final class SHORouteNavigator {
  static Future<void> followLink(BuildContext context, String link) async {
    final container = ProviderScope.containerOf(context, listen: false);
    final session = container.read(sessionProvider);
    await SHODeepLinkNavigator.openLink(context, link, session: session);
  }
}
