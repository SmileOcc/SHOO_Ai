import 'package:shoo/core/deeplink/hos_deeplink_action_type.dart';
import 'package:shoo/core/deeplink/hos_deeplink_link_kind.dart';

/// Deep Link 解析结果：GoRouter 路径 + 鉴权要求 + 链接形态。
class SHODeepLinkTarget {
  const SHODeepLinkTarget({
    required this.type,
    required this.appPath,
    required this.requiresAuth,
    required this.linkKind,
    this.rawLink,
  });

  final SHODeepLinkActionType type;
  final String appPath;
  final bool requiresAuth;
  final SHODeepLinkLinkKind linkKind;
  final String? rawLink;
}
