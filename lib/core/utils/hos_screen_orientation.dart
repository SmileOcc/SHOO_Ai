import 'package:flutter/services.dart';

/// 横竖屏与沉浸模式工具，可在视频播放等场景复用。
abstract final class SHOScreenOrientation {
  static var _lockMode = _SHOOrientationLockMode.followDevice;

  /// 当前是否允许跟随设备物理旋转（未被人为锁死方向）。
  static bool get allowsDeviceRotation =>
      _lockMode == _SHOOrientationLockMode.followDevice;

  static bool get isLockedToPortrait =>
      _lockMode == _SHOOrientationLockMode.portrait;

  static bool get isLockedToLandscape =>
      _lockMode == _SHOOrientationLockMode.landscape;

  /// 允许设备自由旋转（横竖屏均可）。
  static Future<void> enableDeviceRotation() async {
    _lockMode = _SHOOrientationLockMode.followDevice;
    await SystemChrome.setPreferredOrientations(DeviceOrientation.values);
  }

  /// 锁定竖屏（仅正向，避免 iOS 过渡失败）。
  static Future<void> lockPortrait() async {
    _lockMode = _SHOOrientationLockMode.portrait;
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  /// 锁定横屏。
  static Future<void> lockLandscape() async {
    _lockMode = _SHOOrientationLockMode.landscape;
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  /// 沉浸 / 边缘系统 UI。
  static Future<void> setImmersive(bool enabled) async {
    await SystemChrome.setEnabledSystemUIMode(
      enabled ? SystemUiMode.immersiveSticky : SystemUiMode.edgeToEdge,
    );
  }

  /// 离开页面时恢复：关闭沉浸并允许设备旋转。
  static Future<void> restoreOnLeave() async {
    await setImmersive(false);
    await enableDeviceRotation();
  }

  /// 进入横屏沉浸播放（用户点全屏，且当前为竖屏时）。
  static Future<void> enterLandscapePlayback() async {
    await lockLandscape();
    await setImmersive(true);
  }

  /// 退出横屏沉浸，回到竖屏。
  ///
  /// iOS 在 VC 仍只允许横屏时不能直接切 portrait，需先放开全部方向再锁定竖屏。
  static Future<void> exitLandscapePlayback() async {
    await setImmersive(false);
    await _transitionFromLandscapeToPortrait();
  }

  static Future<void> _transitionFromLandscapeToPortrait() async {
    _lockMode = _SHOOrientationLockMode.followDevice;
    await SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    await Future<void>.delayed(const Duration(milliseconds: 150));
    _lockMode = _SHOOrientationLockMode.portrait;
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }
}

enum _SHOOrientationLockMode {
  followDevice,
  portrait,
  landscape,
}
