import '../config/hos_config.dart';
import '../constants/hos_constants.dart';

/// 解析远程日志上报的 API 根地址（与业务 Mock 解耦）。
abstract final class SHORemoteLogBaseUrl {
  static SHOAppConfig? _effectiveConfig;

  /// 由 [dioProvider] 写入 Debug 面板生效后的完整配置。
  static void setEffectiveConfig(SHOAppConfig config) {
    _effectiveConfig = config;
  }

  static String resolve() {
    final cfg = _effectiveConfig ?? SHOAppConfig.instance;
    return _normalize(cfg.apiBaseUrl, cfg);
  }

  static String _normalize(String url, SHOAppConfig cfg) {
    if (cfg.environment.usesLocalServer) {
      return cfg.apiBaseUrl;
    }

    if (cfg.useMockApi) {
      return SHOAppConstants.defaultLocalApiBaseUrl;
    }

    final host = Uri.tryParse(url)?.host.toLowerCase() ?? '';
    if (host == 'mock.shoo.local') {
      return SHOAppConstants.defaultLocalApiBaseUrl;
    }

    return url;
  }
}
