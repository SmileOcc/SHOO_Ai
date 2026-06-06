import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/deeplink/hos_deeplink_mapper.dart';

/// 统一 in-app / 深链导航（活动弹窗 CTA、Banner 等）。
abstract final class SHORouteNavigator {
  static void followLink(BuildContext context, String link) {
    final path = SHODeepLinkMapper.linkToAppPath(link);
    if (path == null || path.isEmpty) return;
    context.push(path);
  }
}
