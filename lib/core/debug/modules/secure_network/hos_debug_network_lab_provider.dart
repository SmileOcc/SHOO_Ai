import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shoo/core/config/hos_config.dart';
import 'package:shoo/core/debug/modules/secure_network/hos_debug_custom_interceptor.dart';
import 'package:shoo/core/debug/modules/secure_network/hos_debug_fail_interceptor.dart';
import 'package:shoo/core/debug/modules/secure_network/hos_debug_network_lab_config.dart';
import 'package:shoo/core/network/hos_dio_client.dart';
import 'package:shoo/core/network/hos_mock_interceptor.dart';
import 'package:shoo/core/network/security/hos_secure_dio_factory.dart';
import 'package:shoo/features/auth/presentation/state/hos_auth_token_provider.dart';

final debugNetworkLabConfigProvider =
    StateProvider<SHODebugNetworkLabConfig>((ref) {
  return const SHODebugNetworkLabConfig();
});

final debugNetworkLabLogProvider =
    StateNotifierProvider<SHODebugNetworkLabLogNotifier, List<String>>(
  (ref) => SHODebugNetworkLabLogNotifier(),
);

class SHODebugNetworkLabLogNotifier extends StateNotifier<List<String>> {
  SHODebugNetworkLabLogNotifier() : super(const []);

  void add(String message) {
    final stamp = DateTime.now().toIso8601String().substring(11, 23);
    state = [...state, '[$stamp] $message'];
  }

  void clear() => state = const [];
}

/// 网络实验室专用 Dio（含失败模拟 + 可配置自定义拦截器）。
final debugNetworkLabDioProvider = Provider<Dio>((ref) {
  final config = ref.watch(appConfigProvider);
  final labConfig = ref.watch(debugNetworkLabConfigProvider);
  final crypto = ref.watch(cryptoServiceProvider);

  void logEvent(String message) {
    ref.read(debugNetworkLabLogProvider.notifier).add(message);
  }

  Interceptor? customInterceptor;
  if (labConfig.enableCustomInterceptor) {
    customInterceptor = SHODebugCustomInterceptor(
      config: labConfig,
      onEvent: logEvent,
    );
  }

  final prepend = <Interceptor>[
    if (config.useMockApi) SHOMockInterceptor(),
    SHODebugFailInterceptor(),
    if (labConfig.enableCustomInterceptor && labConfig.customInsertBeforeAuth)
      customInterceptor!,
  ];

  final append = <Interceptor>[
    if (labConfig.enableCustomInterceptor && !labConfig.customInsertBeforeAuth)
      customInterceptor!,
    if (kDebugMode) LogInterceptor(requestBody: true, responseBody: true),
  ];

  return SHOSecureDioFactory.create(
    baseUrl: config.apiBaseUrl,
    securityLevel: config.securityLevel,
    crypto: crypto,
    tokenReader: () => ref.read(authTokenProvider),
    skipEncryption: config.useMockApi,
    prependInterceptors: prepend,
    appendInterceptors: append,
  );
});
