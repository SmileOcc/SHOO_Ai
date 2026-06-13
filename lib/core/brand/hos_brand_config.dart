import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/hos_constants.dart';
import '../storage/hos_local_storage.dart';
import 'hos_app_icon_style.dart';

const _iconStyleStorageKey = 'brand_icon_style_v1';

/// 品牌配置：应用名称与当前选中的 Icon 风格。
abstract final class SHOAppBrandConfig {
  /// 应用显示名称（全大写）。
  static const String displayName = SHOAppConstants.appName;

  /// App Icon 内嵌字样（与桌面图标一致）。
  static const String iconMark = 'SO';

  /// 正式选定的全局 App Icon 风格。
  static const SHOAppIconStyle iconStyle = SHOAppIconStyle.classic;

  static const SHOAppIconStyle defaultIconStyle = iconStyle;
}

final appIconStyleProvider =
    NotifierProvider<SHOAppIconStyleNotifier, SHOAppIconStyle>(
  SHOAppIconStyleNotifier.new,
);

class SHOAppIconStyleNotifier extends Notifier<SHOAppIconStyle> {
  late final SHOLocalStorage _storage;

  @override
  SHOAppIconStyle build() {
    _storage = ref.read(localStorageProvider);
    Future.microtask(_persistDefault);
    return SHOAppBrandConfig.iconStyle;
  }

  Future<void> _persistDefault() async {
    await _storage.write(_iconStyleStorageKey, state.name);
  }

  Future<void> select(SHOAppIconStyle style) async {
    state = SHOAppBrandConfig.iconStyle;
    await _storage.write(_iconStyleStorageKey, state.name);
  }
}
