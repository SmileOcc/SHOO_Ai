/// Hybrid Bridge 协议常量（Flutter ↔ Native 统一 method / kind 命名）。
abstract final class SHOHybridBridgeMethods {
  // Flutter → Native (native_bridge)
  static const openSActivity = 'sActivity/open';
  static const openDialogLab = 'sActivity/openDialogLab';
  static const popHybridPage = 'sActivity/popHybridPage';

  // Native → Flutter (native_host)
  static const navigate = 'navigate';
  static const showDialog = 'showDialog';
  static const abandonNativeOverlaySession = 'abandonNativeOverlaySession';
  static const onHybridFlutterPopped = 'onHybridFlutterPopped';
  static const runMethodChannelDemo = 'runMethodChannelDemo';
  static const runMessageChannelDemo = 'runMessageChannelDemo';
  static const runEventChannelDemo = 'runEventChannelDemo';
  static const trackNativeAnalytics = 'trackNativeAnalytics';
}

abstract final class SHOHybridDialogKind {
  static const alert = 'alert';
  static const confirm = 'confirm';
  static const bottomSheet = 'bottomSheet';
  static const actionSheet = 'actionSheet';
}
