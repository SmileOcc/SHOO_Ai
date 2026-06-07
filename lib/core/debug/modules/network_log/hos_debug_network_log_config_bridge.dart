import 'hos_debug_network_log_config.dart';

/// 供拦截器 / 上报通道在无 BuildContext 时读取最新网络日志配置。
abstract final class SHODebugNetworkLogConfigBridge {
  static SHODebugNetworkLogConfig config = const SHODebugNetworkLogConfig();

  static void update(SHODebugNetworkLogConfig value) {
    config = value;
  }
}
