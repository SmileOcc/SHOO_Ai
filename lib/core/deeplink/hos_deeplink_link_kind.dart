/// Deep Link 入口形态（与 [SHODeepLinkActionType] 业务动作正交）。
enum SHODeepLinkLinkKind {
  /// `shoo://...` Custom Scheme。
  customScheme,

  /// `https://shoo.app/...` Universal Link / Android App Links。
  appLink,

  /// 应用内相对路径，如 `/product/p-1`。
  inAppPath,
}
