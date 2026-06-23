import 'package:shoo/core/deeplink/hos_deeplink_action_type.dart';

/// Deep Link 解析结果：GoRouter 路径 + 鉴权要求。
class SHODeepLinkTarget {
  const SHODeepLinkTarget({
    required this.type,
    required this.appPath,
    required this.requiresAuth,
    this.rawLink,
  });

  final SHODeepLinkActionType type;
  final String appPath;
  final bool requiresAuth;
  final String? rawLink;
}
